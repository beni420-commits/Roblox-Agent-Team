--!strict
-- Ablauf eines Laufs (Server-Autorität): Bahnsteig-Countdown → Wagen 0–50 → Ende → zurück zum Bahnsteig.
-- Simuliert alle Wesen mit denselben Fahrplänen wie die Clients (shared/Logic) und wertet Treffer nur hier.
-- Interaktionen kommen über ProximityPrompts (vom Server empfangen) und wenige geprüfte Remotes.

local Players = game:GetService("Players")
local ProximityPromptService = game:GetService("ProximityPromptService")
local RunService = game:GetService("RunService")

local Causes = require("@game/ReplicatedStorage/Shared/Logic/Causes")
local Conductor = require("@game/ReplicatedStorage/Shared/Logic/Conductor")
local Events = require("@game/ReplicatedStorage/Shared/Telemetry/Events")
local Eyes = require("@game/ReplicatedStorage/Shared/Logic/Eyes")
local GameConfig = require("@game/ReplicatedStorage/Shared/Config/GameConfig")
local HideState = require("@game/ReplicatedStorage/Shared/Logic/HideState")
local Inspector = require("@game/ReplicatedStorage/Shared/Logic/Inspector")
local Lobby = require("@game/ReplicatedStorage/Shared/Logic/Lobby")
local MotionTracker = require("@game/ReplicatedStorage/Shared/Logic/MotionTracker")
local Oncoming = require("@game/ReplicatedStorage/Shared/Logic/Oncoming")
local Sweep = require("@game/ReplicatedStorage/Shared/Logic/Sweep")
local RunState = require("@game/ReplicatedStorage/Shared/Logic/RunState")
local TrainGenerator = require("@game/ReplicatedStorage/Shared/Logic/TrainGenerator")
local Types = require("@game/ReplicatedStorage/Shared/Logic/Types")

local NetService = require("./NetService")
local PlayerService = require("./PlayerService")
local TelemetryService = require("./TelemetryService")
local TrainBuilder = require("../TrainBuilder")
local WorldSetup = require("../WorldSetup")

type InspectorRun = { state: Inspector.State, carriage: number, model: Model, x: number, z: number }
type ConductorRun = { state: Conductor.State, model: Model, sentRevision: number, sentAt: number }

local RunController = {}

local HALF = GameConfig.INNER_WIDTH / 2
local WORLD = "WorldEvent"
local PERSONAL = "PersonalEvent"

local rng = Random.new()
local plan: Types.Plan? = nil
local nextPlan: Types.Plan? = nil
local run: RunState.State? = nil
local lobby = Lobby.new()
local hide = HideState.new()
local runId = 0
local participants: { [Player]: boolean } = {}
local deathCounts: { [Player]: { [string]: number } } = {}
local coldWarned: { [Player]: boolean } = {}

local express: Sweep.Schedule? = nil
local chase: Sweep.Schedule? = nil
local oncoming: Oncoming.Schedule? = nil
local oncomingHit: { [Player]: boolean } = {}
local inspector: InspectorRun? = nil
local conductor: ConductorRun? = nil
local noises: { Conductor.Noise } = {}
local eyesByCarriage: { [number]: { Eyes.EyeState } } = {}
local endingScheduled = false

local function keyOf(player: Player): string
	return tostring(player.UserId)
end

local function now(): number
	return workspace:GetServerTimeNow()
end

local function newSeed(): number
	return rng:NextInteger(1, 2 ^ 31 - 2)
end

local function carriageOf(position: Vector3): number?
	local current = plan
	if current == nil or math.abs(position.Z) > HALF + 2 then
		return nil
	end
	return TrainGenerator.carriageAt(current, position.X)
end

local function carriageData(index: number): Types.Carriage?
	local current = plan
	return if current then current.carriages[index + 1] else nil
end

-- Lebende Teilnehmer mit Figur (für Prüfungen in jedem Takt).
local function aliveParticipants(): { Player }
	local list: { Player } = {}
	local current = run
	if current == nil then
		return list
	end
	for player in participants do
		if RunState.isAlive(current, keyOf(player)) and PlayerService.root(player) ~= nil then
			table.insert(list, player)
		end
	end
	return list
