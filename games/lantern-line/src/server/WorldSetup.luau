--!strict
-- Welt: Licht und Atmosphäre (Laternen-Noir), Kollisionsgruppen, Bahnsteig mit stehendem Zug.
-- Bahnsteig ohne Sitzplätze und Emote-Bühne (Compliance H-A7, C-A20).

local CollectionService = game:GetService("CollectionService")
local Lighting = game:GetService("Lighting")
local PhysicsService = game:GetService("PhysicsService")

local Palette = require("@game/ReplicatedStorage/Shared/Visual/Palette")

local WorldSetup = {}

WorldSetup.PLAYER_GROUP = "Players"
WorldSetup.BOARD_TAG = "LanternLineDepartureBoard"

-- Bahnsteig liegt abseits des Zugs (der Zug läuft entlang +x bei z = 0).
local PLATFORM_CENTER = Vector3.new(0, 0, -220)
local BOARDING_MIN = Vector3.new(-6, -2, -215)
local BOARDING_MAX = Vector3.new(6, 10, -209)

local function block(
	parent: Instance,
	name: string,
	size: Vector3,
	position: Vector3,
	color: Color3,
	material: Enum.Material,
	collide: boolean?
): Part
	local p = Instance.new("Part")
	p.Name = name
	p.Anchored = true
	p.Size = size
	p.Position = position
	p.Color = color
	p.Material = material
	p.TopSurface = Enum.SurfaceType.Smooth
	p.BottomSurface = Enum.SurfaceType.Smooth
	p.CanCollide = collide ~= false
	p.Parent = parent
	return p
end

local function setupLighting()
	local atmosphere = Instance.new("Atmosphere")
	atmosphere.Density = 0.32
	atmosphere.Offset = 0
	atmosphere.Color = Color3.fromRGB(26, 32, 42)
	atmosphere.Decay = Color3.fromRGB(12, 16, 22)
	atmosphere.Glare = 0
	atmosphere.Haze = 1.2
	atmosphere.Parent = Lighting
	local grading = Instance.new("ColorCorrectionEffect")
	grading.Contrast = 0.08
	grading.Saturation = -0.15
	grading.TintColor = Color3.fromRGB(242, 248, 255)
	grading.Parent = Lighting
	-- Bloom begrenzt, damit Lichtwesen nie den ganzen Bildschirm weiß machen (Compliance H-A10 d)
	local bloom = Instance.new("BloomEffect")
	bloom.Intensity = 0.5
	bloom.Size = 16
	bloom.Threshold = 1.7
	bloom.Parent = Lighting
end

local function setupCollision()
	PhysicsService:RegisterCollisionGroup(WorldSetup.PLAYER_GROUP)
	-- Spieler kollidieren nicht miteinander (Compliance H-A7, C-A13): niemand blockiert Türen oder Verstecke.
	PhysicsService:CollisionGroupSetCollidable(WorldSetup.PLAYER_GROUP, WorldSetup.PLAYER_GROUP, false)
end

