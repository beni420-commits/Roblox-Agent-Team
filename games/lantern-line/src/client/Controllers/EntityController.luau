--!strict
-- Darstellung der Wesen nach den Fahrplänen des Servers (gleiche Logik wie dort, nur Optik):
-- Express (weißes Licht + schwingende Lampen + Warnleiste), Gegenzug (blaues Seitenlicht + Pfeil +
-- markierte Gefahrenhälfte), Kofferlawine (rumpelnde Kofferwand), Schaffner (Weg-Interpolation),
-- Kontrolleur (Kelle + Laterne), Augen (hell in der Nähe). Lichtwesen ohne Gesicht/Partikelkörper (H-A2).

local CollectionService = game:GetService("CollectionService")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")

local AmbienceController = require("./AmbienceController")
local Context = require("./Context")
local GameConfig = require("@game/ReplicatedStorage/Shared/Config/GameConfig")
local Hud = require("./Hud")
local Palette = require("@game/ReplicatedStorage/Shared/Visual/Palette")
local Sweep = require("@game/ReplicatedStorage/Shared/Logic/Sweep")
local Settings = require("./Settings")
local TrainView = require("./TrainView")

local EntityController = {}

local HALF = GameConfig.INNER_WIDTH / 2
local EYES_TAG = "LanternLineEyes"

type Mover = { schedule: Sweep.Schedule, model: Model }
type ConductorPath = {
	originX: number,
	x: number,
	z: number,
	fx: number,
	fz: number,
	speed: number,
	points: { { x: number, z: number } },
	at: number,
}

local movers: { Mover } = {}
local oncomingParts: { BasePart } = {}
local oncomingUntil = 0
local conductorPath: ConductorPath? = nil
local localStuff: Folder

local function part(parent: Instance, size: Vector3, color: Color3, material: Enum.Material): Part
	local p = Instance.new("Part")
	p.Anchored = true
	p.CanCollide = false
	p.CanQuery = false
	p.CanTouch = false
	p.Size = size
	p.Color = color
	p.Material = material
	p.Parent = parent
	return p
end

local function scheduleOf(payload: any, kind: string): Sweep.Schedule
	return {
		kind = kind,
		carriage = payload.carriage,
		warnAt = payload.warnAt,
		startAt = payload.startAt,
		endAt = payload.endAt,
		x0 = payload.x0,
		x1 = payload.x1,
	}
end

local function lowestCarriage(): number
	local train = TrainView.folder()
	local lowest = math.huge
	if train then
		for _, model in train:GetChildren() do
			local index = model:GetAttribute("Index")
			if type(index) == "number" then
				lowest = math.min(lowest, index)
			end
		end
	end
	return if lowest == math.huge then 0 else lowest
end

-- Express: kleiner Lichtkern über Augenhöhe mit weichem Hof. Nahe an der Kamera blendet er aus,
-- damit er nie das ganze Bild weiß füllt (Compliance H-A10 d, H-A16).
local EXPRESS_FADE_DISTANCE = 12

local function onExpress(payload: any)
	local schedule = scheduleOf(payload, "express")
	local model = Instance.new("Model")
	model.Name = "Express"
	local gentle = Settings.gentle()
	local core = part(model, Vector3.new(3.5, 3.5, 3.5), Palette.express, Enum.Material.Neon)
	core.Shape = Enum.PartType.Ball
	core.Transparency = if gentle then 0.6 else 0.35
	core:SetAttribute("BaseTransparency", core.Transparency)
	local halo = part(model, Vector3.new(7, 7, 7), Palette.express, Enum.Material.Neon)
	halo.Shape = Enum.PartType.Ball
	halo.Transparency = 0.93
	halo:SetAttribute("BaseTransparency", halo.Transparency)
	local light = Instance.new("PointLight")
	light.Range = 30
	light.Brightness = if gentle then 1.2 else 2
	light.Color = Palette.express
	light.Parent = core
	core.CFrame = CFrame.identity
	halo.CFrame = CFrame.identity
	model.WorldPivot = CFrame.identity
	model:PivotTo(CFrame.new(schedule.x0, GameConfig.FLOOR_Y + 6.5, 0))
	model.Parent = localStuff
	table.insert(movers, { schedule = schedule, model = model })
	AmbienceController.addEffect(
		payload.flickerSeed,
		schedule.warnAt,
		schedule.endAt,
		lowestCarriage(),
		schedule.carriage,
		true,
		nil
	)
	-- Warnungen nur für Mitfahrer und Zuschauer, nicht am Bahnsteig (LL-17)
	if Context.inRun() then
		Hud.setWarning(
			Palette.express,
			schedule.startAt + (schedule.x1 - schedule.x0) / 2 / GameConfig.EXPRESS_SPEED,
			"express"
		)
	end
