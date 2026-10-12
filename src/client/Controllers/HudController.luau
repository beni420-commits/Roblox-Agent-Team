--!strict
-- HUD (UX B2): Funken oben links, Etagen-Leiste oben Mitte, „+n“-Popup, Zonen-Banner, Fall-Vignette.
-- Keine interaktiven Elemente in Sprint 1; alle Texte über Strings (Lokalisierung).

local TweenService = game:GetService("TweenService")

local Palette = require("@game/ReplicatedStorage/Shared/Visual/Palette")
local TowerConfig = require("@game/ReplicatedStorage/Shared/Logic/TowerConfig")

local ClientState = require("./ClientState")
local Context = require("./Context")
local Strings = require("./Strings")

local HudController = {}

local vignette: Frame? = nil

local function rgb(color: Palette.RGB): Color3
	return Color3.fromRGB(color.r, color.g, color.b)
end

local function label(parent: Instance, name: string, size: UDim2, position: UDim2): TextLabel
	local text = Instance.new("TextLabel")
	text.Name = name
	text.BackgroundTransparency = 1
	text.Size = size
	text.Position = position
	text.Font = Enum.Font.BuilderSansBold
	text.TextColor3 = Color3.new(1, 1, 1)
	text.TextScaled = true
	local constraint = Instance.new("UITextSizeConstraint")
	constraint.MinTextSize = 14
	constraint.MaxTextSize = 36
	constraint.Parent = text
	local stroke = Instance.new("UIStroke")
	stroke.Thickness = 2
	stroke.Color = Color3.fromRGB(30, 30, 40)
	stroke.Parent = text
	text.Parent = parent
	return text
end

function HudController.flashFall()
	local frame = vignette
	if not frame then
		return
	end
	frame.BackgroundTransparency = 1
	local fadeIn = TweenService:Create(frame, TweenInfo.new(0.15), { BackgroundTransparency = 0.55 })
	fadeIn:Play()
	fadeIn.Completed:Once(function()
		TweenService:Create(frame, TweenInfo.new(0.3), { BackgroundTransparency = 1 }):Play()
	end)
end

