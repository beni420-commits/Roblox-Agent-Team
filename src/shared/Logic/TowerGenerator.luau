--!strict
-- Turm-Generator (tech_notes §6.2, GDD v0.2 §4). Reine Funktion: Seed → Turmbeschreibung.
-- Server (Bauteile) und Client (Funken, Hilfsstufen, Führung) erzeugen damit bitgleiche Strukturen.
-- Jede Pflicht-Verbindung wird gegen den Referenzcharakter geprüft; scheitert eine Etage,
-- wird sie deterministisch neu gewürfelt.

local Movement = require("./Movement")
local Prng = require("../Util/Prng")
local Reachability = require("./Reachability")
local TowerConfig = require("./TowerConfig")

export type PartSpec = {
	id: string,
	kind: string, -- "platform" | "conveyor" | "jumpPad" | "landing" | "camp" | "gate" | "helper" | "ground" | "column"
	floor: number,
	zone: number,
	cx: number,
	cy: number,
	cz: number,
	sx: number, -- Breite (quer zur Laufrichtung)
	sy: number, -- Dicke
	sz: number, -- Länge (entlang der Laufrichtung)
	fx: number, -- Laufrichtung (Einheitsvektor in der XZ-Ebene)
	fz: number,
	conveyorSpeed: number?,
	launchVelocity: number?,
}

export type SparkSpec = { id: number, floor: number, index: number, x: number, y: number, z: number }

export type ConnectionSpec = {
	index: number,
	fromId: string,
	toId: string,
	connection: Reachability.Connection,
	helperId: string?,
}

export type LandingSpec = {
	floor: number,
	isCamp: boolean,
	x: number,
	y: number, -- Oberkante
	z: number,
	halfLength: number,
	halfWidth: number,
	fx: number,
	fz: number,
	partId: string,
}

export type FloorSpec = {
	floor: number,
	zone: number,
	baseY: number, -- Oberkante der Etagenplattform darunter (Rücksetzpunkt)
	topY: number, -- Oberkante der Ziel-Etagenplattform
	parts: { PartSpec },
	helpers: { PartSpec },
	sparks: { SparkSpec },
	connections: { ConnectionSpec },
	pathLength: number,
	attempt: number,
}

export type TowerSpec = {
	seed: number,
	builtFloors: number,
	landings: { [number]: LandingSpec },
	floors: { FloorSpec },
	statics: { PartSpec },
}

local TowerGenerator = {}

local R = TowerConfig.PATH_RADIUS
local SECTOR = TowerConfig.SECTOR_ANGLE
local THICK = TowerConfig.PLATFORM_THICKNESS
local MAX_ATTEMPTS = 16

function TowerGenerator.landingTopY(floor: number): number
	return floor * TowerConfig.FLOOR_HEIGHT + TowerConfig.LANDING_TOP_OFFSET
end

function TowerGenerator.zoneOf(floor: number): number
	return math.max(1, math.ceil(floor / TowerConfig.FLOORS_PER_ZONE))
end

local function landingHalfLength(floor: number): number
	if TowerConfig.CAMP_FLOORS[floor] then
		return TowerConfig.CAMP_LENGTH / 2
	end
	return TowerConfig.LANDING_LENGTH / 2
end

local function landingHalfWidth(floor: number): number
	if TowerConfig.CAMP_FLOORS[floor] then
		return TowerConfig.CAMP_WIDTH / 2
	end
	return TowerConfig.LANDING_WIDTH / 2
end

-- Bogenparameter → Weltposition und Laufrichtung (Helix um die zentrale Säule).
local function arcPoint(theta0: number, s: number): (number, number, number, number)
	local theta = theta0 + s / R
	return R * math.cos(theta), R * math.sin(theta), -math.sin(theta), math.cos(theta)
end

local function makeLanding(floor: number): LandingSpec
	local theta = floor * SECTOR
	local x, z, fx, fz = arcPoint(theta, 0)
	return {
		floor = floor,
		isCamp = TowerConfig.CAMP_FLOORS[floor] == true,
		x = x,
		y = TowerGenerator.landingTopY(floor),
		z = z,
		halfLength = landingHalfLength(floor),
		halfWidth = landingHalfWidth(floor),
		fx = fx,
		fz = fz,
		partId = string.format("L%02d", floor),
	}
end

