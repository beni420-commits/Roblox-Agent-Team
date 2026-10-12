--!strict
-- Baut die Server-Bauteile aus der Turmbeschreibung (TowerGenerator). Funken, Hilfsstufen und Führung
-- erzeugt jeder Client selbst aus demselben Seed (sie sind pro Spieler verschieden).

local CollectionService = game:GetService("CollectionService")

local Palette = require("@game/ReplicatedStorage/Shared/Visual/Palette")
local TowerConfig = require("@game/ReplicatedStorage/Shared/Logic/TowerConfig")
local TowerGenerator = require("@game/ReplicatedStorage/Shared/Logic/TowerGenerator")

local TowerBuilder = {}

TowerBuilder.JUMP_PAD_TAG = "JumpPad"

local function color(rgb: Palette.RGB): Color3
	return Color3.fromRGB(rgb.r, rgb.g, rgb.b)
end

local function zonePalette(zone: number)
	local config = TowerConfig.ZONES[zone]
	return Palette.ZONES[if config then config.palette else "meadow"]
end

local function material(kind: string): Enum.Material
	local name = Palette.MATERIALS[kind] or "SmoothPlastic"
	return Enum.Material:FromName(name) or Enum.Material.SmoothPlastic
end

local function makePart(spec: TowerGenerator.PartSpec): Part
	local part = Instance.new("Part")
	part.Name = spec.id
	part.Anchored = true
	part.TopSurface = Enum.SurfaceType.Smooth
	part.BottomSurface = Enum.SurfaceType.Smooth
	part.CastShadow = spec.kind ~= "gate"
	local palette = zonePalette(spec.zone)
	local position = Vector3.new(spec.cx, spec.cy, spec.cz)

	if spec.kind == "ground" or spec.kind == "column" then
		-- Zylinder liegen in Roblox entlang X; um 90° drehen, damit die Achse senkrecht steht.
		part.Shape = Enum.PartType.Cylinder
		part.Size = Vector3.new(spec.sy, spec.sx, spec.sz)
		part.CFrame = CFrame.new(position) * CFrame.Angles(0, 0, math.pi / 2)
	else
		part.Size = Vector3.new(spec.sx, spec.sy, spec.sz)
		part.CFrame = CFrame.lookAt(position, position + Vector3.new(spec.fx, 0, spec.fz))
	end

	local paletteKey = spec.kind
	if spec.kind == "platform" and (string.byte(spec.id, -1) or 0) % 2 == 0 then
		paletteKey = "platformAlt"
	end
	local rgb = palette[paletteKey] or palette.platform
	part.Color = color(rgb)
	part.Material = material(spec.kind)

	if spec.kind == "conveyor" and spec.conveyorSpeed then
		-- Verankertes Teil mit Geschwindigkeit wirkt als Förderband in Laufrichtung.
		part.AssemblyLinearVelocity = Vector3.new(spec.fx, 0, spec.fz) * spec.conveyorSpeed
	elseif spec.kind == "jumpPad" and spec.launchVelocity then
		part:SetAttribute("LaunchVelocity", spec.launchVelocity)
		CollectionService:AddTag(part, TowerBuilder.JUMP_PAD_TAG)
	end
	return part
end

local function makeBeacon(): Model
	local model = Instance.new("Model")
	model.Name = "SummitBeacon"
	model.ModelStreamingMode = Enum.ModelStreamingMode.Persistent
	local top = TowerConfig.TOTAL_FLOORS * TowerConfig.FLOOR_HEIGHT + 30

	local orb = Instance.new("Part")
	orb.Name = "Orb"
	orb.Shape = Enum.PartType.Ball
	orb.Size = Vector3.new(12, 12, 12)
	orb.Anchored = true
	orb.CanCollide = false
	orb.CanQuery = false
	orb.CanTouch = false
	orb.Material = Enum.Material.Neon
	orb.Color = color(Palette.BEACON)
	orb.Position = Vector3.new(0, top, 0)
	orb.Parent = model

	local light = Instance.new("PointLight")
	light.Range = 60
	light.Brightness = 3
	light.Color = color(Palette.BEACON)
	light.Parent = orb

	local shaft = Instance.new("Part")
	shaft.Name = "Shaft"
	shaft.Size = Vector3.new(2, 160, 2)
	shaft.Anchored = true
	shaft.CanCollide = false
	shaft.CanQuery = false
	shaft.CanTouch = false
	shaft.Material = Enum.Material.Neon
	shaft.Transparency = 0.5
	shaft.Color = color(Palette.BEACON)
	shaft.Position = Vector3.new(0, top + 86, 0)
	shaft.Parent = model

	model.PrimaryPart = orb
	return model
end

function TowerBuilder.build(tower: TowerGenerator.TowerSpec, parent: Instance): Folder
	local root = Instance.new("Folder")
	root.Name = "Tower"

	-- Boden, Säule, Startplattform und Gipfel-Leuchtfeuer sind dauerhaft sichtbar (Sichtachse, P-13).
	local statics = Instance.new("Model")
	statics.Name = "Statics"
	statics.ModelStreamingMode = Enum.ModelStreamingMode.Persistent
	for _, spec in tower.statics do
		makePart(spec).Parent = statics
	end
	statics.Parent = root
	makeBeacon().Parent = root

	for _, floor in tower.floors do
		local model = Instance.new("Model")
		model.Name = string.format("Floor_%02d", floor.floor)
		for _, spec in floor.parts do
			makePart(spec).Parent = model
		end
		model.Parent = root
	end

	root.Parent = parent
	return root
end

return TowerBuilder
