--!strict
local TestRunner = require("../../TestRunner")
local Movement = require("../../../src/shared/Logic/Movement")
local Reachability = require("../../../src/shared/Logic/Reachability")

local expect = TestRunner.expect
local suite = TestRunner.suite("shared/Logic/Reachability")

local JUMP: Reachability.Plan = { jump = true, doubleJump = false, dash = false }
local NONE: Reachability.Abilities = {}
local DJ: Reachability.Abilities = { doubleJump = true }
local ALL: Reachability.Abilities = { doubleJump = true, dash = true }

TestRunner.it(suite, "Physik: Sprunghöhe der Simulation entspricht JumpHeight (7,2 Studs)", function()
	local generous = Reachability.generousProfile()
	local result = Reachability.simulate({ gap = 30, rise = -50 }, generous, JUMP, nil)
	expect(result.maxHeight):toBeNear(7.2, 0.05)
	expect(Movement.jumpVelocity(7.2, 196.2)):toBeNear(53.15, 0.01)
end)

TestRunner.it(suite, "Physik: flacher Sprung reicht großzügig ≈ 8,67 + 1 (Hitbox) Studs", function()
	local reach = Reachability.maxGap(0, Reachability.generousProfile(), NONE)
	expect(reach):toBeNear(9.67, 0.1)
end)

TestRunner.it(suite, "Referenzcharakter ist strenger als das großzügige Modell", function()
	for _, factor in Reachability.ZONE_FACTORS do
		local ref = Reachability.maxGap(0, Reachability.referenceProfile(factor), NONE)
		expect(ref > 0 and ref < 9.67):toBeTruthy()
	end
end)

TestRunner.it(suite, "Lücke wird mit wachsender Weite irgendwann unlösbar (Monotonie im Normalbereich)", function()
	local profile = Reachability.referenceProfile(0.75)
	local previous = true
	for gap = 0, 8, 0.25 do
		local ok = Reachability.canReach({ gap = gap, rise = 1 }, profile, NONE)
		if ok then
			expect(previous):toBe(true) -- kein „wieder lösbar“ nach einem Scheitern
		end
		previous = ok
	end
	expect(previous):toBe(false)
end)

TestRunner.it(suite, "Ohne Doppelsprung ist keine Kante über der Sprunghöhe erreichbar (großzügig)", function()
	expect((Reachability.canReach({ gap = 1, rise = 7.5 }, Reachability.generousProfile(), NONE))):toBe(false)
	expect((Reachability.canReach({ gap = 1, rise = 6.5 }, Reachability.generousProfile(), NONE))):toBe(true)
end)

TestRunner.it(suite, "Decke: zu niedrige Decke verhindert den Sprung (Kopffreiheit)", function()
	local profile = Reachability.referenceProfile(0.85)
	expect((Reachability.canReach({ gap = 2, rise = 0, ceiling = 8 }, profile, NONE))):toBe(false)
	expect((Reachability.canReach({ gap = 2, rise = 0, ceiling = 30 }, profile, NONE))):toBe(true)
end)

TestRunner.it(suite, "Sprungpad: großer Anstieg ist nur mit Pad lösbar", function()
	local profile = Reachability.referenceProfile(0.75)
	local velocity = Movement.jumpVelocity(13, 196.2)
	expect((Reachability.canReach({ gap = 1, rise = 7 }, profile, NONE))):toBe(false)
	expect((Reachability.canReach({ gap = 1, rise = 7, launchVelocity = velocity, launchDistance = 4 }, profile, NONE))):toBe(
		true
	)
end)

-- Design-Befunde für Zonen 2–3 (Sprint 2), hier als Regression festgehalten.
TestRunner.it(suite, "Befund P-03: DJ-Pflicht allein über Weite ist nicht fair möglich (Zone 2)", function()
	local refDj = Reachability.maxGap(0, Reachability.referenceProfile(0.85), DJ)
	local generousJump = Reachability.maxGap(0, Reachability.generousProfile(), NONE)
	expect(refDj < generousJump):toBeTruthy()
end)

TestRunner.it(
	suite,
	"DJ-Pflicht über Höhe: Kante 8–9,5 Studs, Lücke 3 → verlangt DJ und ist fair (Zone 2)",
	function()
		for _, rise in { 8, 8.5, 9, 9.5 } do
			expect(Reachability.requiresAbility({ gap = 3, rise = rise }, "doubleJump", NONE, 0.85)):toBe(true)
		end
	end
)

TestRunner.it(suite, "Dash-Pflicht über Form: Tunnel (Decke 6,5) und Windwand verlangen den Dash (Zone 3)", function()
	expect(Reachability.requiresAbility({ gap = 5, rise = 0, ceiling = 6.5 }, "dash", DJ, 0.88)):toBe(true)
	expect(Reachability.requiresAbility({ gap = 6, rise = 0, windWall = true }, "dash", DJ, 0.88)):toBe(true)
end)

TestRunner.it(suite, "Ein einfacher Sprung verlangt keine Fähigkeit", function()
	expect(Reachability.requiresAbility({ gap = 2, rise = 1 }, "doubleJump", NONE, 0.85)):toBe(false)
	expect(Reachability.requiresAbility({ gap = 2, rise = 1 }, "dash", NONE, 0.88)):toBe(false)
end)

TestRunner.it(suite, "canReach liefert den einfachsten Plan", function()
	local ok, plan = Reachability.canReach({ gap = 2, rise = 1 }, Reachability.referenceProfile(0.85), ALL)
	expect(ok):toBe(true)
	expect(plan and plan.jump and not plan.doubleJump and not plan.dash):toBeTruthy()
end)

return suite