end

local function fadeNearCamera(model: Model)
	local camera = workspace.CurrentCamera
	for _, child in model:GetChildren() do
		local base = child:GetAttribute("BaseTransparency")
		if child:IsA("BasePart") and type(base) == "number" then
			local d = (child.Position - camera.CFrame.Position).Magnitude
			local k = math.clamp((EXPRESS_FADE_DISTANCE - d) / EXPRESS_FADE_DISTANCE, 0, 1)
			child.Transparency = base + (0.97 - base) * k
		end
	end
end

local function onChase(payload: any)
	local schedule = scheduleOf(payload, "chase")
	local model = Instance.new("Model")
	model.Name = "LuggageAvalanche"
	local rng = Random.new(payload.flickerSeed)
	local colors = { Palette.leather, Palette.wood, Palette.woodDark, Palette.cream }
	for row = 0, 3 do
		for column = -3, 3 do
			local size = Vector3.new(rng:NextNumber(1.2, 2), rng:NextNumber(1.4, 2.4), rng:NextNumber(1.4, 2.2))
			local p = part(model, size, colors[rng:NextInteger(1, #colors)], Enum.Material.Fabric)
			p.CFrame = CFrame.new(0, 1.2 + row * 2.4, column * 1.6)
				* CFrame.Angles(rng:NextNumber(-0.4, 0.4), rng:NextNumber(-0.6, 0.6), rng:NextNumber(-0.4, 0.4))
		end
	end
	local glow = part(model, Vector3.new(0.5, 0.5, 0.5), Palette.chase, Enum.Material.Neon)
	glow.CFrame = CFrame.new(-2, 5, 0)
	glow.Transparency = 1
	local light = Instance.new("PointLight")
	light.Range = 24
	light.Brightness = 2
	light.Color = Palette.chase
	light.Parent = glow
	model.WorldPivot = CFrame.identity
	model:PivotTo(CFrame.new(schedule.x0, GameConfig.FLOOR_Y, 0))
	model.Parent = localStuff
	table.insert(movers, { schedule = schedule, model = model })
	AmbienceController.addEffect(
		payload.flickerSeed,
		schedule.warnAt,
		schedule.startAt + 2,
		lowestCarriage(),
		schedule.carriage,
		false,
		Palette.chase
	)
	if Context.inRun() then
		Hud.setWarning(Palette.chase, schedule.endAt, "chase")
	end
end

-- Gegenzug: ruhiges Licht an festen Fensterpositionen, schwillt weich an und ab (keine Lichtwechsel,
-- Compliance H-A16). Zweites Merkmal: markierte Bodenhälfte + Pfeil im HUD (H-A11).
local ONCOMING_FADE = 0.35

local function onOncoming(payload: any)
	oncomingUntil = payload.endAt + ONCOMING_FADE
	if Context.inRun() then
		Hud.setOncoming(payload.side, payload.endAt)
	end
	local band = part(
		localStuff,
		Vector3.new(payload.x1 - payload.x0, 0.06, HALF + GameConfig.ONCOMING_SAFE_Z),
		Palette.oncoming,
		Enum.Material.Neon
	)
	band.CFrame = CFrame.new(
		(payload.x0 + payload.x1) / 2,
		GameConfig.FLOOR_Y + 0.04,
		payload.side * (HALF - (HALF + GameConfig.ONCOMING_SAFE_Z) / 2)
	)
	band.Transparency = 0.82
	table.insert(oncomingParts, band)
	local root = Context.root()
	local centerX = if root then root.Position.X else (payload.x0 + payload.x1) / 2
	for i = -3, 3 do
		local x = math.clamp(centerX + i * 16, payload.x0, payload.x1)
		local glow = part(localStuff, Vector3.new(1, 1, 1), Palette.oncoming, Enum.Material.SmoothPlastic)
		glow.Transparency = 1
		glow.CFrame = CFrame.new(x, GameConfig.FLOOR_Y + 5, payload.side * (HALF + 3))
		glow:SetAttribute("HitAt", payload.hitAt)
		glow:SetAttribute("WarnAt", payload.warnAt)
		glow:SetAttribute("EndAt", payload.endAt)
		local light = Instance.new("PointLight")
		light.Range = 24
		light.Brightness = 0
		light.Color = Palette.oncoming
		light.Parent = glow
		table.insert(oncomingParts, glow)
	end
end

local function updateOncoming(t: number)
	if #oncomingParts == 0 then
		return
	end
	if t > oncomingUntil then
		for _, p in oncomingParts do
			p:Destroy()
		end
		table.clear(oncomingParts)
		return
	end
	local scale = if Settings.gentle() then 0.6 else 1
	for _, p in oncomingParts do
		local hitAt = p:GetAttribute("HitAt")
		local warnAt = p:GetAttribute("WarnAt")
		local endAt = p:GetAttribute("EndAt")
		local light = p:FindFirstChildOfClass("PointLight")
		if type(hitAt) == "number" and type(warnAt) == "number" and type(endAt) == "number" and light then
			-- stetig: Warnphase 0 → 1,2; Trefferphase weich auf 3; danach weich aus (nie ein Sprung)
			local brightness
			if t < hitAt then
				brightness = 1.2 * math.clamp((t - warnAt) / math.max(0.1, hitAt - warnAt), 0, 1)
			elseif t <= endAt then
				brightness = 1.2 + 1.8 * math.clamp((t - hitAt) / ONCOMING_FADE, 0, 1)
			else
				brightness = 3 * math.clamp(1 - (t - endAt) / ONCOMING_FADE, 0, 1)
			end
			light.Brightness = brightness * scale
		end
	end
end

local function updateMovers(t: number)
	for i = #movers, 1, -1 do
		local mover = movers[i]
		local x = Sweep.positionAt(mover.schedule, t)
		if t > mover.schedule.endAt then
			mover.model:Destroy()
			table.remove(movers, i)
		elseif x then
			local jitter = if mover.schedule.kind == "chase" and Settings.motionAllowed()
				then CFrame.Angles(0, 0, math.rad(4) * math.sin(t * 9))
				else CFrame.identity
			local y = if mover.schedule.kind == "express" then 6.5 else 0
			mover.model:PivotTo(CFrame.new(x, GameConfig.FLOOR_Y + y, 0) * jitter)
			if mover.schedule.kind == "express" then
				fadeNearCamera(mover.model)
			end
		end
	end
end

-- Schaffner: Position entlang des zuletzt gesendeten Wegs (lokale Koordinaten + originX).
local function conductorModel(): Model?
	local post = TrainView.carriageModel(GameConfig.RUN_LAST_CARRIAGE)
	local model = if post then post:FindFirstChild("Conductor") else nil
	return if model and model:IsA("Model") then model else nil
end

local function updateConductor(t: number)
	local path = conductorPath
	local model = conductorModel()
	if path == nil or model == nil then
		return
	end
	local x, z = path.x, path.z
	local fx, fz = path.fx, path.fz
	local remaining = path.speed * math.max(0, t - path.at)
	for _, wp in path.points do
		local dx, dz = wp.x - x, wp.z - z
		local d = math.sqrt(dx * dx + dz * dz)
		if d > 1e-6 then
			fx, fz = dx / d, dz / d
		end
		if d <= remaining then
			x, z = wp.x, wp.z
			remaining -= d
		else
			x += dx / d * remaining
			z += dz / d * remaining
			break
		end
	end
	local position = Vector3.new(path.originX + x, GameConfig.FLOOR_Y + 3.8, z)
	model:PivotTo(CFrame.lookAt(position, position + Vector3.new(fx, 0, fz)))
end

local function styleInspector(model: Model)
	local function apply()
		local phase = model:GetAttribute("Phase")
		local round = model:FindFirstChild("PaddleRound")
		local stripe = model:FindFirstChild("PaddleStripe")
		local lantern = model:FindFirstChild("Lantern")
		if
			not (
				round
				and stripe
				and lantern
				and round:IsA("BasePart")
				and stripe:IsA("BasePart")
				and lantern:IsA("BasePart")
			)
		then
			return
		end
		local light = lantern:FindFirstChildOfClass("PointLight")
		local stop = phase == "stop"
		round.Transparency = if stop then 1 else 0
		stripe.Transparency = if stop then 0 else 1
		-- Laterne wechselt die Farbe weich (kein Flackern, Compliance H-A10 b)
		local target = if stop
			then Palette.inspectorStop
			elseif phase == "warn" then Palette.inspectorGo:Lerp(Palette.inspectorStop, 0.5)
			else Palette.inspectorGo
		local duration = if phase == "warn" then GameConfig.INSPECTOR_WARN else 0.3
		TweenService:Create(lantern, TweenInfo.new(duration), { Color = target }):Play()
		if light then
			TweenService:Create(light, TweenInfo.new(duration), { Color = target }):Play()
		end
		if phase == "gone" then
			for _, child in model:GetDescendants() do
				if child:IsA("BasePart") then
					TweenService:Create(child, TweenInfo.new(1), { Transparency = 1 }):Play()
				end
			end
		end
	end
	model:GetAttributeChangedSignal("Phase"):Connect(apply)
	apply()
end

-- Augen werden in der Nähe weich heller (0,5 s statt Umschalten, Playtest LP-17).
local function updateEyes(dt: number)
	local root = Context.root()
	local k = math.clamp(dt * 4, 0, 1)
	for _, eyes in CollectionService:GetTagged(EYES_TAG) do
		local used = eyes:GetAttribute("Used") == true
		for _, dot in eyes:GetChildren() do
			if dot:IsA("BasePart") then
				if used then
					dot.Transparency = 1
				elseif root then
					local d = (dot.Position - root.Position).Magnitude
					local awake = d < GameConfig.EYES_WAKE_RADIUS
					local target = if awake then 0 else 0.55
					dot.Transparency += (target - dot.Transparency) * k
				end
			end
		end
	end
end

function EntityController.clear()
	for _, mover in movers do
		mover.model:Destroy()
	end
	table.clear(movers)
	for _, p in oncomingParts do
		p:Destroy()
	end
	table.clear(oncomingParts)
	conductorPath = nil
end

function EntityController.init()
	localStuff = Instance.new("Folder")
	localStuff.Name = "LocalEntities"
	localStuff.Parent = workspace
	Context.onWorld("express", onExpress)
	Context.onWorld("chase", onChase)
	Context.onWorld("oncoming", onOncoming)
	Context.onWorld("conductor", function(payload)
		conductorPath = payload
	end)
	Context.onWorld("chaseStop", function()
		-- Abgekoppelt: Die Kofferwand bleibt stehen und fällt mit den hinteren Wagen zurück.
		Hud.setWarning(Palette.chase, 0, "chase") -- Warnleiste sofort aus (LL-17)
		for i = #movers, 1, -1 do
			local mover = movers[i]
			if mover.schedule.kind == "chase" then
				table.remove(movers, i)
				local model = mover.model
				local start = model:GetPivot()
				task.spawn(function()
					local t0 = os.clock()
					while os.clock() - t0 < 2.5 and model.Parent do
						local k = (os.clock() - t0) / 2.5
						model:PivotTo(start * CFrame.new(-60 * k * k, -2 * k, 0))
						task.wait()
					end
					model:Destroy()
				end)
			end
		end
	end)
	Context.onWorld("reset", EntityController.clear)
	Context.onWorld("start", EntityController.clear)
	workspace.DescendantAdded:Connect(function(descendant)
		if descendant.Name == "Inspector" and descendant:IsA("Model") then
			task.defer(styleInspector, descendant)
		end
	end)
	RunService.Heartbeat:Connect(function()
		local t = Context.now()
		updateMovers(t)
		updateOncoming(t)
		updateConductor(t)
	end)
	RunService.Heartbeat:Connect(updateEyes)
end

return EntityController
