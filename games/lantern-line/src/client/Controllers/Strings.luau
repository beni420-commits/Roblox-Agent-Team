--!strict
-- Lokalisierte Texte über die LocalizationTable „GameStrings“ (EN Quelle, DE Übersetzung).
-- Bis der Translator geladen ist, gilt der englische Fallback (scripts/check.sh prüft, dass jeder
-- Schlüssel hier auch in der CSV steht).

local LocalizationService = game:GetService("LocalizationService")

local Strings = {}

local FALLBACK: { [string]: string } = {
	["hud.carriage"] = "CAR {1}",
	["hud.key"] = "Key",
	["hud.sneak"] = "Sneak",
	["hud.leave"] = "Get out",
	["hud.cold"] = "It is getting cold…",
	["hud.walk"] = "Walk",
	["hud.standstill"] = "Stand still",
	["hud.settings"] = "Settings",
	["settings.flicker"] = "Reduce flicker",
	["settings.gentle"] = "Gentle mode",
	["settings.motion"] = "Reduce motion",
	["settings.on"] = "On",
	["settings.off"] = "Off",
	["settings.close"] = "Close",
	["lobby.subtitle"] = "The Night Train",
	["lobby.board"] = "Stand at the platform edge to board",
	["lobby.departs"] = "Departs in {1}",
	["lobby.waiting"] = "Waiting for passengers",
	["lobby.enroute"] = "Train en route – car {1}",
	["death.title"] = "Your journey ended in car {1}",
	["death.from"] = "– the stationmaster",
	["spectate.label"] = "Fellow traveller {1}/{2}",
	["end.won"] = "Line 1 complete!",
	["end.lost"] = "End of the line",
	["end.car"] = "Car reached: {1}",
	["end.stubs"] = "Ticket stubs: {1}",
	["end.time"] = "Time: {1}",
	["notes.title"] = "Notebook",
	["validator.title"] = "Punch the pattern",
	["validator.submit"] = "Validate",
	["validator.clear"] = "Clear",
	["validator.wrong"] = "Wrong pattern!",
	["validator.right"] = "The gate opens!",
}

local translator: Translator? = nil
local readyCallbacks: { () -> () } = {}

function Strings.init(player: Player)
	local ok, result = pcall(function()
		return LocalizationService:GetTranslatorForPlayerAsync(player)
	end)
	if ok then
		translator = result
		for _, callback in readyCallbacks do
			task.spawn(callback)
		end
	end
end

function Strings.onReady(callback: () -> ())
	table.insert(readyCallbacks, callback)
end

function Strings.format(key: string, args: { any }?): string
	local current = translator
	if current then
		local ok, text = pcall(function()
			return current:FormatByKey(key, args or {})
		end)
		if ok and type(text) == "string" then
			return text
		end
	end
	local text = FALLBACK[key] or key
	for index, value in args or {} do
		text = string.gsub(text, "{" .. index .. "}", tostring(value))
	end
	return text
end

return Strings
