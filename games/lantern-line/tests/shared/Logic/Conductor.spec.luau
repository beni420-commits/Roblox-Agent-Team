--!strict
local CarriageCatalog = require("../../../src/shared/Logic/CarriageCatalog")
local Conductor = require("../../../src/shared/Logic/Conductor")
local GameConfig = require("../../../src/shared/Config/GameConfig")
local Prng = require("../../../src/shared/Util/Prng")
local TestRunner = require("../../TestRunner")
local Types = require("../../../src/shared/Logic/Types")

local expect = TestRunner.expect
local suite = TestRunner.suite("lantern-line/Logic/Conductor")

local DT = 0.1

local function newConductor(now: number): (Conductor.State, Types.PostLayout)
	local layout = CarriageCatalog.build("post", Prng.new(5))
	local post = layout.post :: Types.PostLayout
	return Conductor.new(post, layout.obstacles, 99, now), post
end

local function listener(key: string, x: number, z: number, speed: number, hidden: boolean?): Conductor.Listener
	return { key = key, x = x, z = z, speed = speed, hidden = hidden == true, alive = true }
end

-- Stellt den Schaffner an (x, z) mit Blickrichtung (fx, fz), wach und auf Streife.
local function place(state: Conductor.State, x: number, z: number, fx: number, fz: number)
	state.x, state.z, state.fx, state.fz = x, z, fx, fz
	state.mode = "patrol"
	state.wakeAt = -math.huge
	state.path = {}
end

TestRunner.it(suite, "schläft WAKE Sekunden, startet am anderen Ende", function()
	local state, post = newConductor(0)
	expect(state.mode):toBe("dormant")
	local start = post.nodes[post.conductorStart]
	expect(state.x):toBe(start.x)
	expect(
		#Conductor.update(state, GameConfig.CONDUCTOR_WAKE - 0.1, DT, { listener("a", start.x - 2, start.z, 16) }, {})
	):toBe(0)
	expect(state.mode):toBe("dormant")
	Conductor.update(state, GameConfig.CONDUCTOR_WAKE + 0.1, DT, {}, {})
	expect(state.mode):toBe("patrol")
end)

TestRunner.it(suite, "Lichtkegel: sieht vorn im Gang, nicht hinter sich, nicht durch Regale", function()
	local state = newConductor(0)
	place(state, 50, 3.5, 1, 0) -- Nordgang, Blick nach vorn (+x)
	expect(Conductor.sees(state, 60, 3.5)):toBe(true)
	expect(Conductor.sees(state, 50 + GameConfig.CONDUCTOR_VIEW_DISTANCE + 1, 3.5)):toBe(false)
	expect(Conductor.sees(state, 40, 3.5)):toBe(false) -- hinter ihm
	expect(Conductor.sees(state, 54, -3.5)):toBe(false) -- Südgang hinter dem Regal (Winkel > 30° und verdeckt)
	place(state, 40, 3.5, 1, -0.3)
	expect(Conductor.lineOfSight(state, 55, -3.5)):toBe(false) -- Regal 50–60 verdeckt
end)

TestRunner.it(suite, "Hören: Laufen bis zur Sichtweite (H-A17), Schleichen nur in 6, Stillstand nie", function()
	expect(Conductor.noiseRadius(16)):toBe(GameConfig.NOISE_WALK_RADIUS)
	expect(Conductor.noiseRadius(8)):toBe(GameConfig.NOISE_SNEAK_RADIUS)
	expect(Conductor.noiseRadius(0.5)):toBe(0)
	expect(GameConfig.NOISE_WALK_RADIUS <= GameConfig.CONDUCTOR_VIEW_DISTANCE):toBe(true)
	local state = newConductor(0)
	place(state, 50, 3.5, 1, 0)
	-- Spieler 15 Studs hinter ihm (nicht im Kegel): schleichend unbemerkt, laufend gehört
	Conductor.update(state, 10, DT, { listener("a", 35, 3.5, 8) }, {})
	expect(state.mode):toBe("patrol")
	Conductor.update(state, 10.1, DT, { listener("a", 35, 3.5, 16) }, {})
	expect(state.mode):toBe("hunt")
end)