end

local function isHidden(player: Player): boolean
	return HideState.isHidden(hide, keyOf(player))
end

---------------------------------------------------------------------------------------------------
-- Verstecke

local function leaveHiding(player: Player)
	local spotKey = HideState.leave(hide, keyOf(player))
	if spotKey == nil then
		return
	end
	coldWarned[player] = nil
	player:SetAttribute("HiddenIn", 0)
	local carriageIndex = HideState.carriageOf(spotKey)
	local spotId = spotKey % 100
	local prompt = TrainBuilder.prompt("hide", carriageIndex, spotId)
	if prompt then
		prompt.Enabled = true
	end
	local root = PlayerService.root(player)
	local c = carriageData(carriageIndex)
	if root and c then
		local spot = c.hidingSpots[spotId]
		root.Anchored = false
		if spot then
			local _, _, exit = TrainBuilder.spotFrames(c, spot)
			PlayerService.teleport(player, exit)
		end
	end
end

local function enterHiding(player: Player, carriageIndex: number, spotId: number, prompt: ProximityPrompt)
	local current = run
	local c = carriageData(carriageIndex)
	local root = PlayerService.root(player)
	if current == nil or c == nil or root == nil or c.chase then
		return
	end
	local spot = c.hidingSpots[spotId]
	if spot == nil then
		return
	end
	local spotKey = HideState.spotKey(carriageIndex, spotId)
	if not HideState.enter(hide, keyOf(player), spotKey, now()) then
		return
	end
	prompt.Enabled = false
	local inside = TrainBuilder.spotFrames(c, spot)
	root.Anchored = true
	PlayerService.teleport(player, inside)
	player:SetAttribute("HiddenIn", spotKey)
	TelemetryService.onboarding(player, 4)
	TelemetryService.custom(player, Events.CUSTOM.Hide, carriageIndex, nil)
end

---------------------------------------------------------------------------------------------------
-- Schaden und Ausscheiden

local function eliminate(player: Player, cause: string)
	local current = run
	if current == nil then
		return
	end
	local root = PlayerService.root(player)
	local carriage = (if root then carriageOf(root.Position) else nil) or current.opened
	if not RunState.kill(current, keyOf(player), cause, carriage) then
		return
	end
	if isHidden(player) then
		HideState.leave(hide, keyOf(player))
		player:SetAttribute("HiddenIn", 0)
	end
	player:SetAttribute("Alive", false)
	local counts = deathCounts[player] or {}
	deathCounts[player] = counts
	counts[cause] = (counts[cause] or 0) + 1
	NetService.fire(player, PERSONAL, {
		type = "death",
		cause = cause,
		carriage = carriage,
		hint = Causes.hintKey(cause, counts[cause]),
	})
	PlayerService.vanish(player)
	TelemetryService.custom(player, Events.CUSTOM.Death, carriage, cause)
end

local function hurt(player: Player, amount: number, cause: string)
	if PlayerService.damage(player, amount) then
		eliminate(player, cause)
	else
		NetService.fire(player, PERSONAL, { type = "damage", cause = cause, amount = amount })
		TelemetryService.custom(player, Events.CUSTOM.Damage, amount, cause)
	end
end

---------------------------------------------------------------------------------------------------
-- Wagen bauen, abkoppeln („Der Ruck“)

local function buildCarriage(index: number)
	local current = plan
	local c = carriageData(index)
	if current == nil or c == nil then
		return
	end
	TrainBuilder.build(c, current.lastIndex)
	if c.dark and eyesByCarriage[index] == nil then
		eyesByCarriage[index] = Eyes.fromCarriage(c)
	end
	if c.chase then
		-- Während der Kofferlawine helfen keine Verstecke (Hinweis HINT_CHASE_2): Prompts aus.
		for _, spot in c.hidingSpots do
			local prompt = TrainBuilder.prompt("hide", index, spot.id)
			if prompt then
				prompt.Enabled = false
			end
		end
	end
end

