--!strict
local TestRunner = require("../TestRunner")
local Events = require("../../src/shared/Telemetry/Events")

local expect = TestRunner.expect
local suite = TestRunner.suite("shared/Telemetry/Events")

TestRunner.it(suite, "Katalog bleibt unter 20 Custom-Event-Namen (Limit 100, Plan ≤ 20)", function()
	local count = 0
	for _ in Events.CUSTOM do
		count += 1
	end
	expect(count <= 20):toBeTruthy()
end)

TestRunner.it(suite, "Onboarding-Funnel hat lückenlose Schritte 1–8", function()
	for step = 1, 8 do
		expect(type(Events.ONBOARDING_STEPS[step])):toBe("string")
	end
	expect(Events.ONBOARDING_STEPS[9]):toBe(nil)
end)

TestRunner.it(suite, "Bündel begrenzen die Kardinalität", function()
	expect(Events.floorBucket(0)):toBe("F00-04")
	expect(Events.floorBucket(7)):toBe("F05-09")
	expect(Events.secondsBucket(45)):toBe("31-60")
	expect(Events.secondsBucket(500)):toBe(">120")
	local buckets: { [string]: boolean } = {}
	for floor = 0, 30 do
		buckets[Events.floorBucket(floor)] = true
	end
	local n = 0
	for _ in buckets do
		n += 1
	end
	expect(n <= 7):toBeTruthy()
end)

return suite
