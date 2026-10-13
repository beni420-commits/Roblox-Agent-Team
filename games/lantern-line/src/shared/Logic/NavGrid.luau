--!strict
-- Begehbarkeits-Raster eines Wagens (1 × 1 Stud) für den Fairness-Prüfer.
-- Hindernisse werden um PLAYER_CLEARANCE vergrößert. Wege laufen über 4 Nachbarn (Manhattan);
-- das überschätzt echte Laufwege leicht und ist damit für Fairness-Garantien konservativ.

local GameConfig = require("../Config/GameConfig")
local Types = require("./Types")

export type Grid = {
	nx: number,
	nz: number,
	length: number,
	blocked: { boolean },
}

export type Shape = {
	read length: number,
	read obstacles: { Types.Box },
}

local HALF = GameConfig.INNER_WIDTH / 2
local CLEARANCE = GameConfig.PLAYER_CLEARANCE
local INF = math.huge

local NavGrid = {}

local function index(grid: Grid, i: number, j: number): number
	return (i - 1) * grid.nz + j
end

function NavGrid.cellCenter(grid: Grid, idx: number): (number, number)
	local i = (idx - 1) // grid.nz + 1
	local j = (idx - 1) % grid.nz + 1
	return i - 0.5, -HALF + j - 0.5
end

function NavGrid.cellOf(grid: Grid, x: number, z: number): number?
	local i = math.floor(x) + 1
	local j = math.floor(z + HALF) + 1
	if i < 1 or i > grid.nx or j < 1 or j > grid.nz then
		return nil
	end
	return index(grid, i, j)
end

function NavGrid.build(shape: Shape): Grid
	local nx = math.ceil(shape.length)
	local nz = GameConfig.INNER_WIDTH
	local grid: Grid = { nx = nx, nz = nz, length = shape.length, blocked = table.create(nx * nz, false) }
	for i = 1, nx do
		for j = 1, nz do
			local cx, cz = i - 0.5, -HALF + j - 0.5
			local blocked = math.abs(cz) > HALF - CLEARANCE
			if not blocked then
				for _, box in shape.obstacles do
					if
						math.abs(cx - box.cx) < box.sx / 2 + CLEARANCE
						and math.abs(cz - box.cz) < box.sz / 2 + CLEARANCE
					then
						blocked = true
						break
					end
				end
			end
			grid.blocked[index(grid, i, j)] = blocked
		end
	end
	return grid
end

-- Sperrt alle Zellen, deren Mittelpunkt näher als r an (x, z) liegt (z. B. Augen des Blinden Passagiers).
function NavGrid.blockDisc(grid: Grid, x: number, z: number, r: number)
	for idx = 1, grid.nx * grid.nz do
		local cx, cz = NavGrid.cellCenter(grid, idx)
		local dx, dz = cx - x, cz - z
		if dx * dx + dz * dz < r * r then
			grid.blocked[idx] = true
		end
	end
end

function NavGrid.isWalkable(grid: Grid, idx: number?): boolean
	return idx ~= nil and grid.blocked[idx] == false
end

-- Zellen direkt an der hinteren (front = false) bzw. vorderen Tür.
function NavGrid.doorCells(grid: Grid, front: boolean): { number }
	local i = if front then grid.nx else 1
	local cells: { number } = {}
	for j = 1, grid.nz do
		local cz = -HALF + j - 0.5
		local idx = index(grid, i, j)
		if math.abs(cz) < GameConfig.DOOR_WIDTH / 2 and not grid.blocked[idx] then
			table.insert(cells, idx)
		end
	end
	return cells
end

-- Breitensuche von mehreren Startzellen; Ergebnis: Weglänge in Studs je Zelle (INF = unerreichbar).
function NavGrid.distanceField(grid: Grid, sources: { number }): { number }
	local dist = table.create(grid.nx * grid.nz, INF)
	local queue: { number } = {}
	local head = 1
	for _, idx in sources do
		if not grid.blocked[idx] and dist[idx] == INF then
			dist[idx] = 0
			table.insert(queue, idx)
		end
	end
	while head <= #queue do
		local idx = queue[head]
		head += 1
		local i = (idx - 1) // grid.nz + 1
		local j = (idx - 1) % grid.nz + 1
		local d = dist[idx] + 1
		local function visit(ni: number, nj: number)
			if ni >= 1 and ni <= grid.nx and nj >= 1 and nj <= grid.nz then
				local n = index(grid, ni, nj)
				if not grid.blocked[n] and dist[n] > d then
					dist[n] = d
					table.insert(queue, n)
				end
			end
		end
		visit(i - 1, j)
		visit(i + 1, j)
		visit(i, j - 1)
		visit(i, j + 1)
	end
	return dist
end

NavGrid.INF = INF

return table.freeze(NavGrid)
