--!strict
-- Schaffner im Postwagen (§6.5, Compliance H-A3): sieht nur, was der Lichtkegel seiner Laterne trifft
-- (Entfernung, Öffnungswinkel, freie Sicht an Regalen vorbei), und hört laute Schritte.
-- Bewegt sich auf dem Wegenetz; Streife langsam, Jagd langsamer als Laufen, schneller als Schleichen.
-- Koordinaten sind lokal zum Postwagen (x ab hinterer Tür, z ab Wagenmitte).

local GameConfig = require("../Config/GameConfig")
local NavGraph = require("./NavGraph")
local Prng = require("../Util/Prng")
local Types = require("./Types")

export type Mode = "dormant" | "patrol" | "hunt"

export type Point = { x: number, z: number }

export type State = {
	graph: NavGraph.Graph,
	blockers: { Types.Box },
	rng: Prng.Prng,
	x: number,
	z: number,
	fx: number,
	fz: number,
	path: { Point },
	mode: Mode,
	wakeAt: number,
	lastAlertAt: number,
	targetNode: number,
	direct: boolean,
	revision: number, -- steigt bei jeder Wegänderung (Server schickt dann ein Update an die Clients)
}

export type Listener = {
	key: string,
	x: number,
	z: number,
	speed: number,
	hidden: boolean,
	alive: boolean,
}

export type Noise = { x: number, z: number, radius: number }

local DIRECT_APPROACH = 7 -- ab hier läuft er auf Sicht direkt auf das Ziel zu
local BLOCKER_MIN_HEIGHT = 5
local PATROL_MIN_DISTANCE = 20

local Conductor = {}

-- Strecke (x0,z0)→(x1,z1) schneidet die Box (ohne Vergrößerung)? Slab-Verfahren in 2D.
function Conductor.segmentHitsBox(x0: number, z0: number, x1: number, z1: number, box: Types.Box): boolean
	local tMin, tMax = 0, 1
	local hx, hz = box.sx / 2, box.sz / 2
	local d = { x1 - x0, z1 - z0 }
	local o = { x0 - box.cx, z0 - box.cz }
	local h = { hx, hz }
	for axis = 1, 2 do
		if math.abs(d[axis]) < 1e-9 then
			if math.abs(o[axis]) > h[axis] then
				return false
			end
		else
			local t1 = (-h[axis] - o[axis]) / d[axis]
			local t2 = (h[axis] - o[axis]) / d[axis]
			if t1 > t2 then
				t1, t2 = t2, t1
			end
			tMin = math.max(tMin, t1)
			tMax = math.min(tMax, t2)
			if tMin > tMax then
				return false
			end
		end
	end
	return true
end

function Conductor.lineOfSight(state: State, x: number, z: number): boolean
	for _, box in state.blockers do
		if Conductor.segmentHitsBox(state.x, state.z, x, z, box) then
			return false
		end
	end
	return true
end

function Conductor.new(post: Types.PostLayout, obstacles: { Types.Box }, seed: number, now: number): State
	local graph = NavGraph.new(post.nodes, post.edges)
	local start = post.nodes[post.conductorStart]
	local blockers: { Types.Box } = {}
	for _, box in obstacles do
		if box.h >= BLOCKER_MIN_HEIGHT then
			table.insert(blockers, box)
		end
	end
	return {
		graph = graph,
		blockers = blockers,
		rng = Prng.new(seed),
		x = start.x,
		z = start.z,
		fx = -1, -- blickt zum Eingang
		fz = 0,
		path = {},
		mode = "dormant",
		wakeAt = now + GameConfig.CONDUCTOR_WAKE,
		lastAlertAt = -math.huge,
		targetNode = post.conductorStart,
		direct = false,
		revision = 0,
	}
end

function Conductor.noiseRadius(speed: number): number
	if speed > GameConfig.NOISE_WALK_SPEED then
		return GameConfig.NOISE_WALK_RADIUS
	elseif speed > GameConfig.NOISE_MIN_SPEED then
		return GameConfig.NOISE_SNEAK_RADIUS
	end
	return 0
end

-- Trifft der Laternenkegel den Punkt?
function Conductor.sees(state: State, x: number, z: number): boolean
	local dx, dz = x - state.x, z - state.z
	local d = math.sqrt(dx * dx + dz * dz)
	if d > GameConfig.CONDUCTOR_VIEW_DISTANCE then
		return false
	end
	if d > 1e-6 then
		local cosAngle = (dx * state.fx + dz * state.fz) / d
		if cosAngle < math.cos(math.rad(GameConfig.CONDUCTOR_VIEW_ANGLE)) then
			return false
		end
	end
	return Conductor.lineOfSight(state, x, z)
end

local function setPath(state: State, path: { Point }, targetNode: number, direct: boolean)
	state.path = path
	state.targetNode = targetNode
	state.direct = direct
	state.revision += 1
end

