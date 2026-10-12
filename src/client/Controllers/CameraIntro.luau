--!strict
-- Beim allerersten Spawn: Kamera blickt 2 s zum Gipfel-Leuchtfeuer (Ziel ohne Text, GDD v0.2 §7).
-- Jede Eingabe überspringt den Schwenk.

local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")

local TowerConfig = require("@game/ReplicatedStorage/Shared/Logic/TowerConfig")

local Context = require("./Context")

local CameraIntro = {}

local DURATION = 2

function CameraIntro.play(context: Context.Context)
	local character = context.player.Character or context.player.CharacterAdded:Wait()
	local root = character:WaitForChild("HumanoidRootPart", 10)
	local camera = workspace.CurrentCamera
	if not root or not root:IsA("BasePart") or not camera then
		return
	end
	local beacon = Vector3.new(0, TowerConfig.TOTAL_FLOORS * TowerConfig.FLOOR_HEIGHT + 30, 0)
	local towardTower = (Vector3.new(0, root.Position.Y, 0) - root.Position).Unit
	local eye = root.Position - towardTower * 12 + Vector3.new(0, 6, 0)

	local finished = false
	local function finish()
		if finished then
			return
		end
		finished = true
		camera.CameraType = Enum.CameraType.Custom
	end

	camera.CameraType = Enum.CameraType.Scriptable
	camera.CFrame = CFrame.lookAt(eye, Vector3.new(0, 40, 0))
	local tween = TweenService:Create(
		camera,
		TweenInfo.new(DURATION * 0.6, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut),
		{ CFrame = CFrame.lookAt(eye, beacon) }
	)
	tween:Play()
	local skip = UserInputService.InputBegan:Connect(function()
		tween:Cancel()
		finish()
	end)
	task.delay(DURATION, function()
		skip:Disconnect()
		finish()
	end)
end

return CameraIntro
