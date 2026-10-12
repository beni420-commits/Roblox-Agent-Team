--!strict
-- Funken (pro Spieler verschieden, daher clientseitig gebaut). Einsammeln: optimistisch ausblenden,
-- Server bestätigt per StateSync; ohne Bestätigung nach 2 s wieder einblenden.

local RunService = game:GetService("RunService")

local Palette = require("@game/ReplicatedStorage/Shared/Visual/Palette")

local ClientState = require("./ClientState")
local Context = require("./Context")

local SparkController = {}

local PICKUP_RADIUS = 3.5
local CONFIRM_TIMEOUT = 2

function SparkController.start(context: Context.Context)
	local folder = Instance.new("Folder")
	folder.Name = "Sparks"
	folder.Parent = context.fxFolder

	local parts: { [number]: BasePart } = {}
	local byFloor: { [number]: { number } } = {}
	local positions: { [number]: Vector3 } = {}
	local pending: { [number]: number } = {}

	for _, floor in context.tower.floors do
		byFloor[floor.floor] = {}
		for _, spark in floor.sparks do
			local part = Instance.new("Part")
			part.Name = tostring(spark.id)
			part.Shape = Enum.PartType.Ball
			part.Size = Vector3.new(1.4, 1.4, 1.4)
			part.Anchored = true
			part.CanCollide = false
			part.CanQuery = false
			part.CanTouch = false
			part.CastShadow = false
			part.Material = Enum.Material.Neon
			part.Color = Color3.fromRGB(Palette.SPARK.r, Palette.SPARK.g, Palette.SPARK.b)
			local position = Vector3.new(spark.x, spark.y, spark.z)
			part.Position = position
			part.Parent = folder
			parts[spark.id] = part
			positions[spark.id] = position
			table.insert(byFloor[floor.floor], spark.id)
		end
	end

	-- Verpasste Funken bereits passierter Etagen bleiben einsammelbar, sind aber abgedunkelt (CR-07).
	local function refresh()
		local now = os.clock()
		local state = ClientState.get()
		for id, part in parts do
			local collected = ClientState.isCollected(id)
			if collected then
				pending[id] = nil
			end
			local waiting = pending[id] ~= nil and now - (pending[id] :: number) < CONFIRM_TIMEOUT
			local passed = id // 100 <= state.currentFloor
			part.Transparency = if collected or waiting then 1 elseif passed then 0.6 else 0
		end
	end

	ClientState.onChanged(function()
		refresh()
	end)
	refresh()

	RunService.Heartbeat:Connect(function()
		local character = context.player.Character
		local root = character and character:FindFirstChild("HumanoidRootPart")
		if not root or not root:IsA("BasePart") then
			return
		end
		local now = os.clock()
		-- Wie der Server: alle Etagen bis highestFloor + 1 (bei 60 Funken billig).
		local maxFloor = ClientState.get().highestFloor + 1
		local expired = false
		for floorIndex = 1, maxFloor do
			local ids = byFloor[floorIndex]
			if ids then
				for _, id in ids do
					local since = pending[id]
					if since and now - since >= CONFIRM_TIMEOUT then
						pending[id] = nil -- keine Bestätigung: wieder sichtbar
						expired = true
					end
					if not pending[id] and not ClientState.isCollected(id) then
						if (root.Position - positions[id]).Magnitude <= PICKUP_RADIUS then
							pending[id] = now
							parts[id].Transparency = 1
							context.fire("CollectSpark", id)
						end
					end
				end
			end
		end
		if expired then
			refresh()
		end
	end)
end

return SparkController
