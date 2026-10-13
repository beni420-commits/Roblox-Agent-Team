--!strict
-- Zustand eines Laufs (Server-Autorität): Türen, Schlüssel, Behälter, Leben, Rätsel, Ende.
-- Schlüssel gehören der Gruppe (Schlüsselbund im HUD), damit ein Tod nie zur Sackgasse führt.

local GameConfig = require("../Config/GameConfig")
local Puzzle = require("./Puzzle")
local Types = require("./Types")

export type Phase = "lobby" | "running" | "ended"
export type Outcome = "won" | "lost"

export type PlayerRun = {
	alive: boolean,
	stubs: number,
	cause: string?,
	diedIn: number?,
}

export type State = {
	plan: Types.Plan,
	phase: Phase,
	opened: number, -- höchster betretener Wagen (Tür `opened` ist offen)
	keys: { [number]: boolean }, -- Türnummer → Schlüssel vorhanden
	players: { [string]: PlayerRun },
	openedContainers: { [number]: boolean },
	readRows: { [number]: boolean },
	solved: boolean,
	outcome: Outcome?,
	startedAt: number,
	endedAt: number,
}

local RunState = {}

function RunState.new(plan: Types.Plan): State
	return {
		plan = plan,
		phase = "lobby",
		opened = 0,
		keys = {},
		players = {},
		openedContainers = {},
		readRows = {},
		solved = false,
		outcome = nil,
		startedAt = 0,
		endedAt = 0,
	}
end

function RunState.start(state: State, playerKeys: { string }, now: number)
	assert(state.phase == "lobby", "run already started")
	state.phase = "running"
	state.startedAt = now
	for _, key in playerKeys do
		state.players[key] = { alive = true, stubs = 0, cause = nil, diedIn = nil }
	end
end

local function carriage(state: State, index: number): Types.Carriage?
	return state.plan.carriages[index + 1]
end

-- Tür n führt in Wagen n und sitzt an der Front von Wagen n − 1.
function RunState.canOpenDoor(state: State, door: number): (boolean, string?)
	if state.phase ~= "running" then
		return false, "not running"
	end
	if door ~= state.opened + 1 or door > state.plan.lastIndex then
		return false, "not next door"
	end
	local before = carriage(state, door - 1)
	if before and before.locked and not state.keys[door] then
		return false, "locked"
	end
	return true, nil
end

-- Öffnet Tür n und liefert das Ereignis des neuen Wagens (falls vorhanden).
function RunState.openDoor(state: State, door: number): (boolean, Types.Event?)
	local ok = RunState.canOpenDoor(state, door)
	if not ok then
		return false, nil
	end
	state.opened = door
	state.keys[door] = nil
	local c = carriage(state, door)
	return true, if c then c.event else nil
end

-- Nur für Tests in Roblox Studio (Workspace-Attribut „DebugStartCarriage“): Lauf beginnt in Wagen n.
-- Ereignisse der übersprungenen Wagen entfallen. Liefert das Ereignis von Wagen n.
function RunState.debugSkipTo(state: State, index: number): (boolean, Types.Event?)
	if state.phase ~= "running" or state.opened ~= 0 or index < 1 or index > state.plan.lastIndex then
		return false, nil
	end
	state.opened = math.floor(index)
	local c = carriage(state, state.opened)
	return true, if c then c.event else nil
end

function RunState.containerKey(carriageIndex: number, containerId: number): number
	return carriageIndex * 100 + containerId
end

-- Öffnet einen Behälter (einmal je Lauf). Liefert Inhalt und Abrisse.
function RunState.openContainer(
	state: State,
	player: string,
	carriageIndex: number,
	containerId: number
): (boolean, string, number)
	local run = state.players[player]
	if state.phase ~= "running" or run == nil or not run.alive then
		return false, "none", 0
	end
	if carriageIndex > state.opened or carriageIndex < 0 then
		return false, "none", 0
	end
	local c = carriage(state, carriageIndex)
	local container = if c then c.containers[containerId] else nil
	if container == nil then
		return false, "none", 0
	end
	local key = RunState.containerKey(carriageIndex, containerId)
	if state.openedContainers[key] then
		return false, "none", 0
	end
	state.openedContainers[key] = true
	if container.content == "key" then
		state.keys[carriageIndex + 1] = true
	elseif container.content == "stubs" then
		run.stubs += container.stubs
	end
	return true, container.content, container.stubs
end

function RunState.kill(state: State, player: string, cause: string, carriageIndex: number): boolean
	local run = state.players[player]
	if run == nil or not run.alive or state.phase ~= "running" then
		return false
	end
	run.alive = false
	run.cause = cause
	run.diedIn = carriageIndex
	return true
end

-- Spieler verlässt den Server: zählt nicht mehr als lebend, aber nicht als Tod (keine Ursache).
function RunState.removePlayer(state: State, player: string)
	local run = state.players[player]
	if run then
		run.alive = false
	end
end

function RunState.alivePlayers(state: State): { string }
	local list: { string } = {}
	for key, run in state.players do
		if run.alive then
			table.insert(list, key)
		end
	end
	table.sort(list)
	return list
end

function RunState.isAlive(state: State, player: string): boolean
	local run = state.players[player]
	return run ~= nil and run.alive
end

function RunState.readFragment(state: State, row: number): boolean
	if state.opened ~= state.plan.lastIndex or row < 1 or row > 3 or state.readRows[row] then
		return false
	end
	state.readRows[row] = true
	return true
end

-- Entwerter: nur im Postwagen, nur einmal lösbar.
function RunState.submitPattern(state: State, mask: number): boolean
	local post = (carriage(state, state.plan.lastIndex) :: Types.Carriage).post
	if state.phase ~= "running" or state.opened ~= state.plan.lastIndex or state.solved or post == nil then
		return false
	end
	if Puzzle.check(post, mask) then
		state.solved = true
		return true
	end
	return false
end

-- Prüft das Lauf-Ende: alle tot (verloren) oder Ziel erreicht (gewonnen).
function RunState.checkEnd(state: State, now: number, finished: boolean): Outcome?
	if state.phase ~= "running" then
		return state.outcome
	end
	if finished and state.solved then
		state.phase = "ended"
		state.outcome = "won"
		state.endedAt = now
	elseif #RunState.alivePlayers(state) == 0 then
		state.phase = "ended"
		state.outcome = "lost"
		state.endedAt = now
	end
	return state.outcome
end

-- Wagen, die bestehen bleiben (alles davor wird abgekoppelt, „Der Ruck“).
function RunState.retainFrom(state: State): number
	return math.max(0, state.opened - GameConfig.RETAIN_BEHIND)
end

function RunState.buildUpTo(state: State): number
	return math.min(state.plan.lastIndex, state.opened + GameConfig.BUILD_AHEAD)
end

return table.freeze(RunState)
