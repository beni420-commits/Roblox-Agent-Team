--!strict
-- Lokalisierte Texte über die LocalizationTable „GameStrings“ (EN Quelle, DE Übersetzung).
-- Bis der Translator geladen ist, gilt der englische Fallback (scripts/check.sh prüft, dass jeder
-- Schlüssel hier auch in der CSV steht). Enthält alle Client-Schlüssel inkl. HINT_* (LL-20);
-- prompt.*/object.* übersetzt Roblox per AutoLocalize.

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
	["hud.getready"] = "Get ready to stand still",
	["hud.checked"] = "Ticket checked",
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
	["lobby.ready"] = "{1}/{2} ready",
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
	["toast.ruck"] = "The train lurches – you are pulled forward",
	["info.title"] = "Passenger information",
	["info.express"] = "Glow from behind → climb into a wardrobe",
	["info.oncoming"] = "Light at one side → go to the other side",
	["info.eyes"] = "Green glow in the dark → keep your distance",
	["info.inspector"] = "Striped paddle → stand still",
	["info.chase"] = "Luggage rolling → run forward, release the coupling",
	["info.conductor"] = "Lamp beam → sneak and stay out of it",
	["HINT_EXPRESS_1"] = "When the lamps swing and a white glow grows behind you, climb into a wardrobe or trunk until it has passed.",
	["HINT_EXPRESS_2"] = "You have a few seconds. Remember where the nearest wardrobe is in every car.",
	["HINT_ONCOMING_1"] = "Bright light at the windows on one side: cross to the other side of the car.",
	["HINT_ONCOMING_2"] = "The arrows point away from the light. Follow them to the safe side.",
	["HINT_EYES_1"] = "In dark cars, keep your distance from the green glow under seats and racks.",
	["HINT_EYES_2"] = "The glow gets brighter when you come close. Walk around it.",
	["HINT_INSPECTOR_1"] = "When the inspector's paddle starts to change, get ready. At the striped paddle, stand still until the round paddle returns.",
	["HINT_INSPECTOR_2"] = "Walk to the inspector while the round paddle shows. Once your ticket is checked, you are safe.",
	["HINT_CHASE_1"] = "When the lamps behind you turn orange and luggage starts rolling, run forward and do not stop.",
	["HINT_CHASE_2"] = "Wardrobes will not help here. Once everyone is past the coupling, release it to leave the luggage behind.",
	["HINT_CONDUCTOR_1"] = "The conductor only sees what his lamp lights up and hears footsteps. Sneak and stay out of the beam.",
	["HINT_CONDUCTOR_2"] = "Read all three ticket scraps, then punch the full pattern at the validator. Wrong patterns are loud.",
	["HINT_LOST_1"] = "You got separated from the train. Stay inside the carriages.",
	["HINT_LOST_2"] = "Stay with your group and keep moving forward.",
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
