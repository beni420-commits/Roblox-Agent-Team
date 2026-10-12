--!strict
local TestRunner = require("../../TestRunner")
local RunState = require("../../../src/shared/Logic/RunState")

local expect = TestRunner.expect
local suite = TestRunner.suite("shared/Logic/RunState")

local BUILT = 10

local function climbTo(state: RunState.RunState, floor: number)
	for f = state.currentFloor + 1, floor do
		RunState.reachLanding(state, f, BUILT)
	end
end

TestRunner.it(suite, "Etagen werden nur lückenlos erreicht", function()
	local state = RunState.new()
	expect(RunState.reachLanding(state, 1, BUILT).accepted):toBe(true)
	expect(RunState.reachLanding(state, 2, BUILT).accepted):toBe(true)
	expect(state.currentFloor):toBe(2)
	expect(RunState.reachLanding(state, 5, BUILT).accepted):toBe(false) -- übersprungen
	expect(state.currentFloor):toBe(2)
	expect(state.flagged):toBe(true)
	expect(state.skippedLandings):toBe(1)
end)

TestRunner.it(suite, "zurücklaufen ändert nichts; ungültige Etagen werden ignoriert", function()
	local state = RunState.new()
	climbTo(state, 3)
	expect(RunState.reachLanding(state, 1, BUILT).accepted):toBe(false)
	expect(RunState.reachLanding(state, 99, BUILT).accepted):toBe(false)
	expect(state.currentFloor):toBe(3)
	expect(state.flagged):toBe(false)
end)

TestRunner.it(suite, "Lager E5 und E10: Bonus genau einmal pro Lauf, Zone 1 fertig bei E10", function()
	local state = RunState.new()
	climbTo(state, 4)
	local camp = RunState.reachLanding(state, 5, BUILT)
	expect(camp.campReached):toBe(true)
	expect(camp.campBonus):toBe(5)
	expect(state.sparks):toBe(5)
	expect(state.campFloor):toBe(5)
	-- erneutes Erreichen (z. B. nach Rücksetzen) bringt keinen zweiten Bonus
	state.currentFloor = 4
	local again = RunState.reachLanding(state, 5, BUILT)
	expect(again.accepted):toBe(true)
	expect(again.campBonus):toBe(0)
	expect(state.sparks):toBe(5)
	climbTo(state, 9)
	local done = RunState.reachLanding(state, 10, BUILT)
	expect(done.zoneCompleted):toBe(1)
	expect(done.campBonus):toBe(5)
end)

TestRunner.it(suite, "Hilfe: Chevrons ab 3, Hilfsstufen ab 6 Fehlversuchen; neue Etage startet bei 0", function()
	local state = RunState.new()
	climbTo(state, 2)
	expect(RunState.helpLevel(state, true, BUILT)):toBe(0)
	for _ = 1, 3 do
		RunState.registerFail(state, BUILT)
	end
	expect(RunState.helpLevel(state, true, BUILT)):toBe(1)
	for _ = 1, 3 do
		RunState.registerFail(state, BUILT)
	end
	expect(RunState.helpLevel(state, true, BUILT)):toBe(2)
	expect(RunState.failsOnTarget(state)):toBe(6)
	expect(RunState.helpLevel(state, false, BUILT)):toBe(0) -- in den Optionen abgeschaltet
	local event = RunState.reachLanding(state, 3, BUILT)
	expect(event.failsOnSegment):toBe(6)
	expect(RunState.helpLevel(state, true, BUILT)):toBe(0)
end)

TestRunner.it(suite, "Oberste Etage: keine Fehlversuche, keine Hilfe (keine Falle, CR-06)", function()
	local state = RunState.new()
	climbTo(state, BUILT)
	expect(RunState.isAtTop(state, BUILT)):toBe(true)
	expect(RunState.registerFail(state, BUILT)):toBe(0)
	expect(state.failsByFloor[BUILT + 1]):toBe(nil)
	expect(RunState.helpLevel(state, true, BUILT)):toBe(0)
end)

TestRunner.it(suite, "Funken: jeder genau einmal, nur bis zur nächsten Etage, IDs geprüft", function()
	local state = RunState.new()
	expect((RunState.collectSpark(state, 101, BUILT))):toBe(true)
	local ok, reason = RunState.collectSpark(state, 101, BUILT)
	expect(ok):toBe(false)
	expect(reason):toBe("already collected")
	expect(state.sparks):toBe(1)
	-- Etage 3 ist noch nicht erreichbar (höchste Etage 0 → nur Etage 1 erlaubt)
	expect((RunState.collectSpark(state, 301, BUILT))):toBe(false)
	expect((RunState.collectSpark(state, 117, BUILT))):toBe(false) -- Index > 16
	expect((RunState.collectSpark(state, 100, BUILT))):toBe(false) -- Index 0
	expect((RunState.collectSpark(state, 1101, BUILT))):toBe(false) -- Etage nicht gebaut
	expect(RunState.isSparkCollected(state, 101)):toBe(true)
	expect(RunState.isSparkCollected(state, 102)):toBe(false)
end)

TestRunner.it(suite, "Onboarding: jeder Schritt einmal; Client darf nur Schritt 3 und erst nach Schritt 1", function()
	local state = RunState.new()
	expect(RunState.markOnboarding(state, 3, true)):toBe(false) -- vor „Spawned“
	expect(RunState.markOnboarding(state, 1, false)):toBe(true)
	expect(RunState.markOnboarding(state, 1, false)):toBe(false)
	expect(RunState.markOnboarding(state, 3, true)):toBe(true)
	expect(RunState.markOnboarding(state, 3, true)):toBe(false)
	expect(RunState.markOnboarding(state, 4, true)):toBe(false) -- Server-Schritt vom Client
	expect(RunState.markOnboarding(state, 8, false)):toBe(false)
end)

TestRunner.it(suite, "Reichweite: 10 Studs mit Toleranz", function()
	expect(RunState.withinReach(0, 0, 0, 6, 6, 5)):toBe(true)
	expect(RunState.withinReach(0, 0, 0, 50, 0, 0)):toBe(false)
end)

return suite
