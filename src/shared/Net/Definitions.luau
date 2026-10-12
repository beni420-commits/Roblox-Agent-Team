--!strict
-- Alle Client→Server-Remotes mit Argumentprüfung und Rate-Limit (tech_notes §3, §6.5).
-- Der Server registriert nur, was hier steht; alles andere existiert nicht.

local Validator = require("../Util/Validator")

export type Definition = {
	read check: (args: { any }, count: number) -> (boolean, string?),
	read perSecond: number,
	read burst: number,
}

local MAX_SPARK_ID = 30 * 100 + 16

local Definitions: { [string]: Definition } = {
	CollectSpark = {
		check = Validator.args({ Validator.integer(101, MAX_SPARK_ID) }),
		perSecond = 10,
		burst = 20,
	},
	RequestRespawn = {
		check = Validator.args({}),
		perSecond = 1,
		burst = 2,
	},
	RequestReset = {
		-- Roblox-Reset-Knopf: zurück an den Etagenanfang, ohne Fehlversuch und ohne Charaktertod (CR-17).
		check = Validator.args({}),
		perSecond = 0.5,
		burst = 1,
	},
	ReportOnboardingStep = {
		check = Validator.args({ Validator.integer(1, 7) }),
		perSecond = 2,
		burst = 4,
	},
	ReportPreferredInput = {
		check = Validator.args({ Validator.enum({ "Touch", "KeyboardAndMouse", "Gamepad" }) }),
		perSecond = 1,
		burst = 3,
	},
}

-- Server → Client (keine Prüfung nötig; nur Namen, damit beide Seiten dieselben nutzen).
local serverToClient: { [string]: string } = {
	StateSync = "StateSync",
}
local ServerToClient = table.freeze(serverToClient)

return table.freeze({
	ClientToServer = table.freeze(Definitions),
	ServerToClient = ServerToClient,
	FolderName = "Remotes",
})
