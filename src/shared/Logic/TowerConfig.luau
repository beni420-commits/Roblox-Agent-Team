--!strict
-- Feste Turm-Parameter (GDD v0.2 §4, tech_notes §6.2). Änderungen hier ändern jeden Turm.

local TowerConfig = {}

TowerConfig.FLOOR_HEIGHT = 16
TowerConfig.TOTAL_FLOORS = 30
TowerConfig.FLOORS_PER_ZONE = 10
TowerConfig.BUILT_ZONES = 1 -- Sprint 1: nur Zone 1 („Wiese“) ist gebaut
TowerConfig.PATH_RADIUS = 40
TowerConfig.SECTOR_ANGLE = math.pi / 2 -- Helix: jede Etage im nächsten 90°-Sektor
TowerConfig.LANDING_TOP_OFFSET = 1 -- Oberkante Etagenplattform n = n * FLOOR_HEIGHT + Offset
TowerConfig.LANDING_LENGTH = 8
TowerConfig.LANDING_WIDTH = 10
TowerConfig.CAMP_LENGTH = 14
TowerConfig.CAMP_WIDTH = 14
TowerConfig.CAMP_FLOORS = table.freeze({ [5] = true, [10] = true, [15] = true, [20] = true, [25] = true })
TowerConfig.GATE_HEIGHT = 14
TowerConfig.COLUMN_RADIUS = 10
TowerConfig.GROUND_RADIUS = 95
TowerConfig.SPARKS_PER_FLOOR = 6
TowerConfig.PART_BUDGET_PER_FLOOR = 120
TowerConfig.PLATFORM_THICKNESS = 1.5
TowerConfig.SPAWN_POSITION = table.freeze({ x = 78, y = 0, z = 0 })
TowerConfig.FIRST_RUN_SEED = 20261012 -- fester Seed für Lauf 1 dieser Spielversion

type Range = { read min: number, read max: number }

export type ZoneConfig = {
	read index: number,
	read factor: number, -- Referenzcharakter-Faktor (Reachability.ZONE_FACTORS)
	read abilities: { read doubleJump: boolean, read dash: boolean },
	read connections: Range,
	read rise: Range, -- Anstieg normaler Sprünge
	read gapMin: number,
	read gapUsage: number, -- Anteil der maximal fairen Lücke, den der Generator höchstens nutzt
	read platformLength: Range,
	read platformWidth: number,
	read conveyorChance: number,
	read conveyorSpeed: number,
	read padChance: number,
	read padFromFloor: number,
	read padRise: Range,
	read padHeight: number, -- Sprungpad-Höhe (Studs) → vertikale Startgeschwindigkeit
	read palette: string,
}

TowerConfig.ZONES = table.freeze({
	table.freeze({
		index = 1,
		factor = 0.75,
		abilities = { doubleJump = false, dash = false },
		connections = { min = 6, max = 8 },
		rise = { min = 0.5, max = 3.5 },
		gapMin = 0.5,
		gapUsage = 0.9,
		platformLength = { min = 4, max = 10 },
		platformWidth = 8,
		conveyorChance = 0.18,
		conveyorSpeed = 6,
		padChance = 0.4,
		padFromFloor = 3,
		padRise = { min = 5.5, max = 6.5 }, -- ≤ 6,5: auch ohne Pad-Impuls für geübte Spieler lösbar (CR-01)
		padHeight = 13,
		palette = "meadow",
	} :: ZoneConfig),
})

return table.freeze(TowerConfig)
