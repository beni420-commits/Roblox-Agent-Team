--!strict
-- Entwerter im Postwagen: 3 × 3 Lochfelder antippen, „Entwerten“ schickt die Bitmaske (0–511).
-- Keine Texteingabe (Compliance H-A12). Der Notizzettel zeigt bekannte Reihen als Hilfe.

local GuiService = game:GetService("GuiService")
local TweenService = game:GetService("TweenService")

local Context = require("./Context")
local Hud = require("./Hud")
local Palette = require("@game/ReplicatedStorage/Shared/Visual/Palette")
local Puzzle = require("@game/ReplicatedStorage/Shared/Logic/Puzzle")
local Settings = require("./Settings")
local Strings = require("./Strings")
local UiKit = require("./UiKit")

local ValidatorController = {}

local panel: Frame
local title: TextLabel
local status: TextLabel
local cells: { { TextButton } } = {}
local submit: TextButton
local clear: TextButton
local mask = 0

local function refresh()
	for row = 1, 3 do
		for column = 1, 3 do
			local punched = bit32.band(mask, Puzzle.bit(row, column)) ~= 0
			cells[row][column].BackgroundColor3 = if punched then Palette.hudShade else Palette.ticket
		end
	end
end

local function close()
	panel.Visible = false
	GuiService.SelectedObject = nil
end

local function open()
	mask = 0
	refresh()
	title.Text = Strings.format("validator.title")
	submit.Text = Strings.format("validator.submit")
	clear.Text = Strings.format("validator.clear")
	status.Text = ""
	panel.Visible = true
	GuiService.SelectedObject = cells[1][1]
end

function ValidatorController.init()
	local gui = UiKit.screen("Validator", 25)
	panel = UiKit.ticket(gui, UDim2.fromOffset(340, 400), UDim2.fromScale(0.5, 0.5), Vector2.new(0.5, 0.5))
	panel.Visible = false
	title = UiKit.label(panel, "", UDim2.new(1, 0, 0.1, 0), UDim2.fromScale(0, 0))
	for row = 1, 3 do
		cells[row] = {}
		for column = 1, 3 do
			local cell = UiKit.button(
				panel,
				"",
				UDim2.fromOffset(64, 64),
				UDim2.new(0.5, -110 + (column - 1) * 78, 0, 52 + (row - 1) * 78),
				true
			)
			cell.BackgroundColor3 = Palette.ticket
			UiKit.corner(cell, 32)
			UiKit.stroke(cell, Palette.ticketInk, 2)
			cell.Activated:Connect(function()
				mask = Puzzle.toggle(mask, row, column)
				refresh()
			end)
			cells[row][column] = cell
		end
	end
	status = UiKit.label(panel, "", UDim2.new(1, 0, 0.08, 0), UDim2.fromScale(0, 0.72))
	clear = UiKit.button(panel, "", UDim2.new(0.42, 0, 0.1, 0), UDim2.fromScale(0.04, 0.84), true)
	submit = UiKit.button(panel, "", UDim2.new(0.42, 0, 0.1, 0), UDim2.fromScale(0.54, 0.84), true)
	local closeButton = UiKit.button(panel, "×", UDim2.fromOffset(32, 32), UDim2.new(1, -28, 0, -4), true)
	clear.Activated:Connect(function()
		mask = 0
		refresh()
	end)
	submit.Activated:Connect(function()
		Context.fire("SubmitPattern", mask)
	end)
	closeButton.Activated:Connect(close)
	Context.onPersonal("validator", open)
	Context.onPersonal("pattern", function(payload)
		if payload.correct then
			close()
			Hud.toast(Strings.format("validator.right"))
		else
			status.Text = Strings.format("validator.wrong")
			if Settings.motionAllowed() then
				local origin = panel.Position
				panel.Position = origin + UDim2.fromOffset(8, 0)
				TweenService:Create(panel, TweenInfo.new(0.25, Enum.EasingStyle.Elastic), { Position = origin }):Play()
			end
		end
	end)
	Context.onWorld("reset", close)
	Context.onPersonal("death", close) -- Entwerter schließt beim Ausscheiden (Playtest LP-18)
	UiKit.fitHeight(panel, 400, 0.85)
end

return ValidatorController
