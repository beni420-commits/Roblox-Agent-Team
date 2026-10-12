--!strict
-- Lokalisierte Texte über die LocalizationTable „GameStrings“ (EN Quelle, DE Übersetzung).
-- Der Translator lädt asynchron (kann warten, bis die Cloud-Tabelle geladen ist, CR-18);
-- bis dahin gilt der englische Fallback, danach werden Beobachter benachrichtigt.

local LocalizationService = game:GetService("LocalizationService")

local Strings = {}

local FALLBACK: { [string]: string } = {
	["zone.1.name"] = "Meadow",
	["zone.2.name"] = "Clouds",
	["zone.3.name"] = "Thunder",
	["zone.cleared"] = "{1} cleared!",
	["hud.floor"] = "{1}/{2}",
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
