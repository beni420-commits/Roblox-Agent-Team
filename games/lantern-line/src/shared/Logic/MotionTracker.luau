--!strict
-- Waagerechte Bewegung eines Spielers aus Positionsproben (Server, ca. 10–20 Hz).
-- Grundlage für Kontrolleur (Bewegung bei „Halt“) und Schaffner (Geräusch nach Tempo).

export type Sample = { t: number, x: number, z: number }
export type Tracker = { samples: { Sample } }

local KEEP = 1.0 -- Sekunden
local EPSILON = 1e-6 -- Rundung bei Zeitstempeln (0,1 + 0,2 ≠ 0,3)

local MotionTracker = {}

function MotionTracker.new(): Tracker
	return { samples = {} }
end

function MotionTracker.add(tracker: Tracker, t: number, x: number, z: number)
	local samples = tracker.samples
	table.insert(samples, { t = t, x = x, z = z })
	while #samples > 2 and samples[1].t < t - KEEP do
		table.remove(samples, 1)
	end
end

function MotionTracker.reset(tracker: Tracker)
	table.clear(tracker.samples)
end

-- Verschiebung zwischen der neuesten Probe und der letzten Probe, die mindestens `window` älter ist.
-- Gibt es noch keine so alte Probe, zählt die älteste vorhandene.
function MotionTracker.displacement(tracker: Tracker, window: number): number
	local samples = tracker.samples
	local n = #samples
	if n < 2 then
		return 0
	end
	local latest = samples[n]
	local ref = samples[1]
	for i = n - 1, 1, -1 do
		if latest.t - samples[i].t >= window - EPSILON then
			ref = samples[i]
			break
		end
	end
	local dx, dz = latest.x - ref.x, latest.z - ref.z
	return math.sqrt(dx * dx + dz * dz)
end

-- Geschwindigkeit (Studs/s) über das Fenster.
function MotionTracker.speed(tracker: Tracker, window: number): number
	local samples = tracker.samples
	local n = #samples
	if n < 2 then
		return 0
	end
	local latest = samples[n]
	local ref = samples[1]
	for i = n - 1, 1, -1 do
		if latest.t - samples[i].t >= window - EPSILON then
			ref = samples[i]
			break
		end
	end
	local dt = latest.t - ref.t
	if dt <= 0 then
		return 0
	end
	local dx, dz = latest.x - ref.x, latest.z - ref.z
	return math.sqrt(dx * dx + dz * dz) / dt
end

return table.freeze(MotionTracker)
