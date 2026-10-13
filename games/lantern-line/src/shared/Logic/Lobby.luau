--!strict
-- Bahnsteig-Countdown (§8): startet, sobald einer bereit ist; verkürzt sich, wenn alle bereit sind.

local GameConfig = require("../Config/GameConfig")

export type State = { endsAt: number? }

local Lobby = {}

function Lobby.new(): State
	return { endsAt = nil }
end

-- Liefert true, wenn der Zug jetzt abfährt.
function Lobby.update(state: State, now: number, ready: number, total: number): boolean
	if ready <= 0 or total <= 0 then
		state.endsAt = nil
		return false
	end
	local target = now + if ready >= total then GameConfig.LOBBY_COUNTDOWN_ALL_READY else GameConfig.LOBBY_COUNTDOWN
	local current = state.endsAt
	if current == nil or target < current then
		state.endsAt = target
	end
	return now >= (state.endsAt :: number)
end

function Lobby.remaining(state: State, now: number): number?
	local endsAt = state.endsAt
	if endsAt == nil then
		return nil
	end
	return math.max(0, endsAt - now)
end

return table.freeze(Lobby)
