--!strict
-- Client-Einstiegspunkt. Wartet auf die Replikation, erzeugt den Turm lokal aus demselben Seed
-- wie der Server und startet die Controller.

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

if not game:IsLoaded() then
	game.Loaded:Wait()
end
ReplicatedStorage:WaitForChild("Shared")
local remotes = ReplicatedStorage:WaitForChild("Remotes")

local TowerGenerator = require("@game/ReplicatedStorage/Shared/Logic/TowerGenerator")

local CameraIntro = require("./Controllers/CameraIntro")
local ClientState = require("./Controllers/ClientState")
local Context = require("./Controllers/Context")
local FallController = require("./Controllers/FallController")
local GuidanceController = require("./Controllers/GuidanceController")
local HudController = require("./Controllers/HudController")
local InputController = require("./Controllers/InputController")
local MovementController = require("./Controllers/MovementController")
local SparkController = require("./Controllers/SparkController")
local Strings = require("./Controllers/Strings")

local player = Players.LocalPlayer

local function waitForAttribute(name: string): number
	local value = workspace:GetAttribute(name)
	while type(value) ~= "number" do
		workspace:GetAttributeChangedSignal(name):Wait()
		value = workspace:GetAttribute(name)
	end
	return value :: number
end

local seed = waitForAttribute("TowerSeed")
local builtFloors = waitForAttribute("BuiltFloors")
local tower = TowerGenerator.generate(seed, builtFloors)

local fxFolder = Instance.new("Folder")
fxFolder.Name = "ClientFx"
fxFolder.Parent = workspace

local function fire(name: string, ...: any)
	local remote = remotes:FindFirstChild(name)
	if remote and remote:IsA("RemoteEvent") then
		remote:FireServer(...)
	end
end

local context: Context.Context = {
	player = player,
	tower = tower,
	fire = fire,
	fxFolder = fxFolder,
}

Strings.init(player)

local stateSync = remotes:WaitForChild("StateSync")
if stateSync:IsA("RemoteEvent") then
	stateSync.OnClientEvent:Connect(ClientState.apply)
end

HudController.start(context)
SparkController.start(context)
GuidanceController.start(context)
MovementController.start(context)
FallController.start(context)
InputController.start(context)

-- Kamera-Schwenk nur beim ersten Klettern dieses Laufs (noch keine Etage erreicht).
task.spawn(function()
	if ClientState.get().highestFloor == 0 then
		CameraIntro.play(context)
	end
end)
