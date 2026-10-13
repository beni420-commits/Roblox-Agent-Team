--!strict
local GameConfig = require("../../../src/shared/Config/GameConfig")
local Oncoming = require("../../../src/shared/Logic/Oncoming")
local TestRunner = require("../../TestRunner")
local TrainGenerator = require("../../../src/shared/Logic/TrainGenerator")
local Types = require("../../../src/shared/Logic/Types")

local expect = TestRunner.expect
local suite = TestRunner.suite("lantern-line/Logic/Oncoming")

local function find(): (Types.Plan, number)
	for s = 1, 300 do
		local plan = TrainGenerator.generate(s)
		for _, c in plan.carriages do
			if c.event and (c.event :: Types.Event).kind == "oncoming" then
				return plan, c.index
			end
		end
	end
	error("no oncoming found")
end

TestRunner.it(suite, "Fahrplan: Warnzeit, dann ONCOMING_DURATION Licht über die angehängten Wagen", function()
	local plan, k = find()
	local event = plan.carriages[k + 1].event :: Types.Event
	local s = Oncoming.schedule(plan, k, 50)
	expect(s.side == 1 or s.side == -1):toBe(true)
	expect(s.side):toBe(event.side)
	expect(s.hitAt):toBeNear(50 + event.delay, 1e-9)
	expect(s.endAt - s.hitAt):toBeNear(GameConfig.ONCOMING_DURATION, 1e-9)
	local first = plan.carriages[math.max(0, k - GameConfig.RETAIN_BEHIND) + 1]
	expect(s.x0):toBe(first.originX - GameConfig.GANGWAY)
end)

TestRunner.it(suite, "Treffer nur auf der Fensterseite, im Zeitfenster, nicht versteckt", function()
	local plan, k = find()
	local s = Oncoming.schedule(plan, k, 0)
	local x = plan.carriages[k + 1].originX + 10
	local t = s.hitAt + 0.5
	local danger = s.side * 3
	local safe = -s.side * 3
	expect(Oncoming.hits(s, t, x, danger, false)):toBe(true)
	expect(Oncoming.hits(s, t, x, 0, false)):toBe(true) -- Mitte ist nicht sicher
	expect(Oncoming.hits(s, t, x, safe, false)):toBe(false)
	expect(Oncoming.hits(s, t, x, danger, true)):toBe(false)
	expect(Oncoming.hits(s, s.hitAt - 0.1, x, danger, false)):toBe(false)
	expect(Oncoming.hits(s, s.endAt + 0.1, x, danger, false)):toBe(false)
	expect(Oncoming.hits(s, t, s.x1 + 5, danger, false)):toBe(false) -- Wagen dahinter (noch zu)
	expect(Oncoming.isActive(s, s.warnAt)):toBe(true)
end)

return suite
