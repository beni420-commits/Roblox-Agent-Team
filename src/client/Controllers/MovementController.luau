--!strict
-- Steuerungs-Komfort (GDD v0.3 §5): Coyote-Time 0,12 s, Sprungpuffer 0,1 s, Sprungpads.
-- Charakterphysik läuft clientseitig (Roblox-Standard); der Server prüft Plausibilität (ab Sprint 2).

local CollectionService = game:GetService("CollectionService")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")

local Movement = require("@game/ReplicatedStorage/Shared/Logic/Movement")

local Context = require("./Context")

local MovementController = {}

local JUMP_PAD_TAG = "JumpPad"
local PAD_DEBOUNCE = 0.25

type CharacterState = {
	humanoid: Humanoid,
	root: BasePart,
	character: Model,
	lastPadAt: number,
}

local current: CharacterState? = nil
local boundPads: { [Instance]: boolean } = setmetatable({}, { __mode = "k" }) :: any

-- Sprungpad: nur die Geschwindigkeit setzen und in den Fall-Zustand wechseln. Kein Wechsel nach
-- „Jumping“, sonst überschreibt der normale Sprungimpuls den Pad-Impuls (Code-Review CR-01).
local function launch(state: CharacterState, velocity: number)
	local now = os.clock()
	if now - state.lastPadAt < PAD_DEBOUNCE then
		return
	end
	state.lastPadAt = now
	local function apply()
		local v = state.root.AssemblyLinearVelocity
		if v.Y < velocity * 0.9 then
			state.root.AssemblyLinearVelocity = Vector3.new(v.X, velocity, v.Z)
		end
	end
	apply()
	state.humanoid:ChangeState(Enum.HumanoidStateType.Freefall)
	-- Im nächsten Physikschritt sicherstellen, dass der Impuls nicht verloren ging.
	RunService.PreSimulation:Once(apply)
end

local function bindPad(pad: Instance)
	if not pad:IsA("BasePart") or boundPads[pad] then
		return -- jedes Pad nur einmal binden (CR-35)
	end
	boundPads[pad] = true
	pad.Touched:Connect(function(hit: BasePart)
		local state = current
		if not state or not hit:IsDescendantOf(state.character) then
			return
		end
		local velocity = pad:GetAttribute("LaunchVelocity")
		if type(velocity) == "number" and velocity > 0 and velocity < 200 then
			launch(state, velocity)
		end
	end)
end

local function bindCharacter(context: Context.Context, character: Model)
	local humanoid = character:WaitForChild("Humanoid", 10)
	local root = character:WaitForChild("HumanoidRootPart", 10)
	if not humanoid or not humanoid:IsA("Humanoid") or not root or not root:IsA("BasePart") then
		return
	end
	local state: CharacterState = { humanoid = humanoid, root = root, character = character, lastPadAt = -math.huge }
	current = state

	local lastGroundedAt = os.clock()
	local jumpedSinceGround = false
	local bufferedAt = -math.huge
	local groundRequestAt = -math.huge
	local reportedJump = false
	local connections: { RBXScriptConnection } = {}

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
					context.fire("ReportOnboardingStep", 3)
				end
			end
		end)
	)

	table.insert(
		connections,
		UserInputService.JumpRequest:Connect(function()
			local now = os.clock()
			if humanoid.FloorMaterial ~= Enum.Material.Air then
				-- Normaler Sprung (macht der Humanoid). Zeitpunkt merken: Feuert dieselbe Anfrage gleich danach
				-- in der Luft noch einmal (JumpRequest feuert mehrfach, CR-15), darf das keinen Coyote-Sprung
				-- auslösen. Wer dagegen ohne Sprung über die Kante läuft, behält die Coyote-Time (CR-34).
				groundRequestAt = now
				return
			end
			local sameRequest = now - groundRequestAt < 0.25
			if not jumpedSinceGround and not sameRequest and now - lastGroundedAt <= Movement.CONTROL.coyoteTime then
				-- Coyote-Time: knapp nach der Kante noch springen dürfen.
				jumpedSinceGround = true
				local velocity = root.AssemblyLinearVelocity
				root.AssemblyLinearVelocity =
					Vector3.new(velocity.X, Movement.jumpVelocity(humanoid.JumpHeight, workspace.Gravity), velocity.Z)
				humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
			else
				bufferedAt = now
			end
		end)
	)

	local function cleanup()
		for _, connection in connections do
			connection:Disconnect()
		end
		table.clear(connections)
		if current == state then
			current = nil
		end
	end
	humanoid.Died:Once(cleanup)
	character.AncestryChanged:Connect(function()
		if not character.Parent then
			cleanup()
		end
	end)
end

function MovementController.start(context: Context.Context)
	-- Pads streamingfest binden: vorhandene und später gestreamte (CR-27).
	for _, pad in CollectionService:GetTagged(JUMP_PAD_TAG) do
		bindPad(pad)
	end
	CollectionService:GetInstanceAddedSignal(JUMP_PAD_TAG):Connect(bindPad)

	context.player.CharacterAdded:Connect(function(character: Model)
		bindCharacter(context, character)
	end)
	if context.player.Character then
		task.spawn(bindCharacter, context, context.player.Character)
	end
end

return MovementController
