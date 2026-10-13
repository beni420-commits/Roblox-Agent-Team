--!strict
-- Hilfen für synthetische Wagen in Tests.
local Types = require("../src/shared/Logic/Types")

local Fixtures = {}

export type Options = {
	index: number?,
	length: number?,
	originX: number?,
	obstacles: { Types.Box }?,
	spots: { { number } }?, -- { x, z, fx, fz } (Standpunkt = Mitte + Richtung · 3)
	eyes: { { number } }?, -- { x, z }
}

function Fixtures.carriage(options: Options): Types.Carriage
	local spots: { Types.HidingSpot } = {}
	for i, s in options.spots or {} do
		local x, z, fx, fz = s[1], s[2], s[3], s[4]
		table.insert(spots, {
			id = i,
			kind = "wardrobe",
			x = x,
			z = z,
			sx = 2.6,
			sz = 2.6,
			h = 7.5,
			fx = fx,
			fz = fz,
			ax = x + fx * 2.9,
			az = z + fz * 2.9,
		})
	end
	local obstacles: { Types.Box } = table.clone(options.obstacles or {})
	for _, spot in spots do
		table.insert(obstacles, { cx = spot.x, cz = spot.z, sx = spot.sx, sz = spot.sz, h = spot.h, kind = "hiding" })
	end
	local eyes: { Types.Eye } = {}
	for i, e in options.eyes or {} do
		table.insert(eyes, { id = i, x = e[1], y = 0.6, z = e[2] })
	end
	return {
		index = options.index or 1,
		kind = "test",
		length = options.length or 40,
		originX = options.originX or 0,
		dark = #eyes > 0,
		locked = false,
		obstacles = obstacles,
		hidingSpots = spots,
		containers = {
			{ id = 1, kind = "rack", x = 5, y = 7, z = 0, ax = 5, az = 0, content = "none", stubs = 0 },
			{ id = 2, kind = "rack", x = 10, y = 7, z = 0, ax = 10, az = 0, content = "none", stubs = 0 },
		},
		lamps = {},
		eyes = eyes,
		chase = false,
		event = nil,
		post = nil,
	}
end

function Fixtures.event(kind: string, delay: number, speed: number, side: number): Types.Event
	return { kind = kind, delay = delay, speed = speed, side = side, seed = 1 }
end

return Fixtures
