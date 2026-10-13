--!strict
-- Wagentypen (GDD §5): erzeugt das Layout eines Wagens aus einem Zufallsgenerator.
-- Reine Daten; gebaut wird im Server (TrainBuilder). Lokale Koordinaten siehe Types.luau.
-- Jeder Typ garantiert: Weg von hinterer zu vorderer Tür, ≥ 2 Verstecke, ≥ 2 Behälter
-- (geprüft durch NavGrid in den Tests).

local GameConfig = require("../Config/GameConfig")
local Prng = require("../Util/Prng")
local Types = require("./Types")

type Box = Types.Box
type HidingSpot = Types.HidingSpot
type Container = Types.Container
type Lamp = Types.Lamp
type PostLayout = Types.PostLayout

export type Layout = {
	length: number,
	obstacles: { Box },
	hidingSpots: { HidingSpot },
	containers: { Container },
	lamps: { Lamp },
	post: PostLayout?,
}

export type KindInfo = {
	read weight: number,
	read minIndex: number,
}

local HALF = GameConfig.INNER_WIDTH / 2
local ACCESS_GAP = 1.6 -- Abstand Standpunkt ↔ Möbelfront (größer als PLAYER_CLEARANCE + halbe Zelle)

local CarriageCatalog = {}

-- Zufällig wählbare Typen (Einstieg und Postwagen sind fest).
local kindTable: { [string]: KindInfo } = {
	saloon = { weight = 3, minIndex = 1 },
	sleeper = { weight = 2.5, minIndex = 2 },
	dining = { weight = 2, minIndex = 3 },
	luggage = { weight = 2, minIndex = 4 },
	tearoom = { weight = 1.5, minIndex = 6 },
}
CarriageCatalog.RANDOM_KINDS = table.freeze(kindTable)
-- Feste Reihenfolge für deterministische Auswahl (Tabellen-Iteration ist nicht geordnet).
CarriageCatalog.KIND_ORDER = table.freeze({ "saloon", "sleeper", "dining", "luggage", "tearoom" })

local function newLayout(length: number): Layout
	return { length = length, obstacles = {}, hidingSpots = {}, containers = {}, lamps = {}, post = nil }
end

local function addBox(layout: Layout, cx: number, cz: number, sx: number, sz: number, h: number, kind: string)
	table.insert(layout.obstacles, { cx = cx, cz = cz, sx = sx, sz = sz, h = h, kind = kind })
end

-- Versteck mit Tür in Richtung (fx, fz); der Standpunkt liegt davor.
local function addSpot(
	layout: Layout,
	kind: string,
	x: number,
	z: number,
	sx: number,
	sz: number,
	h: number,
	fx: number,
	fz: number
)
	local depth = if fx ~= 0 then sx else sz
	local reach = depth / 2 + ACCESS_GAP
	table.insert(layout.hidingSpots, {
		id = #layout.hidingSpots + 1,
		kind = kind,
		x = x,
		z = z,
		sx = sx,
		sz = sz,
		h = h,
		fx = fx,
		fz = fz,
		ax = x + fx * reach,
		az = z + fz * reach,
	})
end

local function addContainer(layout: Layout, kind: string, x: number, y: number, z: number, ax: number, az: number)
	table.insert(layout.containers, {
		id = #layout.containers + 1,
		kind = kind,
		x = x,
		y = y,
		z = z,
		ax = ax,
		az = az,
		content = "none",
		stubs = 0,
	})
end

local function addCenterLamps(layout: Layout, z: number)
	local x = 5
	while x < layout.length do
		table.insert(layout.lamps, { x = x, z = z })
		x += 10
	end
end

