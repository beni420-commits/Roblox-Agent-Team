--!strict
-- HUD im Fahrkarten-Stil: Wagennummer, Lebens-Fahrkarte (10 Lochfelder), Schlüssel, Schleichen,
-- Einstellungen, Kälte, Kontrolleur-Kelle (Form + Text + Farbe), Gegenzug-Pfeil, Notizzettel, Hinweise.
-- Signale nie nur über Farbe (Compliance H-A11); keine großflächigen Rot-/Weiß-Blitze (H-A10).

local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")

local Context = require("./Context")
local GameConfig = require("@game/ReplicatedStorage/Shared/Config/GameConfig")
local Palette = require("@game/ReplicatedStorage/Shared/Visual/Palette")
local Settings = require("./Settings")
local SettingsPanel = require("./SettingsPanel")
local Strings = require("./Strings")
local TrainView = require("./TrainView")
local UiKit = require("./UiKit")

local Hud = {}

local gui: ScreenGui
local carriageLabel: TextLabel
local healthHoles: { Frame } = {}
local keyTicket: Frame
local keyLabel: TextLabel
local sneakLabel: TextLabel
local settingsButton: TextButton
local coldFrame: Frame
local coldLabel: TextLabel
local signFrame: Frame
local signShape: Frame
local signLabel: TextLabel
local arrows: { [string]: TextLabel } = {}
local warnBar: Frame
local notesPanel: Frame
local noteCells: { { Frame } } = {}
local toastLabel: TextLabel
local shade: Frame

local oncomingSide = 0
local oncomingUntil = 0
local warnColor: Color3? = nil
local warnUntil = 0

local function refreshCarriage()
	local index = workspace:GetAttribute("RunCarriage")
	local inRun = Context.inRun()
	carriageLabel.Visible = inRun
	if type(index) == "number" then
		carriageLabel.Text = Strings.format("hud.carriage", { string.format("%02d", index) })
	end
	notesPanel.Visible = inRun and index == GameConfig.RUN_LAST_CARRIAGE
end

local function refreshKey()
	local door = workspace:GetAttribute("KeyDoor")
	keyTicket.Visible = Context.inRun() and type(door) == "number" and door > 0
	keyLabel.Text = Strings.format("hud.key")
end

local function refreshNotes()
	for row = 1, 3 do
		local holes = workspace:GetAttribute("Note" .. row)
		for column = 1, 3 do
			local cell = noteCells[row][column]
			if type(holes) ~= "number" or holes < 0 then
				cell.BackgroundColor3 = Palette.cream:Lerp(Palette.hudShade, 0.35) -- unbekannt
			elseif bit32.band(holes, bit32.lshift(1, column - 1)) ~= 0 then
				cell.BackgroundColor3 = Palette.hudShade -- gelocht
			else
				cell.BackgroundColor3 = Palette.ticket
			end
		end
	end
end

