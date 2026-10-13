--!strict
-- Atmosphäre „Der Zug fährt“ (GDD S2): vorbeiziehende Lichter vor den Fenstern, leichtes Schwanken
-- (nur ohne „Bewegung reduzieren“/„Sanfter Modus“) und Lampen-Effekte bei Ereignissen.
-- Lampen flackern synchron nach EINEM Plan (FlickerPlanner, ≤ 2 Blitze/s, Compliance H-A10).

local CollectionService = game:GetService("CollectionService")
local RunService = game:GetService("RunService")

local Context = require("./Context")
local FlickerPlanner = require("@game/ReplicatedStorage/Shared/Logic/FlickerPlanner")
local Palette = require("@game/ReplicatedStorage/Shared/Visual/Palette")
local Settings = require("./Settings")

local AmbienceController = {}

local LAMP_TAG = "LanternLineLamp"
local PASSING_SPEED = 70
local PASSING_COUNT = 6

type Effect = {
	from: number,
	to: number,
	pulses: { FlickerPlanner.Pulse },
	minCarriage: number,
	maxCarriage: number,
	swing: boolean,
	tint: Color3?,
}

local effects: { Effect } = {}
local passing: { BasePart } = {}
local lampDefaults: { [BasePart]: { cframe: CFrame, color: Color3, brightness: number } } = {}

local function lampCarriage(lamp: BasePart): number
	local value = lamp:GetAttribute("Carriage")
	return if type(value) == "number" then value else -1
end

local function remember(lamp: BasePart)
	if lampDefaults[lamp] == nil then
		local light = lamp:FindFirstChildOfClass("PointLight")
		lampDefaults[lamp] = {
			cframe = lamp.CFrame,
			color = if light then light.Color else Palette.lampLight,
			brightness = if light then light.Brightness else 1,
		}
	end
end

-- Neuer Lampen-Effekt für Wagen [minCarriage, maxCarriage] im Zeitraum [from, to].
function AmbienceController.addEffect(
	seed: number,
	from: number,
	to: number,
	minCarriage: number,
	maxCarriage: number,
	swing: boolean,
	tint: Color3?
)
	table.insert(effects, {
		from = from,
		to = to,
		pulses = FlickerPlanner.pulses(seed, from, to),
		minCarriage = minCarriage,
		maxCarriage = maxCarriage,
		swing = swing,
		tint = tint,
	})
end

function AmbienceController.clear()
	table.clear(effects)
	table.clear(lampDefaults)
end

local function updateLamps(t: number)
	local reduced = Settings.reducedFlicker()
	local motion = Settings.motionAllowed()
	for _, lamp in CollectionService:GetTagged(LAMP_TAG) do
		if lamp:IsA("BasePart") and lamp.Parent then
			local index = lampCarriage(lamp)
			local level, swingAngle, tint = 1, 0, nil
			for _, effect in effects do
				if
					index >= effect.minCarriage
					and index <= effect.maxCarriage
					and t >= effect.from
					and t <= effect.to
				then
					level = math.min(level, FlickerPlanner.levelAt(effect.pulses, effect.from, effect.to, t, reduced))
					if effect.swing and motion then
						swingAngle = math.rad(12) * math.sin((t - effect.from) * math.pi * 1.6)
					end
					tint = effect.tint or tint
				end
			end
			local light = lamp:FindFirstChildOfClass("PointLight")
			if level < 1 or swingAngle ~= 0 or tint or lampDefaults[lamp] then
				remember(lamp)
				local defaults = lampDefaults[lamp]
				if light and light.Enabled then
					light.Brightness = defaults.brightness * level
					light.Color = if tint then defaults.color:Lerp(tint, 0.6) else defaults.color
				end
				lamp.CFrame = defaults.cframe * CFrame.Angles(swingAngle, 0, swingAngle * 0.5)
				if level >= 1 and swingAngle == 0 and tint == nil then
					lampDefaults[lamp] = nil
				end
			end
		end
	end
	for i = #effects, 1, -1 do
		if t > effects[i].to + 0.5 then
			table.remove(effects, i)
		end
	end
end

local function buildPassing()
	for i = 1, PASSING_COUNT do
		local p = Instance.new("Part")
		p.Name = "PassingLight"
		p.Anchored = true
		p.CanCollide = false
		p.CanQuery = false
		p.CanTouch = false
		p.CastShadow = false
		p.Material = Enum.Material.Neon
		p.Color = Palette.lampOn
		p.Size = Vector3.new(1.2, 1.2, 1.2)
		p.Shape = Enum.PartType.Ball
		local light = Instance.new("PointLight")
		light.Range = 20
		light.Brightness = 0.8
		light.Color = Palette.lampLight
		light.Parent = p
		p:SetAttribute("Offset", (i - 1) * (240 / PASSING_COUNT))
		p:SetAttribute("Side", if i % 2 == 0 then 1 else -1)
		p.Parent = workspace
		table.insert(passing, p)
	end
end

local function updatePassing()
	local root = Context.root()
	local active = Context.inRun() and root ~= nil
	for _, p in passing do
		if not active or root == nil then
			p.Transparency = 1
			local light = p:FindFirstChildOfClass("PointLight")
			if light then
				light.Enabled = false
			end
		else
			local offset = p:GetAttribute("Offset") :: number
			local side = p:GetAttribute("Side") :: number
			-- Lichter laufen von vorn nach hinten an der Figur vorbei (Fahrtrichtung +x).
			local phase = (os.clock() * PASSING_SPEED + offset) % 240
			p.Position = Vector3.new(root.Position.X + 120 - phase, 6, side * 14)
			p.Transparency = 0
			local light = p:FindFirstChildOfClass("PointLight")
			if light then
				light.Enabled = true
			end
		end
	end
end

local function sway()
	if not Context.inRun() or not Settings.motionAllowed() then
		return
	end
	local camera = workspace.CurrentCamera
	if camera.CameraType ~= Enum.CameraType.Custom then
		return
	end
	local roll = math.rad(0.35) * math.sin(os.clock() * 1.3)
	camera.CFrame = camera.CFrame * CFrame.Angles(0, 0, roll)
end

function AmbienceController.init()
	buildPassing()
	RunService.Heartbeat:Connect(function()
		updatePassing()
		updateLamps(Context.now())
	end)
	RunService:BindToRenderStep("LanternSway", Enum.RenderPriority.Camera.Value + 1, sway)
	Context.onWorld("reset", AmbienceController.clear)
end

return AmbienceController
