--!strict
-- Deterministischer Pseudozufall (xorshift32).
-- Nutzt ausschließlich bit32-Operationen und Division, damit Luau-CLI, Roblox-Server und
-- Roblox-Client bitgleiche Folgen erzeugen (kein Random.new, kein math.random).

export type Prng = {
	nextUInt32: () -> number,
	nextFloat: () -> number,
	nextInt: (minValue: number, maxValue: number) -> number,
	nextRange: (minValue: number, maxValue: number) -> number,
	chance: (probability: number) -> boolean,
}

local Prng = {}

local UINT32 = 4294967296

local function step(x: number): number
	x = bit32.bxor(x, bit32.lshift(x, 13))
	x = bit32.bxor(x, bit32.rshift(x, 17))
	x = bit32.bxor(x, bit32.lshift(x, 5))
	return x
end

local function toUInt32(value: number): number
	-- Luau-% ist „floored“: auch negative Seeds landen im Bereich [0, 2^32).
	return math.floor(value) % UINT32
end

-- Kombiniert zwei Zahlen deterministisch zu einem neuen 32-Bit-Seed (z. B. Basis-Seed + Etage).
function Prng.combine(a: number, b: number): number
	local x = bit32.bxor(toUInt32(a), 0x85EBCA6B)
	if x == 0 then
		x = 0x27D4EB2F
	end
	x = step(step(x))
	x = bit32.bxor(x, toUInt32(b))
	if x == 0 then
		x = 0x165667B1
	end
	return step(step(step(x)))
end

function Prng.new(seed: number): Prng
	local state = bit32.bxor(toUInt32(seed), 0x9E3779B9)
	if state == 0 then
		state = 0x6D2B79F5
	end
	-- Aufwärmen, damit ähnliche Seeds schnell auseinanderlaufen.
	for _ = 1, 8 do
		state = step(state)
	end

	local function nextUInt32(): number
		state = step(state)
		return state
	end

	local function nextFloat(): number
		return nextUInt32() / UINT32
	end

	local function nextInt(minValue: number, maxValue: number): number
		assert(maxValue >= minValue, "nextInt: maxValue < minValue")
		local span = math.floor(maxValue) - math.floor(minValue) + 1
		return math.floor(minValue) + math.floor(nextFloat() * span)
	end

	local function nextRange(minValue: number, maxValue: number): number
		return minValue + (maxValue - minValue) * nextFloat()
	end

	local function chance(probability: number): boolean
		return nextFloat() < probability
	end

	return {
		nextUInt32 = nextUInt32,
		nextFloat = nextFloat,
		nextInt = nextInt,
		nextRange = nextRange,
		chance = chance,
	}
end

return table.freeze(Prng)
