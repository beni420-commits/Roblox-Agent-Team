--!strict
-- Erreichbarkeitsprüfer (tech_notes §6.3, Playtest-Befund P-02).
-- Simuliert die Flugbahn eines Referenzcharakters zwischen zwei Plattformen statt Sicherheitsfaktoren
-- je Achse anzuwenden. Koordinaten je Verbindung: x = horizontal in Laufrichtung (0 = Absprungkante),
-- y = Fußhöhe relativ zur Absprungfläche.

local Movement = require("./Movement")

export type Connection = {
	read gap: number, -- Kante-zu-Kante-Abstand in Laufrichtung (Studs)
	read rise: number, -- Höhe der Landefläche minus Höhe der Absprungfläche
	read ceiling: number?, -- freie Höhe über der Absprungfläche (nil = unbegrenzt), z. B. Tunnel
	read launchVelocity: number?, -- Sprungpad: vertikale Startgeschwindigkeit statt eigenem Sprung
	read launchDistance: number?, -- Sprungpad: Abstand des Abwurfpunkts zur Kante (ersetzt Absprung-Annahmen)
	read windWall: boolean?, -- Windwand: nur ein Dash kommt hindurch
}

export type Abilities = { read doubleJump: boolean?, read dash: boolean? }

export type Profile = {
	stats: Movement.Stats,
	takeoffOffset: number, -- Absprung so weit vor der Kante
	latency: number, -- Eingabelatenz: Absprung entsprechend früher (konservativ)
	landingMargin: number, -- Körpermitte muss so weit hinter der Landekante liegen (negativ = Kante reicht)
	djOffsets: { number }, -- Doppelsprung relativ zum Scheitel des ersten Sprungs
	requireAllTimings: boolean, -- true: alle Zeitpunkte müssen gelingen (Referenz); false: einer reicht
	clearanceMargin: number,
}

-- jump = eigener Sprung bzw. Sprungpad; groundDash = Dash vom Boden ohne Sprung (z. B. Tunnel).
export type Plan = { jump: boolean, doubleJump: boolean, dash: boolean }

export type Result = { landed: boolean, reason: string, maxHeight: number, landingX: number }

local Reachability = {}

local DT = 1 / 120
local MAX_TIME = 4

local PLANS: { Plan } = {
	{ jump = true, doubleJump = false, dash = false },
	{ jump = true, doubleJump = true, dash = false },
	{ jump = false, doubleJump = false, dash = true },
	{ jump = true, doubleJump = false, dash = true },
	{ jump = true, doubleJump = true, dash = true },
}

-- Startwerte je Zone (GDD v0.2 §5, tech_notes §6.3) [ANNAHME → Owner-Playtest].
Reachability.ZONE_FACTORS = table.freeze({ 0.75, 0.85, 0.88 })
Reachability.DAILY_FACTOR = 0.88
Reachability.HELPER_FACTOR = 0.6

function Reachability.referenceProfile(factor: number): Profile
	return {
		stats = Movement.scaled(Movement.BASE_STATS, factor),
		takeoffOffset = 0.5,
		latency = 0.1,
		landingMargin = 0.5,
		djOffsets = { -0.1, 0, 0.1 },
		requireAllTimings = true,
		clearanceMargin = 1,
	}
end

-- Großzügiges Modell: volle Werte, keine Latenz, Absprung an der Kante, optimales Timing.
-- Damit wird geprüft, ob eine Lücke eine Fähigkeit wirklich verlangt.
function Reachability.generousProfile(): Profile
	local offsets = {}
	for i = -12, 30 do
		table.insert(offsets, i * 0.02)
	end
	return {
		stats = Movement.BASE_STATS,
		takeoffOffset = 0,
		latency = 0,
		landingMargin = -Movement.HITBOX.width / 2,
		djOffsets = offsets,
		requireAllTimings = false,
		clearanceMargin = 0,
	}
end

