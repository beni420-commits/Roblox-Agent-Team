--!strict
local MotionTracker = require("../../../src/shared/Logic/MotionTracker")
local TestRunner = require("../../TestRunner")

local expect = TestRunner.expect
local suite = TestRunner.suite("lantern-line/Logic/MotionTracker")

TestRunner.it(suite, "Verschiebung und Tempo über ein Fenster aus 10-Hz-Proben", function()
	local tracker = MotionTracker.new()
	expect(MotionTracker.displacement(tracker, 0.3)):toBe(0)
	for i = 0, 10 do
		MotionTracker.add(tracker, i * 0.1, i * 1.6, 0) -- 16 Studs/s
	end
	expect(MotionTracker.displacement(tracker, 0.3)):toBeNear(4.8, 1e-9)
	expect(MotionTracker.speed(tracker, 0.3)):toBeNear(16, 1e-9)
	-- Stillstand: neue Proben am selben Ort
	for i = 11, 15 do
		MotionTracker.add(tracker, i * 0.1, 16, 0)
	end
	expect(MotionTracker.displacement(tracker, 0.3)):toBeNear(0, 1e-9)
	expect(MotionTracker.speed(tracker, 0.25)):toBeNear(0, 1e-9)
end)

TestRunner.it(suite, "alte Proben werden verworfen; reset leert", function()
	local tracker = MotionTracker.new()
	for i = 0, 100 do
		MotionTracker.add(tracker, i * 0.05, 0, i * 0.1)
	end
	expect(#tracker.samples <= 22):toBe(true)
	MotionTracker.reset(tracker)
	expect(#tracker.samples):toBe(0)
end)

return suite
