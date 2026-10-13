--!strict
-- Tod, Zuschauen und Ergebnis: Abblende (≤ 1 s, kein Gesicht, Sanfter Modus ohne Blitz, H-A9),
-- Fahrkarten-Notiz des Bahnhofsvorstehers mit Hinweis (H-A2 c), Zuschauen ohne Spielernamen (H-A12),
-- Ergebnis-Fahrkarte am Laufende.

local ContextActionService = game:GetService("ContextActionService")
local GuiService = game:GetService("GuiService")
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")

local Context = require("./Context")
local Hud = require("./Hud")
local Palette = require("@game/ReplicatedStorage/Shared/Visual/Palette")
local Settings = require("./Settings")
local Strings = require("./Strings")
local UiKit = require("./UiKit")

local DeathController = {}

local TINT: { [string]: Color3 } = {
	express = Palette.express:Lerp(Palette.hudShade, 0.4),
	oncoming = Palette.oncoming,
	eyes = Palette.eyes:Lerp(Palette.hudShade, 0.5),
	inspector = Palette.inspectorGo,
	chase = Palette.chase,
	conductor = Palette.conductorBeam:Lerp(Palette.hudShade, 0.4),
}

local note: Frame
local noteTitle: TextLabel
local noteHint: TextLabel
local noteFrom: TextLabel
local spectateBar: Frame
local spectateLabel: TextLabel
local summary: Frame
local summaryLines: { TextLabel } = {}
local spectating = false
local spectateIndex = 1
local spectateTarget: Player? = nil

-- Zuschauen mit Kamera hinter und über dem Mitreisenden statt in seinem Kopf (Compliance H-A18).
-- Die Kamera schaut immer in Fahrtrichtung (+x, ruhig, keine fremden Drehungen) und bleibt per
-- Raycast vor Wänden und Möbeln (Code-Review LL-07).
local spectateParams = RaycastParams.new()
spectateParams.FilterType = Enum.RaycastFilterType.Exclude

local function spectateCamera(dt: number)
	local target = spectateTarget
	local character = if target then target.Character else nil
	local root = if character then character:FindFirstChild("HumanoidRootPart") else nil
	if not spectating or root == nil or not root:IsA("BasePart") then
		return
	end
	local camera = workspace.CurrentCamera
	camera.CameraType = Enum.CameraType.Scriptable
	local focus = root.Position + Vector3.new(0, 1.5, 0)
	local wanted = root.Position + Vector3.new(-7, 3.5, 0)
	local excluded: { Instance } = { workspace:FindFirstChild("LocalEntities") :: Instance }
	for _, player in Players:GetPlayers() do
		if player.Character then
			table.insert(excluded, player.Character)
		end
	end
	spectateParams.FilterDescendantsInstances = excluded
	local hit = workspace:Raycast(focus, wanted - focus, spectateParams)
	local eye = if hit then hit.Position + (focus - hit.Position).Unit * 0.6 else wanted
	local goal = CFrame.lookAt(eye, focus)
	local alpha = if Settings.motionAllowed() then math.clamp(dt * 4, 0, 1) else 1
	camera.CFrame = camera.CFrame:Lerp(goal, alpha)
end

local function candidates(): { Player }
	local list: { Player } = {}
	for _, player in Players:GetPlayers() do
		if
			player ~= Context.player
			and player:GetAttribute("InRun") == true
			and player:GetAttribute("Alive") ~= false
		then
			local character = player.Character
			if character and character:FindFirstChildOfClass("Humanoid") then
				table.insert(list, player)
			end
		end
	end
	table.sort(list, function(a: Player, b: Player): boolean
		return a.UserId < b.UserId
	end)
	return list
end

