--!strict
-- Abfahrtstafel am Bahnsteig (lokalisiert, vom Client gezeichnet): Titel, Untertitel, Countdown bzw.
-- „Zug unterwegs – Wagen n“, Hinweis zum Einsteigen. Fundstück-Hinweise (Schlüssel, Abrisse).

local CollectionService = game:GetService("CollectionService")

local Context = require("./Context")
local Hud = require("./Hud")
local Palette = require("@game/ReplicatedStorage/Shared/Visual/Palette")
local Strings = require("./Strings")

local LobbyController = {}

local BOARD_TAG = "LanternLineDepartureBoard"
local INFO_TAG = "LanternLineInfoBoard"
local lines: { TextLabel } = {}

local function line(gui: SurfaceGui, y: number, height: number, font: Enum.Font, color: Color3): TextLabel
	local label = Instance.new("TextLabel")
	label.BackgroundTransparency = 1
	label.Size = UDim2.fromScale(0.94, height)
	label.Position = UDim2.fromScale(0.03, y)
	label.TextScaled = true
	label.Font = font
	label.TextColor3 = color
	label.TextXAlignment = Enum.TextXAlignment.Left
	label.Parent = gui
	return label
end

local function attach(board: Instance)
	if not board:IsA("BasePart") then
		return
	end
	local gui = Instance.new("SurfaceGui")
	gui.Face = Enum.NormalId.Front
	gui.SizingMode = Enum.SurfaceGuiSizingMode.PixelsPerStud
	gui.PixelsPerStud = 50
	gui.LightInfluence = 0
	gui.Adornee = board
	gui.ResetOnSpawn = false
	gui.Parent = Context.player:WaitForChild("PlayerGui")
	table.clear(lines)
	table.insert(lines, line(gui, 0.04, 0.3, Enum.Font.Michroma, Palette.lampOn))
	table.insert(lines, line(gui, 0.34, 0.18, Enum.Font.SpecialElite, Palette.cream))
	table.insert(lines, line(gui, 0.56, 0.2, Enum.Font.Michroma, Palette.lampOn))
	table.insert(lines, line(gui, 0.78, 0.16, Enum.Font.SpecialElite, Palette.cream))
end

local function refresh()
	if #lines < 4 then
		return
	end
	lines[1].Text = "LANTERN LINE"
	lines[2].Text = Strings.format("lobby.subtitle")
	local phase = workspace:GetAttribute("RunPhase")
	local endsAt = workspace:GetAttribute("LobbyEndsAt")
	if phase == "lobby" then
		local ready = workspace:GetAttribute("LobbyReady")
		local total = workspace:GetAttribute("LobbyTotal")
		if type(endsAt) == "number" and endsAt > 0 then
			lines[3].Text = Strings.format("lobby.departs", { math.max(0, math.ceil(endsAt - Context.now())) })
		else
			lines[3].Text = Strings.format("lobby.waiting")
		end
		-- Wer bereit ist (alle am Bahnsteig fahren mit, Playtest LP-04)
		local count = if type(ready) == "number" and type(total) == "number"
			then "  ·  " .. Strings.format("lobby.ready", { ready, total })
			else ""
		lines[4].Text = Strings.format("lobby.board") .. count
	else
		local carriage = workspace:GetAttribute("RunCarriage")
		lines[3].Text = Strings.format(
			"lobby.enroute",
			{ string.format("%02d", if type(carriage) == "number" then carriage else 0) }
		)
		lines[4].Text = ""
	end
end

-- Fahrgastinformation in Wagen 0: sechs Zeichen mit Reaktion, je Symbol aus Frames (Playtest LP-06).
local INFO_ROWS: { { key: string, color: Color3, shape: string } } = {
	{ key = "info.express", color = Palette.express, shape = "ball" },
	{ key = "info.oncoming", color = Palette.oncoming, shape = "arrows" },
	{ key = "info.eyes", color = Palette.eyes, shape = "dots" },
	{ key = "info.inspector", color = Palette.inspectorStop, shape = "stripe" },
	{ key = "info.chase", color = Palette.chase, shape = "stack" },
	{ key = "info.conductor", color = Palette.conductorBeam, shape = "cone" },
}

