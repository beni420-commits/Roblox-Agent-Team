--!strict
-- Gemeinsamer Client-Kontext: Remotes, Ereignis-Verteiler (nach payload.type), Serverzeit.

local Players = game:GetService("Players")

local Definitions = require("@game/ReplicatedStorage/Shared/Net/Definitions")

export type Handler = (payload: any) -> ()

local Context = {}

Context.player = Players.LocalPlayer

local remotes: Instance? = nil
local worldHandlers: { [string]: { Handler } } = {}
local personalHandlers: { [string]: { Handler } } = {}

local function dispatch(handlers: { [string]: { Handler } }, payload: any)
	if type(payload) ~= "table" or type(payload.type) ~= "string" then
		return
	end
	for _, handler in handlers[payload.type] or {} do
		task.spawn(handler, payload)
	end
end

function Context.init(folder: Instance)
	remotes = folder
	local world = folder:WaitForChild(Definitions.ServerToClient.WorldEvent) :: RemoteEvent
	local personal = folder:WaitForChild(Definitions.ServerToClient.PersonalEvent) :: RemoteEvent
	world.OnClientEvent:Connect(function(payload)
		dispatch(worldHandlers, payload)
	end)
	personal.OnClientEvent:Connect(function(payload)
		dispatch(personalHandlers, payload)
	end)
end

function Context.onWorld(kind: string, handler: Handler)
	local list = worldHandlers[kind] or {}
	worldHandlers[kind] = list
	table.insert(list, handler)
end

function Context.onPersonal(kind: string, handler: Handler)
	local list = personalHandlers[kind] or {}
	personalHandlers[kind] = list
	table.insert(list, handler)
end

function Context.fire(name: string, ...: any)
	local folder = remotes
	if folder == nil then
		return
	end
	local remote = folder:FindFirstChild(name)
	if remote and remote:IsA("RemoteEvent") then
		remote:FireServer(...)
	end
end

function Context.now(): number
	return workspace:GetServerTimeNow()
end

function Context.inRun(): boolean
	return workspace:GetAttribute("RunPhase") == "running" and Context.player:GetAttribute("InRun") == true
end

function Context.alive(): boolean
	return Context.player:GetAttribute("Alive") ~= false
end

function Context.root(): BasePart?
	local character = Context.player.Character
	local root = if character then character:FindFirstChild("HumanoidRootPart") else nil
	return if root and root:IsA("BasePart") then root else nil
end

function Context.humanoid(): Humanoid?
	local character = Context.player.Character
	return if character then character:FindFirstChildOfClass("Humanoid") else nil
end

return Context
