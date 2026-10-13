--!strict
local FlickerPlanner = require("../../../src/shared/Logic/FlickerPlanner")
local TestRunner = require("../../TestRunner")

local expect = TestRunner.expect
local suite = TestRunner.suite("lantern-line/Logic/FlickerPlanner")

TestRunner.it(suite, "Compliance H-A10: höchstens 2 Blitze in jedem 1-s-Fenster (500 Pläne)", function()
	for seed = 1, 500 do
		local list = FlickerPlanner.pulses(seed, 0, 2 + (seed % 7))
		expect(#list > 0):toBe(true)
		local worst = FlickerPlanner.maxInWindow(list, 1)
		if worst > FlickerPlanner.MAX_PER_SECOND then
			error(string.format("seed %d: %d flashes in 1 s", seed, worst))
		end
		for _, pulse in list do
			expect(pulse.t1 > pulse.t0):toBe(true)
		end
	end
end)

TestRunner.it(suite, "maxInWindow zählt korrekt (Gegenprobe mit 3 Pulsen in 1 s)", function()
	local list = { { t0 = 0, t1 = 0.1 }, { t0 = 0.4, t1 = 0.5 }, { t0 = 0.8, t1 = 0.9 }, { t0 = 2, t1 = 2.1 } }
	expect(FlickerPlanner.maxInWindow(list, 1)):toBe(3)
end)

TestRunner.it(suite, "Flackern reduzieren: keine Sprünge, nie dunkler als REDUCED_LEVEL", function()
	local list = FlickerPlanner.pulses(3, 10, 14)
	local prev = FlickerPlanner.levelAt(list, 10, 14, 9.9, true)
	for i = 0, 450 do
		local t = 9.9 + i * 0.01
		local level = FlickerPlanner.levelAt(list, 10, 14, t, true)
		expect(level >= FlickerPlanner.REDUCED_LEVEL - 1e-9):toBe(true)
		-- Übergang ≥ 0,3 s: in 0,01 s höchstens (1 − Stufe) / 0,3 · 0,01 Änderung
		expect(math.abs(level - prev) <= (1 - FlickerPlanner.REDUCED_LEVEL) / 0.3 * 0.01 + 1e-9):toBe(true)
		prev = level
	end
	expect(FlickerPlanner.levelAt(list, 10, 14, 9, false)):toBe(1)
	expect(FlickerPlanner.levelAt(list, 10, 14, list[1].t0 + 0.01, false)):toBe(FlickerPlanner.DIM_LEVEL)
end)

return suite