-- Größte faire Lücke je (Zone, Anstieg, Pad) mit Cache. Anstieg wird konservativ aufgerundet.
local gapCache: { [string]: number } = {}
local function cachedMaxGap(zone: TowerConfig.ZoneConfig, rise: number, pad: boolean, padLength: number): number
	local bucket = math.ceil(rise * 4) / 4
	local key = string.format("%d:%.2f:%s:%.1f", zone.index, bucket, tostring(pad), padLength)
	local cached = gapCache[key]
	if cached then
		return cached
	end
	local profile = Reachability.referenceProfile(zone.factor)
	local value: number
	if pad then
		local velocity = Movement.jumpVelocity(zone.padHeight, Movement.BASE_STATS.gravity)
		local low, high = 0, 40
		local function ok(gap: number): boolean
			return (
				Reachability.canReach(
					{ gap = gap, rise = bucket, launchVelocity = velocity, launchDistance = padLength },
					profile,
					zone.abilities
				)
			)
		end
		if not ok(0) then
			value = -1
		else
			for _ = 1, 30 do
				local mid = (low + high) / 2
				if ok(mid) then
					low = mid
				else
					high = mid
				end
			end
			value = low
		end
	else
		value = Reachability.maxGap(bucket, profile, zone.abilities)
	end
	gapCache[key] = value
	return value
end

local function partFromArc(
	id: string,
	kind: string,
	floor: number,
	zone: number,
	theta0: number,
	sFrom: number,
	sTo: number,
	topY: number,
	width: number
): PartSpec
	local sMid = (sFrom + sTo) / 2
	local x, z, fx, fz = arcPoint(theta0, sMid)
	return {
		id = id,
		kind = kind,
		floor = floor,
		zone = zone,
		cx = x,
		cy = topY - THICK / 2,
		cz = z,
		sx = width,
		sy = THICK,
		sz = sTo - sFrom,
		fx = fx,
		fz = fz,
	}
end

local function landingPart(landing: LandingSpec, zone: number): PartSpec
	return {
		id = landing.partId,
		kind = if landing.isCamp then "camp" else "landing",
		floor = landing.floor,
		zone = zone,
		cx = landing.x,
		cy = landing.y - THICK / 2,
		cz = landing.z,
		sx = landing.halfWidth * 2,
		sy = THICK,
		sz = landing.halfLength * 2,
		fx = landing.fx,
		fz = landing.fz,
	}
end

-- Tor am Eingang der Etagenplattform: zwei Pfosten + Querbalken (dekorativ, kollidiert).
local function gateParts(landing: LandingSpec, zone: number): { PartSpec }
	local parts = {}
	local height = TowerConfig.GATE_HEIGHT
	local entryX = landing.x - landing.fx * landing.halfLength
	local entryZ = landing.z - landing.fz * landing.halfLength
	-- Querrichtung (radial) = Laufrichtung um 90° gedreht.
	local qx, qz = landing.fz, -landing.fx
	for side = -1, 1, 2 do
		local offset = landing.halfWidth - 0.5
		table.insert(parts, {
			id = string.format("G%02d_%s", landing.floor, if side < 0 then "a" else "b"),
			kind = "gate",
			floor = landing.floor,
			zone = zone,
			cx = entryX + qx * offset * side,
			cy = landing.y + height / 2,
			cz = entryZ + qz * offset * side,
			sx = 1,
			sy = height,
			sz = 1,
			fx = landing.fx,
			fz = landing.fz,
		})
	end
	table.insert(parts, {
		id = string.format("G%02d_top", landing.floor),
		kind = "gate",
		floor = landing.floor,
		zone = zone,
		cx = entryX,
		cy = landing.y + height + 0.5,
		cz = entryZ,
		sx = landing.halfWidth * 2,
		sy = 1,
		sz = 1,
		fx = landing.fx,
		fz = landing.fz,
	})
	return parts
end

type Draft = {
	rises: { number },
	gaps: { number },
	lengths: { number },
	padIndex: number?,
}

