--!strict
-- Erzeugt den vollständigen Bauplan eines Laufs (Wagen 0–50) deterministisch aus einem Seed.
-- Ereignisse werden nur gesetzt, wenn der Fairness-Prüfer sie bestätigt (GDD §9).
-- Gleicher Seed ⇒ gleicher Plan (nur bit32-Zufall und exakte Arithmetik).

local CarriageCatalog = require("./CarriageCatalog")
local Fairness = require("./Fairness")
local GameConfig = require("../Config/GameConfig")
local Prng = require("../Util/Prng")
local Types = require("./Types")

type Carriage = Types.Carriage
type Event = Types.Event
type Plan = Types.Plan

local TrainGenerator = {}

-- Wagentypen ohne Slalom, in denen die Kofferlawine fair ist (gerader Mittelgang).
local CHASE_KINDS: { [string]: boolean } = { saloon = true, dining = true, tearoom = true }

local function lerp(a: number, b: number, t: number): number
	return a + (b - a) * math.clamp(t, 0, 1)
end

local SLEEPER_MAX = math.floor(GameConfig.SLEEPER_MAX_SHARE * (GameConfig.RUN_LAST_CARRIAGE + 1))

local function pickKind(
	rng: Prng.Prng,
	index: number,
	prev1: string?,
	prev2: string?,
	chase: boolean,
	sleepers: number
): string
	local names: { string } = {}
	local weights: { number } = {}
	local total = 0
	for _, kind in CarriageCatalog.KIND_ORDER do
		local info = CarriageCatalog.RANDOM_KINDS[kind]
		local tripled = prev1 == kind and prev2 == kind
		local capped = kind == "sleeper" and sleepers >= SLEEPER_MAX
		if index >= info.minIndex and not tripled and not capped and (not chase or CHASE_KINDS[kind]) then
			table.insert(names, kind)
			table.insert(weights, info.weight)
			total += info.weight
		end
	end
	local roll = rng.nextFloat() * total
	for i, name in names do
		roll -= weights[i]
		if roll < 0 then
			return name
		end
	end
	return names[#names]
end

local function placeEyes(c: Carriage, rng: Prng.Prng)
	local wanted = rng.nextInt(GameConfig.EYES_MIN, GameConfig.EYES_MAX)
	local attempts = 0
	while #c.eyes < wanted and attempts < 40 do
		attempts += 1
		local side = if rng.chance(0.5) then 1 else -1
		local eye: Types.Eye = {
			id = #c.eyes + 1,
			x = rng.nextRange(6, c.length - 6),
			y = if rng.chance(0.5) then 0.6 else 7.2, -- unter den Sitzen oder in der Gepäckablage
			z = side * rng.nextRange(3, 5),
		}
		table.insert(c.eyes, eye)
		if not Fairness.checkCarriage(c) then
			table.remove(c.eyes)
		end
	end
end

local function newEvent(kind: string): Event
	return { kind = kind, delay = 0, speed = 0, side = 0, seed = 0 }
end

function TrainGenerator.generate(seed: number): Plan
	local rng = Prng.new(Prng.combine(seed, 0x7A11))
	local last = GameConfig.RUN_LAST_CARRIAGE
	local chaseStart = rng.nextInt(GameConfig.CHASE_START_MIN, GameConfig.CHASE_START_MAX)
	local chaseEnd = chaseStart + GameConfig.CHASE_LENGTH - 1

	local carriages: { Carriage } = {}
	local originX = 0
	local lastSweep, lastInspector = -100, -100
	local prevDark, prevLocked = false, false
	local prev1: string?, prev2: string? = nil, nil
	local sleepers = 0

	for i = 0, last do
		local inChase = i >= chaseStart and i <= chaseEnd
		local kind = if i == 0
			then "boarding"
			elseif i == last then "post"
			else pickKind(rng, i, prev1, prev2, inChase, sleepers)
		if kind == "sleeper" then
			sleepers += 1
		end
		local layout = CarriageCatalog.build(kind, Prng.new(Prng.combine(seed, 1000 + i)))
		local c: Carriage = {
			index = i,
			kind = kind,
			length = layout.length,
			originX = originX,
			dark = false,
			locked = false,
			obstacles = layout.obstacles,
			hidingSpots = layout.hidingSpots,
			containers = layout.containers,
			lamps = layout.lamps,
			eyes = {},
			chase = inChase,
			event = nil,
			post = layout.post,
		}
		-- Wagen direkt vor und nach der Lawine bleiben ruhig.
		local quiet = inChase or i == chaseStart - 1 or i == chaseEnd + 1
		local regular = i <= GameConfig.EVENT_LAST_INDEX and not quiet

		-- Dunkel (nie zweimal in Folge)
		if regular and i >= GameConfig.DARK_MIN_INDEX and not prevDark then
			local t = (i - GameConfig.DARK_MIN_INDEX) / (GameConfig.EVENT_LAST_INDEX - GameConfig.DARK_MIN_INDEX)
			local p = lerp(GameConfig.DARK_CHANCE_START, GameConfig.DARK_CHANCE_END, t)
			if kind == "luggage" then
				p *= 1.5
			end
			if rng.chance(p) then
				c.dark = true
				placeEyes(c, Prng.new(Prng.combine(seed, 3000 + i)))
			end
		end

		-- Verschlossene Vordertür; der Schlüssel liegt in einem Behälter desselben Wagens.
		if regular and i >= GameConfig.LOCKED_MIN_INDEX and not prevLocked and rng.chance(GameConfig.LOCKED_CHANCE) then
			c.locked = true
			local keyContainer = c.containers[rng.nextInt(1, #c.containers)]
			keyContainer.content = "key"
		end
		for _, container in c.containers do
			if container.content ~= "key" and rng.chance(GameConfig.STUB_CHANCE) then
				container.content = "stubs"
				container.stubs = rng.nextInt(1, 3)
			end
		end

		-- Ereignisse
		if i == last then
			local event = newEvent("conductor")
			event.seed = rng.nextUInt32()
			c.event = event
		elseif i == chaseStart then
			local event = newEvent("chase")
			event.delay = GameConfig.CHASE_WARN
			event.speed = GameConfig.CHASE_SPEED
			c.event = event
		elseif regular and i > GameConfig.GRACE_CARRIAGES then
			local canInspect = kind == "sleeper"
				and i >= GameConfig.INSPECTOR_MIN_INDEX
				and not c.dark
				and not c.locked
				and i - lastInspector >= GameConfig.INSPECTOR_GAP
			if canInspect and rng.chance(GameConfig.INSPECTOR_CHANCE) then
				local event = newEvent("inspector")
				event.seed = rng.nextUInt32()
				c.event = event
				lastInspector = i
			elseif i >= GameConfig.EXPRESS_MIN_INDEX and i - lastSweep >= GameConfig.EXPRESS_GAP then
				local t = (i - GameConfig.EXPRESS_MIN_INDEX)
					/ (GameConfig.EVENT_LAST_INDEX - GameConfig.EXPRESS_MIN_INDEX)
				if rng.chance(lerp(GameConfig.EXPRESS_CHANCE_START, GameConfig.EXPRESS_CHANCE_END, t)) then
					local prev = carriages[i] -- Wagen i − 1
					local oncoming = i >= GameConfig.ONCOMING_MIN_INDEX and rng.chance(GameConfig.ONCOMING_SHARE)
					local event: Event
					local fair: boolean
					if oncoming then
						event = newEvent("oncoming")
						event.delay = rng.nextRange(GameConfig.ONCOMING_DELAY_MIN, GameConfig.ONCOMING_DELAY_MAX)
						event.side = if rng.chance(0.5) then 1 else -1
						fair = Fairness.checkOncoming(prev, c, event)
					else
						event = newEvent("express")
						event.delay = rng.nextRange(GameConfig.EXPRESS_DELAY_MIN, GameConfig.EXPRESS_DELAY_MAX)
						event.speed = GameConfig.EXPRESS_SPEED
						local behind: { Carriage } = {}
						for back = i - 2, math.max(0, i - 3), -1 do
							table.insert(behind, carriages[back + 1])
						end
						fair = Fairness.checkExpress(prev, c, event, behind)
					end
					if fair then
						c.event = event
						lastSweep = i
					end
				end
			end
		end

		table.insert(carriages, c)
		prevDark, prevLocked = c.dark, c.locked
		prev2, prev1 = prev1, kind
		originX += c.length + GameConfig.GANGWAY
	end

	return { seed = seed, carriages = carriages, lastIndex = last }
end

-- Wagen, in dem die Welt-x-Position liegt (Übergang zählt zum folgenden Wagen), sonst nil.
function TrainGenerator.carriageAt(plan: Plan, worldX: number): number?
	local list = plan.carriages
	if #list == 0 or worldX < list[1].originX then
		return nil
	end
	local lo, hi = 1, #list
	while lo < hi do
		local mid = (lo + hi + 1) // 2
		if list[mid].originX - GameConfig.GANGWAY <= worldX then
			lo = mid
		else
			hi = mid - 1
		end
	end
	local c = list[lo]
	if worldX > c.originX + c.length then
		return nil -- vor dem letzten Wagen
	end
	return c.index
end

-- Kurzer Fingerabdruck des Plans (Tests, Telemetrie, Fehlersuche).
function TrainGenerator.fingerprint(plan: Plan): number
	local h = 2166136261
	local function mix(value: number)
		h = Prng.combine(h, math.floor(value * 16))
	end
	for _, c in plan.carriages do
		mix(c.index)
		mix(c.length)
		mix(if c.dark then 1 else 0)
		mix(if c.locked then 1 else 0)
		mix(#c.obstacles)
		mix(#c.hidingSpots)
		mix(#c.eyes)
		local event = c.event
		if event then
			mix(#event.kind)
			mix(event.delay)
			mix(event.side)
		end
		for _, container in c.containers do
			mix(container.x)
			mix(container.stubs)
		end
	end
	return h
end

return table.freeze(TrainGenerator)
