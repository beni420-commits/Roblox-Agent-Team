--!strict
-- Client-Einstiegspunkt. Wartet auf die Replikation, erzeugt den Turm lokal aus demselben Seed
-- wie der Server und startet die Controller.

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local StarterGui = game:GetService("StarterGui")

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
local serverHash = waitForAttribute("TowerHash")
if TowerGenerator.fingerprint(tower) ~= serverHash then
	-- Client und Server haben verschiedene Türme erzeugt (CR-23): Funken würden in der Luft hängen.
	warn("[Client] Turm-Fingerabdruck weicht vom Server ab – bitte melden")
end

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

task.spawn(Strings.init, player) -- nicht blockieren: HUD und Führung starten sofort (CR-18)

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

-- Roblox-Reset-Knopf: kein Charaktertod, sondern Rücksetzen an den Etagenanfang (CR-17).
local resetEvent = Instance.new("BindableEvent")
resetEvent.Event:Connect(function()
	fire("RequestReset")
end)
task.spawn(function()
	for _ = 1, 10 do
		local ok = pcall(function()
			StarterGui:SetCore("ResetButtonCallback", resetEvent)
		end)
		if ok then
			return
		end
		task.wait(1) -- SetCore ist erst verfügbar, wenn die Core-Skripte geladen sind
	end
end)

-- Kamera-Schwenk nur beim ersten Klettern dieses Laufs (noch keine Etage erreicht).
task.spawn(function()
	if ClientState.get().highestFloor == 0 then
		CameraIntro.play(context)
	end
end)
