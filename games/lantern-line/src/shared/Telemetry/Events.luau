--!strict
-- Erlaubte Telemetrie-Namen (docs/lantern-line/telemetry_plan.md). Nur Namen aus dieser Tabelle dürfen gesendet werden.

local Events = {}

-- Onboarding (erster Lauf). Roblox wertet übersprungene Schritte als erledigt;
-- der Funnel misst „mindestens bis Schritt n gekommen“.
Events.ONBOARDING_STEPS = table.freeze({
	[1] = "Platform",
	[2] = "Boarded",
	[3] = "FirstDoor",
	[4] = "FirstHide",
	[5] = "Carriage10",
	[6] = "Carriage25",
	[7] = "PostCar",
	[8] = "LineComplete",
})

-- Lauf-Funnel: Meilenstein-Wagen je Lauf (Schritt i = MILESTONES[i]; letzter Schritt = geschafft).
Events.RUN_FUNNEL = "Run"
Events.MILESTONES = table.freeze({ 1, 5, 10, 15, 20, 25, 30, 35, 40, 45, 50 })
Events.FINISH_STEP = #Events.MILESTONES + 1

local custom: { [string]: string } = {
	Death = "Death", -- Wert = Wagen, Feld 03 = Ursache
	Damage = "Damage", -- Wert = Schaden, Feld 03 = Ursache
	Hide = "Hide", -- Wert = Wagen
	PatternWrong = "PatternWrong",
	PatternSolved = "PatternSolved",
	RunEnded = "RunEnded", -- Wert = erreichter Wagen, Feld 03 = won/lost
	SettingChanged = "SettingChanged",
	RemoteRejected = "RemoteRejected",
}
Events.CUSTOM = table.freeze(custom)

-- Schritt im Lauf-Funnel für einen erreichten Wagen (nil, wenn kein Meilenstein).
function Events.milestoneStep(carriage: number): number?
	for i, m in Events.MILESTONES do
		if m == carriage then
			return i
		end
	end
	return nil
end

return table.freeze(Events)
