--!strict
-- Figuren: Erscheinen am Bahnsteig, Teleport in den Zug, Positionsproben, Schaden und „Abblenden“.
-- Kein Roblox-Tod: Bei 0 Lebenspunkten verblasst die Figur und wird entfernt (kein Ragdoll, kein Blut,
-- Compliance H-A8). Keine Regeneration (leeres Skript „Health“ in StarterCharacterScripts).

local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")

local GameConfig = require("@game/ReplicatedStorage/Shared/Config/GameConfig")
local MotionTracker = require("@game/ReplicatedStorage/Shared/Logic/MotionTracker")
local Palette = require("@game/ReplicatedStorage/Shared/Visual/Palette")
local WorldSetup = require("../WorldSetup")

local PlayerService = {}

local trackers: { [Player]: MotionTracker.Tracker } = {}
local vanishing: { [Player]: boolean } = {}

local function setupCharacter(character: Model)
	for _, child in character:GetDescendants() do
		if child:IsA("BasePart") then
			child.CollisionGroup = WorldSetup.PLAYER_GROUP
		end
	end
	character.DescendantAdded:Connect(function(child)
		if child:IsA("BasePart") then
			child.CollisionGroup = WorldSetup.PLAYER_GROUP
		end
	end)
	local humanoid = character:FindFirstChildOfClass("Humanoid")
	if humanoid then
		humanoid.BreakJointsOnDeath = false
		humanoid.MaxHealth = GameConfig.MAX_HEALTH
		humanoid.Health = GameConfig.MAX_HEALTH
		humanoid.WalkSpeed = GameConfig.WALK_SPEED
		humanoid.JumpHeight = 0
	end
	-- Persönliches Laternenlicht: in dunklen Wagen das einzige Licht (GDD §6.3)
	local root = character:FindFirstChild("HumanoidRootPart")
	if root and root:IsA("BasePart") then
		local light = Instance.new("PointLight")
		light.Name = "Lantern"
		light.Range = 9
		light.Brightness = 0.7
		light.Color = Palette.lampLight
		light.Shadows = false
		light.Parent = root
	end
end

function PlayerService.init()
	Players.PlayerAdded:Connect(function(player)
		trackers[player] = MotionTracker.new()
		player.CharacterAdded:Connect(setupCharacter)
	end)
	Players.PlayerRemoving:Connect(function(player)
		trackers[player] = nil
		vanishing[player] = nil
	end)
	for _, player in Players:GetPlayers() do
		trackers[player] = MotionTracker.new()
		player.CharacterAdded:Connect(setupCharacter)
		if player.Character then
			setupCharacter(player.Character)
		end
	end
end

function PlayerService.root(player: Player): BasePart?
	local character = player.Character
	if character == nil or vanishing[player] then
		return nil
	end
	local root = character:FindFirstChild("HumanoidRootPart")
	if root and root:IsA("BasePart") then
		return root
	end
	return nil
end

function PlayerService.humanoid(player: Player): Humanoid?
	local character = player.Character
	return if character then character:FindFirstChildOfClass("Humanoid") else nil
end

function PlayerService.position(player: Player): Vector3?
	local root = PlayerService.root(player)
	return if root then root.Position else nil
end

-- Lädt die Figur neu am Bahnsteig (blockiert, bis sie da ist).
function PlayerService.spawnAtPlatform(player: Player)
	if player.Parent == nil then
		return
	end
	vanishing[player] = nil
	local ok, err = pcall(function()
		player:LoadCharacterAsync()
	end)
	if not ok then
		warn("[PlayerService] LoadCharacterAsync failed: " .. tostring(err))
		return
	end
	local character = player.Character
	if character then
		character:PivotTo(WorldSetup.platformSpawn())
	end
	local tracker = trackers[player]
	if tracker then
		MotionTracker.reset(tracker)
	end
end

function PlayerService.teleport(player: Player, cframe: CFrame)
	local character = player.Character
	if character then
		character:PivotTo(cframe)
	end
	local tracker = trackers[player]
	if tracker then
		MotionTracker.reset(tracker)
	end
end

-- Positionsproben für Kontrolleur und Schaffner (aufgerufen mit ca. 20 Hz).
function PlayerService.sample(now: number)
	for player, tracker in trackers do
		local root = PlayerService.root(player)
		if root then
			local p = root.Position
			MotionTracker.add(tracker, now, p.X, p.Z)
		end
	end
end

function PlayerService.motion(player: Player): MotionTracker.Tracker?
	return trackers[player]
end

-- Fügt Schaden zu. Liefert true, wenn die Figur dadurch „ausscheidet“ (dann ruft der Aufrufer vanish).
function PlayerService.damage(player: Player, amount: number): boolean
	local humanoid = PlayerService.humanoid(player)
	if humanoid == nil or vanishing[player] then
		return false
	end
	local remaining = humanoid.Health - amount
	if remaining <= 0 then
		humanoid.Health = 1 -- nie den Roblox-Tod auslösen; wir blenden selbst ab
		return true
	end
	humanoid.Health = remaining
	return false
end

-- Figur verblasst in 0,6 s und wird entfernt (Zuschauen übernimmt der Client).
function PlayerService.vanish(player: Player)
	local character = player.Character
	if character == nil or vanishing[player] then
		return
	end
	vanishing[player] = true
	local root = character:FindFirstChild("HumanoidRootPart")
	if root and root:IsA("BasePart") then
		root.Anchored = true
	end
	for _, child in character:GetDescendants() do
		if child:IsA("BasePart") or child:IsA("Decal") then
			TweenService:Create(child, TweenInfo.new(0.6), { Transparency = 1 }):Play()
		end
	end
	task.delay(0.7, function()
		if player.Character == character then
			player.Character = nil
		end
		character:Destroy()
	end)
end

function PlayerService.isVanishing(player: Player): boolean
	return vanishing[player] == true
end

return PlayerService
