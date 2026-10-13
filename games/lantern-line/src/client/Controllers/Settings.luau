--!strict
-- Spieler-Einstellungen (nur für diese Sitzung, nichts wird gespeichert):
-- Flackern reduzieren, Sanfter Modus, Bewegung reduzieren (Compliance H-A9 bis H-A11).
-- „Bewegung reduzieren“ übernimmt die Roblox-Einstellung GuiService.ReducedMotionEnabled.

local GuiService = game:GetService("GuiService")

export type Name = "flicker" | "gentle" | "motion"

local Settings = {}

local values: { [Name]: boolean } = {
	flicker = false,
	gentle = false,
	motion = GuiService.ReducedMotionEnabled,
}
local listeners: { () -> () } = {}

local function notify()
	for _, listener in listeners do
		task.spawn(listener)
	end
end

function Settings.init()
	GuiService:GetPropertyChangedSignal("ReducedMotionEnabled"):Connect(function()
		if GuiService.ReducedMotionEnabled then
			values.motion = true
			notify()
		end
	end)
end

function Settings.get(name: Name): boolean
	return values[name]
end

function Settings.set(name: Name, value: boolean)
	if values[name] ~= value then
		values[name] = value
		notify()
	end
end

function Settings.onChanged(listener: () -> ())
	table.insert(listeners, listener)
end

-- Kurzformen. Der Sanfte Modus schließt „Flackern reduzieren“ ein (Compliance H-A16).
function Settings.reducedFlicker(): boolean
	return values.flicker or values.gentle
end

function Settings.gentle(): boolean
	return values.gentle
end

-- Kamerawackeln und Schwanken nur, wenn weder „Bewegung reduzieren“ noch „Sanfter Modus“ an ist.
function Settings.motionAllowed(): boolean
	return not values.motion and not values.gentle
end

return Settings
