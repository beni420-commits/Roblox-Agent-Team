--!strict
-- Baut Wagen aus dem Bauplan (nur Engine-Bauteile, Kat. 0, Compliance H-A14): Hülle mit Fenstern,
-- Übergang, Türen mit Schablonennummer, Möbel, Verstecke, Behälter, Lampen, Augen, Postwagen-Rätsel.
-- Interaktionen laufen über ProximityPrompts (automatisch lokalisiert über GameStrings).
-- Möbel sind schlichte Blöcke ohne Sitz-Instanzen (Compliance H-A7).

local CollectionService = game:GetService("CollectionService")
local LocalizationService = game:GetService("LocalizationService")
local TweenService = game:GetService("TweenService")

local GameConfig = require("@game/ReplicatedStorage/Shared/Config/GameConfig")
local Palette = require("@game/ReplicatedStorage/Shared/Visual/Palette")
local Types = require("@game/ReplicatedStorage/Shared/Logic/Types")

type Carriage = Types.Carriage

local TrainBuilder = {}

local HALF = GameConfig.INNER_WIDTH / 2
local HEIGHT = GameConfig.INNER_HEIGHT
local FLOOR_Y = GameConfig.FLOOR_Y
local WALL = 0.6
local GANGWAY = GameConfig.GANGWAY
local DOOR_HALF = GameConfig.DOOR_WIDTH / 2
local DOOR_H = GameConfig.DOOR_HEIGHT

TrainBuilder.LAMP_TAG = "LanternLineLamp"
TrainBuilder.EYES_TAG = "LanternLineEyes"
TrainBuilder.INFO_TAG = "LanternLineInfoBoard"

local trainFolder: Folder? = nil
local carriageModels: { [number]: Model } = {}
local doorModels: { [number]: Model } = {}
local promptLookup: { [string]: ProximityPrompt } = {}

local SPOT_STYLE: { [string]: { color: Color3, material: Enum.Material, text: string } } = {
	wardrobe = { color = Palette.woodDark, material = Enum.Material.Wood, text = "Wardrobe" },
	locker = { color = Palette.lockerGreen, material = Enum.Material.Metal, text = "Locker" },
	trunk = { color = Palette.leather, material = Enum.Material.Fabric, text = "Steamer trunk" },
	pantry = { color = Palette.cream, material = Enum.Material.Wood, text = "Pantry" },
}

local CONTAINER_TEXT: { [string]: string } = {
	rack = "Luggage rack",
	suitcase = "Suitcase",
	drawer = "Drawer",
	crate = "Crate",
}

local function folder(): Folder
	local current = trainFolder
	if current == nil or current.Parent == nil then
		local f = Instance.new("Folder")
		f.Name = "Train"
		f.Parent = workspace
		trainFolder = f
		return f
	end
	return current
end

local function block(
	parent: Instance,
	name: string,
	size: Vector3,
	cframe: CFrame,
	color: Color3,
	material: Enum.Material,
	collide: boolean?
): Part
	local p = Instance.new("Part")
	p.Name = name
	p.Anchored = true
	p.Size = size
	p.CFrame = cframe
	p.Color = color
	p.Material = material
	p.TopSurface = Enum.SurfaceType.Smooth
	p.BottomSurface = Enum.SurfaceType.Smooth
	p.CanCollide = collide ~= false
	p.CanTouch = false
	p.Parent = parent
	return p
end

local function world(c: Carriage, x: number, y: number, z: number): Vector3
	return Vector3.new(c.originX + x, FLOOR_Y + y, z)
end

local function at(c: Carriage, x: number, y: number, z: number): CFrame
	return CFrame.new(world(c, x, y, z))
end

local function newPrompt(
	parent: Instance,
	action: string,
	object: string,
	hold: number,
	distance: number
): ProximityPrompt
	local prompt = Instance.new("ProximityPrompt")
	prompt.ActionText = action
	prompt.ObjectText = object
	prompt.HoldDuration = hold
	prompt.MaxActivationDistance = distance
	prompt.RequiresLineOfSight = false
	prompt.KeyboardKeyCode = Enum.KeyCode.E
	prompt.GamepadKeyCode = Enum.KeyCode.ButtonX
	prompt.Exclusivity = Enum.ProximityPromptExclusivity.OnePerButton
	prompt.AutoLocalize = true
	local tableInstance = LocalizationService:FindFirstChild("GameStrings")
	if tableInstance and tableInstance:IsA("LocalizationTable") then
		prompt.RootLocalizationTable = tableInstance
	end
	prompt.Parent = parent
	return prompt
end

local function promptKey(kind: string, carriage: number, id: number): string
	return string.format("%s:%d:%d", kind, carriage, id)
end

local function registerPrompt(prompt: ProximityPrompt, kind: string, carriage: number, id: number)
	prompt:SetAttribute("Kind", kind)
	prompt:SetAttribute("Carriage", carriage)
	prompt:SetAttribute("Id", id)
	promptLookup[promptKey(kind, carriage, id)] = prompt