local function draft(
	rng: Prng.Prng,
	floor: number,
	zone: TowerConfig.ZoneConfig,
	available: number,
	padLength: number
): Draft?
	local count = rng.nextInt(zone.connections.min, zone.connections.max)
	local padIndex: number? = nil
	if floor >= zone.padFromFloor and rng.chance(zone.padChance) then
		padIndex = rng.nextInt(2, count - 1)
	end

	local rises: { number } = {}
	local padRise = 0
	local sum = 0
	for i = 1, count do
		if i == padIndex then
			padRise = rng.nextRange(zone.padRise.min, zone.padRise.max)
			rises[i] = padRise
		else
			rises[i] = rng.nextRange(zone.rise.min, zone.rise.max)
			sum += rises[i]
		end
	end
	local needed = TowerConfig.FLOOR_HEIGHT - padRise
	local scale = needed / sum
	for i = 1, count do
		if i ~= padIndex then
			rises[i] *= scale
			if rises[i] < 0 or rises[i] > zone.rise.max then
				return nil
			end
		end
	end

	local gaps: { number } = {}
	local gapSum = 0
	for i = 1, count do
		local maxGap = cachedMaxGap(zone, rises[i], i == padIndex, padLength) * zone.gapUsage
		if maxGap < zone.gapMin then
			return nil
		end
		gaps[i] = rng.nextRange(zone.gapMin, maxGap)
		gapSum += gaps[i]
	end

	-- count - 1 Zwischenplattformen füllen den restlichen Bogen.
	local platformTotal = available - gapSum
	local weights: { number } = {}
	local weightSum = 0
	for i = 1, count - 1 do
		weights[i] = rng.nextRange(0.7, 1.3)
		weightSum += weights[i]
	end
	local lengths: { number } = {}
	for i = 1, count - 1 do
		local length = platformTotal * weights[i] / weightSum
		if i + 1 == padIndex then
			length = padLength
		end
		lengths[i] = length
	end
	-- Pad-Länge ist fest; Rest auf die übrigen Plattformen verteilen.
	if padIndex then
		local fixed = padLength
		local rest = platformTotal - fixed
		local restWeight = weightSum - weights[padIndex - 1]
		for i = 1, count - 1 do
			if i + 1 ~= padIndex then
				lengths[i] = rest * weights[i] / restWeight
			end
		end
	end
	for i = 1, count - 1 do
		if i + 1 ~= padIndex and (lengths[i] < zone.platformLength.min or lengths[i] > zone.platformLength.max) then
			return nil
		end
	end
	return { rises = rises, gaps = gaps, lengths = lengths, padIndex = padIndex }
end

