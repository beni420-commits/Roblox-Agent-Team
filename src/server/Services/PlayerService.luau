--!strict
-- Spieler-Sitzungen und Spiellogik auf dem Server (Server-Autorität, tech_notes §2/§6).
-- Sprint 1: Lauf-Zustand nur im Speicher (Speicherstand folgt in Sprint 2).

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")

local Events = require("@game/ReplicatedStorage/Shared/Telemetry/Events")
local LandingLocator = require("@game/ReplicatedStorage/Shared/Logic/LandingLocator")
local Movement = require("@game/ReplicatedStorage/Shared/Logic/Movement")
local RunState = require("@game/ReplicatedStorage/Shared/Logic/RunState")
local TowerGenerator = require("@game/ReplicatedStorage/Shared/Logic/TowerGenerator")
local Trove = require("@game/ReplicatedStorage/Shared/Util/Trove")

local TelemetryService = require("./TelemetryService")
local WorldSetup = require("../WorldSetup")

type NetLike = {
	fire: (player: Player, name: string, payload: any) -> (),
	rejections: (player: Player) -> { [string]: number },
	forget: (player: Player) -> (),
}

type Session = {
	player: Player,
	state: RunState.RunState,
	joinedAt: number,
	spawnPosition: Vector3?,
	lastRespawnAt: number,
	helpLevelSent: number,
	trove: Trove.Trove,
}

local PlayerService = {}

local TICK_INTERVAL = 0.1 -- 10 Hz Etagen- und Fallerkennung
local RESPAWN_DEBOUNCE = 1
local HELPERS_ENABLED = true -- Optionen folgen in Sprint 2

local tower: TowerGenerator.TowerSpec
local net: NetLike
local sparkById: { [number]: TowerGenerator.SparkSpec } = {}
local sessions: { [Player]: Session } = {}

local function rootOf(player: Player): BasePart?
	local character = player.Character
	if not character then
		return nil
	end
	local root = character:FindFirstChild("HumanoidRootPart")
	if root and root:IsA("BasePart") then
		return root
	end
	return nil
end

local function popcount(mask: number): number
	local count = 0
	while mask ~= 0 do
		count += bit32.band(mask, 1)
		mask = bit32.rshift(mask, 1)
	end
	return count
end

local function resetY(state: RunState.RunState): number
	return LandingLocator.fallThreshold(tower, state.currentFloor, Movement.FALL_RESET_DEPTH)
end

local function sync(session: Session)
	local state = session.state
	local helpLevel = RunState.helpLevel(state, HELPERS_ENABLED)
	session.player:SetAttribute("Floor", state.currentFloor)
	session.player:SetAttribute("ResetY", resetY(state))
	net.fire(session.player, "StateSync", {
		sparks = state.sparks,
		currentFloor = state.currentFloor,
		highestFloor = state.highestFloor,
		helpLevel = helpLevel,
		collected = state.collected,
		runIndex = state.runIndex,
	})
end

local function teleportToFloor(player: Player, floor: number)
	local character = player.Character
	local root = rootOf(player)
	if not character or not root then
		return
	end
	local landing = tower.landings[floor]
	local position = Vector3.new(landing.x, landing.y + 3.5, landing.z)
	character:PivotTo(CFrame.lookAt(position, position + Vector3.new(landing.fx, 0, landing.fz)))
	root.AssemblyLinearVelocity = Vector3.zero
end

local function markStep(session: Session, step: number, fromClient: boolean, context: string?)
	if RunState.markOnboarding(session.state, step, fromClient) then
		TelemetryService.onboarding(session.player, step, context)
	end
end

local function onFall(session: Session)
	local now = os.clock()
	if now - session.lastRespawnAt < RESPAWN_DEBOUNCE then
		return
	end
	session.lastRespawnAt = now
	RunState.registerFail(session.state)
	teleportToFloor(session.player, session.state.currentFloor)
	local level = RunState.helpLevel(session.state, HELPERS_ENABLED)
	if level > session.helpLevelSent then
		session.helpLevelSent = level
		local kind = if level >= 2 then "helper" else "trail"
		TelemetryService.custom(
			session.player,
			Events.CUSTOM.HelpShown,
			1,
			string.format("%s_F%02d", kind, session.state.currentFloor + 1)
		)
	end
	sync(session)
end

local function onLanding(session: Session, floor: number)
	local state = session.state
	local event = RunState.reachLanding(state, floor, tower.builtFloors)
	if not event.accepted then
		if state.flagged and state.skippedLandings == 1 then
			TelemetryService.custom(session.player, Events.CUSTOM.MovementFlagged, 1, "skip")
		end
		return
	end
	local player = session.player
	session.helpLevelSent = 0
	TelemetryService.floorCompleted(player, floor, TowerGenerator.zoneOf(floor))
	TelemetryService.custom(player, Events.CUSTOM.FloorSummary, event.failsOnSegment, string.format("F%02d", floor))
	local collectedOnFloor = popcount(state.collected[tostring(floor)] or 0)
	TelemetryService.economySource(player, collectedOnFloor, state.sparks, Events.ECONOMY_SKUS.floorSparks)
	if event.campBonus > 0 then
		TelemetryService.economySource(player, event.campBonus, state.sparks, Events.ECONOMY_SKUS.campBonus)
	end
	if floor == 1 then
		markStep(session, 5, false, Events.secondsBucket(os.clock() - session.joinedAt))
	elseif floor == 5 then
		markStep(session, 6, false, nil)
	elseif floor == 10 then
		markStep(session, 8, false, nil)
	end
	sync(session)
