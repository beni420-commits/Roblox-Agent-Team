--!strict
-- Erlaubte Telemetrie-Namen (docs/telemetry_plan.md). Nur Namen aus dieser Tabelle dürfen gesendet werden.

local Events = {}

Events.ONBOARDING_STEPS = table.freeze({
	[1] = "Spawned",
	[2] = "FirstMove",
	[3] = "FirstSpark",
	[4] = "FirstJump",
	[5] = "Floor1",
	[6] = "FirstCamp",
	[7] = "FirstUpgrade",
	[8] = "Zone1Done",
})

Events.PROGRESSION_MAIN = "MainTower"
Events.CURRENCY = "Sparks"

local custom: { [string]: string } = {
	FloorSummary = "FloorSummary",
	HelpShown = "HelpShown",
	SummitReached = "SummitReached",
	RunStarted = "RunStarted",
	AbilityUnlocked = "AbilityUnlocked",
	AbilityResult = "AbilityResult",
	SessionEnded = "SessionEnded",
	SettingChanged = "SettingChanged",
	ClientPerf = "ClientPerf",
	ServerHealth = "ServerHealth",
	RemoteRejected = "RemoteRejected",
	MovementFlagged = "MovementFlagged",
	DataError = "DataError",
	CampLiftUsed = "CampLiftUsed",
	SignalSent = "SignalSent",
	DailyTowerStarted = "DailyTowerStarted",
	MomentumPeak = "MomentumPeak",
}
Events.CUSTOM = table.freeze(custom)

Events.ECONOMY_SKUS = table.freeze({
	floorSparks = "floor_sparks",
	campBonus = "camp_bonus",
})

-- Etagen-Bündel für Custom Field 03 (begrenzte Kardinalität).
function Events.floorBucket(floor: number): string
	local low = (floor // 5) * 5
	return string.format("F%02d-%02d", low, low + 4)
end

function Events.secondsBucket(seconds: number): string
	if seconds <= 30 then
		return "<=30"
	elseif seconds <= 60 then
		return "31-60"
	elseif seconds <= 120 then
		return "61-120"
	end
	return ">120"
end

return table.freeze(Events)