end

local function stencil(parent: BasePart, face: Enum.NormalId, text: string)
	local gui = Instance.new("SurfaceGui")
	gui.Face = face
	gui.SizingMode = Enum.SurfaceGuiSizingMode.PixelsPerStud
	gui.PixelsPerStud = 40
	gui.LightInfluence = 0.6
	local label = Instance.new("TextLabel")
	label.Size = UDim2.fromScale(1, 1)
	label.BackgroundTransparency = 1
	label.Text = text
	label.TextScaled = true
	label.Font = Enum.Font.Michroma
	label.TextColor3 = Palette.stencil
	label.Parent = gui
	gui.Parent = parent
end

-- Hülle: Boden, Decke, Seitenwände mit Fenstern, Stirnwände mit Türöffnungen, Übergang nach vorn.
local function buildShell(model: Model, c: Carriage)
	local L = c.length
	local fullWidth = GameConfig.INNER_WIDTH + 2 * WALL
	block(model, "Floor", Vector3.new(L, 1, fullWidth), at(c, L / 2, -0.5, 0), Palette.floor, Enum.Material.WoodPlanks)
	block(
		model,
		"Ceiling",
		Vector3.new(L, 0.6, fullWidth),
		at(c, L / 2, HEIGHT + 0.3, 0),
		Palette.ceiling,
		Enum.Material.Plastic
	)
	for _, side in { 1, -1 } do
		local z = side * (HALF + WALL / 2)
		block(model, "WallLow", Vector3.new(L, 3.2, WALL), at(c, L / 2, 1.6, z), Palette.wall, Enum.Material.Wood)
		block(
			model,
			"WallHigh",
			Vector3.new(L, HEIGHT - 7.4, WALL),
			at(c, L / 2, (7.4 + HEIGHT) / 2, z),
			Palette.wall,
			Enum.Material.Wood
		)
		local glass = block(
			model,
			"Window",
			Vector3.new(L, 4.2, 0.2),
			at(c, L / 2, 5.3, side * (HALF + WALL - 0.1)),
			Palette.glass,
			Enum.Material.Glass
		)
		glass.Transparency = 0.55
		local x = 0
		while x < L do
			local w = math.min(2.5, L - x)
			block(
				model,
				"Pillar",
				Vector3.new(w, 4.2, WALL),
				at(c, x + w / 2, 5.3, z),
				Palette.wallTrim,
				Enum.Material.Wood
			)
			x += 6
		end
	end
	-- Stirnwände mit Türöffnung (z ∈ [-DOOR_HALF, DOOR_HALF], Höhe DOOR_H)
	for _, x in { 0, L } do
		local sideWidth = HALF - DOOR_HALF
		for _, side in { 1, -1 } do
			block(
				model,
				"EndWall",
				Vector3.new(WALL, HEIGHT, sideWidth),
				at(c, x, HEIGHT / 2, side * (DOOR_HALF + sideWidth / 2)),
				Palette.wall,
				Enum.Material.Wood
			)
		end
		block(
			model,
			"Lintel",
			Vector3.new(WALL, HEIGHT - DOOR_H, 2 * DOOR_HALF),
			at(c, x, (DOOR_H + HEIGHT) / 2, 0),
			Palette.wall,
			Enum.Material.Wood
		)
	end
	-- Übergang (Faltenbalg) nach vorn
	local gx = L + GANGWAY / 2
	block(
		model,
		"GangwayFloor",
		Vector3.new(GANGWAY, 1, 7),
		at(c, gx, -0.5, 0),
		Palette.metal,
		Enum.Material.DiamondPlate
	)
	block(
		model,
		"GangwayRoof",
		Vector3.new(GANGWAY, 0.6, 7),
		at(c, gx, DOOR_H + 0.8, 0),
		Palette.hudShade,
		Enum.Material.Fabric
	)
	for _, side in { 1, -1 } do
		block(
			model,
			"Bellows",
			Vector3.new(GANGWAY, DOOR_H + 1, 0.6),
			at(c, gx, (DOOR_H + 1) / 2, side * 3.3),
			Palette.hudShade,
			Enum.Material.Fabric
		)
	end
end

