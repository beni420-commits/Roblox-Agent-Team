--!strict
-- Verstecke (§7, Compliance H-A7): genau eine Person je Versteck, jederzeit verlassbar.
-- Kälte: Wer ohne aktives Wesen HIDE_COLD_WARN s versteckt ist, wird gewarnt, nach HIDE_COLD_EJECT s
-- hinausgeschoben (kein Schaden). Solange ein Wesen aktiv ist, beginnt die Zeit neu.

local GameConfig = require("../Config/GameConfig")

export type State = {
	occupant: { [number]: string }, -- Versteck-Schlüssel → Spieler
	hiddenIn: { [string]: number }, -- Spieler → Versteck-Schlüssel
	since: { [string]: number },
}

export type Cold = "none" | "warn" | "eject"

local HideState = {}

-- Eindeutiger Schlüssel aus Wagen und Versteck-Nummer.
function HideState.spotKey(carriage: number, spotId: number): number
	return carriage * 100 + spotId
end

function HideState.carriageOf(spotKey: number): number
	return spotKey // 100
end

function HideState.new(): State
	return { occupant = {}, hiddenIn = {}, since = {} }
end

function HideState.enter(state: State, player: string, spotKey: number, now: number): (boolean, string?)
	if state.hiddenIn[player] ~= nil then
		return false, "already hidden"
	end
	if state.occupant[spotKey] ~= nil then
		return false, "occupied"
	end
	state.occupant[spotKey] = player
	state.hiddenIn[player] = spotKey
	state.since[player] = now
	return true, nil
end

function HideState.leave(state: State, player: string): number?
	local spotKey = state.hiddenIn[player]
	if spotKey == nil then
		return nil
	end
	state.occupant[spotKey] = nil
	state.hiddenIn[player] = nil
	state.since[player] = nil
	return spotKey
end

function HideState.isHidden(state: State, player: string): boolean
	return state.hiddenIn[player] ~= nil
end

function HideState.cold(state: State, player: string, now: number, entityActive: boolean): Cold
	local since = state.since[player]
	if since == nil then
		return "none"
	end
	if entityActive then
		state.since[player] = now
		return "none"
	end
	local elapsed = now - since
	if elapsed >= GameConfig.HIDE_COLD_EJECT then
		return "eject"
	elseif elapsed >= GameConfig.HIDE_COLD_WARN then
		return "warn"
	end
	return "none"
end

-- Alle, die in Verstecken der Wagen < minCarriage sitzen (z. B. vor dem Abkoppeln).
function HideState.occupantsBefore(state: State, minCarriage: number): { string }
	local list: { string } = {}
	for player, spotKey in state.hiddenIn do
		if HideState.carriageOf(spotKey) < minCarriage then
			table.insert(list, player)
		end
	end
	table.sort(list)
	return list
end

return table.freeze(HideState)