local function rearFrame(index: number): CFrame?
	local c = carriageData(index)
	if c == nil then
		return nil
	end
	local p = Vector3.new(c.originX + 3, GameConfig.FLOOR_Y + 3, 0)
	return CFrame.lookAt(p, p + Vector3.new(1, 0, 0))
end

local function decouple(keepFrom: number)
	for _, index in TrainBuilder.builtIndices() do
		if index < keepFrom then
			local c = carriageData(index)
			for _, player in aliveParticipants() do
				local root = PlayerService.root(player)
				if root and c and root.Position.X < c.originX + c.length + GameConfig.GANGWAY then
					if isHidden(player) then
						leaveHiding(player)
					end
					local frame = rearFrame(keepFrom)
					if frame then
						PlayerService.teleport(player, frame)
						NetService.fire(player, PERSONAL, { type = "ruck" })
					end
				end
			end
			TrainBuilder.remove(index)
			eyesByCarriage[index] = nil
			TrainBuilder.sealRear(keepFrom)
		end
	end
end

---------------------------------------------------------------------------------------------------
-- Ereignisse

local function triggerEvent(k: number, event: Types.Event)
	local current = plan
	local c = carriageData(k)
	if current == nil or c == nil then
		return
	end
	local t = now()
	if event.kind == "express" then
		local s = Sweep.express(current, k, t)
		express = s
		NetService.fireAll(WORLD, {
			type = "express",
			carriage = k,
			warnAt = s.warnAt,
			startAt = s.startAt,
			endAt = s.endAt,
			x0 = s.x0,
			x1 = s.x1,
			flickerSeed = newSeed(),
		})
	elseif event.kind == "oncoming" then
		local s = Oncoming.schedule(current, k, t)
		oncoming = s
		table.clear(oncomingHit)
		NetService.fireAll(WORLD, {
			type = "oncoming",
			carriage = k,
			side = s.side,
			warnAt = s.warnAt,
			hitAt = s.hitAt,
			endAt = s.endAt,
			x0 = s.x0,
			x1 = s.x1,
			flickerSeed = newSeed(),
		})
	elseif event.kind == "inspector" then
		local model = TrainBuilder.buildInspector(c)
		inspector = {
			state = Inspector.new(event.seed, t),
			carriage = k,
			model = model,
			x = c.originX + c.length - GameConfig.INSPECTOR_X_FROM_FRONT,
			z = GameConfig.INSPECTOR_Z,
		}
	elseif event.kind == "chase" then
		-- Nachzügler hinter dem Start der Lawine an das Heck von Wagen k − 1 holen.
		local s = Sweep.chase(current, k, t)
		for _, player in aliveParticipants() do
			local root = PlayerService.root(player)
			local frame = rearFrame(k - 1)
			if root and frame and root.Position.X < s.x0 then
				if isHidden(player) then
					leaveHiding(player)
				end
				PlayerService.teleport(player, frame)
			end
		end
		chase = s
		NetService.fireAll(WORLD, {
			type = "chase",
			carriage = k,
			warnAt = s.warnAt,
			startAt = s.startAt,
			endAt = s.endAt,
			x0 = s.x0,
			x1 = s.x1,
			flickerSeed = newSeed(),
		})
	elseif event.kind == "conductor" then
		local post = c.post
		if post == nil then
			return
		end
		local start = post.nodes[post.conductorStart]
		local model = TrainBuilder.buildConductor(c, start.x, start.z)
		conductor =
			{ state = Conductor.new(post, c.obstacles, event.seed, t), model = model, sentRevision = -1, sentAt = 0 }
		NetService.fireAll(WORLD, { type = "conductorWake", wakeAt = t + GameConfig.CONDUCTOR_WAKE })
	end
end

---------------------------------------------------------------------------------------------------
-- Türen

local function telemetryForDoor(door: number)
	local step = Events.milestoneStep(door)
	for _, player in aliveParticipants() do
		if step then
			TelemetryService.runStep(player, runId, step)
		end
		if door == 1 then
			TelemetryService.onboarding(player, 3)
		elseif door == 10 then
			TelemetryService.onboarding(player, 5)
		elseif door == 25 then
			TelemetryService.onboarding(player, 6)
		elseif door == 50 then
			TelemetryService.onboarding(player, 7)
		end
	end
