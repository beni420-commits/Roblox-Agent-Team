--!strict
-- Visuelle Führung ohne Text (GDD v0.2 §2 S1, §6.3, §7; UX A5/B4):
-- * Lichtsäule über der nächsten Etagenplattform (Ziel = hellstes Objekt)
-- * goldene Führungs-Chevrons: im allerersten Abschnitt, ab 3 Fehlversuchen und 3 s nach (Re-)Spawn
-- * Hilfsstufen (nur lokal) ab 6 Fehlversuchen
-- * kurzer Lichtring beim Erreichen einer Etage

local TweenService = game:GetService("TweenService")

local Palette = require("@game/ReplicatedStorage/Shared/Visual/Palette")
local TowerConfig = require("@game/ReplicatedStorage/Shared/Logic/TowerConfig")
local TowerGenerator = require("@game/ReplicatedStorage/Shared/Logic/TowerGenerator")

local ClientState = require("./ClientState")
local Context = require("./Context")

local GuidanceController = {}

local REJOIN_GUIDE_SECONDS = 3

local function color(rgb: Palette.RGB): Color3
	return Color3.fromRGB(rgb.r, rgb.g, rgb.b)
end

local function fxPart(name: string, size: Vector3, cframe: CFrame, rgb: Palette.RGB, transparency: number): Part
	local part = Instance.new("Part")
	part.Name = name
	part.Size = size
	part.CFrame = cframe
	part.Anchored = true
	part.CanCollide = false
	part.CanQuery = false
	part.CanTouch = false
	part.CastShadow = false
	part.Material = Enum.Material.Neon
	part.Color = color(rgb)
	part.Transparency = transparency
	return part
end

-- Pfeilspitze („>“) aus zwei flachen Leisten, zeigt in Laufrichtung. Groß genug für kleine Telefone (CR-09).
local function chevron(parent: Instance, position: Vector3, forward: Vector3)
	local base = CFrame.lookAt(position, position + forward)
	for side = -1, 1, 2 do
		local arm = base * CFrame.Angles(0, math.rad(35) * side, 0) * CFrame.new(0, 0, 1.1)
		fxPart("Chevron", Vector3.new(0.7, 0.2, 2.8), arm, Palette.GUIDANCE_GOLD, 0).Parent = parent
	end
end

local function partTop(spec: TowerGenerator.PartSpec): Vector3
	return Vector3.new(spec.cx, spec.cy + spec.sy / 2 + 0.1, spec.cz)
end