local function buildObstacle(model: Model, c: Carriage, box: Types.Box)
	if string.sub(box.kind, 1, 7) == "hiding:" then
		return -- Verstecke baut buildSpot
	end
	local size = Vector3.new(box.sx, box.h, box.sz)
	local cf = at(c, box.cx, box.h / 2, box.cz)
	if box.kind == "chair" then
		block(
			model,
			"ChairBase",
			Vector3.new(box.sx, 1.6, box.sz),
			at(c, box.cx, 0.8, box.cz),
			Palette.fabric,
			Enum.Material.Fabric
		)
		block(
			model,
			"ChairBack",
			Vector3.new(0.4, box.h, box.sz),
			at(c, box.cx - box.sx / 2 + 0.2, box.h / 2, box.cz),
			Palette.fabric,
			Enum.Material.Fabric
		)
	elseif box.kind == "booth" then
		block(
			model,
			"Booth",
			Vector3.new(box.sx, 1.8, box.sz),
			at(c, box.cx, 0.9, box.cz),
			Palette.fabric,
			Enum.Material.Fabric
		)
		block(
			model,
			"Table",
			Vector3.new(1.6, 0.3, box.sz),
			at(c, box.cx, 3, box.cz),
			Palette.cream,
			Enum.Material.Wood
		)
	elseif box.kind == "bed" then
		block(model, "BedFrame", size, cf, Palette.woodDark, Enum.Material.Wood)
		block(
			model,
			"Blanket",
			Vector3.new(box.sx - 0.2, 0.3, box.sz - 0.2),
			at(c, box.cx, box.h + 0.15, box.cz),
			Palette.fabric,
			Enum.Material.Fabric,
			false
		)
	elseif box.kind == "teacounter" then
		block(model, "TeaCounter", size, cf, Palette.wood, Enum.Material.Wood)
		-- Samowar und Tassen (Compliance H-A6: Tee statt Bar)
		local urn = block(
			model,
			"Samovar",
			Vector3.new(1, 1.6, 1),
			at(c, box.cx + 2, box.h + 0.8, box.cz),
			Palette.metal,
			Enum.Material.Metal,
			false
		)
		urn.Shape = Enum.PartType.Cylinder
		urn.CFrame = at(c, box.cx + 2, box.h + 0.8, box.cz) * CFrame.Angles(0, 0, math.rad(90))
	elseif box.kind == "cratewall" or box.kind == "crate" then
		block(model, "Crates", size, cf, Palette.wood, Enum.Material.WoodPlanks)
	elseif box.kind == "shelf" then
		block(model, "Shelf", size, cf, Palette.woodDark, Enum.Material.Wood)
	elseif box.kind == "sofa" then
		block(
			model,
			"SofaBase",
			Vector3.new(box.sx, 1.4, box.sz),
			at(c, box.cx, 0.7, box.cz),
			Palette.leather,
			Enum.Material.Fabric
		)
		local backZ = box.cz + (if box.cz > 0 then 1 else -1) * (box.sz / 2 - 0.3)
		block(
			model,
			"SofaBack",
			Vector3.new(box.sx, box.h, 0.6),
			at(c, box.cx, box.h / 2, backZ),
			Palette.leather,
			Enum.Material.Fabric
		)
	elseif box.kind == "wall" then
		block(model, "Partition", size, cf, Palette.wallTrim, Enum.Material.Wood)
	else
		block(model, box.kind, size, cf, Palette.wood, Enum.Material.Wood)
	end
end

-- Innen- und Ausstiegsposition eines Verstecks (Welt), für Server und Kamera des Clients.
function TrainBuilder.spotFrames(c: Carriage, spot: Types.HidingSpot): (CFrame, CFrame, CFrame)
	local center = world(c, spot.x, 3, spot.z)
	local facing = Vector3.new(spot.fx, 0, spot.fz)
	local inside = CFrame.lookAt(center, center + facing)
	local depth = if spot.fx ~= 0 then spot.sx else spot.sz
	local eyePos = world(c, spot.x, 4.6, spot.z) + facing * (depth / 2 - 0.25)
	local eye = CFrame.lookAt(eyePos, eyePos + facing)
	local exitPos = world(c, spot.ax, 3, spot.az)
	local exit = CFrame.lookAt(exitPos, exitPos + facing)
	return inside, eye, exit
end

local function buildSpot(model: Model, c: Carriage, spot: Types.HidingSpot)
	local style = SPOT_STYLE[spot.kind] or SPOT_STYLE.wardrobe
	local spotModel = Instance.new("Model")
	spotModel.Name = "Hiding_" .. spot.id
	local body = block(
		spotModel,
		"Body",
		Vector3.new(spot.sx, spot.h, spot.sz),
		at(c, spot.x, spot.h / 2, spot.z),
		style.color,
		style.material
	)
	local facing = Vector3.new(spot.fx, 0, spot.fz)
	local depth = if spot.fx ~= 0 then spot.sx else spot.sz
	local width = if spot.fx ~= 0 then spot.sz else spot.sx
	local frontCenter = world(c, spot.x, spot.h / 2, spot.z) + facing * (depth / 2 + 0.05)
	local panelSize = if spot.fx ~= 0
		then Vector3.new(0.1, spot.h - 0.6, width - 0.4)
		else Vector3.new(width - 0.4, spot.h - 0.6, 0.1)
	block(spotModel, "Door", panelSize, CFrame.new(frontCenter), style.color:Lerp(Palette.cream, 0.15), style.material)
	-- Sehschlitze auf Augenhöhe
	for i = 0, 1 do
		local slitPos = frontCenter + Vector3.new(0, 4.4 - spot.h / 2 + i * 0.35, 0) + facing * 0.06
		local slitSize = if spot.fx ~= 0 then Vector3.new(0.05, 0.12, width - 1) else Vector3.new(width - 1, 0.12, 0.05)
		block(spotModel, "Slit", slitSize, CFrame.new(slitPos), Palette.hudShade, Enum.Material.SmoothPlastic, false)
	end
	local attachment = Instance.new("Attachment")
	attachment.WorldPosition = world(c, spot.x, 3, spot.z) + facing * (depth / 2 + 0.2)
	attachment.Parent = body
	local prompt = newPrompt(attachment, "Climb in", style.text, 0, 6)
	registerPrompt(prompt, "hide", c.index, spot.id)
	local _, eye = TrainBuilder.spotFrames(c, spot)
	spotModel:SetAttribute("EyeCFrame", eye)
	spotModel:SetAttribute("SpotKey", c.index * 100 + spot.id)
	spotModel.Parent = model