local function icon(parent: Instance, shape: string, color: Color3): Frame
	local holder = Instance.new("Frame")
	holder.Size = UDim2.fromScale(0.12, 0.8)
	holder.Position = UDim2.fromScale(0, 0.1)
	holder.BackgroundColor3 = Palette.hudShade
	holder.BorderSizePixel = 0
	holder.Parent = parent
	local function piece(size: UDim2, position: UDim2, round: boolean)
		local f = Instance.new("Frame")
		f.AnchorPoint = Vector2.new(0.5, 0.5)
		f.Size = size
		f.Position = position
		f.BackgroundColor3 = color
		f.BorderSizePixel = 0
		if round then
			local corner = Instance.new("UICorner")
			corner.CornerRadius = UDim.new(0.5, 0)
			corner.Parent = f
		end
		f.Parent = holder
		return f
	end
	if shape == "ball" then
		piece(UDim2.fromScale(0.6, 0.6), UDim2.fromScale(0.5, 0.5), true)
	elseif shape == "dots" then
		piece(UDim2.fromScale(0.18, 0.18), UDim2.fromScale(0.35, 0.5), true)
		piece(UDim2.fromScale(0.18, 0.18), UDim2.fromScale(0.65, 0.5), true)
	elseif shape == "stripe" then
		piece(UDim2.fromScale(0.75, 0.2), UDim2.fromScale(0.5, 0.5), false)
	elseif shape == "stack" then
		for i = 0, 2 do
			piece(UDim2.fromScale(0.6 - i * 0.12, 0.18), UDim2.fromScale(0.5, 0.75 - i * 0.22), false)
		end
	elseif shape == "cone" then
		local beam = piece(UDim2.fromScale(0.25, 0.7), UDim2.fromScale(0.5, 0.5), false)
		beam.Rotation = 35
	else
		local label = Instance.new("TextLabel")
		label.BackgroundTransparency = 1
		label.Size = UDim2.fromScale(1, 1)
		label.Text = "››"
		label.TextScaled = true
		label.Font = Enum.Font.Michroma
		label.TextColor3 = color
		label.Parent = holder
	end
	return holder
end

local infoLabels: { [string]: TextLabel } = {}
local infoTitle: TextLabel? = nil

local function refreshInfo()
	for key, label in infoLabels do
		label.Text = Strings.format(key)
	end
	if infoTitle then
		infoTitle.Text = Strings.format("info.title")
	end
end

local function attachInfo(board: Instance)
	if not board:IsA("BasePart") then
		return
	end
	local gui = Instance.new("SurfaceGui")
	gui.Face = Enum.NormalId.Back
	gui.SizingMode = Enum.SurfaceGuiSizingMode.PixelsPerStud
	gui.PixelsPerStud = 60
	gui.LightInfluence = 0.3
	gui.Adornee = board
	gui.ResetOnSpawn = false
	gui.Parent = Context.player:WaitForChild("PlayerGui")
	local title = line(gui, 0.02, 0.18, Enum.Font.Michroma, Palette.ticketInk)
	title.TextXAlignment = Enum.TextXAlignment.Center
	infoTitle = title
	table.clear(infoLabels)
	for i, row in INFO_ROWS do
		local column = (i - 1) // 3
		local index = (i - 1) % 3
		local frame = Instance.new("Frame")
		frame.BackgroundTransparency = 1
		frame.Size = UDim2.fromScale(0.47, 0.24)
		frame.Position = UDim2.fromScale(0.02 + column * 0.5, 0.22 + index * 0.26)
		frame.Parent = gui
		icon(frame, row.shape, row.color)
		local label = Instance.new("TextLabel")
		label.BackgroundTransparency = 1
		label.Size = UDim2.fromScale(0.85, 1)
		label.Position = UDim2.fromScale(0.15, 0)
		label.TextScaled = true
		label.TextXAlignment = Enum.TextXAlignment.Left
		label.Font = Enum.Font.SpecialElite
		label.TextColor3 = Palette.ticketInk
		label.Parent = frame
		infoLabels[row.key] = label
	end
	refreshInfo()
	-- Tafel verschwindet mit Wagen 0 beim Abkoppeln
	board.AncestryChanged:Connect(function()
		if board.Parent == nil then
			gui:Destroy()
		end
	end)
end

function LobbyController.init()
	for _, board in CollectionService:GetTagged(BOARD_TAG) do
		attach(board)
	end
	CollectionService:GetInstanceAddedSignal(BOARD_TAG):Connect(attach)
	for _, board in CollectionService:GetTagged(INFO_TAG) do
		attachInfo(board)
	end
	CollectionService:GetInstanceAddedSignal(INFO_TAG):Connect(attachInfo)
	Strings.onReady(refreshInfo)
	Context.onPersonal("found", function(payload)
		if payload.content == "key" then
			Hud.toast(Strings.format("hud.key"))
		elseif payload.content == "stubs" then
			Hud.toast("+" .. tostring(payload.stubs))
		end
	end)
	task.spawn(function()
		while true do
			refresh()
			task.wait(0.25)
		end
	end)
end

return LobbyController
