--!strict
-- Steuerungs-Komfort (GDD v0.2 §5): Coyote-Time 0,12 s, Sprungpuffer 0,1 s, Sprungpads.
-- Charakterphysik läuft clientseitig (Roblox-Standard); der Server prüft Plausibilität (ab Sprint 2).

local CollectionService = game:GetService("CollectionService")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")

local Movement = require("@game/ReplicatedStorage/Shared/Logic/Movement")

local Context = require("./Context")

local MovementController = {}

local JUMP_PAD_TAG = "JumpPad"
local PAD_DEBOUNCE = 0.25

local function bindCharacter(context: Context.Context, character: Model)
	local humanoid = character:WaitForChild("Humanoid", 10)
	local root = character:WaitForChild("HumanoidRootPart", 10)
	if not humanoid or not humanoid:IsA("Humanoid") or not root or not root:IsA("BasePart") then
		return
	end

	local lastGroundedAt = os.clock()
	local jumpedSinceGround = false
	local bufferedAt = -math.huge
	local lastPadAt = -math.huge
	local reportedJump = false
	local connections: { RBXScriptConnection } = {}

	local function jumpVelocity(): number
		return Movement.jumpVelocity(humanoid.JumpHeight, workspace.Gravity)
	end

	table.insert(
		connections,
		RunService.Heartbeat:Connect(function()
			if humanoid.FloorMaterial ~= Enum.Material.Air then
				lastGroundedAt = os.clock()
			end
		end)
	)

	table.insert(
		connections,
		humanoid.StateChanged:Connect(function(_old: Enum.HumanoidStateType, new: Enum.HumanoidStateType)
			if new == Enum.HumanoidStateType.Landed or new == Enum.HumanoidStateType.Running then
				jumpedSinceGround = false
				if os.clock() - bufferedAt <= Movement.CONTROL.jumpBuffer then
					bufferedAt = -math.huge
					humanoid.Jump = true -- Sprungpuffer: kurz vor der Landung gedrückt
				end
			elseif new == Enum.HumanoidStateType.Jumping then
				jumpedSinceGround = true
				if not reportedJump then
					reportedJump = true
					context.fire("ReportOnboardingStep", 4)
				end
			end
		end)
	)

	table.insert(
		connections,
		UserInputService.JumpRequest:Connect(function()
			if humanoid.FloorMaterial ~= Enum.Material.Air then
				return -- normaler Sprung, macht der Humanoid selbst
			end
			local now = os.clock()
			if not jumpedSinceGround and now - lastGroundedAt <= Movement.CONTROL.coyoteTime then
				-- Coyote-Time: knapp nach der Kante noch springen dürfen.
				jumpedSinceGround = true
				local velocity = root.AssemblyLinearVelocity
				root.AssemblyLinearVelocity = Vector3.new(velocity.X, jumpVelocity(), velocity.Z)
				humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
			else
				bufferedAt = now
			end
		end)
	)

	table.insert(
		connections,
		humanoid.Touched:Connect(function(hit: BasePart)
			if not CollectionService:HasTag(hit, JUMP_PAD_TAG) then
				return
			end
			local now = os.clock()
			if now - lastPadAt < PAD_DEBOUNCE then
				return
			end
			lastPadAt = now
			local launch = hit:GetAttribute("LaunchVelocity")
			if type(launch) == "number" and launch > 0 and launch < 200 then
				local velocity = root.AssemblyLinearVelocity
				humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
				root.AssemblyLinearVelocity = Vector3.new(velocity.X, launch, velocity.Z)
				jumpedSinceGround = true
			end
		end)
	)

	humanoid.Died:Once(function()
		for _, connection in connections do
			connection:Disconnect()
		end
	end)
	character.AncestryChanged:Connect(function()
		if not character.Parent then
			for _, connection in connections do
				connection:Disconnect()
			end
		end
	end)
end

function MovementController.start(context: Context.Context)
	context.player.CharacterAdded:Connect(function(character: Model)
		bindCharacter(context, character)
	end)
	if context.player.Character then
		task.spawn(bindCharacter, context, context.player.Character)
	end
end

return MovementController
