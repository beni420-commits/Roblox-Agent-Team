--!strict
-- Flacker-Planer (Compliance H-A10): Alle Lampen eines Ereignisses flackern synchron nach EINEM Plan,
-- damit die Blitzzahl für den ganzen Bildschirm gilt. Höchstens MAX_PER_SECOND Pulse je 1-s-Fenster
-- (Ziel 2, WCAG-Grenze 3). Ein Puls = kurzes Abdunkeln und Wiederaufhellen (ein Blitz).
-- „Flackern reduzieren“: keine Pulse, nur sanftes Abdunkeln (levelAt mit reduced = true).

local Prng = require("../Util/Prng")

export type Pulse = { t0: number, t1: number }

local FlickerPlanner = {}

FlickerPlanner.MAX_PER_SECOND = 2
FlickerPlanner.DIM_LEVEL = 0.15
FlickerPlanner.REDUCED_LEVEL = 0.45
FlickerPlanner.REDUCED_FADE = 0.4 -- Sekunden (Übergänge ≥ 0,3 s)

function FlickerPlanner.pulses(seed: number, from: number, to: number): { Pulse }
	local rng = Prng.new(seed)
	local spacing = 1 / FlickerPlanner.MAX_PER_SECOND
	local list: { Pulse } = {}
	local t = from + rng.nextRange(0, 0.2)
	while t < to do
		local duration = rng.nextRange(0.12, 0.25)
		table.insert(list, { t0 = t, t1 = math.min(t + duration, to) })
		-- Abstand der Pulsanfänge > spacing (strikt), plus Zufall; so liegen nie 3 Anfänge in 1 s.
		t += spacing + 0.01 + rng.nextRange(0, 0.4)
	end
	return list
end

-- Größte Zahl von Pulsanfängen in einem gleitenden Fenster der Länge `window`.
function FlickerPlanner.maxInWindow(list: { Pulse }, window: number): number
	local best = 0
	local j = 1
	for i = 1, #list do
		while list[i].t0 - list[j].t0 >= window do
			j += 1
		end
		best = math.max(best, i - j + 1)
	end
	return best
end

-- Helligkeitsfaktor (0–1) der Lampen zum Zeitpunkt t.
function FlickerPlanner.levelAt(list: { Pulse }, from: number, to: number, t: number, reduced: boolean): number
	if t < from or t > to then
		return 1
	end
	if reduced then
		local fade = FlickerPlanner.REDUCED_FADE
		local k = math.min(1, (t - from) / fade, (to - t) / fade)
		return 1 - (1 - FlickerPlanner.REDUCED_LEVEL) * math.max(0, k)
	end
	for _, pulse in list do
		if t >= pulse.t0 and t <= pulse.t1 then
			return FlickerPlanner.DIM_LEVEL
		end
	end
	return 1
end

return table.freeze(FlickerPlanner)
