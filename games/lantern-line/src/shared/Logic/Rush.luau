--!strict
-- Kinematik der Wesen, die den Zug entlang fahren: Express (§6.1) und Kofferlawine (§6.6).
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

local Rush = {}

local function carriage(plan: Types.Plan, index: number): Types.Carriage
	local c = plan.carriages[index + 1]
	assert(c, "carriage out of range")
	return c
end

-- Express: startet EXPRESS_SPAWN_BEHIND hinter Wagen k−1 und endet an der Front von Wagen k.
function Rush.express(plan: Types.Plan, k: number, triggerTime: number): Schedule
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
function Rush.chase(plan: Types.Plan, c: number, triggerTime: number): Schedule
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
function Rush.positionAt(s: Schedule, t: number): number?
	if t < s.startAt or t > s.endAt then
		return nil
	end
	return s.x0 + (s.x1 - s.x0) * (t - s.startAt) / (s.endAt - s.startAt)
end

-- Überstrichener Bereich zwischen ta und tb (nil, wenn das Wesen in dem Zeitraum nicht fährt).
function Rush.sweep(s: Schedule, ta: number, tb: number): (number?, number?)
	local a = math.max(ta, s.startAt)
	local b = math.min(tb, s.endAt)
	if a > b then
		return nil, nil
	end
	return Rush.positionAt(s, a), Rush.positionAt(s, b)
end

function Rush.isActive(s: Schedule, t: number): boolean
	return t >= s.warnAt and t <= s.endAt
end

-- Trifft der Express im Zeitraum [ta, tb] einen nicht versteckten Spieler an Welt-x px?
function Rush.expressHits(s: Schedule, ta: number, tb: number, px: number): boolean
	local lo, hi = Rush.sweep(s, ta, tb)
	if lo == nil or hi == nil then
		return false
	end
	local margin = GameConfig.EXPRESS_KILL_MARGIN
	return px >= lo - margin and px <= hi + margin and px >= s.x0 and px <= s.x1
end

-- Holt die Kofferlawine einen Spieler an Welt-x px ein? (Verstecke schützen nicht.)
function Rush.chaseCatches(s: Schedule, t: number, px: number): boolean
	local front = Rush.positionAt(s, t)
	if front == nil then
		return false
	end
	return px <= front + GameConfig.CHASE_CATCH
end

return table.freeze(Rush)
