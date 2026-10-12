--!strict
local TestRunner = require("../../TestRunner")
local Reachability = require("../../../src/shared/Logic/Reachability")
local TowerConfig = require("../../../src/shared/Logic/TowerConfig")
local TowerGenerator = require("../../../src/shared/Logic/TowerGenerator")

local expect = TestRunner.expect
local suite = TestRunner.suite("shared/Logic/TowerGenerator")

local SEEDS = 200

TestRunner.it(suite, "Determinismus: gleicher Seed → identischer Turm", function()
	local a = TowerGenerator.generate(TowerConfig.FIRST_RUN_SEED)
	local b = TowerGenerator.generate(TowerConfig.FIRST_RUN_SEED)
	expect(a):toEqual(b)
end)

TestRunner.it(suite, "verschiedene Seeds → verschiedene Türme", function()
	local a = TowerGenerator.generate(1)
	local b = TowerGenerator.generate(2)
	expect(a.floors[1].connections[1].connection.gap ~= b.floors[1].connections[1].connection.gap):toBeTruthy()
end)

TestRunner.it(
	suite,
	string.format("%d Seeds × 10 Etagen: jede Verbindung ist für den Referenzcharakter lösbar", SEEDS),
	function()
		for seed = 1, SEEDS do
			local tower = TowerGenerator.generate(seed)
			for _, floor in tower.floors do
				local zone = TowerConfig.ZONES[floor.zone]
				local profile = Reachability.referenceProfile(zone.factor)
				local riseSum = 0
				for _, spec in floor.connections do
					local ok = Reachability.canReach(spec.connection, profile, zone.abilities)
					if not ok then
						error(string.format("Seed %d Etage %d Verbindung %d unlösbar", seed, floor.floor, spec.index))
					end
					riseSum += spec.connection.rise
					expect(spec.connection.gap >= zone.gapMin - 1e-9):toBeTruthy()
				end
				expect(riseSum):toBeNear(TowerConfig.FLOOR_HEIGHT, 1e-6)
			end
		end
	end
)

TestRunner.it(suite, "Hilfsstufen sind mit dem Hilfe-Faktor (0,6) lösbar", function()
	local helperProfile = Reachability.referenceProfile(Reachability.HELPER_FACTOR)
	for seed = 1, 50 do
		local tower = TowerGenerator.generate(seed)
		for _, floor in tower.floors do
			local zone = TowerConfig.ZONES[floor.zone]
			for _, spec in floor.connections do
				if spec.helperId then
					local c = spec.connection
					local legGap = math.max(0, c.gap / 2 - 1.5)
					expect((Reachability.canReach({ gap = legGap, rise = c.rise / 2 }, helperProfile, zone.abilities))):toBe(
						true
					)
				end
			end
		end
	end
end)

TestRunner.it(suite, "Funken: genau 6 je Etage, eindeutige IDs (Etage·100 + i), über Plattformen", function()
	local tower = TowerGenerator.generate(TowerConfig.FIRST_RUN_SEED)
	local seen: { [number]: boolean } = {}
	for _, floor in tower.floors do
		expect(#floor.sparks):toBe(TowerConfig.SPARKS_PER_FLOOR)
		for _, spark in floor.sparks do
			expect(spark.id):toBe(floor.floor * 100 + spark.index)
			expect(seen[spark.id]):toBe(nil)
			seen[spark.id] = true
			expect(spark.y > floor.baseY and spark.y < floor.topY + 4):toBeTruthy()
		end
	end
end)

TestRunner.it(suite, "Bauteil-Budget: ≤ 120 je Etage und hochgerechnet ≤ 15 000 für 30 Etagen", function()
	for seed = 1, 50 do
		local tower = TowerGenerator.generate(seed)
		for _, floor in tower.floors do
			expect(#floor.parts + #floor.helpers <= TowerConfig.PART_BUDGET_PER_FLOOR):toBeTruthy()
			expect((#floor.parts + #floor.helpers) * TowerConfig.TOTAL_FLOORS <= 15000):toBeTruthy()
		end
	end
end)

TestRunner.it(
	suite,
	"Helix: Etagenplattform n liegt bei Winkel n·90° und Höhe n·16+1; Pfad auf Radius 40",
	function()
		local tower = TowerGenerator.generate(TowerConfig.FIRST_RUN_SEED)
		for floor = 0, tower.builtFloors do
			local landing = tower.landings[floor]
			local angle = floor * math.pi / 2
			expect(landing.x):toBeNear(40 * math.cos(angle), 1e-6)
			expect(landing.z):toBeNear(40 * math.sin(angle), 1e-6)
			expect(landing.y):toBe(floor * 16 + 1)
		end
		for _, floor in tower.floors do
			for _, part in floor.parts do
				if part.kind == "platform" or part.kind == "conveyor" or part.kind == "jumpPad" then
					local radius = math.sqrt(part.cx * part.cx + part.cz * part.cz)
					expect(math.abs(radius - TowerConfig.PATH_RADIUS) < 0.5):toBeTruthy()
					-- Kopffreiheit: alles einer Etage liegt im Höhenband [baseY, topY]
					expect(part.cy >= floor.baseY - 2 and part.cy <= floor.topY):toBeTruthy()
				end
			end
		end
	end
)

TestRunner.it(suite, "Kopffreiheit: über jeder Verbindung ≥ 20 Studs (außer am Torbalken der Zieletage)", function()
	for seed = 1, 50 do
		local tower = TowerGenerator.generate(seed)
		for _, floor in tower.floors do
			for _, spec in floor.connections do
				local ceiling = spec.connection.ceiling or math.huge
				expect(ceiling >= 14):toBeTruthy()
				if spec.index < #floor.connections then
					expect(ceiling >= 20):toBeTruthy()
				end
			end
		end
	end
end)

TestRunner.it(suite, "Lager auf Etage 5 und 10 sind größer als normale Etagenplattformen", function()
	local tower = TowerGenerator.generate(TowerConfig.FIRST_RUN_SEED)
	expect(tower.landings[5].isCamp):toBe(true)
	expect(tower.landings[10].isCamp):toBe(true)
	expect(tower.landings[4].isCamp):toBe(false)
	expect(tower.landings[5].halfLength > tower.landings[4].halfLength):toBeTruthy()
end)

TestRunner.it(suite, "Lauf-Seeds: Lauf 1 fest, ab Lauf 2 neu gemischt und deterministisch", function()
	local base = TowerConfig.FIRST_RUN_SEED
	expect(TowerGenerator.seedForRun(base, 1)):toBe(base)
	expect(TowerGenerator.seedForRun(base, 2) ~= base):toBeTruthy()
	expect(TowerGenerator.seedForRun(base, 2)):toBe(TowerGenerator.seedForRun(base, 2))
	expect(TowerGenerator.seedForRun(base, 2) ~= TowerGenerator.seedForRun(base, 3)):toBeTruthy()
end)

return suite
