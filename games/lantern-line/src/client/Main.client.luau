--!strict
-- Client-Einstiegspunkt „Lantern Line – Der Nachtzug“.
-- Wartet auf das Spiel und die Remotes, dann starten die Controller in fester Reihenfolge.

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local StarterGui = game:GetService("StarterGui")
local UserInputService = game:GetService("UserInputService")

if not game:IsLoaded() then
	game.Loaded:Wait()
end
ReplicatedStorage:WaitForChild("Shared")
local remotes = ReplicatedStorage:WaitForChild("Remotes")

local AmbienceController = require("./Controllers/AmbienceController")
local Context = require("./Controllers/Context")
local DeathController = require("./Controllers/DeathController")
local EntityController = require("./Controllers/EntityController")
local HidingController = require("./Controllers/HidingController")
local Hud = require("./Controllers/Hud")
local LobbyController = require("./Controllers/LobbyController")
local MovementController = require("./Controllers/MovementController")
local Settings = require("./Controllers/Settings")
local Strings = require("./Controllers/Strings")
local ValidatorController = require("./Controllers/ValidatorController")

Context.init(remotes)
task.spawn(Strings.init, Context.player)
Settings.init()
Hud.init()
MovementController.init()
AmbienceController.init()
EntityController.init()
HidingController.init()
DeathController.init()
ValidatorController.init()
LobbyController.init()

-- Roblox-Reset aus: Ausscheiden passiert nur über das Spiel (kein Selbsttod).
task.spawn(function()
	for _ = 1, 10 do
		local ok = pcall(function()
			StarterGui:SetCore("ResetButtonCallback", false)
		end)
		if ok then
			return
		end
		task.wait(1)
	end
end)

-- Bevorzugte Eingabe einmalig für die Telemetrie melden.
local function inputName(): string
	local last = UserInputService:GetLastInputType()
	if last == Enum.UserInputType.Touch then
		return "Touch"
	elseif string.find(last.Name, "Gamepad") then
		return "Gamepad"
	end
	return "KeyboardAndMouse"
end
local reported = inputName()
Context.fire("ReportPreferredInput", reported)
UserInputService.LastInputTypeChanged:Connect(function()
	local current = inputName()
	if current ~= reported then
		reported = current
		Context.fire("ReportPreferredInput", current)
	end
end)
