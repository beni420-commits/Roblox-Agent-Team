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

TestRunner.it(suite, "span: Zeitspanne der Proben, 0 nach reset (Bewegungsprüfung erst mit vollem Fenster)", function()
	local tracker = MotionTracker.new()
	expect(MotionTracker.span(tracker)):toBe(0)
	MotionTracker.add(tracker, 10, 0, 0)
	expect(MotionTracker.span(tracker)):toBe(0)
	-- Netz-Jitter: zwei Pakete in 0,05 s wirken wie 32 Studs/s, das Fenster ist aber zu kurz zum Urteilen
	MotionTracker.add(tracker, 10.05, 1.6, 0)
	expect(MotionTracker.speed(tracker, 1.0) > 24):toBe(true)
	expect(MotionTracker.span(tracker) < 0.8):toBe(true)
	for i = 2, 20 do
		MotionTracker.add(tracker, 10 + i * 0.05, i * 0.8, 0) -- 16 Studs/s
	end
	expect(MotionTracker.span(tracker) >= 0.8):toBe(true)
	expect(MotionTracker.speed(tracker, 1.0) <= 24):toBe(true)
	MotionTracker.reset(tracker)
	expect(MotionTracker.span(tracker)):toBe(0)
end)

return suite