local function showSpectate()
	local list = candidates()
	local camera = workspace.CurrentCamera
	if #list == 0 then
		spectateBar.Visible = false
		return
	end
	spectateIndex = ((spectateIndex - 1) % #list) + 1
	spectateTarget = list[spectateIndex]
	camera.CameraType = Enum.CameraType.Scriptable
	spectateBar.Visible = true
	spectateLabel.Text = Strings.format("spectate.label", { spectateIndex, #list })
end

local function cycle(step: number)
	if spectating then
		spectateIndex += step
		showSpectate()
	end
end

local function bindSpectateKeys(on: boolean)
	if on then
		ContextActionService:BindAction("LanternSpectate", function(_, state, input)
			if state == Enum.UserInputState.Begin then
				local back = input.KeyCode == Enum.KeyCode.Q or input.KeyCode == Enum.KeyCode.ButtonL1
				cycle(if back then -1 else 1)
			end
			return Enum.ContextActionResult.Sink
		end, false, Enum.KeyCode.Q, Enum.KeyCode.E, Enum.KeyCode.ButtonL1, Enum.KeyCode.ButtonR1)
	else
		ContextActionService:UnbindAction("LanternSpectate")
	end
end

local function startSpectating()
	note.Visible = false
	spectating = true
	bindSpectateKeys(true)
	Hud.clearShade()
	showSpectate()
end

local okButton: TextButton
local diedAt = -math.huge
local lastHint: string? = nil

local function onDeath(payload: any)
	diedAt = os.clock()
	lastHint = payload.hint
	task.spawn(Hud.fadeOut, TINT[payload.cause])
	task.wait(1)
	if summary.Visible then
		return -- Lauf schon vorbei: Hinweis steht auf der Ergebnis-Fahrkarte (Playtest LP-05)
	end
	noteTitle.Text = Strings.format("death.title", { string.format("%02d", payload.carriage or 0) })
	noteHint.Text = Strings.format(payload.hint)
	noteFrom.Text = Strings.format("death.from")
	note.Visible = true
	GuiService.SelectedObject = okButton -- Gamepad: „OK“ vorausgewählt (LP-11)
	-- Nach 8 s automatisch zuschauen, falls niemand „OK“ drückt
	task.delay(8, function()
		if note.Visible and not summary.Visible then
			startSpectating()
		end
	end)
end

local function formatTime(seconds: number): string
	return string.format("%d:%02d", seconds // 60, seconds % 60)
end

local function onSummary(payload: any)
	-- Kurz nach dem eigenen Ausscheiden erst die Abblende abwarten, dann Ergebnis mit Hinweis zeigen.
	local wait = 1.2 - (os.clock() - diedAt)
	if wait > 0 then
		task.wait(wait)
	end
	note.Visible = false
	spectateBar.Visible = false
	local died = Context.player:GetAttribute("Alive") == false and lastHint ~= nil
	summaryLines[5].Text = if died
		then Strings.format(lastHint :: string) .. " " .. Strings.format("death.from")
		else ""
	summaryLines[1].Text = Strings.format(if payload.outcome == "won" then "end.won" else "end.lost")
	summaryLines[2].Text = Strings.format("end.car", { string.format("%02d", payload.carriage or 0) })
	summaryLines[3].Text = Strings.format("end.stubs", { payload.stubs or 0 })
	summaryLines[4].Text = Strings.format("end.time", { formatTime(payload.seconds or 0) })
	summary.Visible = true
end

local function reset()
	spectating = false
	spectateTarget = nil
	lastHint = nil
	bindSpectateKeys(false)
	note.Visible = false
	spectateBar.Visible = false
	summary.Visible = false
	Hud.clearShade()
	local camera = workspace.CurrentCamera
	camera.CameraType = Enum.CameraType.Custom
	local humanoid = Context.humanoid()
	if humanoid then
		camera.CameraSubject = humanoid
	end
end

function DeathController.init()
	local gui = UiKit.screen("Journey", 30)
	note = UiKit.ticket(gui, UDim2.fromOffset(460, 250), UDim2.fromScale(0.5, 0.45), Vector2.new(0.5, 0.5))
	note.Visible = false
	noteTitle = UiKit.label(note, "", UDim2.new(1, 0, 0.2, 0), UDim2.fromScale(0, 0))
	noteHint = UiKit.label(note, "", UDim2.new(1, 0, 0.45, 0), UDim2.fromScale(0, 0.22))
	noteFrom = UiKit.label(note, "", UDim2.new(0.6, 0, 0.12, 0), UDim2.fromScale(0.4, 0.68))
	noteFrom.TextXAlignment = Enum.TextXAlignment.Right
	okButton = UiKit.button(note, "OK", UDim2.new(0.3, 0, 0.14, 0), UDim2.fromScale(0.35, 0.84), true)
	okButton.Activated:Connect(startSpectating)
	UiKit.fitHeight(note, 250, 0.8)

	spectateBar = UiKit.ticket(gui, UDim2.fromOffset(360, 56), UDim2.new(0.5, 0, 1, -24), Vector2.new(0.5, 1))
	spectateBar.Visible = false
	local prev = UiKit.button(spectateBar, "‹", UDim2.new(0.18, 0, 0.8, 0), UDim2.fromScale(0, 0.1), true)
	spectateLabel = UiKit.label(spectateBar, "", UDim2.new(0.6, 0, 0.8, 0), UDim2.fromScale(0.2, 0.1))
	local nextButton = UiKit.button(spectateBar, "›", UDim2.new(0.18, 0, 0.8, 0), UDim2.fromScale(0.82, 0.1), true)
	prev.Activated:Connect(function()
		cycle(-1)
	end)
	nextButton.Activated:Connect(function()
		cycle(1)
	end)
	summary = UiKit.ticket(gui, UDim2.fromOffset(440, 300), UDim2.fromScale(0.5, 0.45), Vector2.new(0.5, 0.5))
	summary.Visible = false
	for i = 1, 4 do
		summaryLines[i] = UiKit.label(
			summary,
			"",
			UDim2.new(1, 0, 0.14, 0),
			UDim2.fromScale(0, (i - 1) * 0.16),
			if i == 1 then UiKit.FONT_STENCIL else nil
		)
	end
	-- Hinweis des Bahnhofsvorstehers auf der Ergebnis-Fahrkarte (Playtest LP-05)
	summaryLines[5] = UiKit.label(summary, "", UDim2.new(1, 0, 0.32, 0), UDim2.fromScale(0, 0.66))
	UiKit.fitHeight(summary, 300, 0.8)

	RunService.RenderStepped:Connect(spectateCamera)
	Context.onPersonal("death", onDeath)
	Context.onPersonal("summary", onSummary)
	Context.onPersonal("damage", function()
		Hud.damage()
	end)
	Context.onWorld("reset", reset)
	Players.PlayerRemoving:Connect(function()
		if spectating then
			task.defer(showSpectate)
		end
	end)
	-- Stirbt der beobachtete Mitreisende, zum nächsten wechseln
	Context.player:GetAttributeChangedSignal("Alive"):Connect(function()
		if Context.player:GetAttribute("Alive") ~= false then
			spectating = false
			bindSpectateKeys(false)
			spectateBar.Visible = false
		end
	end)
	task.spawn(function()
		while true do
			task.wait(1)
			if spectating then
				showSpectate()
			end
		end
	end)
end

return DeathController