TestRunner.it(suite, "Jagd: läuft zum Ziel und fängt; Versteckte sind sicher; vergisst nach FORGET", function()
	local state = newConductor(0)
	place(state, 48, 3.5, 1, 0)
	local target = listener("a", 55, 3.5, 16)
	local caught: { string } = {}
	local t = 10
	for _ = 1, 30 do
		caught = Conductor.update(state, t, DT, { target }, {})
		t += DT
		if #caught > 0 then
			break
		end
	end
	expect(caught[1]):toBe("a")

	local s2 = newConductor(0)
	place(s2, 48, 3.5, 1, 0)
	local hidden = listener("b", 49, 3.5, 0, true)
	expect(#Conductor.update(s2, 10, DT, { hidden }, {})):toBe(0)
	expect(s2.mode):toBe("patrol")

	-- Geräusch (falsches Muster am Entwerter) lockt an, danach vergisst er
	local s3 = newConductor(0)
	place(s3, 20, -3.5, 1, 0)
	Conductor.update(s3, 10, DT, {}, { { x = 70, z = 3.5, radius = GameConfig.NOISE_WRONG_CODE_RADIUS } })
	expect(s3.mode):toBe("hunt")
	local t3 = 10
	while t3 < 10 + GameConfig.CONDUCTOR_FORGET + 0.5 do
		t3 += DT
		Conductor.update(s3, t3, DT, {}, {})
	end
	expect(s3.mode):toBe("patrol")
end)

TestRunner.it(suite, "Jagdtempo liegt zwischen Schleichen und Laufen; bleibt immer im Wagen", function()
	expect(GameConfig.CONDUCTOR_HUNT_SPEED > GameConfig.SNEAK_SPEED):toBe(true)
	expect(GameConfig.CONDUCTOR_HUNT_SPEED < GameConfig.WALK_SPEED):toBe(true)
	local state = newConductor(0)
	local rng = Prng.new(77)
	local t = 0
	for _ = 1, 2000 do
		t += DT
		local players = { listener("a", rng.nextRange(2, 94), rng.nextRange(-4, 4), rng.nextRange(0, 16)) }
		Conductor.update(state, t, DT, players, {})
		expect(state.x >= 0 and state.x <= 96):toBe(true)
		expect(math.abs(state.z) <= 6):toBe(true)
	end
end)

TestRunner.it(suite, "Moduswechsel erhöht die Wegrevision (Clients rechnen sofort mit neuem Tempo)", function()
	local state = newConductor(0)
	place(state, 50, 3.5, 1, 0)
	local before = state.revision
	Conductor.update(state, 10, DT, {}, { { x = 50.5, z = 3.5, radius = 10 } }) -- Ziel nahe der eigenen Position
	expect(state.mode):toBe("hunt")
	expect(state.revision > before):toBe(true)
end)

TestRunner.it(suite, "Strecke-Box-Schnitt (Sichtprüfung)", function()
	local box: Types.Box = { cx = 0, cz = 0, sx = 2, sz = 2, h = 7, kind = "shelf" }
	expect(Conductor.segmentHitsBox(-5, 0, 5, 0, box)):toBe(true)
	expect(Conductor.segmentHitsBox(-5, 2, 5, 2, box)):toBe(false)
	expect(Conductor.segmentHitsBox(-5, -5, 5, 5, box)):toBe(true)
	expect(Conductor.segmentHitsBox(-5, 0, -2, 0, box)):toBe(false) -- endet vor der Box
	expect(Conductor.segmentHitsBox(0.5, 5, 0.5, 3, box)):toBe(false) -- senkrecht, erreicht sie nicht
end)

return suite
