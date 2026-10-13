--!strict
-- Schleichen (Taste C, Gamepad L3, Touch-Knopf): Tempo 8 statt 16, leise für den Schaffner.
-- Gamepad B bleibt „Versteck verlassen“, Strg bleibt frei (Playtest LP-10).
-- Der Server misst das Tempo selbst (MotionTracker); der Client setzt nur die eigene Laufgeschwindigkeit.

local ContextActionService = game:GetService("ContextActionService")

local Context = require("./Context")
local GameConfig = require("@game/ReplicatedStorage/Shared/Config/GameConfig")
local Hud = require("./Hud")
local Strings = require("./Strings")

local MovementController = {}

local sneaking = false

local function apply()
	local humanoid = Context.humanoid()
	if humanoid then
		humanoid.WalkSpeed = if sneaking then GameConfig.SNEAK_SPEED else GameConfig.WALK_SPEED
	end
	Hud.setSneak(sneaking)
end

function MovementController.setSneaking(on: boolean)
	sneaking = on
	apply()
end

function MovementController.init()
	ContextActionService:BindAction("LanternSneak", function(_, state)
		if state == Enum.UserInputState.Begin then
			MovementController.setSneaking(not sneaking)
		end
		return Enum.ContextActionResult.Sink
	end, true, Enum.KeyCode.C, Enum.KeyCode.ButtonL3)
	ContextActionService:SetPosition("LanternSneak", UDim2.new(1, -170, 1, -170))
	local function retitle()
		ContextActionService:SetTitle("LanternSneak", Strings.format("hud.sneak"))
	end
	Strings.onReady(retitle)
	retitle()
	-- Bei Warnungen, die Laufen verlangen, Schleichen automatisch aus (Playtest LP-10).
	for _, kind in { "express", "chase" } do
		Context.onWorld(kind, function()
			MovementController.setSneaking(false)
		end)
	end
	Context.player.CharacterAdded:Connect(function(character)
		character:WaitForChild("Humanoid", 10)
		sneaking = false
		apply()
	end)
end

return MovementController