end

local function tickSession(session: Session)
	local root = rootOf(session.player)
	if not root then
		return
	end
	local position = root.Position
	if session.spawnPosition and (position - session.spawnPosition).Magnitude > 4 then
		markStep(session, 2, false, nil)
	end
	local floor = LandingLocator.landingAt(tower, position.X, position.Y, position.Z)
	if floor and floor > session.state.currentFloor then
		onLanding(session, floor)
	end
	if position.Y < resetY(session.state) then
		onFall(session)
	end
end

local function onCharacterAdded(session: Session, character: Model)
	WorldSetup.assignCharacter(character)
	local humanoid = character:WaitForChild("Humanoid", 10)
	if humanoid and humanoid:IsA("Humanoid") then
		humanoid.UseJumpPower = false
		humanoid.JumpHeight = Movement.BASE_STATS.jumpHeight
		humanoid.WalkSpeed = Movement.BASE_STATS.walkSpeed
	end
	local root = character:WaitForChild("HumanoidRootPart", 10)
	if not root or not root:IsA("BasePart") then
		return
	end
	if session.state.currentFloor > 0 then
		task.defer(teleportToFloor, session.player, session.state.currentFloor)
	else
		session.spawnPosition = root.Position
	end
	if RunState.markOnboarding(session.state, 1, false) then
		TelemetryService.onboarding(session.player, 1, nil)
		TelemetryService.progressionStart(session.player, 0, nil)
	end
	sync(session)
end

local function onPlayerAdded(player: Player)
	local session: Session = {
		player = player,
		state = RunState.new(1),
		joinedAt = os.clock(),
		spawnPosition = nil,
		lastRespawnAt = 0,
		helpLevelSent = 0,
		trove = Trove.new(),
	}
	sessions[player] = session
	session.trove.add(player.CharacterAdded:Connect(function(character: Model)
		onCharacterAdded(session, character)
	end))
	if player.Character then
		task.spawn(onCharacterAdded, session, player.Character)
	end
end

local function onPlayerRemoving(player: Player)
	local session = sessions[player]
	if not session then
		return
	end
	sessions[player] = nil
	TelemetryService.custom(
		player,
		Events.CUSTOM.SessionEnded,
		math.floor(os.clock() - session.joinedAt),
		Events.floorBucket(session.state.currentFloor)
	)
	for remoteName, count in net.rejections(player) do
		TelemetryService.custom(player, Events.CUSTOM.RemoteRejected, count, remoteName)
	end
	net.forget(player)
	TelemetryService.forget(player)
	session.trove.clean()
end

-- Handler für NetService (Argumente sind bereits vom Guard geprüft).
local handlers = {
	CollectSpark = function(player: Player, sparkId: number)
		local session = sessions[player]
		local spark = sparkById[sparkId]
		local root = rootOf(player)
		if not session or not spark or not root then
			return
		end
		local p = root.Position
		if not RunState.withinReach(p.X, p.Y, p.Z, spark.x, spark.y, spark.z) then
			return
		end
		local ok = RunState.collectSpark(session.state, sparkId, tower.builtFloors)
		if ok then
			markStep(session, 3, false, nil)
			sync(session)
		end
	end,
	RequestRespawn = function(player: Player)
		local session = sessions[player]
		local root = rootOf(player)
		if not session or not root then
			return
		end
		-- Nur echte Stürze zählen (Client meldet früher als der 10-Hz-Takt des Servers).
		if root.Position.Y < resetY(session.state) + 2 then
			onFall(session)
		end
	end,
	ReportOnboardingStep = function(player: Player, step: number)
		local session = sessions[player]
		if session then
			markStep(session, step, true, nil)
		end
	end,
	ReportPreferredInput = function(player: Player, input: string)
		TelemetryService.setInput(player, input)
	end,
}

function PlayerService.init(
	towerSpec: TowerGenerator.TowerSpec,
	netService: NetLike
): { [string]: (Player, ...any) -> () }
	tower = towerSpec
	net = netService
	for _, floor in tower.floors do
		for _, spark in floor.sparks do
			sparkById[spark.id] = spark
		end
	end
	return handlers :: any
end

function PlayerService.start()
	Players.PlayerAdded:Connect(onPlayerAdded)
	Players.PlayerRemoving:Connect(onPlayerRemoving)
	for _, player in Players:GetPlayers() do
		task.spawn(onPlayerAdded, player)
	end
	local accumulator = 0
	RunService.Heartbeat:Connect(function(dt: number)
		accumulator += dt
		if accumulator < TICK_INTERVAL then
			return
		end
		accumulator = 0
		for _, session in sessions do
			local ok, err = pcall(tickSession, session)
			if not ok then
				warn("[PlayerService] tick failed: " .. tostring(err))
			end
		end
	end)
end

return PlayerService