function HudController.start(context: Context.Context)
	local gui = Instance.new("ScreenGui")
	gui.Name = "Hud"
	gui.ResetOnSpawn = false
	gui.ScreenInsets = Enum.ScreenInsets.CoreUISafeInsets
	gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

	-- Funken-Zähler (oben links): Rauten-Symbol + Zahl.
	local sparkBox = Instance.new("Frame")
	sparkBox.Name = "Sparks"
	sparkBox.BackgroundTransparency = 1
	sparkBox.Size = UDim2.fromScale(0.16, 0.07)
	sparkBox.Position = UDim2.fromScale(0.02, 0.02)
	local sizeLimit = Instance.new("UISizeConstraint")
	sizeLimit.MinSize = Vector2.new(110, 36)
	sizeLimit.Parent = sparkBox
	sparkBox.Parent = gui

	local icon = Instance.new("Frame")
	icon.Name = "Icon"
	icon.AnchorPoint = Vector2.new(0.5, 0.5)
	icon.Position = UDim2.new(0, 18, 0.5, 0)
	icon.Size = UDim2.fromOffset(20, 20)
	icon.Rotation = 45
	icon.BackgroundColor3 = rgb(Palette.SPARK)
	local iconStroke = Instance.new("UIStroke")
	iconStroke.Thickness = 2
	iconStroke.Color = Color3.fromRGB(30, 30, 40)
	iconStroke.Parent = icon
	icon.Parent = sparkBox

	local sparkCount = label(sparkBox, "Count", UDim2.new(1, -40, 1, 0), UDim2.fromOffset(40, 0))
	sparkCount.TextXAlignment = Enum.TextXAlignment.Left
	sparkCount.Text = "0"

	local popup = label(sparkBox, "Popup", UDim2.new(0.6, 0, 0.8, 0), UDim2.new(0.55, 0, 0.9, 0))
	popup.TextColor3 = rgb(Palette.SPARK)
	popup.TextTransparency = 1
	popup.TextXAlignment = Enum.TextXAlignment.Left

	-- Etagen-Leiste (oben Mitte): Zahl + Fortschritt über 30 Etagen; noch nicht gebaute Etagen gedimmt.
	local floorBox = Instance.new("Frame")
	floorBox.Name = "Floors"
	floorBox.BackgroundTransparency = 1
	floorBox.AnchorPoint = Vector2.new(0.5, 0)
	floorBox.Position = UDim2.fromScale(0.5, 0.02)
	floorBox.Size = UDim2.fromScale(0.34, 0.08)
	floorBox.Parent = gui

	local floorText = label(floorBox, "Value", UDim2.fromScale(1, 0.6), UDim2.fromScale(0, 0))
	local bar = Instance.new("Frame")
	bar.Name = "Bar"
	bar.Position = UDim2.fromScale(0, 0.68)
	bar.Size = UDim2.fromScale(1, 0.24)
	bar.BackgroundColor3 = Color3.fromRGB(40, 40, 52)
	bar.BackgroundTransparency = 0.25
	local corner = Instance.new("UICorner")
	corner.CornerRadius = UDim.new(0.5, 0)
	corner.Parent = bar
	bar.Parent = floorBox
	local built = Instance.new("Frame")
	built.Name = "Built"
	built.BackgroundColor3 = Color3.fromRGB(90, 90, 110)
	built.BorderSizePixel = 0
	built.Size = UDim2.fromScale(context.tower.builtFloors / TowerConfig.TOTAL_FLOORS, 1)
	built.Parent = bar
	local fill = Instance.new("Frame")
	fill.Name = "Fill"
	fill.BackgroundColor3 = rgb(Palette.REACHED)
	fill.BorderSizePixel = 0
	fill.Size = UDim2.fromScale(0, 1)
	fill.Parent = bar
	-- Lager-Kerben (Form statt nur Farbe: kleine helle Striche).
	for floor in TowerConfig.CAMP_FLOORS do
		local notch = Instance.new("Frame")
		notch.BackgroundColor3 = Color3.new(1, 1, 1)
		notch.BorderSizePixel = 0
		notch.AnchorPoint = Vector2.new(0.5, 0.5)
		notch.Position = UDim2.fromScale(floor / TowerConfig.TOTAL_FLOORS, 0.5)
		notch.Size = UDim2.new(0, 3, 1.4, 0)
		notch.Parent = bar
	end

	local banner = label(gui, "Banner", UDim2.fromScale(0.5, 0.1), UDim2.fromScale(0.25, 0.2))
	banner.TextTransparency = 1
	banner.TextColor3 = rgb(Palette.REACHED)

	-- Vignette in eigener, nicht interaktiver ScreenGui ohne Insets: deckt den ganzen Bildschirm (CR-26).
	local overlay = Instance.new("ScreenGui")
	overlay.Name = "FallOverlay"
	overlay.ResetOnSpawn = false
	overlay.ScreenInsets = Enum.ScreenInsets.None
	overlay.DisplayOrder = -1
	local frame = Instance.new("Frame")
	frame.Name = "Vignette"
	frame.BackgroundColor3 = Color3.new(0, 0, 0)
	frame.BackgroundTransparency = 1
	frame.Size = UDim2.fromScale(1, 1)
	frame.Active = false
	frame.Parent = overlay
	vignette = frame

	local function render(state: ClientState.Snapshot, old: ClientState.Snapshot?)
		sparkCount.Text = tostring(state.sparks)
		floorText.Text = Strings.format("hud.floor", { state.currentFloor, TowerConfig.TOTAL_FLOORS })
		fill.Size = UDim2.fromScale(state.currentFloor / TowerConfig.TOTAL_FLOORS, 1)
		if old and state.sparks > old.sparks then
			popup.Text = "+" .. tostring(state.sparks - old.sparks)
			popup.TextTransparency = 0
			popup.Position = UDim2.new(0.55, 0, 0.9, 0)
			TweenService:Create(popup, TweenInfo.new(0.6), {
				TextTransparency = 1,
				Position = UDim2.new(0.55, 0, 0.2, 0),
			}):Play()
		end
		if old and state.currentFloor > old.currentFloor and state.currentFloor % TowerConfig.FLOORS_PER_ZONE == 0 then
			local zone = state.currentFloor // TowerConfig.FLOORS_PER_ZONE
			banner.Text = Strings.format("zone.cleared", { Strings.format("zone." .. zone .. ".name") })
			banner.TextTransparency = 0
			task.delay(3, function()
				TweenService:Create(banner, TweenInfo.new(0.5), { TextTransparency = 1 }):Play()
			end)
		end
	end

	render(ClientState.get(), nil)
	ClientState.onChanged(render)
	Strings.onReady(function()
		render(ClientState.get(), nil)
	end)
	local playerGui = context.player:WaitForChild("PlayerGui")
	overlay.Parent = playerGui
	gui.Parent = playerGui
end

return HudController
