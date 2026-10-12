--!strict
-- Findet, auf welcher Etagenplattform eine Position steht (Server: Etagenerkennung mit 10 Hz).
-- Die Box reicht bis 8 Studs über die Oberkante, damit auch Spieler im Sprung über der Plattform zählen.

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