end

local function openDoor(door: number)
	local current = run
	if current == nil then
		return
	end
	local ok, event = RunState.openDoor(current, door)
	if not ok then
		return
	end
	TrainBuilder.setDoorOpen(door, true)
	TrainBuilder.setLocked(door, false)
	workspace:SetAttribute("RunCarriage", door)
	workspace:SetAttribute("KeyDoor", if current.keys[door + 1] then door + 1 else 0)
	for index = door, RunState.buildUpTo(current) do
		buildCarriage(index)
	end
	decouple(RunState.retainFrom(current))
	telemetryForDoor(door)
	if event then
		triggerEvent(door, event)
	end
end

-- Sicherheitsnetz: Wer trotz geschlossener Hülle unter den Zug fällt, kommt zurück an den Anfang
-- des höchsten geöffneten Wagens (ohne Schaden).
local function rescueFallen()
	local current = run
	if current == nil then
		return
	end
	for _, player in aliveParticipants() do
		local root = PlayerService.root(player)
		local frame = rearFrame(current.opened)
		if root and frame and root.Position.Y < GameConfig.FLOOR_Y - 30 then
			if isHidden(player) then
				leaveHiding(player)
			end
			root.Anchored = false
			PlayerService.teleport(player, frame)
		end
	end
end

local function checkDoors()
	local current = run
	if current == nil or current.phase ~= "running" then
		return
	end
	local door = current.opened + 1
	local c = carriageData(current.opened)
	if c == nil or door > current.plan.lastIndex then
		return
	end
	local active = inspector
	if active and active.carriage == current.opened then
		return -- Fahrkartenkontrolle: Tür bleibt zu, bis alle kontrolliert sind
	end
	if not RunState.canOpenDoor(current, door) then
		return
	end
	local doorX = c.originX + c.length
	for _, player in aliveParticipants() do
		local root = PlayerService.root(player)
		if root and not isHidden(player) then
			local p = root.Position
			if p.X >= doorX - GameConfig.DOOR_OPEN_DISTANCE and p.X <= doorX + 1 and math.abs(p.Z) < HALF then
				openDoor(door)
				return
			end
		end
	end
end

---------------------------------------------------------------------------------------------------
-- Lauf starten und beenden

local function setRunAttributes(phase: string)
	workspace:SetAttribute("RunPhase", phase)
	workspace:SetAttribute("RunCarriage", if run then (run :: RunState.State).opened else 0)
	if phase ~= "running" then
		workspace:SetAttribute("KeyDoor", 0)
	end
end

local function prepareNextPlan()
	task.defer(function()
		nextPlan = TrainGenerator.generate(newSeed())
	end)
end

local function startRun(boarders: { Player })
	local t = now()
	local newPlan = nextPlan or TrainGenerator.generate(newSeed())
	nextPlan = nil
	plan = newPlan
	runId += 1
	local current = RunState.new(newPlan)
	run = current
	hide = HideState.new()
	table.clear(participants)
	table.clear(eyesByCarriage)
	table.clear(noises)
	express, chase, oncoming, inspector, conductor = nil, nil, nil, nil, nil
	endingScheduled = false
	local keys: { string } = {}
	for _, player in boarders do
		participants[player] = true
		table.insert(keys, keyOf(player))
	end
	RunState.start(current, keys, t)
	-- Nur in Roblox Studio: Workspace-Attribut „DebugStartCarriage“ startet den Lauf in Wagen n
	-- (für den Owner-Test des Finales, reports/lantern-line/owner_test_template.md). Live wirkungslos.
	local debugStart = workspace:GetAttribute("DebugStartCarriage")
	local startEvent: Types.Event? = nil
	local startIndex = 0
	if RunService:IsStudio() and type(debugStart) == "number" then
		local ok, event = RunState.debugSkipTo(current, debugStart)
		if ok then
			startIndex = current.opened
			startEvent = event
		end
	end
	for index = math.max(0, startIndex - 1), RunState.buildUpTo(current) do
		buildCarriage(index)
	end
	if startIndex > 0 then
		TrainBuilder.setDoorOpen(startIndex, true)
		TrainBuilder.sealRear(startIndex - 1)
	end
	local first = newPlan.carriages[startIndex + 1]
	for i, player in boarders do
		-- Nebeneinander im hinteren Vorraum (x 1,5–3,5, |z| ≤ 2,5: dort steht in keinem Wagentyp ein Möbelstück).
		local p = Vector3.new(first.originX + 2.5, GameConfig.FLOOR_Y + 3, -1.5 + (i - 1))
		PlayerService.teleport(player, CFrame.lookAt(p, p + Vector3.new(1, 0, 0)))
		player:SetAttribute("InRun", true)
		player:SetAttribute("Alive", true)
		player:SetAttribute("Stubs", 0)
		player:SetAttribute("HiddenIn", 0)
		TelemetryService.onboarding(player, 2)
	end
	for row = 1, 3 do
		workspace:SetAttribute("Note" .. row, -1)
	end
	workspace:SetAttribute("RunStartedAt", t)
	workspace:SetAttribute("LobbyEndsAt", -1)
	setRunAttributes("running")
	NetService.fireAll(WORLD, { type = "start", runId = runId })
	if startEvent then
		triggerEvent(startIndex, startEvent)
	end
	prepareNextPlan()
