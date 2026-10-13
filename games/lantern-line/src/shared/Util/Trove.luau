--!strict
-- Sammelt Aufräum-Aufgaben (Verbindungen, Instanzen, Funktionen) und gibt sie gemeinsam frei.
-- Verhindert Speicherlecks durch vergessene Verbindungen (tech_notes §2).

export type Trove = {
	add: <T>(item: T) -> T,
	clean: () -> (),
	size: () -> number,
}

local Trove = {}

local function cleanupItem(item: any)
	-- Typ als String zwischenspeichern: So entsteht keine Typverfeinerung auf Roblox-Typen,
	-- die es im reinen Luau-CLI nicht gibt.
	local kind: string = typeof(item)
	local target: any = item
	if kind == "function" then
		target()
	elseif kind == "RBXScriptConnection" then
		target:Disconnect()
	elseif kind == "Instance" then
		target:Destroy()
	elseif kind == "table" then
		-- Methoden ohne Typverfeinerung aufrufen (der Typ „function“ ist im neuen Solver nicht aufrufbar).
		local disconnect: any = target.Disconnect
		local destroy: any = target.Destroy
		local clean: any = target.clean
		if type(disconnect) == "function" then
			(disconnect :: any)(target)
		elseif type(destroy) == "function" then
			(destroy :: any)(target)
		elseif type(clean) == "function" then
			(clean :: any)()
		end
	end
end

function Trove.new(): Trove
	local items: { any } = {}

	local function add<T>(item: T): T
		table.insert(items, item)
		return item
	end

	local function clean()
		-- In umgekehrter Reihenfolge freigeben (zuletzt Erzeugtes zuerst).
		local pending = items
		items = {}
		for index = #pending, 1, -1 do
			local ok, err = pcall(cleanupItem, pending[index])
			if not ok then
				print("[Trove] cleanup failed: " .. tostring(err))
			end
		end
	end

	local function size(): number
		return #items
	end

	return { add = add, clean = clean, size = size }
end

return table.freeze(Trove)
