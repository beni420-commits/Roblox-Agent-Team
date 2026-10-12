--!strict
-- Registriert alle Remotes aus Shared/Net/Definitions und schaltet den Guard (Validierung + Rate-Limit)
-- vor jeden Handler. Handler-Fehler werden isoliert (pcall), der Server-Zustand bleibt konsistent.

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Definitions = require("@game/ReplicatedStorage/Shared/Net/Definitions")
local Guard = require("@game/ReplicatedStorage/Shared/Net/Guard")

export type Handler = (player: Player, ...any) -> ()

local NetService = {}

local guard = Guard.new(os.clock)
local outgoing: { [string]: RemoteEvent } = {}

local function playerKey(player: Player): string
	return tostring(player.UserId)
end

function NetService.init(handlers: { [string]: Handler })
	local folder = Instance.new("Folder")
	folder.Name = Definitions.FolderName

	for name in Definitions.ClientToServer do
		local handler = handlers[name]
		assert(handler, "missing handler for remote " .. name)
		local remote = Instance.new("RemoteEvent")
		remote.Name = name
		remote.OnServerEvent:Connect(function(player: Player, ...: any)
			local count = select("#", ...)
			local args = { ... }
			local ok = guard.check(playerKey(player), name, args, count)
			if not ok then
				return
			end
			local success, err = pcall(handler, player, ...)
			if not success then
				warn(string.format("[Net] handler %s failed: %s", name, tostring(err)))
			end
		end)
		remote.Parent = folder
	end

	for _, name in Definitions.ServerToClient do
		local remote = Instance.new("RemoteEvent")
		remote.Name = name
		remote.Parent = folder
		outgoing[name] = remote
	end

	folder.Parent = ReplicatedStorage
end

function NetService.fire(player: Player, name: string, payload: any)
	local remote = outgoing[name]
	assert(remote, "unknown outgoing remote " .. name)
	remote:FireClient(player, payload)
end

function NetService.rejections(player: Player): { [string]: number }
	return guard.rejections(playerKey(player))
end

function NetService.forget(player: Player)
	guard.forgetPlayer(playerKey(player))
end

return NetService
