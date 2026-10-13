--!strict
-- Einziger Aufrufer von AnalyticsService (docs/lantern-line/telemetry_plan.md). In Studio werden Events nur
-- protokolliert, weil AnalyticsService nur in veröffentlichten Spielen sendet.

local AnalyticsService = game:GetService("AnalyticsService")
local RunService = game:GetService("RunService")

local BuildInfo = require("@game/ReplicatedStorage/Shared/BuildInfo")
local Events = require("@game/ReplicatedStorage/Shared/Telemetry/Events")

local TelemetryService = {}

local BUILD = "s" .. tostring(BuildInfo.sprint)
local IS_STUDIO = RunService:IsStudio()
local inputByPlayer: { [Player]: string } = {}
local onboardingDone: { [Player]: { [number]: boolean } } = {}

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
	onboardingDone[player] = nil
end

-- Onboarding-Schritt einmal je Spieler und Sitzung.
function TelemetryService.onboarding(player: Player, step: number)
	local name = Events.ONBOARDING_STEPS[step]
	if not name then
		return
	end
	local done = onboardingDone[player]
	if done == nil then
		done = {}
		onboardingDone[player] = done
	end
	if done[step] then
		return
	end
	done[step] = true
	send(string.format("onboarding %d %s", step, name), function()
		AnalyticsService:LogOnboardingFunnelStepEvent(player, step, name, fields(player, nil))
	end)
end

-- Lauf-Funnel: Schritt je Meilenstein-Wagen (funnelSessionId = Lauf-Nummer).
function TelemetryService.runStep(player: Player, runId: number, step: number)
	local label = if step == Events.FINISH_STEP then "Finish" else string.format("C%02d", Events.MILESTONES[step] or 0)
	send(string.format("funnel %s run %d step %d", Events.RUN_FUNNEL, runId, step), function()
		AnalyticsService:LogFunnelStepEvent(
			player,
			Events.RUN_FUNNEL,
			tostring(runId),
			step,
			label,
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
