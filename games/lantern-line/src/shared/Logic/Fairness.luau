--!strict
-- Fairness-Prüfer (GDD §9): prüft Wagen-Layouts und Ereignisse (Express, Gegenzug, Kofferlawine).
-- Wird vom Generator benutzt und in den Tests unabhängig über viele Seeds ausgeführt.
-- Augen des Blinden Passagiers gelten als gesperrte Fläche: Garantien gelten für Wege ohne Schaden.

local GameConfig = require("../Config/GameConfig")
local NavGrid = require("./NavGrid")
local Types = require("./Types")

type Carriage = Types.Carriage
type Event = Types.Event
type Point = { x: number, z: number }

local Fairness = {}

-- Sperrabstand um ein Augenpaar: Fangradius + halbe Zelle (Zellmitte ≠ Figurmitte).
Fairness.EYE_BLOCK_RADIUS = GameConfig.EYES_SNATCH_RADIUS + 0.5

function Fairness.gridFor(c: Carriage): NavGrid.Grid
	local grid = NavGrid.build(c)
	for _, eye in c.eyes do
		NavGrid.blockDisc(grid, eye.x, eye.z, Fairness.EYE_BLOCK_RADIUS)
	end
	return grid
end

local function cellsFor(grid: NavGrid.Grid, points: { Point }): ({ number }, boolean)
	local cells: { number } = {}
	local allWalkable = true
	for _, p in points do
		local idx = NavGrid.cellOf(grid, p.x, p.z)
		if idx == nil or not NavGrid.isWalkable(grid, idx) then
			allWalkable = false
		else
			table.insert(cells, idx)
		end
	end
	return cells, allWalkable
end

local function spotPoints(c: Carriage): { Point }
	local points: { Point } = {}
	for _, spot in c.hidingSpots do
		table.insert(points, { x = spot.ax, z = spot.az })
	end
	return points
end

local function reachableFromRear(grid: NavGrid.Grid): { number }
	return NavGrid.distanceField(grid, NavGrid.doorCells(grid, false))
end

-- Grundregeln je Wagen: Weg hinten → vorn, alle Verstecke, Behälter (und im Postwagen
-- Fragmente, Entwerter und Wegenetz-Knoten) von der hinteren Tür aus erreichbar.
function Fairness.checkCarriage(c: Carriage): (boolean, string?)
	local grid = Fairness.gridFor(c)
	local front = NavGrid.doorCells(grid, true)
	if #NavGrid.doorCells(grid, false) == 0 or #front == 0 then
		return false, "door blocked"
	end
	local fromRear = reachableFromRear(grid)
	local frontReached = false
	for _, idx in front do
		if fromRear[idx] < NavGrid.INF then
			frontReached = true
		end
	end
	if not frontReached then
		return false, "no path rear to front"
	end
	if #c.hidingSpots < 2 then
		return false, "fewer than 2 hiding spots"
	end
	if #c.containers < 2 and c.post == nil then
		return false, "fewer than 2 containers"
	end
	local points = spotPoints(c)
	for _, container in c.containers do
		table.insert(points, { x = container.ax, z = container.az })
	end
	local post = c.post
	if post then
		for _, fragment in post.fragments do
			table.insert(points, { x = fragment.ax, z = fragment.az })
		end
		for _, node in post.nodes do
			table.insert(points, { x = node.x, z = node.z })
		end
		table.insert(points, { x = post.validatorX - 2, z = post.validatorZ })
	end
	for n, p in points do
		local idx = NavGrid.cellOf(grid, p.x, p.z)
		if idx == nil or not NavGrid.isWalkable(grid, idx) then
			return false, string.format("point %d (%.1f, %.1f) not walkable", n, p.x, p.z)
		end
		if fromRear[idx] == NavGrid.INF then
			return false, string.format("point %d (%.1f, %.1f) unreachable", n, p.x, p.z)
		end
	end
	return true, nil
end

-- Zeitpunkt (relativ zum Auslösen), zu dem der Express die Welt-x-Position erreicht.
function Fairness.arrivalTime(prev: Carriage, event: Event, worldX: number): number
	local spawnX = prev.originX - GameConfig.EXPRESS_SPAWN_BEHIND
	return event.delay + (worldX - spawnX) / event.speed
end

