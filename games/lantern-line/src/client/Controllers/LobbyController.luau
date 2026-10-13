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
		if type(endsAt) == "number" and endsAt > 0 then
			lines[3].Text = Strings.format("lobby.departs", { math.max(0, math.ceil(endsAt - Context.now())) })
		else
			lines[3].Text = Strings.format("lobby.waiting")
		end
		lines[4].Text = Strings.format("lobby.board")
	else
		local carriage = workspace:GetAttribute("RunCarriage")
		lines[3].Text = Strings.format(
			"lobby.enroute",
			{ string.format("%02d", if type(carriage) == "number" then carriage else 0) }
		)
		lines[4].Text = ""
	end
end

function LobbyController.init()
	for _, board in CollectionService:GetTagged(BOARD_TAG) do
		attach(board)
	end
	CollectionService:GetInstanceAddedSignal(BOARD_TAG):Connect(attach)
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
