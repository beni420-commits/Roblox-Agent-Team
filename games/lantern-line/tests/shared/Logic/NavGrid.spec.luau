--!strict
local TestRunner = require("../../TestRunner")
local NavGrid = require("../../../src/shared/Logic/NavGrid")

local expect = TestRunner.expect
local suite = TestRunner.suite("lantern-line/Logic/NavGrid")

TestRunner.it(suite, "leerer Wagen: Wände um Abstand vergrößert, Mitte frei", function()
	local grid = NavGrid.build({ length = 10, obstacles = {} })
	expect(grid.nx):toBe(10)
	expect(grid.nz):toBe(12)
	expect(NavGrid.isWalkable(grid, NavGrid.cellOf(grid, 5.2, 0.3))):toBe(true)
	expect(NavGrid.isWalkable(grid, NavGrid.cellOf(grid, 5.2, 5.5))):toBe(false) -- an der Wand
	expect(NavGrid.isWalkable(grid, NavGrid.cellOf(grid, 5.2, 4.5))):toBe(true)
	expect(NavGrid.cellOf(grid, -0.1, 0)):toBe(nil)
	expect(NavGrid.cellOf(grid, 10.1, 0)):toBe(nil)
end)

TestRunner.it(suite, "Hindernis sperrt inkl. Abstand, Abstand-Grenze ist frei", function()
	local grid =
		NavGrid.build({ length = 20, obstacles = { { cx = 10, cz = 0, sx = 2, sz = 2, h = 3, kind = "box" } } })
	expect(NavGrid.isWalkable(grid, NavGrid.cellOf(grid, 10.5, 0.5))):toBe(false)
	expect(NavGrid.isWalkable(grid, NavGrid.cellOf(grid, 8.5, 0.5))):toBe(false) -- 1,5 < 1 + 1
	expect(NavGrid.isWalkable(grid, NavGrid.cellOf(grid, 7.5, 0.5))):toBe(true) -- 2,5 > 2
end)

TestRunner.it(suite, "Breitensuche liefert Manhattan-Weglängen und umgeht Hindernisse", function()
	local grid = NavGrid.build({ length = 20, obstacles = {} })
	local start = NavGrid.cellOf(grid, 0.5, 0.5) :: number
	local field = NavGrid.distanceField(grid, { start })
	expect(field[NavGrid.cellOf(grid, 10.5, 0.5) :: number]):toBe(10)
	expect(field[NavGrid.cellOf(grid, 10.5, 2.5) :: number]):toBe(12)
	-- Wand quer über die ganze Breite: dahinter unerreichbar
	local walled = NavGrid.build({
		length = 20,
		obstacles = { { cx = 10, cz = 0, sx = 0.4, sz = 12, h = 10, kind = "wall" } },
	})
	local f2 = NavGrid.distanceField(walled, { NavGrid.cellOf(walled, 0.5, 0.5) :: number })
	expect(f2[NavGrid.cellOf(walled, 15.5, 0.5) :: number]):toBe(NavGrid.INF)
end)

TestRunner.it(suite, "Türzellen liegen in der Türbreite an beiden Enden", function()
	local grid = NavGrid.build({ length = 30, obstacles = {} })
	local rear = NavGrid.doorCells(grid, false)
	local front = NavGrid.doorCells(grid, true)
	expect(#rear):toBe(4) -- z = -1,5 … 1,5 (Tür 5 breit)
	expect(#front):toBe(4)
	local x = NavGrid.cellCenter(grid, front[1])
	expect(x):toBe(29.5)
end)

TestRunner.it(suite, "blockDisc sperrt nur innerhalb des Radius", function()
	local grid = NavGrid.build({ length = 20, obstacles = {} })
	NavGrid.blockDisc(grid, 10, 0, 2)
	expect(NavGrid.isWalkable(grid, NavGrid.cellOf(grid, 10.5, 0.5))):toBe(false)
	expect(NavGrid.isWalkable(grid, NavGrid.cellOf(grid, 10.5, 1.5))):toBe(false) -- Abstand ≈ 1,58
	expect(NavGrid.isWalkable(grid, NavGrid.cellOf(grid, 10.5, 2.5))):toBe(true) -- Abstand ≈ 2,55
	expect(NavGrid.isWalkable(grid, NavGrid.cellOf(grid, 13.5, 0.5))):toBe(true)
end)

return suite
