--!strict
-- UI-Bausteine im Fahrkarten-Stil (GDD S3): Cremepapier, Lochungen, Schreibmaschinenschrift.
-- Nur Frames, UIStroke und Systemschriften – keine Bild-Uploads (Compliance H-A14).

local Players = game:GetService("Players")

local Palette = require("@game/ReplicatedStorage/Shared/Visual/Palette")

local UiKit = {}

UiKit.FONT_TICKET = Enum.Font.SpecialElite
UiKit.FONT_STENCIL = Enum.Font.Michroma

-- fullscreen = true: über die Roblox-Leiste hinweg (Abdunkeln, Overlays); sonst im sicheren Bereich
-- unter der Roblox-Leiste und außerhalb von Notch/Rundungen (Playtest LP-12).
function UiKit.screen(name: string, order: number, fullscreen: boolean?): ScreenGui
	local gui = Instance.new("ScreenGui")
	gui.Name = name
	gui.ResetOnSpawn = false
	gui.IgnoreGuiInset = fullscreen ~= false
	if fullscreen == false then
		gui.ScreenInsets = Enum.ScreenInsets.DeviceSafeInsets
	end
	gui.DisplayOrder = order
	gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
	gui.Parent = Players.LocalPlayer:WaitForChild("PlayerGui")
	return gui
end

function UiKit.corner(parent: Instance, radius: number)
	local corner = Instance.new("UICorner")
	corner.CornerRadius = UDim.new(0, radius)
	corner.Parent = parent
end

function UiKit.stroke(parent: Instance, color: Color3, thickness: number)
	local stroke = Instance.new("UIStroke")
	stroke.Color = color
	stroke.Thickness = thickness
	stroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
	stroke.Parent = parent
end

-- Fahrkarte mit Lochrand links.
function UiKit.ticket(parent: Instance, size: UDim2, position: UDim2, anchor: Vector2?): Frame
	local frame = Instance.new("Frame")
	frame.Size = size
	frame.Position = position
	frame.AnchorPoint = anchor or Vector2.zero
	frame.BackgroundColor3 = Palette.ticket
	frame.BorderSizePixel = 0
	UiKit.corner(frame, 6)
	UiKit.stroke(frame, Palette.ticketInk, 1.5)
	for i = 0, 3 do
		local hole = Instance.new("Frame")
		hole.Size = UDim2.fromOffset(8, 8)
		hole.AnchorPoint = Vector2.new(0.5, 0.5)
		hole.Position = UDim2.new(0, 10, 0.2 + i * 0.2, 0)
		hole.BackgroundColor3 = Palette.hudShade
		hole.BorderSizePixel = 0
		UiKit.corner(hole, 4)
		hole.Parent = frame
	end
	local padding = Instance.new("UIPadding")
	padding.PaddingLeft = UDim.new(0, 24)
	padding.PaddingRight = UDim.new(0, 12)
	padding.PaddingTop = UDim.new(0, 8)
	padding.PaddingBottom = UDim.new(0, 8)
	padding.Parent = frame
	frame.Parent = parent
	return frame
end

function UiKit.label(
	parent: Instance,
	text: string,
	size: UDim2,
	position: UDim2,
	font: Enum.Font?,
	color: Color3?
): TextLabel
	local label = Instance.new("TextLabel")
	label.BackgroundTransparency = 1
	label.Size = size
	label.Position = position
	label.Text = text
	label.Font = font or UiKit.FONT_TICKET
	label.TextColor3 = color or Palette.ticketInk
	label.TextScaled = true
	label.TextWrapped = true
	label.Parent = parent
	return label
end

-- Knopf; modal = true gibt im Ich-Modus die Maus frei, solange der Knopf sichtbar ist.
function UiKit.button(parent: Instance, text: string, size: UDim2, position: UDim2, modal: boolean?): TextButton
	local button = Instance.new("TextButton")
	button.Size = size
	button.Position = position
	button.Text = text
	button.Font = UiKit.FONT_TICKET
	button.TextScaled = true
	button.TextColor3 = Palette.ticket
	button.BackgroundColor3 = Palette.ticketStamp
	button.AutoButtonColor = true
	button.Modal = modal == true
	button.Selectable = true
	UiKit.corner(button, 6)
	button.Parent = parent
	return button
end

-- Skaliert ein Fenster herunter, wenn es höher als `share` der Bildschirmhöhe wäre (kleine Handys).
function UiKit.fitHeight(frame: GuiObject, designHeight: number, share: number)
	local scale = Instance.new("UIScale")
	scale.Parent = frame
	local camera = workspace.CurrentCamera
	local function update()
		scale.Scale = math.min(1, camera.ViewportSize.Y * share / designHeight)
	end
	camera:GetPropertyChangedSignal("ViewportSize"):Connect(update)
	update()
end

return UiKit
