--!strict
local GameConfig = require("../../../src/shared/Config/GameConfig")
local Rush = require("../../../src/shared/Logic/Rush")
local TestRunner = require("../../TestRunner")
local TrainGenerator = require("../../../src/shared/Logic/TrainGenerator")
local Types = require("../../../src/shared/Logic/Types")

local expect = TestRunner.expect
local suite = TestRunner.suite("lantern-line/Logic/Rush")

-- Sucht einen Plan mit Express-Ereignis.
local function planWithExpress(): (Types.Plan, number)
	for s = 1, 200 do
		local plan = TrainGenerator.generate(s)
		for _, c in plan.carriages do
			if c.event and (c.event :: Types.Event).kind == "express" then
				return plan, c.index
			end
		end
	end
	error("no express found")
end

local function chaseStart(plan: Types.Plan): number
	for _, c in plan.carriages do
		if c.event and (c.event :: Types.Event).kind == "chase" then
			return c.index
		end
	end
	error("no chase")
end

TestRunner.it(suite, "Express-Fahrplan: Start hinter k−1, Ende an der Front von k, konstantes Tempo", function()
	local plan, k = planWithExpress()
	local prev, cur = plan.carriages[k], plan.carriages[k + 1]
	local event = cur.event :: Types.Event
	local s = Rush.express(plan, k, 100)
	expect(s.x0):toBe(prev.originX - GameConfig.EXPRESS_SPAWN_BEHIND)
	expect(s.x1):toBe(cur.originX + cur.length)
	expect(s.startAt):toBeNear(100 + event.delay, 1e-9)
	expect((s.endAt - s.startAt) * event.speed):toBeNear(s.x1 - s.x0, 1e-6)
	expect(Rush.positionAt(s, s.startAt - 0.01)):toBe(nil)
	expect(Rush.positionAt(s, s.endAt + 0.01)):toBe(nil)
	expect(Rush.positionAt(s, (s.startAt + s.endAt) / 2) :: number):toBeNear((s.x0 + s.x1) / 2, 1e-6)
	expect(Rush.isActive(s, 100)):toBe(true) -- Warnung läuft schon
	expect(Rush.isActive(s, s.endAt + 1)):toBe(false)
end)

TestRunner.it(suite, "Express trifft nur, was er in diesem Zeitraum überstreicht (mit Rand)", function()
	local plan, k = planWithExpress()
	local s = Rush.express(plan, k, 0)
	local mid = (s.startAt + s.endAt) / 2
	local xMid = Rush.positionAt(s, mid) :: number
	local x2 = Rush.positionAt(s, mid + 0.1) :: number
	expect(Rush.expressHits(s, mid, mid + 0.1, (xMid + x2) / 2)):toBe(true)
	expect(Rush.expressHits(s, mid, mid + 0.1, x2 + GameConfig.EXPRESS_KILL_MARGIN - 0.01)):toBe(true)
	expect(Rush.expressHits(s, mid, mid + 0.1, x2 + GameConfig.EXPRESS_KILL_MARGIN + 0.5)):toBe(false)
	expect(Rush.expressHits(s, mid, mid + 0.1, xMid - 10)):toBe(false) -- schon vorbei
	expect(Rush.expressHits(s, s.warnAt, s.startAt - 0.01, s.x0)):toBe(false) -- Warnphase
	expect(Rush.expressHits(s, s.endAt - 0.01, s.endAt + 1, s.x1 + 1)):toBe(false) -- hinter der Endtür
end)

TestRunner.it(suite, "Kofferlawine: langsamer als Laufen, fängt alles hinter ihrer Front", function()
	local plan = TrainGenerator.generate(4242)
	local c = chaseStart(plan)
	local s = Rush.chase(plan, c, 10)
	expect(s.startAt):toBe(10 + GameConfig.CHASE_WARN)
	expect(s.x0):toBe(plan.carriages[c].originX) -- Heck von Wagen c−1
	local last = plan.carriages[c + GameConfig.CHASE_LENGTH]
	expect(s.x1):toBe(last.originX + last.length)
	expect(GameConfig.CHASE_SPEED < GameConfig.WALK_SPEED):toBe(true)
	local t = s.startAt + 2
	local front = Rush.positionAt(s, t) :: number
	expect(Rush.chaseCatches(s, t, front - 20)):toBe(true)
	expect(Rush.chaseCatches(s, t, front + GameConfig.CHASE_CATCH - 0.1)):toBe(true)
	expect(Rush.chaseCatches(s, t, front + GameConfig.CHASE_CATCH + 0.1)):toBe(false)
	expect(Rush.chaseCatches(s, s.startAt - 0.5, s.x0)):toBe(false) -- Warnzeit
	-- Wer beim Auslösen am Heck von c−1 steht und sofort läuft, wird nie eingeholt.
	for dt = 0, (s.endAt - 10), 0.25 do
		local player = s.x0 + GameConfig.WALK_SPEED * dt
		expect(Rush.chaseCatches(s, 10 + dt, math.min(player, s.x1 + 5))):toBe(false)
	end
end)

return suite
