--!strict
-- Wegenetz für den Schaffner im Postwagen: Knoten in den Gängen, Kanten mit euklidischer Länge.
-- Kleines Netz (≈ 35 Knoten): Dijkstra in O(n²) genügt.

local Types = require("./Types")

export type Graph = {
	nodes: { Types.NavNode },
	neighbors: { { number } },
	weights: { { number } },
}

local NavGraph = {}

local function dist(a: Types.NavNode, b: Types.NavNode): number
	local dx, dz = a.x - b.x, a.z - b.z
	return math.sqrt(dx * dx + dz * dz)
end

function NavGraph.new(nodes: { Types.NavNode }, edges: { { number } }): Graph
	local neighbors: { { number } } = {}
	local weights: { { number } } = {}
	for i = 1, #nodes do
		neighbors[i] = {}
		weights[i] = {}
	end
	for _, edge in edges do
		local a, b = edge[1], edge[2]
		local w = dist(nodes[a], nodes[b])
		table.insert(neighbors[a], b)
		table.insert(weights[a], w)
		table.insert(neighbors[b], a)
		table.insert(weights[b], w)
	end
	return { nodes = nodes, neighbors = neighbors, weights = weights }
end

function NavGraph.nearest(graph: Graph, x: number, z: number): number
	local best, bestD = 1, math.huge
	for i, node in graph.nodes do
		local dx, dz = node.x - x, node.z - z
		local d = dx * dx + dz * dz
		if d < bestD then
			best, bestD = i, d
		end
	end
	return best
end

-- Kürzester Weg als Knotenliste von `from` bis `to` (einschließlich beider); {} wenn unerreichbar.
function NavGraph.shortestPath(graph: Graph, from: number, to: number): { number }
	local n = #graph.nodes
	local d = table.create(n, math.huge)
	local prev = table.create(n, 0)
	local done = table.create(n, false)
	d[from] = 0
	for _ = 1, n do
		local u, best = 0, math.huge
		for i = 1, n do
			if not done[i] and d[i] < best then
				u, best = i, d[i]
			end
		end
		if u == 0 or u == to then
			break
		end
		done[u] = true
		for k, v in graph.neighbors[u] do
			local alt = d[u] + graph.weights[u][k]
			if alt < d[v] then
				d[v] = alt
				prev[v] = u
			end
		end
	end
	if d[to] == math.huge then
		return {}
	end
	local path: { number } = {}
	local cur = to
	while cur ~= 0 do
		table.insert(path, 1, cur)
		if cur == from then
			break
		end
		cur = prev[cur]
	end
	return path
end

function NavGraph.isConnected(graph: Graph): boolean
	local seen: { [number]: boolean } = { [1] = true }
	local stack = { 1 }
	local count = 1
	while #stack > 0 do
		local u = table.remove(stack) :: number
		for _, v in graph.neighbors[u] do
			if not seen[v] then
				seen[v] = true
				count += 1
				table.insert(stack, v)
			end
		end
	end
	return count == #graph.nodes
end

NavGraph.distance = dist

return table.freeze(NavGraph)