local function planTo(state: State, tx: number, tz: number)
	local dx, dz = tx - state.x, tz - state.z
	local close = dx * dx + dz * dz <= DIRECT_APPROACH * DIRECT_APPROACH
	local node = NavGraph.nearest(state.graph, tx, tz)
	if close and Conductor.lineOfSight(state, tx, tz) then
		-- Auf Sicht direkt hin; jedes Update ändert das Ziel leicht.
		setPath(state, { { x = tx, z = tz } }, node, true)
		return
	end
	if node == state.targetNode and not state.direct and #state.path > 0 then
		return -- gleiches Ziel, Weg bleibt
	end
	local from = NavGraph.nearest(state.graph, state.x, state.z)
	local ids = NavGraph.shortestPath(state.graph, from, node)
	local path: { Point } = {}
	for _, id in ids do
		local n = state.graph.nodes[id]
		table.insert(path, { x = n.x, z = n.z })
	end
	setPath(state, path, node, false)
end

local function planPatrol(state: State)
	local nodes = state.graph.nodes
	local pick = state.rng.nextInt(1, #nodes)
	for _ = 1, 10 do
		local n = nodes[pick]
		local dx, dz = n.x - state.x, n.z - state.z
		if dx * dx + dz * dz >= PATROL_MIN_DISTANCE * PATROL_MIN_DISTANCE then
			break
		end
		pick = state.rng.nextInt(1, #nodes)
	end
	local from = NavGraph.nearest(state.graph, state.x, state.z)
	local path: { Point } = {}
	for _, id in NavGraph.shortestPath(state.graph, from, pick) do
		local n = nodes[id]
		table.insert(path, { x = n.x, z = n.z })
	end
	setPath(state, path, pick, false)
end

function Conductor.speed(state: State): number
	if state.mode == "hunt" then
		return GameConfig.CONDUCTOR_HUNT_SPEED
	elseif state.mode == "patrol" then
		return GameConfig.CONDUCTOR_PATROL_SPEED
	end
	return 0
end

local function move(state: State, dt: number)
	local remaining = Conductor.speed(state) * dt
	while remaining > 0 and #state.path > 0 do
		local wp = state.path[1]
		local dx, dz = wp.x - state.x, wp.z - state.z
		local d = math.sqrt(dx * dx + dz * dz)
		if d > 1e-6 then
			state.fx, state.fz = dx / d, dz / d
		end
		if d <= remaining then
			state.x, state.z = wp.x, wp.z
			remaining -= d
			table.remove(state.path, 1)
		else
			state.x += dx / d * remaining
			state.z += dz / d * remaining
			remaining = 0
		end
	end
end

-- Ein Simulationsschritt. Liefert die Schlüssel der gefangenen Spieler.
function Conductor.update(state: State, now: number, dt: number, listeners: { Listener }, noises: { Noise }): { string }
	local modeBefore = state.mode
	local caught = Conductor.step(state, now, dt, listeners, noises)
	if state.mode ~= modeBefore then
		-- Tempowechsel sofort an die Clients melden (Code-Review LL-13)
		state.revision += 1
	end
	return caught
end

function Conductor.step(state: State, now: number, dt: number, listeners: { Listener }, noises: { Noise }): { string }
	if state.mode == "dormant" then
		if now < state.wakeAt then
			return {}
		end
		state.mode = "patrol"
		planPatrol(state)
	end

	-- Wahrnehmung: nächstgelegener gesehener oder gehörter Punkt.
	local bestX, bestZ, bestD = 0, 0, math.huge
	local function consider(x: number, z: number)
		local dx, dz = x - state.x, z - state.z
		local d = dx * dx + dz * dz
		if d < bestD then
			bestX, bestZ, bestD = x, z, d
		end
	end
	for _, p in listeners do
		if p.alive and not p.hidden then
			local dx, dz = p.x - state.x, p.z - state.z
			local d = math.sqrt(dx * dx + dz * dz)
			if d <= Conductor.noiseRadius(p.speed) or Conductor.sees(state, p.x, p.z) then
				consider(p.x, p.z)
			end
		end
	end
	for _, noise in noises do
		local dx, dz = noise.x - state.x, noise.z - state.z
		if dx * dx + dz * dz <= noise.radius * noise.radius then
			consider(noise.x, noise.z)
		end
	end

	if bestD < math.huge then
		state.mode = "hunt"
		state.lastAlertAt = now
		planTo(state, bestX, bestZ)
	elseif state.mode == "hunt" and now - state.lastAlertAt > GameConfig.CONDUCTOR_FORGET then
		state.mode = "patrol"
		planPatrol(state)
	elseif #state.path == 0 then
		if state.mode == "patrol" then
			planPatrol(state)
		end
	end

	move(state, dt)

	local caught: { string } = {}
	for _, p in listeners do
		if p.alive and not p.hidden then
			local dx, dz = p.x - state.x, p.z - state.z
			if dx * dx + dz * dz <= GameConfig.CONDUCTOR_CATCH * GameConfig.CONDUCTOR_CATCH then
				table.insert(caught, p.key)
			end
		end
	end
	return caught
end

return table.freeze(Conductor)
