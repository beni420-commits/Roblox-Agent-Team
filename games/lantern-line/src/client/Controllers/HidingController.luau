--!strict
-- Versteck-Ansicht: Kamera an den Sehschlitzen des Schranks, Schlitz-Abdeckung, Knopf „Aussteigen“
-- (Taste E / Gamepad B, mit freier Maus), Raureif bei Kälte. Kein Herzschlag-Minispiel (H-A2 d).

local ContextActionService = game:GetService("ContextActionService")
local ProximityPromptService = game:GetService("ProximityPromptService")

local Context = require("./Context")
local Hud = require("./Hud")
local Palette = require("@game/ReplicatedStorage/Shared/Visual/Palette")
local Strings = require("./Strings")
local TrainView = require("./TrainView")
local UiKit = require("./UiKit")

local HidingController = {}

local overlay: Frame
local leaveButton: TextButton
local hidden = false

local hiddenSpotModel: Instance? = nil

local function findSpot(spotKey: number): (CFrame?, Instance?)
	local train = TrainView.folder()
	if train == nil then
		return nil, nil
	end
	local model = TrainView.carriageModel(spotKey // 100)
	for _, child in (if model then model:GetChildren() else {}) do
		if child:GetAttribute("SpotKey") == spotKey then
			local eye = child:GetAttribute("EyeCFrame")
			if typeof(eye) == "CFrame" then
				return eye, child
			end
		end
	end
	return nil, nil
end

-- Eigenes Versteck lokal ausblenden, damit die Kamera hinaussieht; die Schlitz-Optik kommt aus der UI.
-- Andere Spieler sehen weiter den geschlossenen Schrank (Code-Review LL-02).
local function setSpotSeeThrough(spotModel: Instance?, seeThrough: boolean)
	if spotModel == nil then
		return
	end
	for _, part in spotModel:GetDescendants() do
		if part:IsA("BasePart") then
			part.LocalTransparencyModifier = if seeThrough then 1 else 0
		end
	end
end

local function leave()
	if hidden then
		Context.fire("RequestLeaveHiding")
	end
end

local function apply()
	local spotKey = Context.player:GetAttribute("HiddenIn")
	local camera = workspace.CurrentCamera
	local eye, spotModel = nil, nil
	if type(spotKey) == "number" and spotKey > 0 then
		eye, spotModel = findSpot(spotKey)
	end
	if eye then
		hidden = true
		camera.CameraType = Enum.CameraType.Scriptable
		camera.CFrame = eye
		overlay.Visible = true
		hiddenSpotModel = spotModel
		setSpotSeeThrough(spotModel, true)
		-- Keine fremden Prompts, solange man im Schrank sitzt (E heißt nur „Aussteigen“, LL-09)
		ProximityPromptService.Enabled = false
		ContextActionService:BindAction("LanternLeaveHiding", function(_, state)
			if state == Enum.UserInputState.Begin then
				leave()
			end
			return Enum.ContextActionResult.Sink
		end, false, Enum.KeyCode.E, Enum.KeyCode.ButtonB)
	else
		if hidden then
			camera.CameraType = Enum.CameraType.Custom
		end
		hidden = false
		overlay.Visible = false
		setSpotSeeThrough(hiddenSpotModel, false)
		hiddenSpotModel = nil
		ProximityPromptService.Enabled = true
		Hud.showCold(false)
		ContextActionService:UnbindAction("LanternLeaveHiding")
	end
end

function HidingController.isHidden(): boolean
	return hidden
end

function HidingController.init()
	local gui = UiKit.screen("Hiding", 20)
	overlay = Instance.new("Frame")
	overlay.Size = UDim2.fromScale(1, 1)
	overlay.BackgroundTransparency = 1
	overlay.Visible = false
	overlay.Parent = gui
	-- Schranktür mit zwei Sehschlitzen: dunkle Flächen oben, Mitte, unten
	for _, spec in { { 0, 0.38 }, { 0.46, 0.08 }, { 0.62, 0.38 } } do
		local panel = Instance.new("Frame")
		panel.Size = UDim2.fromScale(1, spec[2])
		panel.Position = UDim2.fromScale(0, spec[1])
		panel.BackgroundColor3 = Palette.woodDark:Lerp(Palette.hudShade, 0.6)
		panel.BorderSizePixel = 0
		panel.Parent = overlay
	end
	leaveButton = UiKit.button(overlay, "", UDim2.fromOffset(220, 48), UDim2.new(0.5, -110, 0.85, 0), true)
	leaveButton.Activated:Connect(leave)
	local function relabel()
		leaveButton.Text = Strings.format("hud.leave") .. "  [E]"
	end
	Strings.onReady(relabel)
	relabel()
	Context.player:GetAttributeChangedSignal("HiddenIn"):Connect(apply)
	Context.onPersonal("cold", function(payload)
		Hud.showCold(payload.level == "warn" and hidden)
	end)
end

return HidingController
