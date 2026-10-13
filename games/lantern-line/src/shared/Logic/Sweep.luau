--!strict
-- Kinematik der Wesen, die den Zug entlang fegen (Sweep): Express (§6.1) und Kofferlawine (§6.6).
-- Server und Client rechnen mit demselben Fahrplan: Der Server prüft Treffer, der Client zeichnet.
-- Zeiten sind Serverzeit (workspace:GetServerTimeNow()), x ist Welt-x entlang des Zugs.

local GameConfig = require("../Config/GameConfig")
local Types = require("./Types")

export type Schedule = {
	kind: string, -- "express" | "chase"
	carriage: number, -- Wagen, dessen Betreten das Ereignis ausgelöst hat
	warnAt: number,
	startAt: number,
	endAt: number,
	x0: number,
	x1: number,
}

local Sweep = {}

local function carriage(plan: Types.Plan, index: number): Types.Carriage
	local c = plan.carriages[index + 1]
	assert(c, "carriage out of range")
	return c
end

-- Express: startet EXPRESS_SPAWN_BEHIND hinter Wagen k−1 und endet an der Front von Wagen k.
function Sweep.express(plan: Types.Plan, k: number, triggerTime: number): Schedule
	local prev, cur = carriage(plan, k - 1), carriage(plan, k)
	local event = cur.event
	assert(event and event.kind == "express", "carriage has no express event")
	local x0 = prev.originX - GameConfig.EXPRESS_SPAWN_BEHIND
	local x1 = cur.originX + cur.length
	local startAt = triggerTime + event.delay
	return {
		kind = "express",
		carriage = k,
		warnAt = triggerTime,
		startAt = startAt,
		endAt = startAt + (x1 - x0) / event.speed,
		x0 = x0,
		x1 = x1,
	}
end

-- Kofferlawine: startet am Heck von Wagen c−1 und endet an der Vordertür von Wagen c+CHASE_LENGTH−1.
function Sweep.chase(plan: Types.Plan, c: number, triggerTime: number): Schedule
	local first = carriage(plan, c - 1)
	local last = carriage(plan, c + GameConfig.CHASE_LENGTH - 1)
	local x0 = first.originX
	local x1 = last.originX + last.length
	local startAt = triggerTime + GameConfig.CHASE_WARN
	return {
		kind = "chase",
		carriage = c,
		warnAt = triggerTime,
		startAt = startAt,
		endAt = startAt + (x1 - x0) / GameConfig.CHASE_SPEED,
		x0 = x0,
		x1 = x1,
	}
end

-- Position der Front zum Zeitpunkt t (nil vor dem Start und nach dem Ende).
function Sweep.positionAt(s: Schedule, t: number): number?
	if t < s.startAt or t > s.endAt then
		return nil
	end
	return s.x0 + (s.x1 - s.x0) * (t - s.startAt) / (s.endAt - s.startAt)
end

-- Überstrichener Bereich zwischen ta und tb (nil, wenn das Wesen in dem Zeitraum nicht fährt).
function Sweep.sweep(s: Schedule, ta: number, tb: number): (number?, number?)
	local a = math.max(ta, s.startAt)
	local b = math.min(tb, s.endAt)
	if a > b then
		return nil, nil
	end
	return Sweep.positionAt(s, a), Sweep.positionAt(s, b)
end

function Sweep.isActive(s: Schedule, t: number): boolean
	return t >= s.warnAt and t <= s.endAt
end

-- Trifft der Express im Zeitraum [ta, tb] einen nicht versteckten Spieler an Welt-x px?
function Sweep.expressHits(s: Schedule, ta: number, tb: number, px: number): boolean
	local lo, hi = Sweep.sweep(s, ta, tb)
	if lo == nil or hi == nil then
		return false
	end
	local margin = GameConfig.EXPRESS_KILL_MARGIN
	return px >= lo - margin and px <= hi + margin and px >= s.x0 and px <= s.x1
end

-- Holt die Kofferlawine einen Spieler an Welt-x px ein? (Verstecke schützen nicht.)
function Sweep.chaseCatches(s: Schedule, t: number, px: number): boolean
	local front = Sweep.positionAt(s, t)
	if front == nil then
		return false
	end
	return px <= front + GameConfig.CHASE_CATCH
end

-- Kupplung der Kofferlawine (Compliance H-A17, eigene Kernmechanik): im Übergang an der Front von
-- Wagen c + CHASE_COUPLING_WAGON. Sind alle Lebenden vorbei, kann die Gruppe abkoppeln.
function Sweep.couplingX(plan: Types.Plan, c: number): number
	local wagon = carriage(plan, c + GameConfig.CHASE_COUPLING_WAGON)
	return wagon.originX + wagon.length + GameConfig.CHASE_COUPLING_OFFSET
end

-- Darf jetzt abgekoppelt werden? Lawine läuft (inkl. Warnzeit), alle Lebenden stehen hinter der Tür vor der Kupplung.
function Sweep.canUncouple(s: Schedule, couplingX: number, t: number, alivePositions: { number }): boolean
	if s.kind ~= "chase" or t < s.warnAt or t > s.endAt or #alivePositions == 0 then
		return false
	end
	local doorX = couplingX - GameConfig.CHASE_COUPLING_OFFSET
	for _, px in alivePositions do
		if px <= doorX + 0.5 then
			return false
		end
	end
	return true
end

-- Hält die Lawine zum Zeitpunkt t an (sie bleibt mit den abgekoppelten Wagen zurück).
function Sweep.stop(s: Schedule, t: number)
	if t >= s.endAt then
		return
	end
	if t <= s.startAt then
		s.startAt = t
		s.endAt = t
		s.x1 = s.x0
		return
	end
	local x = Sweep.positionAt(s, t) :: number
	s.x1 = x
	s.endAt = t
end

return table.freeze(Sweep)
