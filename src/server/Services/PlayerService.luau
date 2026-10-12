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
	readyAt: number?, -- Client bereit (Eingabegerät gemeldet oder Timeout): Start für „Floor1“-Zeit
	spawnPosition: Vector3?,
	graceUntil: number, -- nach (Re-)Spawn keine Sturzerkennung
	lastRespawnAt: number,
	helpLevelSent: number,
	trove: Trove.Trove,
}

export type HandlerResult = string?

local PlayerService = {}

local TICK_INTERVAL = 0.1 -- 10 Hz Etagen- und Sturzerkennung
local RESPAWN_DEBOUNCE = 1
local SPAWN_GRACE = 2
local READY_TIMEOUT = 10
local HELPERS_ENABLED = true -- Optionen folgen in Sprint 2
local NO_RESET = -1e6

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

local function isActive(session: Session): boolean
	return sessions[session.player] == session and session.player.Parent ~= nil
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
	if RunState.isAtTop(state, tower.builtFloors) then
		return NO_RESET -- oberste Etage: frei herumlaufen, kein Zurücksetzen (CR-06)
	end
	return LandingLocator.fallThreshold(tower, state.currentFloor, Movement.FALL_RESET_DEPTH, Movement.ROOT_HEIGHT)
end

-- Steht der Charakter (fast) auf etwas? Dann geht er zurück und fällt nicht (CR-05).
local function hasGroundBelow(character: Model, root: BasePart): boolean
	local params = RaycastParams.new()
	params.FilterType = Enum.RaycastFilterType.Exclude
	-- Alle Charaktere ausschließen: andere Spieler sind kein Boden.
	local exclude: { Instance } = { character }
	for _, other in Players:GetPlayers() do
		if other.Character and other.Character ~= character then
			table.insert(exclude, other.Character)
		end
	end
	params.FilterDescendantsInstances = exclude
	return workspace:Raycast(root.Position, Vector3.new(0, -(Movement.ROOT_HEIGHT + 3), 0), params) ~= nil
end

local function sync(session: Session)
	if not isActive(session) then
		return
	end
	local state = session.state
	session.player:SetAttribute("Floor", state.currentFloor)
	session.player:SetAttribute("ResetY", resetY(state))
	net.fire(session.player, "StateSync", {
		sparks = state.sparks,
		currentFloor = state.currentFloor,
		highestFloor = state.highestFloor,
		helpLevel = RunState.helpLevel(state, HELPERS_ENABLED, tower.builtFloors),
		fails = RunState.failsOnTarget(state),
		collected = state.collected,
		runIndex = state.runIndex,
	})
end

local function landingCFrame(floor: number): CFrame
	local landing = tower.landings[floor]
	local position = Vector3.new(landing.x, landing.y + Movement.ROOT_HEIGHT + 0.5, landing.z)
	return CFrame.lookAt(position, position + Vector3.new(landing.fx, 0, landing.fz))
end

local function teleportToFloor(session: Session, floor: number)
	local character = session.player.Character
	local root = rootOf(session.player)
	if not character or not root then
		return
	end
	session.graceUntil = os.clock() + 0.5
	character:PivotTo(landingCFrame(floor))
	root.AssemblyLinearVelocity = Vector3.zero
end

local function markStep(session: Session, step: number, fromClient: boolean, context: string?)
	if RunState.markOnboarding(session.state, step, fromClient) then
		TelemetryService.onboarding(session.player, step, context)
	end
end

-- Schritt 1 erst, wenn der Client sein Eingabegerät gemeldet hat (Funnel-Aufschlüsselung, CR-11).
local function markReady(session: Session)
	if session.readyAt then
		return
	end
	session.readyAt = os.clock()
	if RunState.markOnboarding(session.state, 1, false) then
		TelemetryService.onboarding(session.player, 1, nil)
		TelemetryService.progressionStart(session.player, 0, tostring(session.state.runIndex))
	end
end

local function onFall(session: Session)
	local now = os.clock()
	if now - session.lastRespawnAt < RESPAWN_DEBOUNCE or now < session.graceUntil then
		return
	end
	session.lastRespawnAt = now
	RunState.registerFail(session.state, tower.builtFloors)
	teleportToFloor(session, session.state.currentFloor)
	local level = RunState.helpLevel(session.state, HELPERS_ENABLED, tower.builtFloors)
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
	TelemetryService.towerFunnel(player, state.runIndex, floor)
	TelemetryService.custom(player, Events.CUSTOM.FloorSummary, event.failsOnSegment, string.format("F%02d", floor))
	local collectedOnFloor = popcount(state.collected[tostring(floor)] or 0)
	TelemetryService.economySource(player, collectedOnFloor, state.sparks, Events.ECONOMY_SKUS.floorSparks)
	if event.campBonus > 0 then
		TelemetryService.economySource(player, event.campBonus, state.sparks, Events.ECONOMY_SKUS.campBonus)
	end
	if floor == 1 then
		local since = os.clock() - (session.readyAt or session.joinedAt)
		markStep(session, 5, false, Events.secondsBucket(since))
	elseif floor == 5 then
		markStep(session, 6, false, nil)
	elseif floor == 10 then
		markStep(session, 7, false, nil)
	end
	sync(session)
