--!strict
-- Prüffunktionen für Remote-Argumente (Server-Autorität, tech_notes §3).
-- Jede Prüfung liefert (ok, grund). Clients dürfen beliebige Werte schicken – auch NaN, ±inf,
-- riesige Zahlen, falsche Typen oder zusätzliche Argumente.

export type Check = (value: unknown) -> (boolean, string?)

local Validator = {}

local function isFinite(x: number): boolean
	return x == x and x ~= math.huge and x ~= -math.huge
end
Validator.isFinite = isFinite

function Validator.integer(minValue: number, maxValue: number): Check
	return function(value: unknown): (boolean, string?)
		if type(value) ~= "number" then
			return false, "not a number"
		end
		local n = value :: number
		if not isFinite(n) then
			return false, "not finite"
		end
		if n % 1 ~= 0 then
			return false, "not an integer"
		end
		if n < minValue or n > maxValue then
			return false, "out of range"
		end
		return true, nil
	end
end

function Validator.number(minValue: number, maxValue: number): Check
	return function(value: unknown): (boolean, string?)
		if type(value) ~= "number" then
			return false, "not a number"
		end
		local n = value :: number
		if not isFinite(n) then
			return false, "not finite"
		end
		if n < minValue or n > maxValue then
			return false, "out of range"
		end
		return true, nil
	end
end

function Validator.boolean(): Check
	return function(value: unknown): (boolean, string?)
		if type(value) ~= "boolean" then
			return false, "not a boolean"
		end
		return true, nil
	end
end

-- Nur exakt einer der erlaubten Strings (Enum). Länge ist dadurch implizit begrenzt.
function Validator.enum(allowed: { string }): Check
	local set: { [string]: boolean } = {}
	for _, name in allowed do
		set[name] = true
	end
	return function(value: unknown): (boolean, string?)
		if type(value) ~= "string" then
			return false, "not a string"
		end
		if not set[value :: string] then
			return false, "not allowed"
		end
		return true, nil
	end
end

-- Prüft eine vollständige Argumentliste: exakte Anzahl, dann jede Position.
function Validator.args(checks: { Check }): (args: { any }, count: number) -> (boolean, string?)
	local expected = #checks
	return function(args: { any }, count: number): (boolean, string?)
		if count ~= expected then
			return false, "wrong argument count"
		end
		for index, check in checks do
			local ok, reason = check(args[index])
			if not ok then
				return false, string.format("arg %d: %s", index, reason or "invalid")
			end
		end
		return true, nil
	end
end

return table.freeze(Validator)
