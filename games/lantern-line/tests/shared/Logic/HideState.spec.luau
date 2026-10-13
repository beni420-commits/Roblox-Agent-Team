--!strict
local GameConfig = require("../../../src/shared/Config/GameConfig")
local HideState = require("../../../src/shared/Logic/HideState")
local TestRunner = require("../../TestRunner")

local expect = TestRunner.expect
local suite = TestRunner.suite("lantern-line/Logic/HideState")

TestRunner.it(suite, "genau eine Person je Versteck (Compliance H-A7); niemand in zwei Verstecken", function()
	local state = HideState.new()
	local spot = HideState.spotKey(12, 3)
	expect(HideState.carriageOf(spot)):toBe(12)
	expect((HideState.enter(state, "a", spot, 0))):toBe(true)
	local ok, why = HideState.enter(state, "b", spot, 0)
	expect(ok):toBe(false)
	expect(why):toBe("occupied")
	local ok2, why2 = HideState.enter(state, "a", HideState.spotKey(12, 4), 0)
	expect(ok2):toBe(false)
	expect(why2):toBe("already hidden")
	expect(HideState.leave(state, "a")):toBe(spot)
	expect(HideState.leave(state, "a")):toBe(nil)
	expect((HideState.enter(state, "b", spot, 1))):toBe(true)
	expect(HideState.isHidden(state, "b")):toBe(true)
end)

TestRunner.it(suite, "Kälte: Warnung, dann hinausschieben; aktive Wesen setzen die Zeit zurück", function()
	local state = HideState.new()
	HideState.enter(state, "a", 101, 0)
	expect(HideState.cold(state, "a", GameConfig.HIDE_COLD_WARN - 0.1, false)):toBe("none")
	expect(HideState.cold(state, "a", GameConfig.HIDE_COLD_WARN + 0.1, false)):toBe("warn")
	expect(HideState.cold(state, "a", GameConfig.HIDE_COLD_EJECT + 0.1, true)):toBe("none") -- Wesen aktiv
	expect(HideState.cold(state, "a", GameConfig.HIDE_COLD_EJECT + 5, false)):toBe("none") -- Zeit lief neu an
	expect(HideState.cold(state, "a", 2 * GameConfig.HIDE_COLD_EJECT + 0.2, false)):toBe("eject")
	expect(HideState.cold(state, "nobody", 100, false)):toBe("none")
end)

TestRunner.it(suite, "occupantsBefore findet Versteckte in abzukoppelnden Wagen", function()
	local state = HideState.new()
	HideState.enter(state, "a", HideState.spotKey(3, 1), 0)
	HideState.enter(state, "b", HideState.spotKey(7, 1), 0)
	expect(HideState.occupantsBefore(state, 5)):toEqual({ "a" })
	expect(HideState.occupantsBefore(state, 8)):toEqual({ "a", "b" })
end)

return suite
