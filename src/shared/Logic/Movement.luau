--!strict
-- Bewegungskonstanten und -formeln. Einzige Quelle für Generator, Erreichbarkeitsprüfer,
-- Server-Plausibilität und Client-Steuerung (tech_notes §6.3, GDD v0.2 §5).
-- Roblox-Defaults im Original geprüft (creator-docs @af5f853): Gravity 196,2; JumpHeight 7,2; WalkSpeed 16.
-- Wir setzen CharacterUseJumpPower = false (Default wäre true mit JumpPower 50).

export type Stats = {
	read gravity: number,
	read walkSpeed: number,
	read jumpHeight: number,
	read doubleJumpHeight: number,
	read dashSpeed: number,
	read dashDuration: number,
}

local Movement = {}

Movement.BASE_STATS = table.freeze({
	gravity = 196.2,
	walkSpeed = 16,
	jumpHeight = 7.2,
	doubleJumpHeight = 7.2 * 0.85, -- DJ setzt vy auf den Wert für 85 % der Sprunghöhe
	dashSpeed = 48, -- Schwebe-Dash: horizontal, Schwerkraft währenddessen aus
	dashDuration = 0.25,
} :: Stats)

-- Charakter-Hitbox (R15, ungefähr) [VORWISSEN, nicht aktuell → Owner prüft in Studio].
Movement.HITBOX = table.freeze({ width = 2, height = 5 })

-- Steuerungs-Komfort (GDD v0.2 §5).
Movement.CONTROL = table.freeze({
	coyoteTime = 0.12,
	jumpBuffer = 0.1,
	doubleJumpMinDelay = 0.15,
	dashCooldown = 2.5,
})

-- Unter dieser Höhe der Füße (relativ zur aktuellen Etagenplattform) gilt ein Spieler als gefallen.
Movement.FALL_RESET_DEPTH = 4
-- Abstand HumanoidRootPart-Mitte ↔ Füße (R15, ungefähr) [VORWISSEN, nicht aktuell → Owner prüft].
Movement.ROOT_HEIGHT = 3

function Movement.jumpVelocity(height: number, gravity: number): number
	return math.sqrt(2 * gravity * height)
end

-- Skaliert alle Fähigkeitswerte mit einem Faktor (Referenzcharakter, Sicherheitsfaktor je Zone).
function Movement.scaled(stats: Stats, factor: number): Stats
	return {
		gravity = stats.gravity,
		walkSpeed = stats.walkSpeed * factor,
		jumpHeight = stats.jumpHeight * factor,
		doubleJumpHeight = stats.doubleJumpHeight * factor,
		dashSpeed = stats.dashSpeed * factor,
		dashDuration = stats.dashDuration,
	}
end

return table.freeze(Movement)
