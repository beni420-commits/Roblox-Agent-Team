--!strict
-- Zentrale Spielwerte (GDD v0.2). Einheiten: Studs und Sekunden.
-- Werte zu Spielgefühl und Balancing sind [ANNAHME], bis Playtests vorliegen.

local GameConfig = table.freeze({
	-- Lauf „Linie 1“
	RUN_LAST_CARRIAGE = 50, -- Wagen 0 = Einstieg, 50 = Postwagen (Finale)
	MAX_PLAYERS = 4,
	GRACE_CARRIAGES = 4, -- Wagen 0–4 ohne Wesen
	EVENT_LAST_INDEX = 48, -- Wagen 49 und 50 ohne zufällige Ereignisse
	SLEEPER_MAX_SHARE = 0.25, -- höchstens 25 % Schlafwagen je Lauf (Compliance H-A7)

	-- Figur
	WALK_SPEED = 16, -- Roblox-Standard
	SNEAK_SPEED = 8,
	MAX_HEALTH = 100,

	-- Zug-Geometrie (Innenmaße)
	INNER_WIDTH = 12,
	INNER_HEIGHT = 11,
	GANGWAY = 4, -- Übergang zwischen zwei Wagen
	DOOR_WIDTH = 5,
	DOOR_HEIGHT = 8,
	FLOOR_Y = 0, -- Oberkante Wagenboden (Welt)
	PLAYER_CLEARANCE = 1, -- halbe Figurbreite für die Wegeprüfung

	-- Türen
	DOOR_OPEN_DISTANCE = 6,
	RETAIN_BEHIND = 4, -- so viele Wagen hinter dem höchsten geöffneten bleiben bestehen („Der Ruck“)
	BUILD_AHEAD = 1, -- so viele Wagen vor dem höchsten geöffneten sind gebaut

	-- Verstecke und Kälte (§7)
	HIDE_ENTER_TIME = 0.5,
	HIDE_COLD_WARN = 14,
	HIDE_COLD_EJECT = 20,
	REACTION_TIME = 1.0, -- Reaktionszeit im Fairness-Prüfer

	-- Express (§6.1)
	EXPRESS_MIN_INDEX = 5,
	EXPRESS_DELAY_MIN = 2.5,
	EXPRESS_DELAY_MAX = 3.5,
	EXPRESS_SPAWN_BEHIND = 140,
	EXPRESS_SPEED = 70,
	EXPRESS_KILL_MARGIN = 2,
	EXPRESS_CHANCE_START = 0.15,
	EXPRESS_CHANCE_END = 0.28,
	EXPRESS_GAP = 4, -- Mindestabstand in Wagen zwischen Express und Gegenzug
	MIN_SPOTS_FOR_RUSH = 4, -- Verstecke in k−1 ∪ k

	-- Gegenzug (§6.2): Licht flutet eine Wagenseite
	ONCOMING_MIN_INDEX = 10,
	ONCOMING_SHARE = 0.4, -- Anteil der Rausch-Ereignisse, die ein Gegenzug sind
	ONCOMING_DELAY_MIN = 3.0,
	ONCOMING_DELAY_MAX = 4.0,
	ONCOMING_DURATION = 1.6,
	ONCOMING_SAFE_Z = 1.0, -- sicher, wenn z · Seite ≤ −ONCOMING_SAFE_Z
	ONCOMING_DAMAGE = 50,

	-- Dunkle Wagen und Blinder Passagier (§6.3): grüne Augen, Abstand halten
	DARK_MIN_INDEX = 8,
	DARK_CHANCE_START = 0.12,
	DARK_CHANCE_END = 0.25,
	EYES_MIN = 2,
	EYES_MAX = 4,
	EYES_SNATCH_RADIUS = 2.5,
	EYES_WAKE_RADIUS = 8, -- ab hier leuchten die Augen hell auf
	EYES_DAMAGE = 35,

	-- Kontrolleur (§6.4)
	INSPECTOR_MIN_INDEX = 7,
	INSPECTOR_CHANCE = 0.3,
	INSPECTOR_GAP = 6,
	INSPECTOR_INTRO = 2,
	INSPECTOR_AMBER_MIN = 3.5,
	INSPECTOR_AMBER_MAX = 5.5,
	INSPECTOR_WARN = 1.2,
	INSPECTOR_RED_MIN = 2.0,
	INSPECTOR_RED_MAX = 3.0,
	INSPECTOR_GRACE = 0.35,
	INSPECTOR_MOVE_WINDOW = 0.3,
	INSPECTOR_MOVE_THRESHOLD = 1.5,
	INSPECTOR_DAMAGE = 40,
	INSPECTOR_CHECK_DISTANCE = 8,
	INSPECTOR_X_FROM_FRONT = 2.5,
	INSPECTOR_Z = -3.5,

	-- Kofferlawine (§6.6, Verfolgungsjagd)
	CHASE_START_MIN = 25,
	CHASE_START_MAX = 38,
	CHASE_LENGTH = 5, -- Wagen c … c+4
	CHASE_WARN = 3,
	CHASE_SPEED = 13,
	CHASE_CATCH = 1.5,

	-- Schaffner (§6.5)
	CONDUCTOR_WAKE = 6,
	CONDUCTOR_PATROL_SPEED = 7,
	CONDUCTOR_HUNT_SPEED = 13,
	CONDUCTOR_CATCH = 3.5,
	CONDUCTOR_FORGET = 5,
	CONDUCTOR_VIEW_DISTANCE = 16,
	CONDUCTOR_VIEW_ANGLE = 30, -- halber Öffnungswinkel des Laternenkegels in Grad
	NOISE_WALK_RADIUS = 22,
	NOISE_SNEAK_RADIUS = 6,
	NOISE_WALK_SPEED = 10, -- ab dieser Geschwindigkeit gilt man als „laufend“
	NOISE_MIN_SPEED = 2,
	NOISE_WRONG_CODE_RADIUS = 60,
	CONDUCTOR_MIN_START_DISTANCE = 60,

	-- Behälter
	LOCKED_MIN_INDEX = 3,
	LOCKED_CHANCE = 0.2,
	STUB_CHANCE = 0.4,

	-- Bahnsteig
	LOBBY_COUNTDOWN = 15,
	LOBBY_COUNTDOWN_ALL_READY = 3,
	END_SCREEN_TIME = 15,
})

export type GameConfig = typeof(GameConfig)

return GameConfig
