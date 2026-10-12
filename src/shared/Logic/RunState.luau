--!strict
-- Lauf-Zustand eines Spielers (Server-Autorität). Reine Logik ohne Roblox-Abhängigkeit.
-- Sprint 1: nur im Speicher; ab Sprint 2 Teil des gespeicherten Datensatzes (tech_notes §6.4).

local TowerConfig = require("./TowerConfig")

export type RunState = {
	runIndex: number,
	currentFloor: number, -- zuletzt erreichte Etagenplattform = Rücksetzpunkt
	highestFloor: number, -- höchste Etage dieses Laufs
	campFloor: number, -- letztes erreichtes Lager (Rejoin-Punkt ab Sprint 2)
	campsClaimed: number, -- Bitmaske eingelöster Lager-Boni
	collected: { [string]: number }, -- Etage → Bitmaske eingesammelter Funken
	sparks: number,
	lifetimeSparks: number,
	failsByFloor: { [number]: number }, -- Fehlversuche je Ziel-Etage
	onboardingSteps: number, -- Bitmaske erledigter Funnel-Schritte
	skippedLandings: number, -- Etagen-Sprünge ohne Zwischenetage (Teleport-Verdacht)
	flagged: boolean,
}

export type LandingEvent = {
	accepted: boolean,
	floor: number,
	campReached: boolean,
	campBonus: number,
	zoneCompleted: number?,
	failsOnSegment: number,
}

local RunState = {}

RunState.HELP_TRAIL_FAILS = 3
RunState.HELP_HELPER_FAILS = 6
RunState.CAMP_BONUS = 5
RunState.MAX_SPARKS_PER_FLOOR = 16
RunState.ONBOARDING_STEPS = 7
RunState.CLIENT_ONBOARDING_STEPS = table.freeze({ [3] = true }) -- nur „FirstJump“ meldet der Client

function RunState.new(runIndex: number?): RunState
	return {
		runIndex = runIndex or 1,
		currentFloor = 0,
		highestFloor = 0,
		campFloor = 0,
		campsClaimed = 0,
		collected = {},
		sparks = 0,
		lifetimeSparks = 0,
		failsByFloor = {},
		onboardingSteps = 0,
		skippedLandings = 0,
		flagged = false,
	}
end

local function hasBit(mask: number, bit: number): boolean
	return bit32.btest(mask, bit32.lshift(1, bit))
end

local function withBit(mask: number, bit: number): number
	return bit32.bor(mask, bit32.lshift(1, bit))
end

-- Der Spieler steht auf Etagenplattform `floor`. Nur die nächste Etage wird akzeptiert (lückenlos).
function RunState.reachLanding(state: RunState, floor: number, builtFloors: number): LandingEvent
	local event: LandingEvent = {
		accepted = false,
		floor = floor,
		campReached = false,
		campBonus = 0,
		zoneCompleted = nil,
		failsOnSegment = 0,
	}
	if floor <= state.currentFloor or floor > builtFloors then
		return event -- zurückgelaufen, stehen geblieben oder ungültig: kein Fortschritt
	end
	if floor > state.currentFloor + 1 then
		-- Etage übersprungen: zählt nicht (Teleport-Schutz, tech_notes §6.6 Punkt 5).
		state.skippedLandings += 1
		state.flagged = true
		return event
	end
	event.accepted = true
	event.failsOnSegment = state.failsByFloor[floor] or 0
	state.currentFloor = floor
	state.highestFloor = math.max(state.highestFloor, floor)
	if TowerConfig.CAMP_FLOORS[floor] then
		event.campReached = true
		state.campFloor = floor
		if not hasBit(state.campsClaimed, floor) then
			state.campsClaimed = withBit(state.campsClaimed, floor)
			state.sparks += RunState.CAMP_BONUS
			state.lifetimeSparks += RunState.CAMP_BONUS
			event.campBonus = RunState.CAMP_BONUS
		end
	end
	if floor % TowerConfig.FLOORS_PER_ZONE == 0 then
		event.zoneCompleted = floor // TowerConfig.FLOORS_PER_ZONE
	end
	return event