end

local function buildContainer(model: Model, c: Carriage, container: Types.Container)
	local holder: BasePart
	if container.kind == "rack" then
		block(
			model,
			"RackBar",
			Vector3.new(3, 0.2, 1.6),
			at(c, container.x, container.y - 0.6, container.z),
			Palette.metal,
			Enum.Material.Metal,
			false
		)
		holder = block(
			model,
			"Suitcase",
			Vector3.new(2, 1, 1.2),
			at(c, container.x, container.y, container.z),
			Palette.leather,
			Enum.Material.Fabric,
			false
		)
	elseif container.kind == "suitcase" then
		holder = block(
			model,
			"Suitcase",
			Vector3.new(2.2, 0.8, 1.4),
			at(c, container.x, container.y, container.z),
			Palette.leather,
			Enum.Material.Fabric,
			false
		)
	elseif container.kind == "crate" then
		holder = block(
			model,
			"CrateLid",
			Vector3.new(2.2, 0.2, 2.2),
			at(c, container.x, container.y, container.z),
			Palette.woodDark,
			Enum.Material.WoodPlanks,
			false
		)
	else
		holder = block(
			model,
			"Drawer",
			Vector3.new(1.4, 0.6, 0.3),
			at(c, container.x, container.y, container.z),
			Palette.cream,
			Enum.Material.Wood,
			false
		)
	end
	holder:SetAttribute("ContainerId", container.id)
	local attachment = Instance.new("Attachment")
	attachment.Parent = holder
	local prompt = newPrompt(attachment, "Search", CONTAINER_TEXT[container.kind] or "Drawer", 0.35, 8)
	registerPrompt(prompt, "container", c.index, container.id)
end

local function buildLamps(model: Model, c: Carriage)
	for _, lamp in c.lamps do
		local fixture = block(
			model,
			"Lamp",
			Vector3.new(1.6, 0.3, 0.8),
			at(c, lamp.x, HEIGHT - 0.35, lamp.z),
			if c.dark then Palette.lampOff else Palette.lampOn,
			if c.dark then Enum.Material.SmoothPlastic else Enum.Material.Neon,
			false
		)
		local light = Instance.new("PointLight")
		light.Range = 16
		light.Brightness = 1.1
		light.Color = Palette.lampLight
		light.Shadows = true
		light.Enabled = not c.dark
		light.Parent = fixture
		fixture:SetAttribute("Carriage", c.index)
		CollectionService:AddTag(fixture, TrainBuilder.LAMP_TAG)
	end
end

local function buildEyes(model: Model, c: Carriage)
	for _, eye in c.eyes do
		local eyesModel = Instance.new("Model")
		eyesModel.Name = "Eyes_" .. eye.id
		for _, dx in { -0.22, 0.22 } do
			local dot = block(
				eyesModel,
				"Eye",
				Vector3.new(0.22, 0.22, 0.22),
				at(c, eye.x + dx, eye.y, eye.z),
				Palette.eyes,
				Enum.Material.Neon,
				false
			)
			dot.Shape = Enum.PartType.Ball
			dot.CastShadow = false
		end
		eyesModel:SetAttribute("Carriage", c.index)
		eyesModel:SetAttribute("EyeId", eye.id)
		eyesModel:SetAttribute("Used", false)
		CollectionService:AddTag(eyesModel, TrainBuilder.EYES_TAG)
		eyesModel.Parent = model
	end
end