function GuidanceController.start(context: Context.Context)
	local tower = context.tower
	local guideFolder = Instance.new("Folder")
	guideFolder.Name = "Guidance"
	guideFolder.Parent = context.fxFolder
	local helperFolder = Instance.new("Folder")
	helperFolder.Name = "Helpers"
	helperFolder.Parent = context.fxFolder

	local goal = fxPart("GoalLight", Vector3.new(2.5, 40, 2.5), CFrame.new(), Palette.GOAL_LIGHT, 0.65)
	goal.Parent = context.fxFolder

	local partsById: { [string]: TowerGenerator.PartSpec } = {}
	for _, floor in tower.floors do
		for _, part in floor.parts do
			partsById[part.id] = part
		end
	end
	for _, part in tower.statics do
		partsById[part.id] = part
	end

	local guideUntil = 0
	local shownGuideFloor = -1
	local shownHelperFloor = -1

	-- Weg von der Plaza zur ersten Etagenplattform (nur vor dem ersten Klettern, GDD §7, CR-09).
	local plazaFolder = Instance.new("Folder")
	plazaFolder.Name = "PlazaPath"
	plazaFolder.Parent = context.fxFolder
	do
		local spawnAt = TowerConfig.SPAWN_POSITION
		local start = Vector3.new(spawnAt.x, 0.2, spawnAt.z)
		local landing0 = tower.landings[0]
		local finish = Vector3.new(landing0.x, 0.2, landing0.z)
		local direction = (finish - start).Unit
		local count = 6
		for index = 1, count do
			local position = start:Lerp(finish, index / (count + 1))
			chevron(plazaFolder, position, direction)
		end
	end

	local function showChevrons(targetFloor: number)
		guideFolder:ClearAllChildren()
		shownGuideFloor = targetFloor
		local floor = tower.floors[targetFloor]
		if not floor then
			return
		end
		for _, connection in floor.connections do
			local from = partsById[connection.fromId]
			if from then
				local forward = Vector3.new(from.fx, 0, from.fz)
				chevron(guideFolder, partTop(from) + forward * (from.sz / 2 - 0.8), forward)
			end
		end
	end

	local function showHelpers(targetFloor: number)
		helperFolder:ClearAllChildren()
		shownHelperFloor = targetFloor
		local floor = tower.floors[targetFloor]
		if not floor then
			return
		end
		for _, spec in floor.helpers do
			local position = Vector3.new(spec.cx, spec.cy, spec.cz)
			local part = Instance.new("Part")
			part.Name = spec.id
			part.Size = Vector3.new(spec.sx, spec.sy, spec.sz)
			part.CFrame = CFrame.lookAt(position, position + Vector3.new(spec.fx, 0, spec.fz))
			part.Anchored = true
			part.CanCollide = true -- nur lokal: trägt nur den eigenen Charakter
			part.Material = Enum.Material.Glass
			part.Color = color(Palette.HELPER)
			part.Transparency = 0.2
			part:SetAttribute("Floor", spec.floor)
			part.Parent = helperFolder
		end
	end

	local function celebrate(floorIndex: number)
		local landing = tower.landings[floorIndex]
		if not landing then
			return
		end
		local ring = fxPart(
			"Celebration",
			Vector3.new(1, 1, 1),
			CFrame.new(landing.x, landing.y + 1, landing.z),
			Palette.REACHED,
			0.2
		)
		ring.Shape = Enum.PartType.Ball
		ring.Parent = context.fxFolder
		local tween =
			TweenService:Create(ring, TweenInfo.new(0.6), { Size = Vector3.new(14, 14, 14), Transparency = 1 })
		tween:Play()
		tween.Completed:Once(function()
			ring:Destroy()
		end)
	end

	local function update(state: ClientState.Snapshot)
		local target = state.currentFloor + 1
		local landing = tower.landings[target]
		if landing then
			goal.Transparency = 0.65
			goal.CFrame = CFrame.new(landing.x, landing.y + 20, landing.z)
		else
			goal.Transparency = 1
		end

		local firstClimb = state.runIndex == 1 and state.highestFloor == 0
		if not firstClimb and #plazaFolder:GetChildren() > 0 then
			plazaFolder:ClearAllChildren()
		end
		local wantGuide = firstClimb or state.helpLevel >= 1 or os.clock() < guideUntil
		if wantGuide and landing then
			if shownGuideFloor ~= target then
				showChevrons(target)
			end
		elseif shownGuideFloor ~= -1 then
			guideFolder:ClearAllChildren()
			shownGuideFloor = -1
		end

		if state.helpLevel >= 2 and landing then
			if shownHelperFloor ~= target then
				showHelpers(target)
			end
		elseif shownHelperFloor ~= -1 then
			helperFolder:ClearAllChildren()
			shownHelperFloor = -1
		end
	end

	local function guideBriefly()
		guideUntil = os.clock() + REJOIN_GUIDE_SECONDS
		update(ClientState.get())
		task.delay(REJOIN_GUIDE_SECONDS + 0.1, function()
			update(ClientState.get())
		end)
	end

	ClientState.onChanged(function(new: ClientState.Snapshot, old: ClientState.Snapshot)
		if new.currentFloor > old.currentFloor then
			celebrate(new.currentFloor)
		end
		if new.fails > old.fails then
			guideBriefly() -- nach einem Sturz die Chevrons kurz aufleuchten lassen (UX B4, CR-08)
		else
			update(new)
		end
	end)
	context.player.CharacterAdded:Connect(guideBriefly)
	guideBriefly()
end

return GuidanceController