end

local function resetToLobby()
	TrainBuilder.clear()
	run = nil
	plan = nil
	express, chase, oncoming, inspector, conductor = nil, nil, nil, nil, nil
	hide = HideState.new()
	table.clear(participants)
	table.clear(eyesByCarriage)
	table.clear(coldWarned)
	lobby = Lobby.new()
	setRunAttributes("lobby")
	NetService.fireAll(WORLD, { type = "reset" })
	for _, player in Players:GetPlayers() do
		player:SetAttribute("InRun", false)
		player:SetAttribute("Alive", true)
		player:SetAttribute("HiddenIn", 0)
		task.spawn(PlayerService.spawnAtPlatform, player)
	end
end

local function endRun(outcome: RunState.Outcome)
	local current = run
	if current == nil or endingScheduled then
		return
	end
	endingScheduled = true
	setRunAttributes("ended")
	local seconds = math.floor(current.endedAt - current.startedAt)
	for player in participants do
		local playerRun = current.players[keyOf(player)]
		NetService.fire(player, PERSONAL, {
			type = "summary",
			outcome = outcome,
			carriage = current.opened,
			stubs = if playerRun then playerRun.stubs else 0,
			seconds = seconds,
		})
		TelemetryService.custom(player, Events.CUSTOM.RunEnded, current.opened, outcome)
		if outcome == "won" then
			TelemetryService.runStep(player, runId, Events.FINISH_STEP)
			TelemetryService.onboarding(player, 8)
		end
	end
	task.delay(GameConfig.END_SCREEN_TIME, resetToLobby)
end

---------------------------------------------------------------------------------------------------
-- Takt

local lastTick = 0
local accumulators: { [string]: number } = { sample = 0, door = 0, inspector = 0, conductor = 0, cold = 0, lobby = 0 }

