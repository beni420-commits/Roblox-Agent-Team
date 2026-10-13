--!strict
-- Alle Client→Server-Remotes mit Argumentprüfung und Rate-Limit.
-- Interaktionen (Versteck betreten, Behälter, Fragmente, Entwerter öffnen) laufen über
-- ProximityPrompts, deren Auslösung der Server selbst erhält – dafür gibt es keine Remotes.

local Validator = require("../Util/Validator")

export type Definition = {
	read check: (args: { any }, count: number) -> (boolean, string?),
	read perSecond: number,
	read burst: number,
}

local Definitions: { [string]: Definition } = {
	-- Versteck verlassen (Knopf im Versteck)
	RequestLeaveHiding = {
		check = Validator.args({}),
		perSecond = 1,
		burst = 3,
	},
	-- Lochmuster am Entwerter (9-Bit-Maske, Compliance H-A12: keine Texteingabe)
	SubmitPattern = {
		check = Validator.args({ Validator.integer(0, 511) }),
		perSecond = 0.5,
		burst = 2,
	},
	-- Bevorzugte Eingabe für die Telemetrie
	ReportPreferredInput = {
		check = Validator.args({ Validator.enum({ "Touch", "KeyboardAndMouse", "Gamepad" }) }),
		perSecond = 1,
		burst = 3,
	},
}

-- Server → Client (keine Prüfung nötig; nur Namen, damit beide Seiten dieselben nutzen).
local serverToClient: { [string]: string } = {
	WorldEvent = "WorldEvent", -- an alle: Ereignisse, Fahrpläne, Schaffner-Wege
	PersonalEvent = "PersonalEvent", -- an einen Spieler: Tod, Kälte, Entwerter, Ergebnis
}
local ServerToClient = table.freeze(serverToClient)

return table.freeze({
	ClientToServer = table.freeze(Definitions),
	ServerToClient = ServerToClient,
	FolderName = "Remotes",
})
