--!strict
local Fairness = require("../../../src/shared/Logic/Fairness")
local Fixtures = require("../../Fixtures")
local GameConfig = require("../../../src/shared/Config/GameConfig")
local TestRunner = require("../../TestRunner")

local expect = TestRunner.expect
local suite = TestRunner.suite("lantern-line/Logic/Fairness")

local function twoSpots(index: number, originX: number, length: number)
	return Fixtures.carriage({
		index = index,
		originX = originX,
		length = length,
		spots = { { 3, 4.7, 0, -1 }, { length - 3, -4.7, 0, 1 } },
	})
end

TestRunner.it(suite, "Grundprüfung: Weg, Verstecke und Behälter erreichbar", function()
	expect(Fairness.checkCarriage(twoSpots(1, 0, 40))):toBe(true)
	-- Querwand ohne Lücke: kein Weg nach vorn
	local blocked = twoSpots(1, 0, 40)
	table.insert(blocked.obstacles, { cx = 20, cz = 0, sx = 0.4, sz = 12, h = 10, kind = "wall" })
	local ok, why = Fairness.checkCarriage(blocked)
	expect(ok):toBe(false)
	expect(why):toBe("no path rear to front")
	-- nur ein Versteck
	local one = Fixtures.carriage({ length = 40, spots = { { 3, 4.7, 0, -1 } } })
	expect((Fairness.checkCarriage(one))):toBe(false)
end)

TestRunner.it(suite, "Augen sperren Fläche: Augen mitten im einzigen Gang machen den Wagen unfair", function()
	-- Gang z ∈ [-2, 2] zwischen zwei Längswänden; Augen in der Mitte des Gangs.
	local walls = {
		{ cx = 20, cz = 4.25, sx = 20, sz = 3.5, h = 3, kind = "seat" },
		{ cx = 20, cz = -4.25, sx = 20, sz = 3.5, h = 3, kind = "seat" },
	}
	local fine =
		Fixtures.carriage({ length = 40, obstacles = walls, spots = { { 3, 4.7, 0, -1 }, { 37, -4.7, 0, 1 } } })
	expect((Fairness.checkCarriage(fine))):toBe(true)
	local eyed = Fixtures.carriage({
		length = 40,
		obstacles = walls,
		spots = { { 3, 4.7, 0, -1 }, { 37, -4.7, 0, 1 } },
		eyes = { { 20, 0 } },
	})
	expect((Fairness.checkCarriage(eyed))):toBe(false)
end)

TestRunner.it(suite, "Express: weit entfernte Verstecke bei kurzer Warnzeit sind unfair", function()
	local prev = twoSpots(4, 0, 40)
	local cur = twoSpots(5, 44, 40)
	local normal = Fixtures.event("express", GameConfig.EXPRESS_DELAY_MIN, GameConfig.EXPRESS_SPEED, 0)
	expect((Fairness.checkRush(prev, cur, normal))):toBe(true)
	-- Nur Verstecke ganz vorn in einem 96 langen Wagen, sofortiger Start: unfair
	local long = Fixtures.carriage({ index = 4, length = 96, spots = { { 93, 4.7, 0, -1 }, { 93, -4.7, 0, 1 } } })
	local cur2 = twoSpots(5, 100, 40)
	local instant = Fixtures.event("express", 0, 200, 0)
	local ok, why = Fairness.checkRush(long, cur2, instant)
	expect(ok):toBe(false)
	expect(string.find(why or "", "carriage 4", 1, true) ~= nil):toBe(true)
end)

TestRunner.it(suite, "Express: zu wenige Verstecke in k−1 ∪ k", function()
	local prev = Fixtures.carriage({ index = 4, length = 40, spots = { { 3, 4.7, 0, -1 } } })
	local cur = Fixtures.carriage({ index = 5, originX = 44, length = 40, spots = { { 3, 4.7, 0, -1 } } })
	local ok, why = Fairness.checkRush(prev, cur, Fixtures.event("express", 3, 70, 0))
	expect(ok):toBe(false)
	expect(why):toBe("not enough hiding spots")
end)

TestRunner.it(suite, "Ankunftszeit des Express wächst linear mit x", function()
	local prev = twoSpots(4, 100, 40)
	local event = Fixtures.event("express", 3, 70, 0)
	expect(Fairness.arrivalTime(prev, event, 100)):toBeNear(3 + GameConfig.EXPRESS_SPAWN_BEHIND / 70, 1e-9)
	expect(Fairness.arrivalTime(prev, event, 170)):toBeNear(4 + GameConfig.EXPRESS_SPAWN_BEHIND / 70, 1e-9)
end)

TestRunner.it(suite, "Gegenzug: sichere Hälfte erreichbar, außer eine Wand trennt die Hälften", function()
	local prev = twoSpots(9, 0, 40)
	local cur = twoSpots(10, 44, 40)
	local event = Fixtures.event("oncoming", GameConfig.ONCOMING_DELAY_MIN, 0, 1)
	expect((Fairness.checkOncoming(prev, cur, event))):toBe(true)
	expect(Fairness.isOncomingSafe(1, -1.5)):toBe(true)
	expect(Fairness.isOncomingSafe(1, -0.5)):toBe(false)
	expect(Fairness.isOncomingSafe(-1, 2)):toBe(true)
	-- Längswand trennt die Wagenhälften, der Zugang zur sicheren Hälfte liegt ganz vorn
	local split = twoSpots(10, 44, 96)
	table.insert(split.obstacles, { cx = 46, cz = 0, sx = 92, sz = 0.4, h = 10, kind = "wall" })
	local ok = Fairness.checkOncoming(prev, split, Fixtures.event("oncoming", 1.2, 0, -1))
	expect(ok):toBe(false)
	expect((Fairness.checkOncoming(prev, cur, Fixtures.event("oncoming", 3, 0, 0)))):toBe(false) -- ungültige Seite
end)

TestRunner.it(suite, "Kofferlawine: gerader Gang fair, Slalom zu langsam", function()
	local straight = twoSpots(30, 0, 56)
	straight.chase = true
	expect((Fairness.checkChaseCarriage(straight))):toBe(true)
	local slalom = twoSpots(30, 0, 60)
	for i, wx in { 10, 20, 30, 40, 50 } do
		local side = if i % 2 == 1 then 1 else -1
		table.insert(slalom.obstacles, { cx = wx, cz = side * 2.5, sx = 2.5, sz = 7, h = 6, kind = "cratewall" })
	end
	expect((Fairness.checkChaseCarriage(slalom))):toBe(false)
	local dark = twoSpots(30, 0, 56)
	dark.dark = true
	expect((Fairness.checkChaseCarriage(dark))):toBe(false)
end)

return suite