local function buildPlatform(): Model
	local model = Instance.new("Model")
	model.Name = "Platform"
	local c = PLATFORM_CENTER
	block(model, "Floor", Vector3.new(90, 1, 22), c + Vector3.new(0, -0.5, 0), Palette.platform, Enum.Material.Concrete)
	block(
		model,
		"EdgeLine",
		Vector3.new(90, 0.05, 0.5),
		c + Vector3.new(0, 0.03, 9),
		Palette.platformEdge,
		Enum.Material.SmoothPlastic,
		false
	)
	-- Unsichtbare Absperrung rundum
	for _, spec in
		{
			{ Vector3.new(92, 20, 1), Vector3.new(0, 9, -11.5) },
			{ Vector3.new(92, 20, 1), Vector3.new(0, 9, 11.5) },
			{ Vector3.new(1, 20, 24), Vector3.new(-45.5, 9, 0) },
			{ Vector3.new(1, 20, 24), Vector3.new(45.5, 9, 0) },
		}
	do
		local barrier = block(model, "Barrier", spec[1], c + spec[2], Palette.platform, Enum.Material.SmoothPlastic)
		barrier.Transparency = 1
	end
	-- Stehender Zug mit warm beleuchteten Fenstern und offener Tür in der Mitte
	block(
		model,
		"TrainBody",
		Vector3.new(90, 12, 8),
		c + Vector3.new(0, 6, 15.5),
		Palette.trainOutside,
		Enum.Material.Metal
	)
	local x = -42
	while x <= 42 do
		if math.abs(x) > 5 then
			local window = block(
				model,
				"Window",
				Vector3.new(4, 3, 0.2),
				c + Vector3.new(x, 6, 11.45),
				Palette.lampOn,
				Enum.Material.Neon,
				false
			)
			window.Transparency = 0.25
		end
		x += 7
	end
	local doorway = block(
		model,
		"Doorway",
		Vector3.new(5, 8, 0.2),
		c + Vector3.new(0, 4, 11.45),
		Palette.lampOn,
		Enum.Material.Neon,
		false
	)
	doorway.Transparency = 0.1
	-- Markierung des Einstiegsfelds (Pfeile, ohne Text)
	for i = 0, 2 do
		local chevron = block(
			model,
			"Chevron",
			Vector3.new(3, 0.05, 0.6),
			c + Vector3.new(0, 0.04, 6 + i * 1.6),
			Palette.platformEdge,
			Enum.Material.Neon,
			false
		)
		chevron.Transparency = 0.4
	end
	-- Laternenmasten
	for _, lx in { -30, -10, 10, 30 } do
		block(model, "Post", Vector3.new(0.5, 9, 0.5), c + Vector3.new(lx, 4.5, -6), Palette.metal, Enum.Material.Metal)
		local head = block(
			model,
			"PostLamp",
			Vector3.new(1.2, 0.6, 1.2),
			c + Vector3.new(lx, 9, -6),
			Palette.lampOn,
			Enum.Material.Neon,
			false
		)
		local light = Instance.new("PointLight")
		light.Range = 24
		light.Brightness = 1.4
		light.Color = Palette.lampLight
		light.Shadows = true
		light.Parent = head
	end
	-- Abfahrtstafel (Text setzt jeder Client lokalisiert)
	local board = block(
		model,
		"DepartureBoard",
		Vector3.new(10, 3.4, 0.4),
		c + Vector3.new(-16, 7.5, -2),
		Palette.hudShade,
		Enum.Material.SmoothPlastic
	)
	block(model, "BoardPost", Vector3.new(0.4, 6, 0.4), c + Vector3.new(-16, 3, -2), Palette.metal, Enum.Material.Metal)
	CollectionService:AddTag(board, WorldSetup.BOARD_TAG)
	-- Startpunkt
	local spawn = Instance.new("SpawnLocation")
	spawn.Name = "PlatformSpawn"
	spawn.Anchored = true
	spawn.Size = Vector3.new(8, 1, 6)
	spawn.Position = c + Vector3.new(0, -0.45, -6)
	spawn.Transparency = 1
	spawn.CanCollide = false
	spawn.Neutral = true
	spawn.Duration = 0
	spawn.Parent = model
	model.Parent = workspace
	return model
end

function WorldSetup.apply()
	setupLighting()
	setupCollision()
	buildPlatform()
end

function WorldSetup.platformSpawn(): CFrame
	local p = PLATFORM_CENTER + Vector3.new(0, 3, -6)
	return CFrame.lookAt(p, p + Vector3.new(0, 0, 1))
end

function WorldSetup.isInBoardingZone(position: Vector3): boolean
	return position.X >= BOARDING_MIN.X
		and position.X <= BOARDING_MAX.X
		and position.Y >= BOARDING_MIN.Y
		and position.Y <= BOARDING_MAX.Y
		and position.Z >= BOARDING_MIN.Z
		and position.Z <= BOARDING_MAX.Z
end

return WorldSetup