end

local function tickSession(session: Session)
	local character = session.player.Character
	local root = rootOf(session.player)
	if not character or not root or not character.Parent then
		return
	end
	local now = os.clock()
	local position = root.Position
	if session.spawnPosition == nil and now >= session.graceUntil and session.state.currentFloor == 0 then
		session.spawnPosition = position -- erst nach dem Platzieren am Spawn messen (CR-03)
	end
	local spawnPosition = session.spawnPosition
	if spawnPosition and (position - spawnPosition).Magnitude > 4 then
		markStep(session, 2, false, nil)
	end
	local floor = LandingLocator.landingAt(tower, position.X, position.Y, position.Z)
	if floor and floor > session.state.currentFloor then
		onLanding(session, floor)
	end
	if position.Y < resetY(session.state) and now >= session.graceUntil and not hasGroundBelow(character, root) then
		onFall(session)
	end
end

local function onCharacterAdded(session: Session, character: Model)
	session.graceUntil = math.huge -- bis der Charakter platziert ist
	WorldSetup.assignCharacter(character)
	local humanoid = character:WaitForChild("Humanoid", 10)
	if humanoid and humanoid:IsA("Humanoid") then
		humanoid.UseJumpPower = false
		humanoid.JumpHeight = Movement.BASE_STATS.jumpHeight
		humanoid.WalkSpeed = Movement.BASE_STATS.walkSpeed
	end
	local root = character:WaitForChild("HumanoidRootPart", 10)
	if not root or not root:IsA("BasePart") or not isActive(session) then
		return
	end
	-- CharacterAdded feuert vor dem Einhängen und Platzieren am Spawn (Player.yaml). Erst danach versetzen.
	if not character.Parent then
		character.AncestryChanged:Wait()
	end
	task.wait(0.2)
	if not isActive(session) or session.player.Character ~= character then
		return
	end
	local floor = session.state.currentFloor
	if floor > 0 then
		local target = landingCFrame(floor)
		pcall(function()
			session.player:RequestStreamAroundAsync(target.Position, 2)
		end)
		if not isActive(session) or session.player.Character ~= character then
			return
		end
		teleportToFloor(session, floor)
	end
	session.graceUntil = os.clock() + SPAWN_GRACE
	sync(session)
end

local function onPlayerAdded(player: Player)
	local session: Session = {
		player = player,
		state = RunState.new(1),
		joinedAt = os.clock(),
		readyAt = nil,
		spawnPosition = nil,
		graceUntil = math.huge,
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
	task.delay(READY_TIMEOUT, function()
		if isActive(session) then
			markReady(session) -- ohne Meldung des Eingabegeräts: „Unknown“
		end
	end)
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
	for key, count in net.rejections(player) do
		TelemetryService.custom(player, Events.CUSTOM.RemoteRejected, count, key)
	end
	net.forget(player)
	TelemetryService.forget(player)
	session.trove.clean()
end

-- Handler für NetService (Argumente sind bereits vom Guard geprüft). Rückgabe: Ablehnungsgrund oder nil.
local handlers = {
	CollectSpark = function(player: Player, sparkId: number): HandlerResult
		local session = sessions[player]
		local spark = sparkById[sparkId]
		local root = rootOf(player)
		if not session or not root then
			return "state"
		end
		if not spark then
			return "unknown"
		end
		local p = root.Position
		if not RunState.withinReach(p.X, p.Y, p.Z, spark.x, spark.y, spark.z) then
			return "reach"
		end
		local ok = RunState.collectSpark(session.state, sparkId, tower.builtFloors)
		if not ok then
			return "rule"
		end
		markStep(session, 4, false, nil)
		sync(session)
		return nil
	end,
	RequestRespawn = function(player: Player): HandlerResult
		local session = sessions[player]
		local character = player.Character
		local root = rootOf(player)
		if not session or not character or not root then
			return "state"
		end
		-- Nur echte Stürze zählen (der Client meldet früher als der 10-Hz-Takt des Servers).
		if root.Position.Y < resetY(session.state) + 2 and not hasGroundBelow(character, root) then
			onFall(session)
			return nil
		end
		return "notFalling"
	end,
	RequestReset = function(player: Player): HandlerResult
		local session = sessions[player]
		if not session then
			return "state"
		end
		-- Reset-Knopf: an den Anfang der aktuellen Etage, ohne Fehlversuch und ohne Charaktertod (CR-17).
		teleportToFloor(session, session.state.currentFloor)
		return nil
	end,
	ReportOnboardingStep = function(player: Player, step: number): HandlerResult
		local session = sessions[player]
		if session then
			markStep(session, step, true, nil)
		end
		return nil
	end,
	ReportPreferredInput = function(player: Player, input: string): HandlerResult
		local session = sessions[player]
		if not session then
			return "state" -- verspätetes Remote nach PlayerRemoving (CR-21)
		end
		TelemetryService.setInput(player, input)
		markReady(session)
		return nil
	end,
}

function PlayerService.init(
	towerSpec: TowerGenerator.TowerSpec,
	netService: NetLike
): { [string]: (Player, ...any) -> HandlerResult }
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