-- Prüft für alle erreichbaren Zellen in prev und cur: Zeit bis zur nächsten Zielzelle ≤ Frist(x).
local function checkReachInTime(
	carriages: { Carriage },
	targetsOf: (Carriage, NavGrid.Grid) -> ({ number }, boolean),
	overhead: number,
	deadline: (Carriage, number) -> number
): (boolean, string?)
	for _, c in carriages do
		local grid = Fairness.gridFor(c)
		local targets, ok = targetsOf(c, grid)
		if not ok or #targets == 0 then
			return false, string.format("carriage %d: target cells blocked", c.index)
		end
		local toTarget = NavGrid.distanceField(grid, targets)
		local fromRear = reachableFromRear(grid)
		for idx = 1, grid.nx * grid.nz do
			if fromRear[idx] < NavGrid.INF then
				local x = NavGrid.cellCenter(grid, idx)
				local needed = toTarget[idx] / GameConfig.WALK_SPEED + overhead
				local limit = deadline(c, x)
				if needed > limit then
					return false,
						string.format("carriage %d x=%.1f needs %.2fs, limit %.2fs", c.index, x, needed, limit)
				end
			end
		end
	end
	return true, nil
end

-- Express in Wagen cur (Vorgänger prev): Von jedem erreichbaren Punkt in prev und cur ist das
-- nächste Versteck desselben Wagens rechtzeitig erreichbar, und es gibt genug Verstecke.
function Fairness.checkRush(prev: Carriage, cur: Carriage, event: Event): (boolean, string?)
	if #prev.hidingSpots + #cur.hidingSpots < GameConfig.MIN_SPOTS_FOR_RUSH then
		return false, "not enough hiding spots"
	end
	return checkReachInTime(
		{ prev, cur },
		function(c, grid)
			return cellsFor(grid, spotPoints(c))
		end,
		GameConfig.REACTION_TIME + GameConfig.HIDE_ENTER_TIME,
		function(c, x)
			return Fairness.arrivalTime(prev, event, c.originX + x)
		end
	)
end

-- Gegenzug: Von jedem erreichbaren Punkt in prev und cur ist die sichere Wagenhälfte
-- (z · Seite ≤ −ONCOMING_SAFE_Z) vor Ablauf der Warnzeit erreichbar.
function Fairness.isOncomingSafe(side: number, z: number): boolean
	return z * side <= -GameConfig.ONCOMING_SAFE_Z
end

function Fairness.checkOncoming(prev: Carriage, cur: Carriage, event: Event): (boolean, string?)
	if event.side ~= 1 and event.side ~= -1 then
		return false, "invalid side"
	end
	return checkReachInTime(
		{ prev, cur },
		function(_c, grid)
			local cells: { number } = {}
			for idx = 1, grid.nx * grid.nz do
				local _, z = NavGrid.cellCenter(grid, idx)
				if NavGrid.isWalkable(grid, idx) and Fairness.isOncomingSafe(event.side, z) then
					table.insert(cells, idx)
				end
			end
			return cells, true
		end,
		GameConfig.REACTION_TIME,
		function()
			return event.delay
		end
	)
end

-- Kofferlawine: Im Lawinenwagen kommt man auf dem kürzesten Weg mit Laufgeschwindigkeit
-- schneller voran als die Lawine (mit 10 % Reserve).
function Fairness.checkChaseCarriage(c: Carriage): (boolean, string?)
	local event = c.event
	if c.dark or c.locked or (event ~= nil and event.kind ~= "chase") then
		return false, "chase carriage must be plain"
	end
	local grid = Fairness.gridFor(c)
	local fromRear = reachableFromRear(grid)
	local best = NavGrid.INF
	for _, idx in NavGrid.doorCells(grid, true) do
		best = math.min(best, fromRear[idx])
	end
	if best == NavGrid.INF then
		return false, "no path"
	end
	local playerTime = (best + GameConfig.GANGWAY) / GameConfig.WALK_SPEED
	local chaseTime = (c.length + GameConfig.GANGWAY) / GameConfig.CHASE_SPEED
	if playerTime > chaseTime * 0.9 then
		return false, string.format("carriage %d too slow for chase (%.2fs vs %.2fs)", c.index, playerTime, chaseTime)
	end
	return true, nil
end

return table.freeze(Fairness)