local function updateLobby()
	if run ~= nil then
		return
	end
	local ready: { Player } = {}
	local total = 0
	for _, player in Players:GetPlayers() do
		local root = PlayerService.root(player)
		if root then
			total += 1
			if WorldSetup.isInBoardingZone(root.Position) then
				table.insert(ready, player)
			end
			if root.Position.Y < -60 then
				PlayerService.teleport(player, WorldSetup.platformSpawn())
			end
		end
	end
	local t = now()
	local depart = Lobby.update(lobby, t, #ready, total)
	workspace:SetAttribute("LobbyEndsAt", lobby.endsAt or -1)
	if depart then
		startRun(ready)
	end
end

local function updateEntities(t: number, dt: number)
	local current = run
	if current == nil or current.phase ~= "running" then
		return
	end
	local alive = aliveParticipants()

	local e = express
	if e then
		for _, player in alive do
			local root = PlayerService.root(player)
			if root and not isHidden(player) and math.abs(root.Position.Z) <= HALF + 1 then
				if Sweep.expressHits(e, t - dt, t, root.Position.X) then
					eliminate(player, "express")
				end
			end
		end
		if t > e.endAt + 0.5 then
			express = nil
		end
	end

	local ch = chase
	if ch then
		for _, player in alive do
			local root = PlayerService.root(player)
			if root and Sweep.chaseCatches(ch, t, root.Position.X) then
				eliminate(player, "chase")
			end
		end
		if t > ch.endAt then
			chase = nil
			TrainBuilder.setDoorOpen(ch.carriage + GameConfig.CHASE_LENGTH, false)
		end
	end

	local o = oncoming
	if o then
		for _, player in alive do
			local root = PlayerService.root(player)
			if root and not oncomingHit[player] then
				if Oncoming.hits(o, t, root.Position.X, root.Position.Z, isHidden(player)) then
					oncomingHit[player] = true
					hurt(player, GameConfig.ONCOMING_DAMAGE, "oncoming")
				end
			end
		end
		if t > o.endAt then
			oncoming = nil
		end
	end

	for _, player in alive do
		local root = PlayerService.root(player)
		if root and not isHidden(player) then
			local index = carriageOf(root.Position)
			local list = if index then eyesByCarriage[index] else nil
			if index and list then
				local eye = Eyes.snatch(list, root.Position.X, root.Position.Z)
				if eye then
					TrainBuilder.markEyesUsed(index, eye.id)
					hurt(player, GameConfig.EYES_DAMAGE, "eyes")
				end
			end
		end
	end
end

local function updateInspector(t: number)
	local active = inspector
	if active == nil then
		return
	end
	local views: { Inspector.PlayerView } = {}
	local byKey: { [string]: Player } = {}
	for _, player in aliveParticipants() do
		local root = PlayerService.root(player)
		local tracker = PlayerService.motion(player)
		if root then
			local p = root.Position
			local dx, dz = p.X - active.x, p.Z - active.z
			local key = keyOf(player)
			byKey[key] = player
			table.insert(views, {
				key = key,
				alive = true,
				inCarriage = carriageOf(p) == active.carriage,
				distance = math.sqrt(dx * dx + dz * dz),
				moved = if tracker and not isHidden(player)
					then MotionTracker.displacement(tracker, GameConfig.INSPECTOR_MOVE_WINDOW)
					else 0,
			})
		end
	end
	local result = Inspector.update(active.state, t, views)
	if result.phaseChanged then
		active.model:SetAttribute("Phase", active.state.phase)
	end
	for _, key in result.hits do
		local player = byKey[key]
		if player then
			hurt(player, GameConfig.INSPECTOR_DAMAGE, "inspector")
		end
	end
	if result.done then
		inspector = nil
		task.delay(1.2, function()
			active.model:Destroy()
		end)
	end
end

local function sendConductor(active: ConductorRun, t: number, force: boolean)
	local s = active.state
	if not force and (s.revision == active.sentRevision or t - active.sentAt < 0.15) then
		return
	end
	local c = carriageData(GameConfig.RUN_LAST_CARRIAGE)
	if c == nil then
		return
	end
	active.sentRevision = s.revision
	active.sentAt = t
	NetService.fireAll(WORLD, {
		type = "conductor",
		originX = c.originX,
		x = s.x,
		z = s.z,
		fx = s.fx,
		fz = s.fz,
		mode = s.mode,
		speed = Conductor.speed(s),
		points = s.path,
		at = t,
	})
end

local function updateConductor(t: number, dt: number)
	local active = conductor
	local c = carriageData(GameConfig.RUN_LAST_CARRIAGE)
	if active == nil or c == nil then
		return
	end
	local listeners: { Conductor.Listener } = {}
	local byKey: { [string]: Player } = {}
	for _, player in aliveParticipants() do
		local root = PlayerService.root(player)
		local tracker = PlayerService.motion(player)
		if root and carriageOf(root.Position) == c.index then
			local key = keyOf(player)
			byKey[key] = player
			table.insert(listeners, {
				key = key,
				x = root.Position.X - c.originX,
				z = root.Position.Z,
				speed = if tracker then MotionTracker.speed(tracker, 0.25) else 0,
				hidden = isHidden(player),
				alive = true,
			})
		end
	end
	local caught = Conductor.update(active.state, t, dt, listeners, noises)
	table.clear(noises)
	for _, key in caught do
		local player = byKey[key]
		if player then
			eliminate(player, "conductor")
		end
	end
	sendConductor(active, t, t - active.sentAt > 1)
end

local function updateCold(t: number)
	local active = conductor
	local entityActive = express ~= nil
		or oncoming ~= nil
		or chase ~= nil
		or (active ~= nil and active.state.mode == "hunt")
	for player in participants do
		if isHidden(player) then
			local cold = HideState.cold(hide, keyOf(player), t, entityActive)
			if cold == "eject" then
				leaveHiding(player)
				NetService.fire(player, PERSONAL, { type = "cold", level = "eject" })
			elseif cold == "warn" and not coldWarned[player] then
				coldWarned[player] = true
				NetService.fire(player, PERSONAL, { type = "cold", level = "warn" })
			elseif cold == "none" and coldWarned[player] then
				coldWarned[player] = nil
				NetService.fire(player, PERSONAL, { type = "cold", level = "none" })
			end
		end
	end
end

local function checkFinish(t: number)
	local current = run
	if current == nil or current.phase ~= "running" then
		return
	end
	local finished = false
	if current.solved then
		local last = carriageData(current.plan.lastIndex)
		for _, player in aliveParticipants() do
			local root = PlayerService.root(player)
			if root and last and root.Position.X > last.originX + last.length + 2 then
				finished = true
			end
		end
	end
	local outcome = RunState.checkEnd(current, t, finished)
	if outcome then
		endRun(outcome)
	end
end

local function step()
	local t = now()
	local dt = math.clamp(t - lastTick, 0, 0.25)
	lastTick = t
	for name in accumulators do
		accumulators[name] += dt
	end
	if accumulators.sample >= 0.05 then
		accumulators.sample = 0
		PlayerService.sample(t)
	end
	if accumulators.lobby >= 0.25 then
		accumulators.lobby = 0
		updateLobby()
	end
	if run == nil then
		return
	end
	updateEntities(t, dt)
	if accumulators.door >= 0.1 then
		accumulators.door = 0
		checkDoors()
		rescueFallen()
		checkFinish(t)
	end
	if accumulators.inspector >= 0.05 then
		accumulators.inspector = 0
		updateInspector(t)
	end
	if accumulators.conductor >= 0.05 then
		local cdt = accumulators.conductor
		accumulators.conductor = 0
		updateConductor(t, cdt)
	end
	if accumulators.cold >= 0.25 then
		accumulators.cold = 0
		updateCold(t)
	end
end

---------------------------------------------------------------------------------------------------
-- Prompts und Remotes

local function promptNumber(prompt: ProximityPrompt, name: string): number?
	local value = prompt:GetAttribute(name)
	return if type(value) == "number" then value else nil
end

local function withinReach(player: Player, prompt: ProximityPrompt): boolean
	local root = PlayerService.root(player)
	local attachment = prompt.Parent
	if root == nil or attachment == nil or not attachment:IsA("Attachment") then
		return false
	end
	return (root.Position - attachment.WorldPosition).Magnitude <= prompt.MaxActivationDistance + 3
end

local function onPrompt(prompt: ProximityPrompt, player: Player)
	local current = run
	local kind = prompt:GetAttribute("Kind")
	local carriage = promptNumber(prompt, "Carriage")
	local id = promptNumber(prompt, "Id")
	if current == nil or current.phase ~= "running" or carriage == nil or id == nil then
		return
	end
	if not participants[player] or not RunState.isAlive(current, keyOf(player)) or isHidden(player) then
		return
	end
	if not withinReach(player, prompt) then
		return
	end
	if kind == "hide" then
		enterHiding(player, carriage, id, prompt)
	elseif kind == "container" then
		local ok, content, stubs = RunState.openContainer(current, keyOf(player), carriage, id)
		if ok then
			TrainBuilder.markContainerOpened(carriage, id)
			local playerRun = current.players[keyOf(player)]
			player:SetAttribute("Stubs", if playerRun then playerRun.stubs else 0)
			if content == "key" then
				workspace:SetAttribute("KeyDoor", carriage + 1)
			end
			NetService.fire(player, PERSONAL, { type = "found", content = content, stubs = stubs })
		end
	elseif kind == "fragment" then
		if RunState.readFragment(current, id) then
			local c = carriageData(carriage)
			local post = if c then c.post else nil
			if post then
				for _, fragment in post.fragments do
					if fragment.row == id then
						workspace:SetAttribute("Note" .. id, fragment.holes)
					end
				end
			end
		end
	elseif kind == "validator" then
		NetService.fire(player, PERSONAL, { type = "validator" })
	end
end

local function onSubmitPattern(player: Player, mask: number): string?
	local current = run
	local c = carriageData(GameConfig.RUN_LAST_CARRIAGE)
	local post = if c then c.post else nil
	if current == nil or c == nil or post == nil or not participants[player] then
		return "state"
	end
	if not RunState.isAlive(current, keyOf(player)) or isHidden(player) then
		return "dead"
	end
	local root = PlayerService.root(player)
	local validatorPos = Vector3.new(c.originX + post.validatorX, GameConfig.FLOOR_Y + 3, post.validatorZ)
	if root == nil or (root.Position - validatorPos).Magnitude > 12 then
		return "reach"
	end
	if current.solved then
		return "solved"
	end
	if RunState.submitPattern(current, mask) then
		TrainBuilder.setDoorOpen(current.plan.lastIndex + 1, true)
		NetService.fireAll(WORLD, { type = "solved" })
		NetService.fire(player, PERSONAL, { type = "pattern", correct = true })
		TelemetryService.custom(player, Events.CUSTOM.PatternSolved, 1, nil)
		return nil
	end
	table.insert(noises, { x = post.validatorX, z = post.validatorZ, radius = GameConfig.NOISE_WRONG_CODE_RADIUS })
	NetService.fire(player, PERSONAL, { type = "pattern", correct = false })
	TelemetryService.custom(player, Events.CUSTOM.PatternWrong, 1, nil)
	return "wrong"
end

function RunController.handlers(): { [string]: NetService.Handler }
	return {
		RequestLeaveHiding = function(player: Player): string?
			if not isHidden(player) then
				return "notHidden"
			end
			leaveHiding(player)
			return nil
		end,
		SubmitPattern = function(player: Player, mask: number): string?
			return onSubmitPattern(player, mask)
		end,
		ReportPreferredInput = function(player: Player, input: string): string?
			TelemetryService.setInput(player, input)
			return nil
		end,
	}
end

local function onPlayerAdded(player: Player)
	player:SetAttribute("InRun", false)
	player:SetAttribute("Alive", true)
	player:SetAttribute("HiddenIn", 0)
	player:SetAttribute("Stubs", 0)
	task.spawn(function()
		PlayerService.spawnAtPlatform(player)
		TelemetryService.onboarding(player, 1)
	end)
end

local function onPlayerRemoving(player: Player)
	local current = run
	if current and participants[player] then
		HideState.leave(hide, keyOf(player))
		RunState.removePlayer(current, keyOf(player))
		participants[player] = nil
	end
	local rejected = 0
	for _, count in NetService.rejections(player) do
		rejected += count
	end
	if rejected > 0 then
		TelemetryService.custom(player, Events.CUSTOM.RemoteRejected, rejected, nil)
	end
	NetService.forget(player)
	TelemetryService.forget(player)
	deathCounts[player] = nil
	coldWarned[player] = nil
	oncomingHit[player] = nil
end

function RunController.start()
	setRunAttributes("lobby")
	workspace:SetAttribute("LobbyEndsAt", -1)
	prepareNextPlan()
	ProximityPromptService.PromptTriggered:Connect(onPrompt)
	Players.PlayerAdded:Connect(onPlayerAdded)
	Players.PlayerRemoving:Connect(onPlayerRemoving)
	for _, player in Players:GetPlayers() do
		onPlayerAdded(player)
	end
	lastTick = now()
	RunService.Heartbeat:Connect(step)
end

return RunController