-- Tür n sitzt an der Front von Wagen n − 1; zwei Schiebeflügel, Schablonennummer, Schloss-Lampe.
local function buildDoor(c: Carriage, door: number, isGate: boolean)
	local doorModel = Instance.new("Model")
	doorModel.Name = string.format("Door_%02d", door)
	local x = c.length + 0.35
	for _, side in { 1, -1 } do
		local panel = block(
			doorModel,
			if side == 1 then "PanelLeft" else "PanelRight",
			Vector3.new(0.3, DOOR_H, DOOR_HALF),
			at(c, x, DOOR_H / 2, side * DOOR_HALF / 2),
			if isGate then Palette.metal else Palette.wallTrim,
			if isGate then Enum.Material.DiamondPlate else Enum.Material.Wood
		)
		panel:SetAttribute("Side", side)
		panel:SetAttribute("ClosedZ", side * DOOR_HALF / 2)
	end
	local sign = block(
		doorModel,
		"Sign",
		Vector3.new(0.1, 1.2, 2.4),
		at(c, c.length - WALL / 2 - 0.06, DOOR_H + 0.9, 0),
		Palette.hudShade,
		Enum.Material.SmoothPlastic,
		false
	)
	stencil(sign, Enum.NormalId.Left, string.format("%02d", door))
	block(
		doorModel,
		"LockLamp",
		Vector3.new(0.15, 0.5, 0.5),
		at(c, c.length - WALL / 2 - 0.08, 4, DOOR_HALF + 0.6),
		Palette.lampOff,
		Enum.Material.SmoothPlastic,
		false
	)
	doorModel:SetAttribute("Door", door)
	doorModel:SetAttribute("Open", false)
	doorModel.Parent = folder()
	doorModels[door] = doorModel
end

local function buildPost(model: Model, c: Carriage)
	local post = c.post
	if post == nil then
		return
	end
	for _, fragment in post.fragments do
		local paper = block(
			model,
			"Fragment_" .. fragment.row,
			Vector3.new(1.4, 0.9, 0.06),
			at(c, fragment.x, fragment.y, fragment.z),
			Palette.ticket,
			Enum.Material.SmoothPlastic,
			false
		)
		local face = if fragment.z > 0 then Enum.NormalId.Back else Enum.NormalId.Front
		local gui = Instance.new("SurfaceGui")
		gui.Face = face
		gui.SizingMode = Enum.SurfaceGuiSizingMode.PixelsPerStud
		gui.PixelsPerStud = 60
		gui.Parent = paper
		local label = Instance.new("TextLabel")
		label.BackgroundTransparency = 1
		label.Size = UDim2.fromScale(1, 0.35)
		label.Text = tostring(fragment.row)
		label.TextScaled = true
		label.Font = Enum.Font.SpecialElite
		label.TextColor3 = Palette.ticketInk
		label.Parent = gui
		for column = 1, 3 do
			local hole = Instance.new("Frame")
			hole.AnchorPoint = Vector2.new(0.5, 0.5)
			hole.Position = UDim2.fromScale(0.2 + (column - 1) * 0.3, 0.68)
			hole.Size = UDim2.fromScale(0.18, 0.4)
			local punched = bit32.band(fragment.holes, bit32.lshift(1, column - 1)) ~= 0
			hole.BackgroundColor3 = if punched then Palette.hudShade else Palette.ticket
			hole.BorderSizePixel = 0
			local stroke = Instance.new("UIStroke")
			stroke.Color = Palette.ticketInk
			stroke.Thickness = 2
			stroke.Parent = hole
			local corner = Instance.new("UICorner")
			corner.CornerRadius = UDim.new(0.5, 0)
			corner.Parent = hole
			hole.Parent = gui
		end
		local attachment = Instance.new("Attachment")
		attachment.Parent = paper
		local prompt = newPrompt(attachment, "Read", "Ticket scrap", 0.2, 7)
		registerPrompt(prompt, "fragment", c.index, fragment.row)
	end
	local validator = block(
		model,
		"Validator",
		Vector3.new(0.8, 2.2, 1.4),
		at(c, post.validatorX, 4, post.validatorZ),
		Palette.metal,
		Enum.Material.Metal
	)
	local slot = block(
		model,
		"ValidatorSlot",
		Vector3.new(0.1, 0.25, 0.9),
		at(c, post.validatorX - 0.42, 4.4, post.validatorZ),
		Palette.lampOn,
		Enum.Material.Neon,
		false
	)
	slot.CastShadow = false
	local attachment = Instance.new("Attachment")
	attachment.Parent = validator
	local prompt = newPrompt(attachment, "Punch ticket", "Ticket validator", 0, 7)
	registerPrompt(prompt, "validator", c.index, 1)
	-- Ankunftsbahnsteig hinter dem Tor
	local exitFloor = block(
		model,
		"ArrivalPlatform",
		Vector3.new(16, 1, 14),
		at(c, c.length + 8, -0.5, 0),
		Palette.platform,
		Enum.Material.Concrete
	)
	local glow = Instance.new("PointLight")
	glow.Range = 20
	glow.Brightness = 1.5
	glow.Color = Palette.lampLight
	glow.Parent = exitFloor
	-- Unsichtbare Absperrung um den Ankunftsbahnsteig (Seiten und Ende)
	local barriers: { { size: Vector3, x: number, z: number } } = {
		{ size = Vector3.new(16, 12, 1), x = c.length + 8, z = 7.5 },
		{ size = Vector3.new(16, 12, 1), x = c.length + 8, z = -7.5 },
		{ size = Vector3.new(1, 12, 16), x = c.length + 16.5, z = 0 },
	}
	for _, spec in barriers do
		local barrier = block(
			model,
			"ArrivalBarrier",
			spec.size,
			at(c, spec.x, 6, spec.z),
			Palette.platform,
			Enum.Material.SmoothPlastic
		)
		barrier.Transparency = 1
	end
