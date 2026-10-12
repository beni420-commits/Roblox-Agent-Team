--!strict
local TestRunner = require("../../TestRunner")
local LandingLocator = require("../../../src/shared/Logic/LandingLocator")
local TowerConfig = require("../../../src/shared/Logic/TowerConfig")
local TowerGenerator = require("../../../src/shared/Logic/TowerGenerator")

local expect = TestRunner.expect
local suite = TestRunner.suite("shared/Logic/LandingLocator")

local tower = TowerGenerator.generate(TowerConfig.FIRST_RUN_SEED)

TestRunner.it(suite, "erkennt jede Etagenplattform in ihrer Mitte und knapp darüber (im Sprung)", function()
	for floor = 0, tower.builtFloors do
		local landing = tower.landings[floor]
		expect(LandingLocator.landingAt(tower, landing.x, landing.y + 3, landing.z)):toBe(floor)
		expect(LandingLocator.landingAt(tower, landing.x, landing.y + 7.5, landing.z)):toBe(floor)
	end
end)

TestRunner.it(suite, "erkennt nichts neben der Plattform oder deutlich darunter", function()
	local landing = tower.landings[3]
	expect(LandingLocator.landingAt(tower, landing.x, landing.y - 3, landing.z)):toBe(nil)
	expect(LandingLocator.landingAt(tower, landing.x + landing.fz * 20, landing.y + 3, landing.z - landing.fx * 20)):toBe(
		nil
	)
	expect(LandingLocator.landingAt(tower, 0, 500, 0)):toBe(nil)
end)

TestRunner.it(suite, "Bei 10 Hz und max. Tempo (+30 %) liegt mindestens eine Probe auf jeder Plattform", function()
	local speed = 16 * 1.3
	local samplesPerSecond = 10
	local stepDistance = speed / samplesPerSecond
	for floor = 1, tower.builtFloors do
		local landing = tower.landings[floor]
		-- Ungünstigster Fall: Spieler läuft der Länge nach über die Plattform.
		expect(stepDistance < (landing.halfLength + LandingLocator.MARGIN_ALONG) * 2):toBeTruthy()
	end
end)

TestRunner.it(
	suite,
	"Fall-Schwelle: Füße 4 Studs unter der Etagenplattform (HRP 3 Studs über den Füßen)",
	function()
		expect(LandingLocator.fallThreshold(tower, 2, 4, 3)):toBe(tower.landings[2].y - 1)
	end
)

TestRunner.it(suite, "Rand in Laufrichtung ist kleiner als jede letzte Lücke (CR-25)", function()
	for seed = 1, 50 do
		local t = TowerGenerator.generate(seed)
		for _, floor in t.floors do
			local last = floor.connections[#floor.connections]
			expect(LandingLocator.MARGIN_ALONG < last.connection.gap):toBeTruthy()
		end
	end
end)

return suite
