--!strict
-- Tod, Zuschauen und Ergebnis: Abblende (≤ 1 s, kein Gesicht, Sanfter Modus ohne Blitz, H-A9),
-- Fahrkarten-Notiz des Bahnhofsvorstehers mit Hinweis (H-A2 c), Zuschauen ohne Spielernamen (H-A12),
-- Ergebnis-Fahrkarte am Laufende.

local ContextActionService = game:GetService("ContextActionService")
local Players = game:GetService("Players")

local Context = require("./Context")
local Hud = require("./Hud")
local Palette = require("@game/ReplicatedStorage/Shared/Visual/Palette")
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
	local target = list[spectateIndex]
	local character = target.Character
	local humanoid = if character then character:FindFirstChildOfClass("Humanoid") else nil
	if humanoid then
		camera.CameraType = Enum.CameraType.Custom
		camera.CameraSubject = humanoid
	end
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

local function onDeath(payload: any)
	task.spawn(Hud.fadeOut, TINT[payload.cause])
	task.wait(1)
	noteTitle.Text = Strings.format("death.title", { string.format("%02d", payload.carriage or 0) })
	noteHint.Text = Strings.format(payload.hint)
	noteFrom.Text = Strings.format("death.from")
	note.Visible = true
end

local function formatTime(seconds: number): string
	return string.format("%d:%02d", seconds // 60, seconds % 60)
end

local function onSummary(payload: any)
	note.Visible = false
	summaryLines[1].Text = Strings.format(if payload.outcome == "won" then "end.won" else "end.lost")
	summaryLines[2].Text = Strings.format("end.car", { string.format("%02d", payload.carriage or 0) })
	summaryLines[3].Text = Strings.format("end.stubs", { payload.stubs or 0 })
	summaryLines[4].Text = Strings.format("end.time", { formatTime(payload.seconds or 0) })
	summary.Visible = true
end

local function reset()
	spectating = false
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
	local ok = UiKit.button(note, "OK", UDim2.new(0.3, 0, 0.14, 0), UDim2.fromScale(0.35, 0.84), true)
	ok.Activated:Connect(startSpectating)

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
	summary = UiKit.ticket(gui, UDim2.fromOffset(380, 220), UDim2.fromScale(0.5, 0.42), Vector2.new(0.5, 0.5))
	summary.Visible = false
	for i = 1, 4 do
		summaryLines[i] = UiKit.label(
			summary,
			"",
			UDim2.new(1, 0, 0.2, 0),
			UDim2.fromScale(0, (i - 1) * 0.24),
			if i == 1 then UiKit.FONT_STENCIL else nil
		)
	end

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