end

-- Baut Wagen c (idempotent). Die Tür an seiner Front (Tür c.index + 1) bzw. das Tor des Postwagens gehört dazu.
function TrainBuilder.build(c: Carriage, lastIndex: number): Model
	local existing = carriageModels[c.index]
	if existing then
		return existing
	end
	local model = Instance.new("Model")
	model.Name = string.format("Carriage_%02d", c.index)
	model:SetAttribute("Index", c.index)
	model:SetAttribute("Kind", c.kind)
	model:SetAttribute("Dark", c.dark)
	model:SetAttribute("OriginX", c.originX)
	model:SetAttribute("Length", c.length)
	buildShell(model, c)
	for _, box in c.obstacles do
		buildObstacle(model, c, box)
	end
	for _, spot in c.hidingSpots do
		buildSpot(model, c, spot)
	end
	for _, container in c.containers do
		buildContainer(model, c, container)
	end
	buildLamps(model, c)
	buildEyes(model, c)
	buildPost(model, c)
	model.Parent = folder()
	carriageModels[c.index] = model
	if c.index == 0 then
		TrainBuilder.sealRear(0)
		-- Fahrgastinformation: Zeichen → Reaktion (Text zeichnet der Client lokalisiert, Playtest LP-06)
		local board = block(
			model,
			"InfoBoard",
			Vector3.new(16, 3.6, 0.15),
			at(c, 20, 5.3, -(HALF - 0.05)),
			Palette.ticket,
			Enum.Material.SmoothPlastic,
			false
		)
		CollectionService:AddTag(board, TrainBuilder.INFO_TAG)
	end
	buildDoor(c, c.index + 1, c.index == lastIndex)
	if c.locked then
		TrainBuilder.setLocked(c.index + 1, true)
	end
	return model
end

-- Verschließt die hintere Türöffnung eines Wagens (Wagen 0 immer; nach dem Abkoppeln der älteste Wagen),
-- damit niemand aus dem Zug ins Leere läuft.
function TrainBuilder.sealRear(index: number)
	local model = carriageModels[index]
	if model == nil or model:FindFirstChild("RearSeal") then
		return
	end
	local origin = model:GetAttribute("OriginX")
	if type(origin) ~= "number" then
		return
	end
	local seal = Instance.new("Part")
	seal.Name = "RearSeal"
	seal.Anchored = true
	seal.Size = Vector3.new(WALL, DOOR_H, 2 * DOOR_HALF)
	seal.CFrame = CFrame.new(origin, FLOOR_Y + DOOR_H / 2, 0)
	seal.Color = Palette.wallTrim
	seal.Material = Enum.Material.Wood
	seal.TopSurface = Enum.SurfaceType.Smooth
	seal.BottomSurface = Enum.SurfaceType.Smooth
	seal.Parent = model
end

function TrainBuilder.remove(index: number)
	local model = carriageModels[index]
	if model then
		model:Destroy()
		carriageModels[index] = nil
	end
	local door = doorModels[index + 1]
	if door then
		door:Destroy()
		doorModels[index + 1] = nil
	end
	for key in promptLookup do
		local _, carriage = string.match(key, "^(%a+):(%-?%d+):")
		if tonumber(carriage) == index then
			promptLookup[key] = nil
		end
	end
end

function TrainBuilder.clear()
	for index in carriageModels do
		TrainBuilder.remove(index)
	end
	table.clear(promptLookup)
	local f = trainFolder
	if f then
		f:Destroy()
		trainFolder = nil
	end
end

function TrainBuilder.setDoorOpen(door: number, open: boolean)
	local doorModel = doorModels[door]
	if doorModel == nil or doorModel:GetAttribute("Open") == open then
		return
	end
	doorModel:SetAttribute("Open", open)
	for _, child in doorModel:GetChildren() do
		local side = child:GetAttribute("Side")
		local closedZ = child:GetAttribute("ClosedZ")
		if child:IsA("BasePart") and type(side) == "number" and type(closedZ) == "number" then
			child.CanCollide = not open
			local target = Vector3.new(
				child.Position.X,
				child.Position.Y,
				if open then closedZ + side * DOOR_HALF * 0.95 else closedZ
			)
			TweenService:Create(child, TweenInfo.new(0.35, Enum.EasingStyle.Quad), { Position = target }):Play()
		end
	end
end

