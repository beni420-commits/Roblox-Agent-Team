--!strict
-- Kontrolleur (§6.4): Phasen Gehen → Achtung → Halt (rot) → Gehen …
-- Bei „stop“ (nach Gnadenzeit) kostet Bewegung Lebenspunkte, höchstens einmal je Haltphase.
-- Wer bis auf INSPECTOR_CHECK_DISTANCE herankommt, ist kontrolliert. Sind alle lebenden Spieler
-- im Wagen kontrolliert (mind. einer), geht der Kontrolleur ab und gibt die Tür frei – spätestens nach
-- INSPECTOR_MAX_DURATION Sekunden.
-- Signale (Compliance H-A10/H-A11): Phasenwechsel ohne Flackern; zweites Merkmal = Form der Kelle.

local GameConfig = require("../Config/GameConfig")
local Prng = require("../Util/Prng")

export type Phase = "intro" | "go" | "warn" | "stop" | "gone"

export type State = {
	rng: Prng.Prng,
	startedAt: number,
	phase: Phase,
	phaseEndsAt: number,
	stopStartedAt: number,
	checked: { [string]: boolean },
	hitThisStop: { [string]: boolean },
}

-- Sicht des Servers auf einen Spieler (pro Aktualisierung).
export type PlayerView = {
	key: string,
	alive: boolean,
	inCarriage: boolean,
	distance: number, -- Abstand zum Kontrolleur (waagerecht)
	moved: number, -- waagerechte Verschiebung im Fenster INSPECTOR_MOVE_WINDOW
}

export type Result = {
	hits: { string },
	phaseChanged: boolean,
	done: boolean,
}

local Inspector = {}

function Inspector.new(seed: number, now: number): State
	return {
		rng = Prng.new(seed),
		startedAt = now,
		phase = "intro",
		phaseEndsAt = now + GameConfig.INSPECTOR_INTRO,
		stopStartedAt = -math.huge,
		checked = {},
		hitThisStop = {},
	}
end

local function nextPhase(state: State)
	local rng = state.rng
	local start = state.phaseEndsAt
	if state.phase == "intro" or state.phase == "stop" then
		state.phase = "go"
		state.phaseEndsAt = start + rng.nextRange(GameConfig.INSPECTOR_AMBER_MIN, GameConfig.INSPECTOR_AMBER_MAX)
	elseif state.phase == "go" then
		state.phase = "warn"
		state.phaseEndsAt = start + GameConfig.INSPECTOR_WARN
	elseif state.phase == "warn" then
		state.phase = "stop"
		state.stopStartedAt = start
		state.hitThisStop = {}
		state.phaseEndsAt = start + rng.nextRange(GameConfig.INSPECTOR_RED_MIN, GameConfig.INSPECTOR_RED_MAX)
	end
end

function Inspector.update(state: State, now: number, players: { PlayerView }): Result
	local result: Result = { hits = {}, phaseChanged = false, done = state.phase == "gone" }
	if state.phase == "gone" then
		return result
	end
	-- Zeitlimit: niemand kann die Gruppe dauerhaft festhalten (Compliance H-A18).
	if now - state.startedAt >= GameConfig.INSPECTOR_MAX_DURATION then
		state.phase = "gone"
		result.phaseChanged = true
		result.done = true
		return result
	end
	while now >= state.phaseEndsAt do
		nextPhase(state)
		result.phaseChanged = true
	end

	for _, p in players do
		if p.alive and p.inCarriage and p.distance <= GameConfig.INSPECTOR_CHECK_DISTANCE then
			state.checked[p.key] = true
		end
	end

	-- Gemessen wird erst, wenn das Messfenster ganz nach der Gnadenzeit liegt (Code-Review LL-04):
	-- Bewegung während der Gnadenzeit zählt nie.
	local measureFrom = state.stopStartedAt + GameConfig.INSPECTOR_GRACE + GameConfig.INSPECTOR_MOVE_WINDOW
	if state.phase == "stop" and now >= measureFrom then
		for _, p in players do
			local exposed = p.alive and p.inCarriage and not state.checked[p.key]
			if exposed and not state.hitThisStop[p.key] and p.moved > GameConfig.INSPECTOR_MOVE_THRESHOLD then
				state.hitThisStop[p.key] = true
				table.insert(result.hits, p.key)
			end
		end
	end

	local anyChecked = next(state.checked) ~= nil
	local waiting = false
	for _, p in players do
		if p.alive and p.inCarriage and not state.checked[p.key] then
			waiting = true
		end
	end
	if anyChecked and not waiting then
		state.phase = "gone"
		result.phaseChanged = true
		result.done = true
	end
	return result
end

-- Bewegung ist in dieser Phase gefährlich (für HUD und Kelle).
function Inspector.isDangerous(phase: Phase): boolean
	return phase == "stop"
end

return table.freeze(Inspector)