-- Simuliert eine einzelne Flugbahn. djOffset: Zeitpunkt des Doppelsprungs relativ zum ersten Scheitel.
-- Horizontal steuert ein „gieriger“ Regler: volle Geschwindigkeit nach vorn, aber nie mit der
-- Hitbox gegen die Seitenwand einer höheren Landeplattform (Spieler können in der Luft abbremsen).
-- Während eines Dashs gibt es diese Kontrolle nicht.
function Reachability.simulate(connection: Connection, profile: Profile, plan: Plan, djOffset: number?): Result
	local stats = profile.stats
	local g = stats.gravity
	local halfWidth = Movement.HITBOX.width / 2
	local ceiling = connection.ceiling or math.huge
	local wallX = connection.gap - halfWidth - 0.01

	local vy = 0
	if plan.jump then
		vy = connection.launchVelocity or Movement.jumpVelocity(stats.jumpHeight, g)
	end
	-- Start nie innerhalb der Seitenwand einer höheren Landeplattform (sehr kleine Lücken).
	local x = -profile.takeoffOffset - stats.walkSpeed * profile.latency
	if connection.launchDistance then
		-- Sprungpad: Der Wurf startet dort, wo der Spieler das Pad berührt (konservativ: hintere Padkante).
		x = -connection.launchDistance
	end
	if connection.rise > 0 then
		x = math.min(x, wallX)
	end
	local y = 0
	local t = 0
	local maxHeight = 0

	local apex1 = vy / g
	local djTime = math.huge
	if plan.doubleJump then
		djTime = math.max(apex1 + (djOffset or 0), Movement.CONTROL.doubleJumpMinDelay) -- frühe Eingabe gepuffert
	end
	local djDone = false
	local dashStart = math.huge
	if plan.dash and not plan.doubleJump then
		dashStart = apex1 -- Dash am Scheitel (bzw. sofort beim Boden-Dash)
	end
	local dashEnd = dashStart + stats.dashDuration

	while t < MAX_TIME do
		if plan.doubleJump and not djDone and t >= djTime then
			djDone = true
			vy = Movement.jumpVelocity(stats.doubleJumpHeight, g) -- setzt vy, addiert nicht
			if plan.dash then
				dashStart = t + vy / g
				dashEnd = dashStart + stats.dashDuration
			end
		end

		local dashing = t >= dashStart and t < dashEnd
		local prevX, prevY = x, y
		if dashing then
			vy = 0
			x += stats.dashSpeed * DT
		else
			-- Exakte Kinematik je Schritt (kein Euler-Fehler bei der Sprunghöhe).
			y += vy * DT - 0.5 * g * DT * DT
			vy -= g * DT
			local nextX = x + stats.walkSpeed * DT
			if prevY < connection.rise - 0.01 and nextX > wallX and x <= wallX + 1e-6 then
				nextX = math.max(x, wallX)
			end
			x = nextX
		end
		t += DT
		maxHeight = math.max(maxHeight, y)

		if y + Movement.HITBOX.height + profile.clearanceMargin > ceiling then
			return { landed = false, reason = "ceiling", maxHeight = maxHeight, landingX = x }
		end

		-- Landung: abwärts durch die Höhe der Landefläche.
		if prevY >= connection.rise and y < connection.rise then
			local fraction = (prevY - connection.rise) / math.max(prevY - y, 1e-9)
			local crossX = prevX + (x - prevX) * fraction
			if crossX >= connection.gap + profile.landingMargin then
				return { landed = true, reason = "ok", maxHeight = maxHeight, landingX = crossX }
			end
			return { landed = false, reason = "short", maxHeight = maxHeight, landingX = crossX }
		end

		-- Seitlicher Aufprall (nur noch möglich, wenn ein Dash die Hitbox in die Wand schiebt).
		if x + halfWidth > connection.gap and y < connection.rise - 0.01 and x - halfWidth < connection.gap then
			return { landed = false, reason = "side", maxHeight = maxHeight, landingX = x }
		end
		if connection.windWall and x > connection.gap * 0.5 and prevX <= connection.gap * 0.5 and not dashing then
			-- Die Windwand steht in der Mitte der Lücke; nur ein laufender Dash bricht hindurch.
			return { landed = false, reason = "wind", maxHeight = maxHeight, landingX = x }
		end
	end
	return { landed = false, reason = "timeout", maxHeight = maxHeight, landingX = x }
end

local function planAllowed(plan: Plan, abilities: Abilities): boolean
	if plan.doubleJump and not abilities.doubleJump then
		return false
	end
	if plan.dash and not abilities.dash then
		return false
	end
	if not plan.jump and not plan.dash then
		return false
	end
	return true
end

-- Gelingt ein Plan unter einem Profil? Referenz: alle DJ-Zeitpunkte; großzügig: irgendeiner.
local function planSucceeds(connection: Connection, profile: Profile, plan: Plan): boolean
	if not plan.doubleJump then
		return Reachability.simulate(connection, profile, plan, nil).landed
	end
	for _, offset in profile.djOffsets do
		local landed = Reachability.simulate(connection, profile, plan, offset).landed
		if profile.requireAllTimings and not landed then
			return false
		end
		if not profile.requireAllTimings and landed then
			return true
		end
	end
	return profile.requireAllTimings
end

-- Ist die Verbindung mit den gegebenen Fähigkeiten lösbar? Liefert den einfachsten Plan.
function Reachability.canReach(connection: Connection, profile: Profile, abilities: Abilities): (boolean, Plan?)
	for _, plan in PLANS do
		if planAllowed(plan, abilities) and planSucceeds(connection, profile, plan) then
			return true, plan
		end
	end
	return false, nil
end

-- Verlangt die Verbindung eine Fähigkeit wirklich? (tech_notes §6.3 Punkt 3)
-- Ohne Fähigkeit mit großzügigem Modell unlösbar UND mit Fähigkeit mit Referenzcharakter lösbar.
function Reachability.requiresAbility(
	connection: Connection,
	ability: "doubleJump" | "dash",
	baseAbilities: Abilities,
	factor: number
): boolean
	local isDoubleJump = ability == "doubleJump"
	local without: Abilities = {
		doubleJump = if isDoubleJump then false else baseAbilities.doubleJump,
		dash = if isDoubleJump then baseAbilities.dash else false,
	}
	local with: Abilities = {
		doubleJump = if isDoubleJump then true else baseAbilities.doubleJump,
		dash = if isDoubleJump then baseAbilities.dash else true,
	}
	local solvableWithout = Reachability.canReach(connection, Reachability.generousProfile(), without)
	local solvableWith = Reachability.canReach(connection, Reachability.referenceProfile(factor), with)
	return (not solvableWithout) and solvableWith
end

-- Größte lösbare Lücke für eine Höhe (Binärsuche; Erreichbarkeit fällt monoton mit der Lücke).
function Reachability.maxGap(rise: number, profile: Profile, abilities: Abilities, ceiling: number?): number
	local function ok(gap: number): boolean
		return (Reachability.canReach({ gap = gap, rise = rise, ceiling = ceiling }, profile, abilities))
	end
	if not ok(0) then
		return -1
	end
	local low, high = 0, 40
	for _ = 1, 30 do
		local mid = (low + high) / 2
		if ok(mid) then
			low = mid
		else
			high = mid
		end
	end
	return low
end

return table.freeze(Reachability)