function TrainBuilder.setLocked(door: number, locked: boolean)
	local doorModel = doorModels[door]
	local lamp = if doorModel then doorModel:FindFirstChild("LockLamp") else nil
	if lamp and lamp:IsA("BasePart") then
		lamp.Color = if locked then Palette.lampOn else Palette.lampOff
		lamp.Material = if locked then Enum.Material.Neon else Enum.Material.SmoothPlastic
	end
	if doorModel then
		doorModel:SetAttribute("Locked", locked)
		-- Schloss-Form auf dem Türflügel (zweites Merkmal neben der Lampe, Playtest LP-14)
		local existing = doorModel:FindFirstChild("Padlock")
		if locked and existing == nil then
			local panel = doorModel:FindFirstChild("PanelLeft")
			if panel and panel:IsA("BasePart") then
				local padlock = Instance.new("Model")
				padlock.Name = "Padlock"
				local front = panel.Position - Vector3.new(0.2, 0, 0)
				local body = block(
					padlock,
					"Body",
					Vector3.new(0.1, 1, 1.1),
					CFrame.new(front + Vector3.new(0, 0.2, -0.6)),
					Palette.stencil,
					Enum.Material.SmoothPlastic,
					false
				)
				body.CastShadow = false
				for _, dz in { -0.35, 0.35 } do
					block(
						padlock,
						"Shackle",
						Vector3.new(0.1, 0.6, 0.15),
						CFrame.new(front + Vector3.new(0, 0.95, -0.6 + dz)),
						Palette.stencil,
						Enum.Material.SmoothPlastic,
						false
					)
				end
				block(
					padlock,
					"ShackleTop",
					Vector3.new(0.1, 0.15, 0.85),
					CFrame.new(front + Vector3.new(0, 1.25, -0.6)),
					Palette.stencil,
					Enum.Material.SmoothPlastic,
					false
				)
				padlock.Parent = doorModel
			end
		elseif not locked and existing then
			existing:Destroy()
		end
	end
end

function TrainBuilder.prompt(kind: string, carriage: number, id: number): ProximityPrompt?
	return promptLookup[promptKey(kind, carriage, id)]
end

function TrainBuilder.markContainerOpened(carriage: number, id: number)
	local prompt = TrainBuilder.prompt("container", carriage, id)
	if prompt then
		prompt.Enabled = false
		local holder = prompt.Parent and prompt.Parent.Parent
		if holder and holder:IsA("BasePart") then
			holder.Color = holder.Color:Lerp(Palette.hudShade, 0.5)
		end
	end
end

function TrainBuilder.markEyesUsed(carriage: number, id: number)
	local model = carriageModels[carriage]
	local eyes = if model then model:FindFirstChild("Eyes_" .. id) else nil
	if eyes then
		eyes:SetAttribute("Used", true)
	end
end

function TrainBuilder.carriageModel(index: number): Model?
	return carriageModels[index]
end

function TrainBuilder.builtIndices(): { number }
	local list: { number } = {}
	for index in carriageModels do
		table.insert(list, index)
	end
	table.sort(list)
	return list
end

-- Kupplung der Kofferlawine (Compliance H-A17) im Übergang an der Front von Wagen c:
-- Hebel an der Balgwand. Der Prompt ist aus, bis der Server ihn freigibt (alle Lebenden vorbei).
function TrainBuilder.buildCoupling(c: Carriage)
	local model = carriageModels[c.index]
	if model == nil or model:FindFirstChild("Coupling") then
		return
	end
	local coupling = Instance.new("Model")
	coupling.Name = "Coupling"
	local x = c.length + GameConfig.CHASE_COUPLING_OFFSET
	local base = block(
		coupling,
		"LeverBase",
		Vector3.new(0.6, 1.4, 0.4),
		at(c, x, 3.4, 2.75),
		Palette.metal,
		Enum.Material.Metal,
		false
	)
	local handle = block(
		coupling,
		"LeverHandle",
		Vector3.new(0.3, 1.2, 0.3),
		at(c, x, 4.5, 2.6),
		Palette.lampOff,
		Enum.Material.SmoothPlastic,
		false
	)
	handle.CFrame = handle.CFrame * CFrame.Angles(math.rad(-25), 0, 0)
	local attachment = Instance.new("Attachment")
	attachment.Parent = base
	local prompt = newPrompt(attachment, "Uncouple", "Coupling", 1, 7)
	prompt.Enabled = false
	registerPrompt(prompt, "coupling", c.index, 1)
	coupling.Parent = model
end

-- Hebel leuchtet, solange Abkoppeln möglich ist (Licht als Zeichen, S1).
function TrainBuilder.setCouplingReady(index: number, ready: boolean)
	local prompt = TrainBuilder.prompt("coupling", index, 1)
	if prompt then
		prompt.Enabled = ready
	end
	local model = carriageModels[index]
	local coupling = if model then model:FindFirstChild("Coupling") else nil
	local handle = if coupling then coupling:FindFirstChild("LeverHandle") else nil
	if handle and handle:IsA("BasePart") then
		handle.Color = if ready then Palette.chase else Palette.lampOff
		handle.Material = if ready then Enum.Material.Neon else Enum.Material.SmoothPlastic
	end