-- Einstiegswagen (Wagen 0): ruhig, zwei Schränke zum Ausprobieren.
local function boarding(_rng: Prng.Prng): Layout
	local layout = newLayout(40)
	addBox(layout, 20, HALF - 1, 24, 2, 1.8, "bench")
	addBox(layout, 20, -(HALF - 1), 24, 2, 1.8, "bench")
	addSpot(layout, "wardrobe", 3, HALF - 1.3, 2.6, 2.6, 7.5, 0, -1)
	addSpot(layout, "wardrobe", 37, -(HALF - 1.3), 2.6, 2.6, 7.5, 0, 1)
	addContainer(layout, "rack", 12, 7, HALF - 1, 12, 2.4)
	addContainer(layout, "rack", 28, 7, -(HALF - 1), 28, -2.4)
	addCenterLamps(layout, 0)
	return layout
end

-- Großraumwagen: Sitzreihen beidseitig, Mittelgang, Gepäckschränke an den Enden.
local function saloon(rng: Prng.Prng): Layout
	local layout = newLayout(56)
	local middleLocker = rng.chance(0.5)
	addSpot(layout, "locker", 2, HALF - 1.4, 3, 2.8, 8, 0, -1)
	addSpot(layout, "locker", 54, -(HALF - 1.4), 3, 2.8, 8, 0, 1)
	if middleLocker then
		addSpot(layout, "locker", 28, HALF - 1.4, 3, 2.8, 8, 0, -1)
	end
	local rows: { number } = {}
	local x = 7.8
	while x <= 48.5 do
		table.insert(rows, x)
		x += 3.5
	end
	for _, rowX in rows do
		for _, side in { 1, -1 } do
			local blockedByLocker = middleLocker and side == 1 and math.abs(rowX - 28) < 3.5
			if not blockedByLocker and rng.chance(0.85) then
				addBox(layout, rowX, side * 4, 1.6, 4, 3.5, "seat")
			end
		end
	end
	-- 3–4 Gepäckablagen über den Sitzen (über Kopfhöhe, kein Hindernis).
	local rackCount = rng.nextInt(3, 4)
	local used: { [number]: boolean } = {}
	local attempts = 0
	while #layout.containers < rackCount and attempts < 50 do
		attempts += 1
		local slot = rng.nextInt(1, #rows)
		if not used[slot] then
			used[slot] = true
			local side = if rng.chance(0.5) then 1 else -1
			addContainer(layout, "rack", rows[slot], 7.5, side * (HALF - 1), rows[slot], 0)
		end
	end
	addCenterLamps(layout, 0)
	return layout
end

-- Schlafwagen: Seitengang (z < -2) und 4–5 Abteile mit je Kleiderschrank, Bett und Koffer.
local function sleeper(rng: Prng.Prng): Layout
	local layout = newLayout(64)
	local cabins = rng.nextInt(4, 5)
	local startX, endX = 5, 59
	local width = (endX - startX) / cabins
	local wallZ = -1.8
	-- Abteilwand zum Gang mit Türöffnungen (4 Studs) je Abteil.
	for c = 0, cabins - 1 do
		local c0 = startX + c * width
		local doorFrom, doorTo = c0 + 1, c0 + 5
		addBox(layout, (c0 + doorFrom) / 2, wallZ, doorFrom - c0, 0.4, GameConfig.INNER_HEIGHT, "wall")
		addBox(layout, (doorTo + c0 + width) / 2, wallZ, c0 + width - doorTo, 0.4, GameConfig.INNER_HEIGHT, "wall")
		-- Trennwand zum nächsten Abteil
		if c < cabins - 1 then
			addBox(layout, c0 + width, (wallZ + HALF) / 2, 0.4, HALF - wallZ, GameConfig.INNER_HEIGHT, "wall")
		end
		-- Bett an der Außenwand, Schrank in der Ecke an der Tür
		local bedFrom = c0 + 5.2
		local bedTo = c0 + width - 0.4
		addBox(layout, (bedFrom + bedTo) / 2, HALF - 1.5, bedTo - bedFrom, 3, 2, "bed")
		addSpot(layout, "wardrobe", c0 + 1.9, HALF - 1.4, 2.6, 2.8, 7.5, 0, -1)
		addContainer(layout, "suitcase", (bedFrom + bedTo) / 2, 2.6, HALF - 1.5, (bedFrom + bedTo) / 2, 1.2)
		table.insert(layout.lamps, { x = c0 + width / 2, z = 2 })
	end
	-- Abschlusswände der Abteile zu den Vorräumen
	addBox(layout, startX, (wallZ + HALF) / 2, 0.4, HALF - wallZ, GameConfig.INNER_HEIGHT, "wall")
	addBox(layout, endX, (wallZ + HALF) / 2, 0.4, HALF - wallZ, GameConfig.INNER_HEIGHT, "wall")
	local x = 3
	while x < layout.length do
		table.insert(layout.lamps, { x = x, z = -4 })
		x += 12
	end
	return layout
end

-- Speisewagen: Sitznischen beidseitig, Küche vorn mit Vorratsschränken und Schubladen.
local function dining(rng: Prng.Prng): Layout
	local layout = newLayout(56)
	addSpot(layout, "wardrobe", 2, HALF - 1.3, 2.6, 2.6, 7.5, 0, -1)
	for _, cx in { 9.5, 16.5, 23.5, 30.5, 37.5 } do
		for _, side in { 1, -1 } do
			if rng.chance(0.9) then
				addBox(layout, cx, side * 4.25, 5.5, 3.5, 3, "booth")
			end
		end
	end
	-- Trennwand zur Küche (Durchgang z ∈ [-2.5, 2.5])
	addBox(layout, 44, 4.25, 0.4, 3.5, GameConfig.INNER_HEIGHT, "wall")
	addBox(layout, 44, -4.25, 0.4, 3.5, GameConfig.INNER_HEIGHT, "wall")
	addBox(layout, 50, 4.75, 10, 2.5, 3.2, "counter")
	addSpot(layout, "pantry", 47, -(HALF - 1.3), 2.6, 2.6, 7.5, 0, 1)
	addSpot(layout, "pantry", 52, -(HALF - 1.3), 2.6, 2.6, 7.5, 0, 1)
	for _, dx in { 47, 50, 53 } do
		addContainer(layout, "drawer", dx, 2.4, 3.5, dx, 1.6)
	end
	addCenterLamps(layout, 0)
	return layout
end

-- Gepäckwagen: Kisten-Slalom; Überseekoffer und Kisten in den Ecken neben den Kistenwänden.
local function luggage(rng: Prng.Prng): Layout
	local layout = newLayout(60)
	local firstSide = if rng.chance(0.5) then 1 else -1
	local wallXs = { 10, 20, 30, 40, 50 }
	for i, wx in wallXs do
		local side = if i % 2 == 1 then firstSide else -firstSide
		-- Kistenwand von der Seitenwand bis 1 Stud über die Mitte; Lücke (5 Studs) auf der anderen Seite.
		addBox(layout, wx, side * (HALF - 3.5), 2.5, 7, 6, "cratewall")
	end
	-- Ecken: direkt hinter einer Wand auf deren Seite und direkt vor einer Wand auf deren Seite.
	local corners: { { number } } = {}
	for i, wx in wallXs do
		local side = if i % 2 == 1 then firstSide else -firstSide
		table.insert(corners, { wx + 3, side }) -- hinter der Wand (in Fahrtrichtung)
		table.insert(corners, { wx - 3, side }) -- vor der Wand
	end
	-- Mischen (Fisher-Yates), dann verteilen: je ein Überseekoffer in der hinteren und vorderen Hälfte
	-- (kurze Wege zum Versteck, Fairness §6.1), optional ein dritter, danach 4 Kisten.
	for i = #corners, 2, -1 do
		local j = rng.nextInt(1, i)
		corners[i], corners[j] = corners[j], corners[i]
	end
	local function take(predicate: (number) -> boolean): { number }?
		for i, corner in corners do
			if predicate(corner[1]) then
				return table.remove(corners, i)
			end
		end
		return nil
	end
	local trunkCorners: { { number } } = {}
	local rearCorner = take(function(x)
		return x < 25
	end)
	local frontCorner = take(function(x)
		return x > 35
	end)
	if rearCorner then
		table.insert(trunkCorners, rearCorner)
	end
	if frontCorner then
		table.insert(trunkCorners, frontCorner)
	end
	if rng.chance(0.5) then
		local extra = table.remove(corners, 1)
		if extra then
			table.insert(trunkCorners, extra)
		end
	end
	for _, corner in trunkCorners do
		local cx, side = corner[1], corner[2]
		addSpot(layout, "trunk", cx, side * (HALF - 1.4), 2.6, 2.8, 5.5, 0, -side)
	end
	for i = 1, 4 do
		local cx, side = corners[i][1], corners[i][2]
		local cz = side * (HALF - 1.2)
		addBox(layout, cx, cz, 2.2, 2.2, 2.2, "crate")
		addContainer(layout, "crate", cx, 2.3, cz, cx, side * (HALF - 1.2 - 1.1 - ACCESS_GAP))
	end
	addCenterLamps(layout, 0)
	return layout
end

-- Teesalon: Sofas, Teetresen mit Schubladen, Garderobenschränke an den Enden (optional ein dritter).
-- Bewusst ohne Bar und Alkohol (Compliance H-A6).
local function tearoom(rng: Prng.Prng): Layout
	local layout = newLayout(48)
	addSpot(layout, "wardrobe", 3, -(HALF - 1.3), 2.6, 2.6, 7.5, 0, 1)
	addSpot(layout, "wardrobe", 45, HALF - 1.3, 2.6, 2.6, 7.5, 0, -1)
	if rng.chance(0.5) then
		addSpot(layout, "wardrobe", 22, -(HALF - 1.3), 2.6, 2.6, 7.5, 0, 1)
	end
	addBox(layout, 14, HALF - 1, 12, 2, 2.5, "sofa")
	addBox(layout, 33, -(HALF - 1), 10, 2, 2.5, "sofa")
	addBox(layout, 31, 4.4, 10, 3.2, 3.5, "teacounter")
	addContainer(layout, "drawer", 28, 2.5, 2.8, 28, 1.0)
	addContainer(layout, "drawer", 34, 2.5, 2.8, 34, 1.0)
	addBox(layout, 14, -(HALF - 0.8), 2, 1.6, 2.2, "sidetable")
	addContainer(layout, "drawer", 14, 1.8, -(HALF - 0.8), 14, -(HALF - 0.8 - 0.8 - ACCESS_GAP))
	addCenterLamps(layout, 0)
	return layout
end

-- Postwagen (Wagen 50): mittlere Regalreihe mit Lücken, zwei Gänge, Schließfächer, Code-Schloss.
-- Reihenmuster mit 1–2 Löchern (Bit 0 = linke Spalte).
local ROW_PATTERNS = { 1, 2, 4, 3, 5, 6 }

local function post(rng: Prng.Prng): Layout
	local layout = newLayout(96)
	local segments = { { 8, 18 }, { 22, 32 }, { 36, 46 }, { 50, 60 }, { 64, 74 }, { 78, 88 } }
	for _, seg in segments do
		addBox(layout, (seg[1] + seg[2]) / 2, 0, seg[2] - seg[1], 2, 7, "shelf")
	end
	for _, lx in { 13, 41, 69 } do
		addSpot(layout, "locker", lx, HALF - 0.7, 2.6, 1.4, 7.5, 0, -1)
	end
	for _, lx in { 27, 55, 83 } do
		addSpot(layout, "locker", lx, -(HALF - 0.7), 2.6, 1.4, 7.5, 0, 1)
	end

	-- Wegenetz: zwei Gänge (z = ±3.5), Lücken-Knoten (z = 0), Vorräume.
	local nodes: { Types.NavNode } = {}
	local edges: { { number } } = {}
	local columnXs = { 4, 13, 20, 27, 34, 41, 48, 55, 62, 69, 76, 83, 92 }
	local north: { number } = {}
	local south: { number } = {}
	for i, cx in columnXs do
		table.insert(nodes, { x = cx, z = 3.5 })
		north[i] = #nodes
		table.insert(nodes, { x = cx, z = -3.5 })
		south[i] = #nodes
		if i > 1 then
			table.insert(edges, { north[i - 1], north[i] })
			table.insert(edges, { south[i - 1], south[i] })
		end
	end
	local function addCrossing(columnIndex: number)
		table.insert(nodes, { x = columnXs[columnIndex], z = 0 })
		local id = #nodes
		table.insert(edges, { id, north[columnIndex] })
		table.insert(edges, { id, south[columnIndex] })
		return id
	end
	addCrossing(1) -- hinterer Vorraum
	for i, cx in columnXs do
		if cx == 20 or cx == 34 or cx == 48 or cx == 62 or cx == 76 then
			addCrossing(i)
		end
	end
	local frontHub = addCrossing(#columnXs)

	-- Drei Fahrkarten-Fragmente (je eine Reihe des 3×3-Lochmusters) an verschiedenen Regalen.
	local segmentOrder = { 1, 2, 3, 4, 5, 6 }
	for i = #segmentOrder, 2, -1 do
		local j = rng.nextInt(1, i)
		segmentOrder[i], segmentOrder[j] = segmentOrder[j], segmentOrder[i]
	end
	local fragments: { Types.Fragment } = {}
	local code = 0
	for row = 1, 3 do
		local seg = segments[segmentOrder[row]]
		local fx = rng.nextRange(seg[1] + 2, seg[2] - 2)
		local side = if rng.chance(0.5) then 1 else -1
		-- 1–2 Löcher je Reihe (nie 0, nie 3), damit jede Reihe etwas zeigt und eindeutig ist.
		local holes = ROW_PATTERNS[rng.nextInt(1, #ROW_PATTERNS)]
		code = bit32.bor(code, bit32.lshift(holes, 3 * (row - 1)))
		table.insert(fragments, {
			row = row,
			holes = holes,
			x = fx,
			y = 4,
			z = side * 1.05,
			ax = fx,
			az = side * 2.8,
		})
	end

	layout.post = {
		nodes = nodes,
		edges = edges,
		fragments = fragments,
		code = code,
		validatorX = 95.4,
		validatorZ = 3.6, -- neben dem Tor an der Stirnwand (Durchgang bleibt frei)
		conductorStart = frontHub,
	}
	local x = 6
	while x < layout.length do
		table.insert(layout.lamps, { x = x, z = 3.5 })
		table.insert(layout.lamps, { x = x + 7, z = -3.5 })
		x += 14
	end
	return layout
end

local builders: { [string]: (Prng.Prng) -> Layout } = {
	boarding = boarding,
	saloon = saloon,
	sleeper = sleeper,
	dining = dining,
	luggage = luggage,
	tearoom = tearoom,
	post = post,
}

function CarriageCatalog.build(kind: string, rng: Prng.Prng): Layout
	local builder = builders[kind]
	assert(builder, "unknown carriage kind " .. kind)
	local layout = builder(rng)
	-- Verstecke sind auch Hindernisse (Möbelkörper).
	for _, spot in layout.hidingSpots do
		addBox(layout, spot.x, spot.z, spot.sx, spot.sz, spot.h, "hiding:" .. spot.kind)
	end
	return layout
end

function CarriageCatalog.isKind(kind: string): boolean
	return builders[kind] ~= nil
end

return table.freeze(CarriageCatalog)
