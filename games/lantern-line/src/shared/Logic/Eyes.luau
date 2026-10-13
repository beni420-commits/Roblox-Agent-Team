--!strict
-- Blinder Passagier (§6.3, neu nach Recherche/Compliance): grüne Augenpaare unter Sitzen und in
-- Gepäckablagen dunkler Wagen. Wer einem Augenpaar näher als EYES_SNATCH_RADIUS kommt, verliert
-- EYES_DAMAGE Lebenspunkte; das Augenpaar verschwindet danach. Ab EYES_WAKE_RADIUS leuchten sie hell.
-- Der Fairness-Prüfer garantiert einen Weg ohne Kontakt (Fairness.gridFor sperrt die Augen).

local GameConfig = require("../Config/GameConfig")
local Types = require("./Types")

export type EyeState = {
	carriage: number,
	id: number,
	x: number, -- Welt-x
	z: number,
	used: boolean,
}

local Eyes = {}

function Eyes.fromCarriage(c: Types.Carriage): { EyeState }
	local list: { EyeState } = {}
	for _, eye in c.eyes do
		table.insert(list, { carriage = c.index, id = eye.id, x = c.originX + eye.x, z = eye.z, used = false })
	end
	return list
end

local function distSq(eye: EyeState, px: number, pz: number): number
	local dx, dz = eye.x - px, eye.z - pz
	return dx * dx + dz * dz
end

-- Erstes unbenutztes Augenpaar in Fangweite (markiert es als benutzt) oder nil.
function Eyes.snatch(list: { EyeState }, px: number, pz: number): EyeState?
	local r = GameConfig.EYES_SNATCH_RADIUS
	for _, eye in list do
		if not eye.used and distSq(eye, px, pz) < r * r then
			eye.used = true
			return eye
		end
	end
	return nil
end

function Eyes.isAwake(eye: EyeState, px: number, pz: number): boolean
	local r = GameConfig.EYES_WAKE_RADIUS
	return not eye.used and distSq(eye, px, pz) < r * r
end

return table.freeze(Eyes)