end

-- Kontrolleur: Silhouette in Uniform mit Laterne und Kelle (Form + Farbe), kollisionsfrei.
function TrainBuilder.buildInspector(c: Carriage): Model
	local model = Instance.new("Model")
	model.Name = "Inspector"
	local x = c.length - GameConfig.INSPECTOR_X_FROM_FRONT
	local z = GameConfig.INSPECTOR_Z
	local coat =
		block(model, "Coat", Vector3.new(1.2, 5.2, 2), at(c, x, 2.6, z), Palette.hudShade, Enum.Material.Fabric, false)
	block(
		model,
		"Head",
		Vector3.new(1.1, 1.1, 1.1),
		at(c, x, 5.85, z),
		Palette.hudShade,
		Enum.Material.SmoothPlastic,
		false
	)
	block(model, "Cap", Vector3.new(1.5, 0.35, 1.5), at(c, x, 6.55, z), Palette.wallTrim, Enum.Material.Fabric, false)
	local lantern = block(
		model,
		"Lantern",
		Vector3.new(0.6, 0.8, 0.6),
		at(c, x - 0.6, 3, z + 1.3),
		Palette.inspectorGo,
		Enum.Material.Neon,
		false
	)
	local light = Instance.new("PointLight")
	light.Range = 14
	light.Brightness = 1.4
	light.Color = Palette.inspectorGo
	light.Parent = lantern
	local disc = block(
		model,
		"PaddleRound",
		Vector3.new(0.15, 1.4, 1.4),
		at(c, x - 0.7, 5.6, z - 1.3),
		Palette.inspectorGo,
		Enum.Material.SmoothPlastic,
		false
	)
	disc.Shape = Enum.PartType.Cylinder
	local bar = block(
		model,
		"PaddleStripe",
		Vector3.new(0.15, 0.45, 1.8),
		at(c, x - 0.7, 5.6, z - 1.3),
		Palette.inspectorStop,
		Enum.Material.SmoothPlastic,
		false
	)
	bar.Transparency = 1
	block(
		model,
		"Handle",
		Vector3.new(0.12, 1.2, 0.12),
		at(c, x - 0.7, 4.6, z - 1.3),
		Palette.metal,
		Enum.Material.Metal,
		false
	)
	for _, child in model:GetDescendants() do
		if child:IsA("BasePart") then
			child.CastShadow = child ~= coat
		end
	end
	model:SetAttribute("Phase", "intro")
	model:SetAttribute("Carriage", c.index)
	model.Parent = carriageModels[c.index] or folder()
	return model
end

-- Schaffner: große Silhouette in Uniform, Kopflampe mit Lichtkegel, kein Gesicht (Compliance H-A2/H-A3).
-- Der Server bewegt ihn nicht; die Clients zeichnen ihn entlang der gesendeten Wege.
function TrainBuilder.buildConductor(c: Carriage, x: number, z: number): Model
	local model = Instance.new("Model")
	model.Name = "Conductor"
	local root = block(
		model,
		"Root",
		Vector3.new(1.4, 7.6, 1.4),
		at(c, x, 3.8, z),
		Palette.hudShade,
		Enum.Material.Fabric,
		false
	)
	-- Gebaut mit Blick nach −Z (Roblox-Vorderseite); PivotTo dreht danach in Laufrichtung.
	block(
		model,
		"Shoulders",
		Vector3.new(2.6, 0.8, 1.6),
		at(c, x, 7.2, z),
		Palette.hudShade,
		Enum.Material.Fabric,
		false
	)
	block(model, "Cap", Vector3.new(1.6, 0.5, 1.6), at(c, x, 8.6, z), Palette.wallTrim, Enum.Material.Fabric, false)
	local lamp = block(
		model,
		"HeadLamp",
		Vector3.new(0.4, 0.4, 0.4),
		at(c, x, 8.2, z - 0.8),
		Palette.conductorBeam,
		Enum.Material.Neon,
		false
	)
	local beam = Instance.new("SpotLight")
	beam.Face = Enum.NormalId.Front
	beam.Angle = GameConfig.CONDUCTOR_VIEW_ANGLE * 2
	beam.Range = GameConfig.CONDUCTOR_VIEW_DISTANCE + 2
	beam.Brightness = 3
	beam.Color = Palette.conductorBeam
	beam.Shadows = true
	beam.Parent = lamp
	for _, child in model:GetChildren() do
		if child:IsA("BasePart") and child ~= root then
			local weld = Instance.new("WeldConstraint")
			weld.Part0 = root
			weld.Part1 = child
			weld.Parent = root
		end
	end
	model.PrimaryPart = root
	model:PivotTo(CFrame.lookAt(root.Position, root.Position + Vector3.new(-1, 0, 0)))
	model.Parent = carriageModels[c.index] or folder()
	return model
end

return TrainBuilder
