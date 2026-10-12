--!strict
-- Licht, Atmosphäre, Spawn und Kollisionsgruppen (GDD v0.2 §4/§8, C-A13).

local Lighting = game:GetService("Lighting")

local TowerConfig = require("@game/ReplicatedStorage/Shared/Logic/TowerConfig")

local WorldSetup = {}

WorldSetup.PLAYER_GROUP = "Players"

local function setupCollisionGroups()
	-- WorldRoot-Methoden ersetzen die veralteten PhysicsService-Varianten (CR-16).
	if not workspace:IsCollisionGroupRegistered(WorldSetup.PLAYER_GROUP) then
		workspace:RegisterCollisionGroup(WorldSetup.PLAYER_GROUP)
	end
	-- Spieler kollidieren nicht miteinander: niemand kann andere herunterschubsen (Anti-Griefing).
	workspace:CollisionGroupSetCollidable(WorldSetup.PLAYER_GROUP, WorldSetup.PLAYER_GROUP, false)
end

local function setupLighting()
	Lighting.ClockTime = 14.5
	Lighting.Brightness = 2
	Lighting.EnvironmentDiffuseScale = 0.6
	Lighting.EnvironmentSpecularScale = 0.4

	local atmosphere = Instance.new("Atmosphere")
	atmosphere.Density = 0.28
	atmosphere.Offset = 0.1
	atmosphere.Haze = 0.6
	atmosphere.Glare = 0.2
	atmosphere.Parent = Lighting

	local bloom = Instance.new("BloomEffect")
	bloom.Intensity = 0.6
	bloom.Size = 24
	bloom.Threshold = 1.4
	bloom.Parent = Lighting

	local grading = Instance.new("ColorCorrectionEffect")
	grading.Saturation = 0.08
	grading.Contrast = 0.05
	grading.Parent = Lighting
end

local function setupSpawn()
	local spawnPoint = Instance.new("SpawnLocation")
	spawnPoint.Name = "PlazaSpawn"
	spawnPoint.Anchored = true
	spawnPoint.Neutral = true
	spawnPoint.Duration = 0 -- kein Schutzschild-Effekt
	spawnPoint.Size = Vector3.new(12, 1, 12)
	spawnPoint.Material = Enum.Material.SmoothPlastic
	spawnPoint.Color = Color3.fromRGB(236, 226, 196)
	local position = TowerConfig.SPAWN_POSITION
	local at = Vector3.new(position.x, position.y + 0.5, position.z)
	-- Blick zum Turm (Mittelpunkt), damit der Gipfel beim Start im Bild ist.
	spawnPoint.CFrame = CFrame.lookAt(at, Vector3.new(0, at.Y, 0))
	spawnPoint.Parent = workspace
end

function WorldSetup.apply()
	setupCollisionGroups()
	setupLighting()
	setupSpawn()
end

function WorldSetup.assignCharacter(character: Model)
	for _, descendant in character:GetDescendants() do
		if descendant:IsA("BasePart") then
			descendant.CollisionGroup = WorldSetup.PLAYER_GROUP
		end
	end
	character.DescendantAdded:Connect(function(descendant: Instance)
		if descendant:IsA("BasePart") then
			descendant.CollisionGroup = WorldSetup.PLAYER_GROUP
		end
	end)
end

return WorldSetup