local function refreshHealth(health: number)
	local intact = math.clamp(math.ceil(health / (GameConfig.MAX_HEALTH / #healthHoles)), 0, #healthHoles)
	for i, hole in healthHoles do
		hole.BackgroundColor3 = if i <= intact then Palette.ticket else Palette.hudShade
	end
end

local function watchCharacter(character: Model)
	local humanoid = character:WaitForChild("Humanoid", 10)
	if humanoid and humanoid:IsA("Humanoid") then
		refreshHealth(humanoid.Health)
		humanoid.HealthChanged:Connect(refreshHealth)
	end
end

local function buildHealth()
	local ticket = UiKit.ticket(gui, UDim2.fromOffset(250, 46), UDim2.new(0, 16, 1, -16), Vector2.new(0, 1))
	local layout = Instance.new("UIListLayout")
	layout.FillDirection = Enum.FillDirection.Horizontal
	layout.Padding = UDim.new(0, 6)
	layout.VerticalAlignment = Enum.VerticalAlignment.Center
	layout.Parent = ticket
	for _ = 1, 10 do
		local hole = Instance.new("Frame")
		hole.Size = UDim2.fromOffset(14, 14)
		hole.BackgroundColor3 = Palette.ticket
		hole.BorderSizePixel = 0
		UiKit.corner(hole, 7)
		UiKit.stroke(hole, Palette.ticketInk, 1.5)
		hole.Parent = ticket
		table.insert(healthHoles, hole)
	end
end

local function buildSign()
	signFrame = UiKit.ticket(gui, UDim2.fromOffset(190, 64), UDim2.new(0.5, 0, 0, 16), Vector2.new(0.5, 0))
	signFrame.Visible = false
	signShape = Instance.new("Frame")
	signShape.Size = UDim2.fromOffset(40, 40)
	signShape.Position = UDim2.new(0, 0, 0.5, -20)
	signShape.BorderSizePixel = 0
	signShape.Parent = signFrame
	signLabel = UiKit.label(signFrame, "", UDim2.new(1, -50, 1, 0), UDim2.fromOffset(50, 0))
end

local function setSign(phase: string?)
	if phase == nil or phase == "gone" then
		signFrame.Visible = false
		return
	end
	signFrame.Visible = true
	local corner = signShape:FindFirstChildOfClass("UICorner")
	if phase == "stop" then
		-- Streifen-Kelle: breite, flache Form
		signShape.Size = UDim2.fromOffset(44, 14)
		signShape.Position = UDim2.new(0, 0, 0.5, -7)
		signShape.BackgroundColor3 = Palette.inspectorStop
		if corner then
			corner:Destroy()
		end
		signLabel.Text = Strings.format("hud.standstill")
	else
		-- runde Kelle (bei „warn“ pulsiert die Form langsam, ≤ 1 Hz)
		local pulse = if phase == "warn" then 0.75 + 0.25 * math.cos(os.clock() * math.pi * 1.6) else 1
		signShape.Size = UDim2.fromOffset(40 * pulse, 40 * pulse)
		signShape.Position = UDim2.new(0, 20 - 20 * pulse, 0.5, -20 * pulse)
		signShape.BackgroundColor3 = Palette.inspectorGo
		if corner == nil then
			UiKit.corner(signShape, 20)
		end
		signLabel.Text = Strings.format("hud.walk")
	end
end

local inspectorModel: Model? = nil

local function inspectorPhase(): string?
	local root = Context.root()
	local model = inspectorModel
	if root == nil or model == nil or model.Parent == nil then
		return nil
	end
	if model:GetAttribute("Carriage") ~= TrainView.carriageAt(root.Position.X) then
		return nil
	end
	local phase = model:GetAttribute("Phase")
	return if type(phase) == "string" then phase else nil
end

local function update()
	local t = Context.now()
	setSign(if Context.inRun() then inspectorPhase() else nil)
	-- Gegenzug-Pfeil auf der Bildschirmseite, von der das Licht kommt
	local showLeft, showRight = false, false
	if oncomingSide ~= 0 and t <= oncomingUntil then
		local camera = workspace.CurrentCamera
		local danger = Vector3.new(0, 0, oncomingSide)
		local right = camera.CFrame.RightVector:Dot(danger)
		showRight = right > 0.2
		showLeft = right < -0.2
	end
	arrows.left.Visible = showLeft
	arrows.right.Visible = showRight
	-- Warnleiste am unteren Rand (Licht „von hinten“), pulsiert höchstens 1 Hz
	if warnColor and t <= warnUntil then
		warnBar.Visible = true
		warnBar.BackgroundColor3 = warnColor :: Color3
		local pulse = if Settings.reducedFlicker() then 0.5 else 0.35 + 0.25 * math.cos(os.clock() * math.pi * 2)
		warnBar.BackgroundTransparency = pulse
	else
		warnBar.Visible = false
	end
	settingsButton.Visible = not SettingsPanel.isOpen()
	local stroke = settingsButton:FindFirstChildOfClass("UIStroke")
	if stroke then
		-- Am Bahnsteig auf die Einstellungen aufmerksam machen (H-A9)
		stroke.Transparency = if workspace:GetAttribute("RunPhase") == "lobby"
			then 0.3 + 0.3 * math.cos(os.clock() * 3)
			else 1
	end
end

function Hud.init()
	gui = UiKit.screen("Hud", 10)
	shade = Instance.new("Frame")
	shade.Size = UDim2.fromScale(1, 1)
	shade.BackgroundColor3 = Palette.hudShade
	shade.BackgroundTransparency = 1
	shade.BorderSizePixel = 0
	shade.Parent = gui

	carriageLabel =
		UiKit.label(gui, "", UDim2.fromOffset(240, 44), UDim2.fromOffset(16, 16), UiKit.FONT_STENCIL, Palette.stencil)
	carriageLabel.TextXAlignment = Enum.TextXAlignment.Left
	buildHealth()

	keyTicket = UiKit.ticket(gui, UDim2.fromOffset(150, 40), UDim2.new(0, 276, 1, -16), Vector2.new(0, 1))
	keyLabel = UiKit.label(keyTicket, "", UDim2.fromScale(1, 1), UDim2.fromScale(0, 0))

	local sneakTicket = UiKit.ticket(gui, UDim2.fromOffset(150, 40), UDim2.new(0, 16, 1, -70), Vector2.new(0, 1))
	sneakTicket.Visible = false
	sneakLabel = UiKit.label(sneakTicket, "", UDim2.fromScale(1, 1), UDim2.fromScale(0, 0))

	settingsButton = UiKit.button(gui, "", UDim2.fromOffset(170, 36), UDim2.new(1, -16, 0, 16), false)
	settingsButton.AnchorPoint = Vector2.new(1, 0)
	UiKit.stroke(settingsButton, Palette.lampOn, 3)
	settingsButton.Activated:Connect(SettingsPanel.toggle)
	SettingsPanel.init(gui)

	coldFrame = Instance.new("Frame")
	coldFrame.Size = UDim2.fromScale(1, 1)
	coldFrame.BackgroundTransparency = 1
	coldFrame.Visible = false
	coldFrame.Parent = gui
	local frost = Instance.new("UIStroke")
	frost.Color = Color3.fromRGB(200, 225, 240)
	frost.Thickness = 40
	frost.Transparency = 0.45
	frost.Parent = coldFrame
	coldLabel = UiKit.label(
		coldFrame,
		"",
		UDim2.fromOffset(360, 40),
		UDim2.new(0.5, -180, 0.2, 0),
		UiKit.FONT_TICKET,
		Palette.stencil
	)

	buildSign()

	local arrowSpecs: { { name: string, text: string, x: number, anchor: number } } = {
		{ name = "left", text = "‹‹", x = 0.02, anchor = 0 },
		{ name = "right", text = "››", x = 0.98, anchor = 1 },
	}
	for _, spec in arrowSpecs do
		local arrow = UiKit.label(
			gui,
			spec.text,
			UDim2.fromOffset(90, 160),
			UDim2.fromScale(spec.x, 0.5),
			UiKit.FONT_STENCIL,
			Palette.oncoming
		)
		arrow.AnchorPoint = Vector2.new(spec.anchor, 0.5)
		arrow.Visible = false
		arrows[spec.name] = arrow
	end

	warnBar = Instance.new("Frame")
	warnBar.Size = UDim2.new(1, 0, 0, 26)
	warnBar.Position = UDim2.fromScale(0, 1)
	warnBar.AnchorPoint = Vector2.new(0, 1)
	warnBar.BorderSizePixel = 0
	warnBar.Visible = false
	local gradient = Instance.new("UIGradient")
	gradient.Rotation = -90
	gradient.Transparency = NumberSequence.new(0, 1)
	gradient.Parent = warnBar
	warnBar.Parent = gui

	notesPanel = UiKit.ticket(gui, UDim2.fromOffset(150, 170), UDim2.new(1, -16, 0, 64), Vector2.new(1, 0))
	notesPanel.Visible = false
	UiKit.label(notesPanel, Strings.format("notes.title"), UDim2.new(1, 0, 0, 24), UDim2.fromScale(0, 0))
	for row = 1, 3 do
		noteCells[row] = {}
		for column = 1, 3 do
			local cell = Instance.new("Frame")
			cell.Size = UDim2.fromOffset(28, 28)
			cell.Position = UDim2.fromOffset(8 + (column - 1) * 36, 32 + (row - 1) * 40)
			cell.BorderSizePixel = 0
			UiKit.corner(cell, 14)
			UiKit.stroke(cell, Palette.ticketInk, 1.5)
			cell.Parent = notesPanel
			noteCells[row][column] = cell
		end
	end

	toastLabel = UiKit.label(
		gui,
		"",
		UDim2.fromOffset(320, 40),
		UDim2.new(0.5, -160, 0.72, 0),
		UiKit.FONT_TICKET,
		Palette.stencil
	)
	toastLabel.TextTransparency = 1

	local function relabel()
		settingsButton.Text = Strings.format("hud.settings") .. "  [M]"
		coldLabel.Text = Strings.format("hud.cold")
		Hud.setSneak(false)
		refreshCarriage()
		refreshKey()
	end
	Strings.onReady(relabel)
	relabel()
	refreshNotes()

	for _, name in { "RunCarriage", "RunPhase" } do
		workspace:GetAttributeChangedSignal(name):Connect(function()
			refreshCarriage()
			refreshKey()
		end)
	end
	workspace:GetAttributeChangedSignal("KeyDoor"):Connect(refreshKey)
	Context.player:GetAttributeChangedSignal("InRun"):Connect(function()
		refreshCarriage()
		refreshKey()
	end)
	for row = 1, 3 do
		workspace:GetAttributeChangedSignal("Note" .. row):Connect(refreshNotes)
	end
	workspace.DescendantAdded:Connect(function(descendant)
		if descendant.Name == "Inspector" and descendant:IsA("Model") then
			inspectorModel = descendant
		end
	end)
	Context.player.CharacterAdded:Connect(watchCharacter)
	if Context.player.Character then
		task.spawn(watchCharacter, Context.player.Character)
	end
	RunService.RenderStepped:Connect(update)
end

function Hud.setSneak(on: boolean)
	local ticket = sneakLabel.Parent
	if ticket and ticket:IsA("Frame") then
		ticket.Visible = on
	end
	sneakLabel.Text = Strings.format("hud.sneak")
end

function Hud.showCold(on: boolean)
	coldFrame.Visible = on
end

function Hud.setOncoming(side: number, untilTime: number)
	oncomingSide = side
	oncomingUntil = untilTime
end

function Hud.setWarning(color: Color3, untilTime: number)
	warnColor = color
	warnUntil = untilTime
end

function Hud.toast(text: string)
	toastLabel.Text = text
	toastLabel.TextTransparency = 0
	TweenService:Create(
		toastLabel,
		TweenInfo.new(1.6, Enum.EasingStyle.Quad, Enum.EasingDirection.In, 0, false, 1),
		{ TextTransparency = 1 }
	):Play()
end

-- Kurzes Abdunkeln bei Schaden (kein Rot, kein Weiß; im Sanften Modus schwächer).
function Hud.damage()
	shade.BackgroundTransparency = if Settings.gentle() then 0.8 else 0.55
	TweenService:Create(shade, TweenInfo.new(0.4), { BackgroundTransparency = 1 }):Play()
end

-- Abblenden (Tod): höchstens ein kurzer getönter Blitz, dann dunkel; Sanfter Modus ohne Blitz.
function Hud.fadeOut(tint: Color3?)
	if tint and not Settings.gentle() then
		shade.BackgroundColor3 = tint
		shade.BackgroundTransparency = 0.6
		task.wait(0.2)
	end
	shade.BackgroundColor3 = Palette.hudShade
	TweenService:Create(shade, TweenInfo.new(0.6), { BackgroundTransparency = 0.15 }):Play()
end

function Hud.clearShade()
	TweenService:Create(shade, TweenInfo.new(0.5), { BackgroundTransparency = 1 }):Play()
end

function Hud.gui(): ScreenGui
	return gui
end

return Hud
