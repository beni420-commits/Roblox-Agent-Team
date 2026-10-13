--!strict
local CarriageCatalog = require("../../../src/shared/Logic/CarriageCatalog")
local NavGraph = require("../../../src/shared/Logic/NavGraph")
local Prng = require("../../../src/shared/Util/Prng")
local TestRunner = require("../../TestRunner")
local Types = require("../../../src/shared/Logic/Types")

local expect = TestRunner.expect
local suite = TestRunner.suite("lantern-line/Logic/NavGraph")

local function postGraph(): (NavGraph.Graph, Types.PostLayout)
	local layout = CarriageCatalog.build("post", Prng.new(1))
	local post = layout.post :: Types.PostLayout
	return NavGraph.new(post.nodes, post.edges), post
end

TestRunner.it(suite, "kürzester Weg im Quadrat und unerreichbare Knoten", function()
	local g = NavGraph.new(
		{ { x = 0, z = 0 }, { x = 10, z = 0 }, { x = 10, z = 10 }, { x = 0, z = 10 }, { x = 50, z = 50 } },
		{
			{ 1, 2 },
			{ 2, 3 },
			{ 3, 4 },
			{ 4, 1 },
			{ 1, 3 },
		}
	)
	expect(NavGraph.shortestPath(g, 1, 3)):toEqual({ 1, 3 }) -- Diagonale 14,1 < 20
	expect(NavGraph.shortestPath(g, 2, 4)[1]):toBe(2)
	expect(#NavGraph.shortestPath(g, 2, 4)):toBe(3)
	expect(NavGraph.shortestPath(g, 1, 5)):toEqual({})
	expect(NavGraph.shortestPath(g, 3, 3)):toEqual({ 3 })
	expect(NavGraph.isConnected(g)):toBe(false)
	expect(NavGraph.nearest(g, 9, 1)):toBe(2)
end)

TestRunner.it(suite, "Postwagen-Netz: zusammenhängend, Wege nur über Kanten", function()
	local g = postGraph()
	expect(NavGraph.isConnected(g)):toBe(true)
	for from = 1, #g.nodes, 5 do
		for to = 1, #g.nodes, 3 do
			local path = NavGraph.shortestPath(g, from, to)
			expect(path[1]):toBe(from)
			expect(path[#path]):toBe(to)
			for i = 2, #path do
				local found = false
				for _, n in g.neighbors[path[i - 1]] do
					if n == path[i] then
						found = true
					end
				end
				expect(found):toBe(true)
			end
		end
	end
end)

return suite
