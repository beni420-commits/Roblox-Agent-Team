--!strict
local CarriageCatalog = require("../../../src/shared/Logic/CarriageCatalog")
local Prng = require("../../../src/shared/Util/Prng")
local Puzzle = require("../../../src/shared/Logic/Puzzle")
local TestRunner = require("../../TestRunner")
local Types = require("../../../src/shared/Logic/Types")

local expect = TestRunner.expect
local suite = TestRunner.suite("lantern-line/Logic/Puzzle")

TestRunner.it(suite, "Bitzuordnung Reihe/Spalte, Umschalten und Reihen lesen", function()
	expect(Puzzle.bit(1, 1)):toBe(1)
	expect(Puzzle.bit(1, 3)):toBe(4)
	expect(Puzzle.bit(2, 1)):toBe(8)
	expect(Puzzle.bit(3, 3)):toBe(256)
	local m = Puzzle.toggle(0, 2, 2)
	expect(m):toBe(16)
	expect(Puzzle.toggle(m, 2, 2)):toBe(0)
	expect(Puzzle.rowOf(0x1C7, 1)):toBe(7)
	expect(Puzzle.rowOf(0x1C7, 2)):toBe(0)
	expect(Puzzle.rowOf(0x1C7, 3)):toBe(7)
end)

TestRunner.it(suite, "nur ganze Zahlen 0–511 sind gültige Muster", function()
	expect(Puzzle.isValidMask(0)):toBe(true)
	expect(Puzzle.isValidMask(511)):toBe(true)
	for _, bad: any in { -1, 512, 1.5, 0 / 0, math.huge, "5", nil, true, {} } do
		expect(Puzzle.isValidMask(bad)):toBe(false)
	end
end)

TestRunner.it(
	suite,
	"nur das vollständige Muster der Fragmente öffnet; Notizen zeigen nur gelesene Reihen",
	function()
		local layout = CarriageCatalog.build("post", Prng.new(31))
		local post = layout.post :: Types.PostLayout
		expect(Puzzle.check(post, post.code)):toBe(true)
		for bitIndex = 0, 8 do
			expect(Puzzle.check(post, bit32.bxor(post.code, bit32.lshift(1, bitIndex)))):toBe(false)
		end
		local notes = Puzzle.notesFor(post, { [2] = true })
		expect(notes[2]):toBe(Puzzle.rowOf(post.code, 2))
		expect(notes[1]):toBe(nil)
	end
)

return suite
