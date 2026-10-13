--!strict
-- Prüft jeden eingehenden Remote-Aufruf: bekannter Name, Argumente, Rate-Limit pro Spieler und Remote.
-- Zählt Ablehnungen für Telemetrie (RemoteRejected) – ohne Kick bei normalem Spam.

local Definitions = require("./Definitions")
local RateLimiter = require("../Util/RateLimiter")

export type Guard = {
	check: (playerKey: string, remoteName: string, args: { any }, count: number) -> (boolean, string),
	note: (playerKey: string, key: string) -> (),
	rejections: (playerKey: string) -> { [string]: number },
	forgetPlayer: (playerKey: string) -> (),
}

local Guard = {}

function Guard.new(clock: () -> number): Guard
	local limiters: { [string]: RateLimiter.RateLimiter } = {}
	for name, definition in Definitions.ClientToServer do
		limiters[name] = RateLimiter.new({ perSecond = definition.perSecond, burst = definition.burst, clock = clock })
	end
	local rejected: { [string]: { [string]: number } } = {}

	local function reject(playerKey: string, remoteName: string, reason: string): (boolean, string)
		local perPlayer = rejected[playerKey]
		if perPlayer == nil then
			perPlayer = {}
			rejected[playerKey] = perPlayer
		end
		local key = if Definitions.ClientToServer[remoteName] then remoteName else "unknown"
		perPlayer[key] = (perPlayer[key] or 0) + 1
		return false, reason
	end

	local function check(playerKey: string, remoteName: string, args: { any }, count: number): (boolean, string)
		local definition = Definitions.ClientToServer[remoteName]
		if definition == nil then
			return reject(playerKey, remoteName, "unknown remote")
		end
		-- Rate-Limit zuerst: auch Müll-Aufrufe verbrauchen Budget.
		if not limiters[remoteName].consume(playerKey) then
			return reject(playerKey, remoteName, "rate limited")
		end
		local ok, reason = definition.check(args, count)
		if not ok then
			return reject(playerKey, remoteName, reason or "invalid")
		end
		return true, "ok"
	end

	-- Fachliche Ablehnung durch den Handler (z. B. „CollectSpark:reach“), CR-20.
	local function note(playerKey: string, key: string)
		local perPlayer = rejected[playerKey]
		if perPlayer == nil then
			perPlayer = {}
			rejected[playerKey] = perPlayer
		end
		perPlayer[key] = (perPlayer[key] or 0) + 1
	end

	local function rejections(playerKey: string): { [string]: number }
		return rejected[playerKey] or {}
	end

	local function forgetPlayer(playerKey: string)
		rejected[playerKey] = nil
		for _, limiter in limiters do
			limiter.forget(playerKey)
		end
	end

	return { check = check, note = note, rejections = rejections, forgetPlayer = forgetPlayer }
end

return table.freeze(Guard)
