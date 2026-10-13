--!strict
-- Einstellungs-Fahrkarte: Flackern reduzieren, Sanfter Modus, Bewegung reduzieren.
-- Öffnen über HUD-Knopf, Taste M oder Gamepad Y (Select gehört Roblox’ UI-Navigation, LL-24); am Bahnsteig vor dem ersten Lauf sichtbar (H-A9).

local ContextActionService = game:GetService("ContextActionService")
local GuiService = game:GetService("GuiService")

local Settings = require("./Settings")
local Strings = require("./Strings")
local UiKit = require("./UiKit")

local SettingsPanel = {}

local panel: Frame? = nil
local refreshers: { () -> () } = {}

local function refresh()
	for _, f in refreshers do
		f()
	end
end

local function addToggle(parent: Frame, row: number, name: Settings.Name, key: string)
	local label =
		UiKit.label(parent, Strings.format(key), UDim2.new(0.6, 0, 0.2, 0), UDim2.new(0, 0, 0.12 + row * 0.22, 0))
	label.TextXAlignment = Enum.TextXAlignment.Left
	local button = UiKit.button(parent, "", UDim2.new(0.3, 0, 0.18, 0), UDim2.new(0.68, 0, 0.13 + row * 0.22, 0), false)
	button.Activated:Connect(function()
		Settings.set(name, not Settings.get(name))
	end)
	table.insert(refreshers, function()
		label.Text = Strings.format(key)
		button.Text = Strings.format(if Settings.get(name) then "settings.on" else "settings.off")
	end)
end

function SettingsPanel.isOpen(): boolean
	local current = panel
	return current ~= nil and current.Visible
end

function SettingsPanel.toggle()
	local current = panel
	if current then
		current.Visible = not current.Visible
		refresh()
		if current.Visible then
			local first = current:FindFirstChildWhichIsA("TextButton")
			GuiService.SelectedObject = first
		end
	end
end

function SettingsPanel.init(gui: ScreenGui)
	local frame = UiKit.ticket(gui, UDim2.fromOffset(380, 230), UDim2.fromScale(0.5, 0.5), Vector2.new(0.5, 0.5))
	frame.Visible = false
	panel = frame
	addToggle(frame, 0, "flicker", "settings.flicker")
	addToggle(frame, 1, "gentle", "settings.gentle")
	addToggle(frame, 2, "motion", "settings.motion")
	local close = UiKit.button(
		frame,
		Strings.format("settings.close"),
		UDim2.new(0.4, 0, 0.16, 0),
		UDim2.new(0.3, 0, 0.8, 0),
		true
	)
	close.Activated:Connect(SettingsPanel.toggle)
	table.insert(refreshers, function()
		close.Text = Strings.format("settings.close")
	end)
	Settings.onChanged(refresh)
	Strings.onReady(refresh)
	refresh()
	ContextActionService:BindAction("LanternSettings", function(_, state)
		if state == Enum.UserInputState.Begin then
			SettingsPanel.toggle()
		end
		return Enum.ContextActionResult.Sink
	end, false, Enum.KeyCode.M, Enum.KeyCode.ButtonY)
end

return SettingsPanel