local function buildFloor(seed: number, floor: number): FloorSpec
	local zoneIndex = TowerGenerator.zoneOf(floor)
	local zone = TowerConfig.ZONES[zoneIndex]
	assert(zone, "zone not configured: " .. zoneIndex)
	local theta0 = (floor - 1) * SECTOR
	local arcLength = R * SECTOR
	local sStart = landingHalfLength(floor - 1)
	local sEnd = arcLength - landingHalfLength(floor)
	local baseY = TowerGenerator.landingTopY(floor - 1)
	local topY = TowerGenerator.landingTopY(floor)
	local padLength = 4
	local profile = Reachability.referenceProfile(zone.factor)
	local helperProfile = Reachability.referenceProfile(Reachability.HELPER_FACTOR)

	for attempt = 1, MAX_ATTEMPTS do
		local rng = Prng.new(Prng.combine(seed, floor * 97 + attempt))
		local plan = draft(rng, floor, zone, sEnd - sStart, padLength)
		if plan then
			local parts: { PartSpec } = {}
			local helpers: { PartSpec } = {}
			local connections: { ConnectionSpec } = {}
			local s = sStart
			local y = baseY
			local fromId = string.format("L%02d", floor - 1)
			local valid = true
			local count = #plan.rises

			for i = 1, count do
				local gap = plan.gaps[i]
				local rise = plan.rises[i]
				local landingTop = y + rise
				local isLast = i == count
				local toId: string
				local platformFrom = s + gap
				local platformTo = if isLast then sEnd else platformFrom + plan.lengths[i]
				if isLast then
					toId = string.format("L%02d", floor)
				else
					toId = string.format("F%02d_P%02d", floor, i)
					local kind = "platform"
					if i + 1 == plan.padIndex then
						kind = "jumpPad"
					elseif rng.chance(zone.conveyorChance) then
						kind = "conveyor"
					end
					local part = partFromArc(
						toId,
						kind,
						floor,
						zoneIndex,
						theta0,
						platformFrom,
						platformTo,
						landingTop,
						zone.platformWidth
					)
					if kind == "jumpPad" then
						part.launchVelocity = Movement.jumpVelocity(zone.padHeight, Movement.BASE_STATS.gravity)
					elseif kind == "conveyor" then
						part.conveyorSpeed = zone.conveyorSpeed
					end
					table.insert(parts, part)
				end

				-- Decke: Sektor darüber (4 Etagen höher) bzw. Torbalken der Ziel-Etagenplattform.
				local ceiling = (baseY + 4 * TowerConfig.FLOOR_HEIGHT - THICK) - y
				if isLast then
					ceiling = math.min(ceiling, topY + TowerConfig.GATE_HEIGHT - y)
				end
				local isPad = i == plan.padIndex
				local connection: Reachability.Connection = {
					gap = gap,
					rise = rise,
					ceiling = ceiling,
					launchVelocity = if isPad
						then Movement.jumpVelocity(zone.padHeight, Movement.BASE_STATS.gravity)
						else nil,
					launchDistance = if isPad then padLength else nil,
				}
				if not Reachability.canReach(connection, profile, zone.abilities) then
					valid = false
					break
				end

				-- Hilfsstufe (nur lokal beim Spieler sichtbar): halbiert die Lücke bzw. den Anstieg.
				local helperId: string? = nil
				if i ~= plan.padIndex and (gap >= 2 or rise >= 2.5) then
					local helperLength = 3
					local mid = s + gap / 2
					local helperTop = y + rise / 2
					local legGap = math.max(0, gap / 2 - helperLength / 2)
					local leg1: Reachability.Connection = { gap = legGap, rise = rise / 2 }
					local leg2: Reachability.Connection = { gap = legGap, rise = rise / 2 }
					if
						Reachability.canReach(leg1, helperProfile, zone.abilities)
						and Reachability.canReach(leg2, helperProfile, zone.abilities)
					then
						helperId = string.format("F%02d_H%02d", floor, i)
						table.insert(
							helpers,
							partFromArc(
								helperId :: string,
								"helper",
								floor,
								zoneIndex,
								theta0,
								mid - helperLength / 2,
								mid + helperLength / 2,
								helperTop,
								4
							)
						)
					end
				end

				table.insert(connections, {
					index = i,
					fromId = fromId,
					toId = toId,
					connection = connection,
					helperId = helperId,
				})
				fromId = toId
				s = platformTo
				y = landingTop
			end

			if valid and math.abs(y - topY) < 1e-6 then
				-- Funken: auf Zwischenplattformen (nicht auf Sprungpads), gleichmäßig verteilt.
				local sparks: { SparkSpec } = {}
				local candidates: { PartSpec } = {}
				for _, part in parts do
					if part.kind ~= "jumpPad" then
						table.insert(candidates, part)
					end
				end
				for index = 1, TowerConfig.SPARKS_PER_FLOOR do
					local part = candidates[((index - 1) % #candidates) + 1]
					local lap = math.floor((index - 1) / #candidates)
					local along = (if lap == 0 then 0 else 0.3) * part.sz
					table.insert(sparks, {
						id = floor * 100 + index,
						floor = floor,
						index = index,
						x = part.cx + part.fx * along,
						y = part.cy + THICK / 2 + 2.5,
						z = part.cz + part.fz * along,
					})
				end

				local landing = makeLanding(floor)
				table.insert(parts, landingPart(landing, zoneIndex))
				for _, gate in gateParts(landing, zoneIndex) do
					table.insert(parts, gate)
				end

				return {
					floor = floor,
					zone = zoneIndex,
					baseY = baseY,
					topY = topY,
					parts = parts,
					helpers = helpers,
					sparks = sparks,
					connections = connections,
					pathLength = sEnd - sStart,
					attempt = attempt,
				}
			end
		end
	end
	error(
		string.format("TowerGenerator: Etage %d nach %d Versuchen nicht lösbar (Seed %d)", floor, MAX_ATTEMPTS, seed)
	)
end

local function staticParts(): { PartSpec }
	local height = TowerConfig.TOTAL_FLOORS * TowerConfig.FLOOR_HEIGHT + 20
	return {
		{
			id = "Ground",
			kind = "ground",
			floor = 0,
			zone = 1,
			cx = 0,
			cy = -1,
			cz = 0,
			sx = TowerConfig.GROUND_RADIUS * 2,
			sy = 2,
			sz = TowerConfig.GROUND_RADIUS * 2,
			fx = 0,
			fz = 1,
		},
		{
			id = "Column",
			kind = "column",
			floor = 0,
			zone = 1,
			cx = 0,
			cy = height / 2,
			cz = 0,
			sx = TowerConfig.COLUMN_RADIUS * 2,
			sy = height,
			sz = TowerConfig.COLUMN_RADIUS * 2,
			fx = 0,
			fz = 1,
		},
	}
end

-- Erzeugt die gebauten Etagen (Sprint 1: Zone 1 = Etagen 1–10).
function TowerGenerator.generate(seed: number, builtFloors: number?): TowerSpec
	local count = builtFloors or (TowerConfig.BUILT_ZONES * TowerConfig.FLOORS_PER_ZONE)
	local landings: { [number]: LandingSpec } = {}
	for floor = 0, count do
		landings[floor] = makeLanding(floor)
	end
	local floors: { FloorSpec } = {}
	for floor = 1, count do
		floors[floor] = buildFloor(seed, floor)
	end
	local statics = staticParts()
	table.insert(statics, landingPart(landings[0], 1))
	return { seed = seed, builtFloors = count, landings = landings, floors = floors, statics = statics }
end

-- Seed eines Laufs: Lauf 1 fest, ab Lauf 2 neu gemischt (GDD v0.2 §3.3).
function TowerGenerator.seedForRun(baseSeed: number, runIndex: number): number
	if runIndex <= 1 then
		return baseSeed
	end
	return Prng.combine(baseSeed, runIndex)
end

return table.freeze(TowerGenerator)
