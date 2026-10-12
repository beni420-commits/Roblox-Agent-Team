--!strict
-- Findet, auf welcher Etagenplattform eine Position steht (Server: Etagenerkennung mit 10 Hz).
-- Die Box reicht bis 8 Studs über die Oberkante, damit auch Spieler im Sprung über der Plattform zählen.

local TowerConfig = require("./TowerConfig")
local TowerGenerator = require("./TowerGenerator")

local LandingLocator = {}

LandingLocator.ABOVE = 8
LandingLocator.BELOW = 0.5
LandingLocator.MARGIN_ACROSS = 1 -- quer zur Laufrichtung großzügig
LandingLocator.MARGIN_ALONG = 0.3 -- in Laufrichtung knapp: erst wer auf der Plattform steht, hat sie erreicht

function LandingLocator.landingAt(tower: TowerGenerator.TowerSpec, x: number, y: number, z: number): number?
	-- Kandidat über die Höhe bestimmen, dann die Grundfläche prüfen.
	for floor = 0, tower.builtFloors do
		local landing = tower.landings[floor]
		if y >= landing.y - LandingLocator.BELOW and y <= landing.y + LandingLocator.ABOVE then
			local dx, dz = x - landing.x, z - landing.z
			local along = dx * landing.fx + dz * landing.fz
			local across = dx * landing.fz - dz * landing.fx
			if
				math.abs(along) <= landing.halfLength + LandingLocator.MARGIN_ALONG
				and math.abs(across) <= landing.halfWidth + LandingLocator.MARGIN_ACROSS
			then
				return floor
			end
		end
	end
	return nil
end

-- Ganz unten (von der Bodenscheibe gefallen): gilt auch auf der obersten Etage als Sturz (CR-32).
LandingLocator.OFF_WORLD_Y = -10

-- In welchem 90°-Sektor (0–3) liegt eine Position? Abschnitt k (zu Etage k) liegt in Sektor (k - 1) mod 4.
function LandingLocator.sectorOf(x: number, z: number): number
	local angle = math.atan2(z, x) % (2 * math.pi)
	return math.floor(angle / TowerConfig.SECTOR_ANGLE) % 4
end

-- Rücksetz-Schwelle für die HumanoidRootPart-Mitte, abhängig vom Ort (CR-05, CR-31, CR-32):
-- * oberste gebaute Etage: nur wer von der Welt fällt
-- * im Abschnitt hinter der aktuellen Etagenplattform (Rückweg): Basis ist die Etagenplattform davor
-- * sonst: Basis ist die aktuelle Etagenplattform
function LandingLocator.resetThreshold(
	tower: TowerGenerator.TowerSpec,
	currentFloor: number,
	x: number,
	z: number,
	depth: number,
	rootHeight: number
): number
	if currentFloor >= tower.builtFloors then
		return LandingLocator.OFF_WORLD_Y
	end
	local base = currentFloor
	if currentFloor >= 1 and LandingLocator.sectorOf(x, z) == (currentFloor - 1) % 4 then
		base = currentFloor - 1
	end
	return LandingLocator.fallThreshold(tower, base, depth, rootHeight)
end

-- Zählt ein getroffenes Bauteil der Etage `partFloor` als Boden? Nur Teile der aktuellen und der nächsten
-- Etage; Erdboden, Plaza und tiefere Etagen bedeuten „gefallen“ (CR-31).
function LandingLocator.isLegitGround(partFloor: number?, currentFloor: number): boolean
	if partFloor == nil then
		return false
	end
	return partFloor == currentFloor or partFloor == currentFloor + 1
end

-- Ab welcher Höhe der HumanoidRootPart-Mitte gilt ein Spieler als gefallen? (Füße `depth` unter der Plattform.)
-- Ob er wirklich fällt (und nicht auf einer tieferen Plattform zurückgeht), prüft der Aufrufer per Raycast.
function LandingLocator.fallThreshold(
	tower: TowerGenerator.TowerSpec,
	currentFloor: number,
	depth: number,
	rootHeight: number
): number
	return tower.landings[currentFloor].y - depth + rootHeight
end

return table.freeze(LandingLocator)