end

-- Ist die oberste gebaute Etage erreicht, gibt es kein Ziel mehr: keine Fehlversuche, keine Hilfe (CR-06).
function RunState.isAtTop(state: RunState, builtFloors: number): boolean
	return state.currentFloor >= builtFloors
end

-- Ein Fall: zählt als Fehlversuch auf der Etage, die gerade erklettert wird.
function RunState.registerFail(state: RunState, builtFloors: number): number
	if RunState.isAtTop(state, builtFloors) then
		return 0
	end
	local target = state.currentFloor + 1
	local fails = (state.failsByFloor[target] or 0) + 1
	state.failsByFloor[target] = fails
	return fails
end

function RunState.failsOnTarget(state: RunState): number
	return state.failsByFloor[state.currentFloor + 1] or 0
end

-- Hilfestufe für die aktuell erkletterte Etage: 0 keine, 1 Führungs-Chevrons, 2 zusätzlich Hilfsstufen.
function RunState.helpLevel(state: RunState, helpersEnabled: boolean, builtFloors: number): number
	if not helpersEnabled or RunState.isAtTop(state, builtFloors) then
		return 0
	end
	local fails = state.failsByFloor[state.currentFloor + 1] or 0
	if fails >= RunState.HELP_HELPER_FAILS then
		return 2
	elseif fails >= RunState.HELP_TRAIL_FAILS then
		return 1
	end
	return 0
end

function RunState.isSparkCollected(state: RunState, sparkId: number): boolean
	local floor = sparkId // 100
	local index = sparkId % 100
	return hasBit(state.collected[tostring(floor)] or 0, index)
end

-- Funke einsammeln. Reichweite prüft der Aufrufer (Positionen); hier: Existenz, Etage, Einmaligkeit.
function RunState.collectSpark(state: RunState, sparkId: number, builtFloors: number): (boolean, string)
	if sparkId % 1 ~= 0 then
		return false, "invalid id"
	end
	local floor = sparkId // 100
	local index = sparkId % 100
	if floor < 1 or floor > builtFloors or index < 1 or index > RunState.MAX_SPARKS_PER_FLOOR then
		return false, "invalid id"
	end
	if floor > state.highestFloor + 1 then
		return false, "floor not reached"
	end
	local key = tostring(floor)
	local mask = state.collected[key] or 0
	if hasBit(mask, index) then
		return false, "already collected"
	end
	state.collected[key] = withBit(mask, index)
	state.sparks += 1
	state.lifetimeSparks += 1
	return true, "ok"
end

-- Onboarding-Schritt markieren. Liefert true nur beim ersten Mal (keine Doppelmeldung an Analytics).
function RunState.markOnboarding(state: RunState, step: number, fromClient: boolean): boolean
	if step % 1 ~= 0 or step < 1 or step > RunState.ONBOARDING_STEPS then
		return false
	end
	if fromClient then
		if not RunState.CLIENT_ONBOARDING_STEPS[step] then
			return false
		end
		if not hasBit(state.onboardingSteps, 1) then
			return false -- Client-Schritte erst nach „Spawned“
		end
	end
	if hasBit(state.onboardingSteps, step) then
		return false
	end
	state.onboardingSteps = withBit(state.onboardingSteps, step)
	return true
end

-- Abstand Spieler ↔ Funke (Server-Positionen) mit Latenz-Toleranz.
RunState.SPARK_REACH = 10

function RunState.withinReach(ax: number, ay: number, az: number, bx: number, by: number, bz: number): boolean
	local dx, dy, dz = ax - bx, ay - by, az - bz
	return dx * dx + dy * dy + dz * dz <= RunState.SPARK_REACH * RunState.SPARK_REACH
end

return table.freeze(RunState)
