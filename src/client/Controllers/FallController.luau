--!strict
-- Erkennt einen Sturz sofort (jedes Frame) und bittet den Server um Rücksetzung an den Etagenanfang.
-- Der Server prüft selbst nach (10 Hz) und entscheidet; der Client zeigt nur die Vignette.

local RunService = game:GetService("RunService")

local Context = require("./Context")
local HudController = require("./HudController")

local FallController = {}

local REQUEST_INTERVAL = 1

function FallController.start(context: Context.Context)
	local lastRequest = -math.huge
	RunService.Heartbeat:Connect(function()
		local character = context.player.Character
		local root = character and character:FindFirstChild("HumanoidRootPart")
		local resetY = context.player:GetAttribute("ResetY")
		if not root or not root:IsA("BasePart") or type(resetY) ~= "number" then
			return
		end
		if root.Position.Y < resetY then
			local now = os.clock()
			if now - lastRequest >= REQUEST_INTERVAL then
				lastRequest = now
				HudController.flashFall()
				context.fire("RequestRespawn")
			end
		end
	end)
end

return FallController
