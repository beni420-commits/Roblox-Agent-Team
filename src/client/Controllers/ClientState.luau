--!strict
-- Letzter vom Server gemeldeter Zustand (StateSync). Der Server ist die Wahrheit; der Client zeigt nur an.

export type Snapshot = {
	sparks: number,
	currentFloor: number,
	highestFloor: number,
	helpLevel: number,
	fails: number,
	collected: { [string]: number },
	runIndex: number,
}

type Listener = (new: Snapshot, old: Snapshot) -> ()

local ClientState = {}

local snapshot: Snapshot = {
	sparks = 0,
	currentFloor = 0,
	highestFloor = 0,
	helpLevel = 0,
	fails = 0,
	collected = {},
	runIndex = 1,
}
local listeners: { Listener } = {}
local received = false

local function number(value: unknown, fallback: number): number
	if type(value) == "number" and value == value then
		return value
	end
	return fallback
end

function ClientState.get(): Snapshot
	return snapshot
end

function ClientState.hasReceived(): boolean
	return received
end

function ClientState.onChanged(listener: Listener): () -> ()
	table.insert(listeners, listener)
	return function()
		local index = table.find(listeners, listener)
		if index then
			table.remove(listeners, index)
		end
	end
end

function ClientState.apply(payload: unknown)
	if type(payload) ~= "table" then
		return
	end
	local data = payload :: { [string]: unknown }
	local collected: { [string]: number } = {}
	if type(data.collected) == "table" then
		for key, mask in data.collected :: { [unknown]: unknown } do
			if type(key) == "string" and type(mask) == "number" then
				collected[key] = mask
			end
		end
	end
	local old = snapshot
	snapshot = {
		sparks = number(data.sparks, old.sparks),
		currentFloor = number(data.currentFloor, old.currentFloor),
		highestFloor = number(data.highestFloor, old.highestFloor),
		helpLevel = number(data.helpLevel, old.helpLevel),
		fails = number(data.fails, old.fails),
		collected = collected,
		runIndex = number(data.runIndex, old.runIndex),
	}
	received = true
	for _, listener in table.clone(listeners) do
		task.spawn(listener, snapshot, old)
	end
end

function ClientState.isCollected(sparkId: number): boolean
	local mask = snapshot.collected[tostring(sparkId // 100)] or 0
	return bit32.btest(mask, bit32.lshift(1, sparkId % 100))
end

return ClientState
