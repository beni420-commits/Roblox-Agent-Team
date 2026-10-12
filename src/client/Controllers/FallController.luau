--!strict
-- Erkennt einen Sturz sofort (jedes Frame) und bittet den Server um Rücksetzung an den Etagenanfang.
-- Wer auf einer tieferen Plattform zurückgeht, fällt nicht (Raycast nach unten, CR-05).
-- Der Server prüft selbst nach (10 Hz) und entscheidet; der Client zeigt nur die Vignette.

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")

local Movement = require("@game/ReplicatedStorage/Shared/Logic/Movement")

local Context = require("./Context")
local HudController = require("./HudController")

local FallController = {}

local REQUEST_INTERVAL = 1
local SPAWN_GRACE = 2

function FallController.start(context: Context.Context)
	local lastRequest = -math.huge
	local spawnedAt = os.clock()
	context.player.CharacterAdded:Connect(function()
		spawnedAt = os.clock()
	end)
	local params = RaycastParams.new()
	params.FilterType = Enum.RaycastFilterType.Exclude

	RunService.Heartbeat:Connect(function()
		local character = context.player.Character
		local root = character and character:FindFirstChild("HumanoidRootPart")
		local resetY = context.player:GetAttribute("ResetY")
		if not character or not root or not root:IsA("BasePart") or type(resetY) ~= "number" then
			return
		end
		local now = os.clock()
		if now - spawnedAt < SPAWN_GRACE or root.Position.Y >= resetY then
			return
		end
		-- Alle Charaktere ausschließen: andere Spieler sind kein Boden.
		local exclude: { Instance } = {}
		for _, other in Players:GetPlayers() do
			if other.Character then
				table.insert(exclude, other.Character)
			end
		end
		params.FilterDescendantsInstances = exclude
		local below = workspace:Raycast(root.Position, Vector3.new(0, -(Movement.ROOT_HEIGHT + 3), 0), params)
		if below then
			return -- steht auf einer tieferen Plattform (z. B. Rückweg zu einem Funken)
		end
		if now - lastRequest >= REQUEST_INTERVAL then
			lastRequest = now
			HudController.flashFall()
			context.fire("RequestRespawn")
		end
	end)
end

return FallController
