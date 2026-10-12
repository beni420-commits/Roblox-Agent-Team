--!strict
-- Einziger Aufrufer von AnalyticsService (docs/telemetry_plan.md). In Studio werden Events nur protokolliert,
-- weil AnalyticsService nur in veröffentlichten Spielen sendet.

local AnalyticsService = game:GetService("AnalyticsService")
local RunService = game:GetService("RunService")

local Events = require("@game/ReplicatedStorage/Shared/Telemetry/Events")

local TelemetryService = {}

local BUILD = "s1"
local IS_STUDIO = RunService:IsStudio()
local inputByPlayer: { [Player]: string } = {}

local function fields(player: Player, context: string?): { [string]: any }
	local result: { [string]: any } = {
		[Enum.AnalyticsCustomFieldKeys.CustomField01.Name] = inputByPlayer[player] or "Unknown",
		[Enum.AnalyticsCustomFieldKeys.CustomField02.Name] = BUILD,
	}
	if context then
		result[Enum.AnalyticsCustomFieldKeys.CustomField03.Name] = context
	end
	return result
end

local function send(description: string, callback: () -> ())
	if IS_STUDIO then
		print("[Telemetry] " .. description)
		return
	end
	local ok, err = pcall(callback)
	if not ok then
		warn("[Telemetry] " .. description .. " failed: " .. tostring(err))
	end
end

function TelemetryService.setInput(player: Player, input: string)
	inputByPlayer[player] = input
end

function TelemetryService.forget(player: Player)
	inputByPlayer[player] = nil
end

function TelemetryService.onboarding(player: Player, step: number, context: string?)
	local name = Events.ONBOARDING_STEPS[step]
	if not name then
		return
	end
	send(string.format("onboarding %d %s", step, name), function()
		AnalyticsService:LogOnboardingFunnelStepEvent(player, step, name, fields(player, context))
	end)
end

function TelemetryService.progressionStart(player: Player, level: number, context: string?)
	send("progression start " .. level, function()
		AnalyticsService:LogProgressionStartEvent(
			player,
			Events.PROGRESSION_MAIN,
			level,
			string.format("F%02d", level),
			fields(player, context)
		)
	end)
end

function TelemetryService.floorCompleted(player: Player, floor: number, zone: number)
	send("progression complete " .. floor, function()
		AnalyticsService:LogProgressionCompleteEvent(
			player,
			Events.PROGRESSION_MAIN,
			floor,
			string.format("F%02d", floor),
			fields(player, "Z" .. zone)
		)
	end)
end

function TelemetryService.economySource(player: Player, amount: number, balance: number, sku: string)
	if amount <= 0 then
		return
	end
	send(string.format("economy source %s %d (balance %d)", sku, amount, balance), function()
		AnalyticsService:LogEconomyEvent(
			player,
			Enum.AnalyticsEconomyFlowType.Source,
			Events.CURRENCY,
			amount,
			balance,
			Enum.AnalyticsEconomyTransactionType.Gameplay.Name,
			sku,
			fields(player, nil)
		)
	end)
end

function TelemetryService.custom(player: Player, eventName: string, value: number, context: string?)
	assert(Events.CUSTOM[eventName] == eventName, "unknown telemetry event: " .. eventName)
	send(string.format("custom %s=%s %s", eventName, tostring(value), context or ""), function()
		AnalyticsService:LogCustomEvent(player, eventName, value, fields(player, context))
	end)
end

return TelemetryService
