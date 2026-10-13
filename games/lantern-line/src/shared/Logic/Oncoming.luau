--!strict
-- Gegenzug (§6.2): Nach der Warnzeit flutet Licht für ONCOMING_DURATION die Fensterseite `side`
-- aller noch angehängten Wagen bis Wagen k. Sicher ist, wer auf der anderen Hälfte steht oder versteckt ist.

local Fairness = require("./Fairness")
local GameConfig = require("../Config/GameConfig")
local Types = require("./Types")

export type Schedule = {
	carriage: number,
	side: number,
	warnAt: number,
	hitAt: number,
	endAt: number,
	x0: number,
	x1: number,
}

local Oncoming = {}

function Oncoming.schedule(plan: Types.Plan, k: number, triggerTime: number): Schedule
	local cur = plan.carriages[k + 1]
	assert(cur, "carriage out of range")
	local event = cur.event
	assert(event and event.kind == "oncoming", "carriage has no oncoming event")
	local first = plan.carriages[math.max(0, k - GameConfig.RETAIN_BEHIND) + 1]
	local hitAt = triggerTime + event.delay
	return {
		carriage = k,
		side = event.side,
		warnAt = triggerTime,
		hitAt = hitAt,
		endAt = hitAt + GameConfig.ONCOMING_DURATION,
		x0 = first.originX - GameConfig.GANGWAY,
		x1 = cur.originX + cur.length,
	}
end

function Oncoming.isActive(s: Schedule, t: number): boolean
	return t >= s.warnAt and t <= s.endAt
end

-- z ist die Welt-z-Position relativ zur Zugmitte.
function Oncoming.hits(s: Schedule, t: number, px: number, pz: number, hidden: boolean): boolean
	if hidden or t < s.hitAt or t > s.endAt then
		return false
	end
	if px < s.x0 or px > s.x1 then
		return false
	end
	return not Fairness.isOncomingSafe(s.side, pz)
end

return table.freeze(Oncoming)
