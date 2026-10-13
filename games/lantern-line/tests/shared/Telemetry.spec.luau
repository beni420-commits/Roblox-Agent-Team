--!strict
local Events = require("../../src/shared/Telemetry/Events")
local GameConfig = require("../../src/shared/Config/GameConfig")
local TestRunner = require("../TestRunner")

local expect = TestRunner.expect
local suite = TestRunner.suite("lantern-line/Telemetry/Events")

TestRunner.it(suite, "Onboarding-Schritte lückenlos 1–8, Lauf-Meilensteine aufsteigend bis Wagen 50", function()
	for i = 1, 8 do
		expect(type(Events.ONBOARDING_STEPS[i])):toBe("string")
	end
	expect(Events.ONBOARDING_STEPS[9]):toBe(nil)
	local last = 0
	for _, m in Events.MILESTONES do
		expect(m > last):toBe(true)
		last = m
	end
	expect(last):toBe(GameConfig.RUN_LAST_CARRIAGE)
	expect(Events.milestoneStep(1)):toBe(1)
	expect(Events.milestoneStep(50)):toBe(#Events.MILESTONES)
	expect(Events.milestoneStep(7)):toBe(nil)
	expect(Events.FINISH_STEP):toBe(#Events.MILESTONES + 1)
end)

TestRunner.it(suite, "Custom-Events: Name = Schlüssel, höchstens 10 (Kardinalität klein halten)", function()
	local count = 0
	for key, name in Events.CUSTOM do
		expect(key):toBe(name)
		count += 1
	end
	expect(count <= 10):toBe(true)
end)

return suite
