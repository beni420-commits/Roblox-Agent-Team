--!strict
-- HUD im Fahrkarten-Stil: Wagennummer, Lebens-Fahrkarte (10 Lochfelder), Schlüssel, Schleichen,
-- Einstellungen, Kälte, Kontrolleur-Kelle (Form + Text + Farbe), Gegenzug-Pfeile, Warnleiste mit Symbol,
-- Notizzettel, Hinweise. Alles oben im sicheren Bereich, damit unten Platz für die Daumen bleibt (LP-12).
-- Signale nie nur über Farbe (Compliance H-A11); keine großflächigen Rot-/Weiß-Blitze (H-A10).

local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")

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
local overlay: ScreenGui
local carriageLabel: TextLabel
local healthHoles: { Frame } = {}
local keyTicket: Frame
local keyLabel: TextLabel
local sneakTicket: Frame
local sneakLabel: TextLabel
local settingsButton: TextButton
local coldFrame: Frame
local coldLabel: TextLabel
local signFrame: Frame
local signShape: Frame
local signLabel: TextLabel
local signTimer: Frame
local arrows: { [string]: TextLabel } = {}
local warnBar: Frame
local warnIcons: { [string]: GuiObject } = {}
local notesPanel: Frame
local noteCells: { { Frame } } = {}
local toastLabel: TextLabel
local shade: Frame

local oncomingSide = 0
local oncomingUntil = 0
local warnColor: Color3? = nil
local warnKind = ""
local warnUntil = 0
local inspectorModel: Model? = nil
local warnStartedAt = 0

local function keyboardInput(): boolean
	local last = UserInputService:GetLastInputType()
	return last == Enum.UserInputType.Keyboard
		or last == Enum.UserInputType.MouseMovement
		or last == Enum.UserInputType.MouseButton1
		or last == Enum.UserInputType.MouseButton2
		or last == Enum.UserInputType.MouseWheel
end

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

local function refreshSettingsLabel()
	-- „[M]“ nur, wenn gerade Tastatur/Maus benutzt wird (Playtest LP-18)
	local suffix = if keyboardInput() then "  [M]" else ""
	settingsButton.Text = Strings.format("hud.settings") .. suffix
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
	local ticket = UiKit.ticket(gui, UDim2.fromOffset(250, 46), UDim2.fromOffset(16, 56))
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
	signFrame = UiKit.ticket(gui, UDim2.fromOffset(230, 70), UDim2.new(0.5, 0, 0, 8), Vector2.new(0.5, 0))
	signFrame.Visible = false
	signShape = Instance.new("Frame")
	signShape.Size = UDim2.fromOffset(40, 40)
	signShape.Position = UDim2.new(0, 0, 0.5, -20)
	signShape.BorderSizePixel = 0
	signShape.Parent = signFrame
	signLabel = UiKit.label(signFrame, "", UDim2.new(1, -50, 0.7, 0), UDim2.fromOffset(50, 0))
	signTimer = Instance.new("Frame")
	signTimer.AnchorPoint = Vector2.new(0, 1)
	signTimer.Position = UDim2.new(0, 50, 1, 0)
	signTimer.Size = UDim2.new(1, -50, 0, 6)
	signTimer.BackgroundColor3 = Palette.ticketInk
	signTimer.BorderSizePixel = 0
	signTimer.Parent = signFrame
end

local function shapeAs(kind: string)
	local corner = signShape:FindFirstChildOfClass("UICorner")
	local stroke = signShape:FindFirstChildOfClass("UIStroke")
	if corner then
		corner:Destroy()
	end
	if stroke then
		stroke:Destroy()
	end
	signShape.BackgroundTransparency = 0
	if kind == "stripe" then
		signShape.Size = UDim2.fromOffset(44, 14)
		signShape.Position = UDim2.new(0, 0, 0.5, -7)
		signShape.BackgroundColor3 = Palette.inspectorStop
	elseif kind == "half" then
		-- Achtung: halbe Kelle (flaches, abgerundetes Feld mit Rand), ohne Puls (LP-01)
		signShape.Size = UDim2.fromOffset(40, 22)
		signShape.Position = UDim2.new(0, 0, 0.5, -11)
		signShape.BackgroundColor3 = Palette.inspectorGo:Lerp(Palette.inspectorStop, 0.5)
		UiKit.corner(signShape, 11)
		UiKit.stroke(signShape, Palette.ticketInk, 2)
	elseif kind == "stamp" then
		signShape.Size = UDim2.fromOffset(36, 36)
		signShape.Position = UDim2.new(0, 2, 0.5, -18)
		signShape.BackgroundTransparency = 1
		UiKit.stroke(signShape, Palette.ticketStamp, 4)
	else
		signShape.Size = UDim2.fromOffset(40, 40)
		signShape.Position = UDim2.new(0, 0, 0.5, -20)
		signShape.BackgroundColor3 = Palette.inspectorGo
		UiKit.corner(signShape, 20)
	end
end

local lastSignKind = ""

local function setSign(phase: string?, checked: boolean)
	if phase == nil or phase == "gone" then
		signFrame.Visible = false
		lastSignKind = ""
		return
	end
	signFrame.Visible = true
	local kind, text = "round", "hud.walk"
	if checked then
		kind, text = "stamp", "hud.checked"
	elseif phase == "stop" then
		kind, text = "stripe", "hud.standstill"
	elseif phase == "warn" then
		kind, text = "half", "hud.getready"
	end
	if kind ~= lastSignKind then
		lastSignKind = kind
		shapeAs(kind)
		-- Text nur beim Wechsel formatieren, nicht in jedem Bild (LL-23)
		signLabel.Text = Strings.format(text)
	end
	-- Ablaufbalken in der Achtungsphase (wie viel Zeit bis „Stillstehen“)
	if kind == "half" then
		local left = math.clamp(1 - (os.clock() - warnStartedAt) / GameConfig.INSPECTOR_WARN, 0, 1)
		signTimer.Visible = true
		signTimer.Size = UDim2.new(left, -50 * left, 0, 6)
	else
		signTimer.Visible = false
	end
end

local function inspectorState(): (string?, boolean)
	local root = Context.root()
	local model = inspectorModel
	if root == nil or model == nil or model.Parent == nil then
		return nil, false
	end
	local carriage = model:GetAttribute("Carriage")
	if carriage ~= TrainView.carriageAt(root.Position.X) then
		return nil, false
	end
	local phase = model:GetAttribute("Phase")
	local checked = Context.player:GetAttribute("CheckedIn") == carriage
	return if type(phase) == "string" then phase else nil, checked
end

local function update()
	local t = Context.now()
	if Context.inRun() then
		setSign(inspectorState())
	else
		setSign(nil, false)
	end
	-- Gegenzug: Pfeile am Rand der Lichtseite, die zur sicheren Seite zeigen (LP-09)
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
	-- Warnleiste oben mit Symbol je Wesen; pulsiert höchstens 1 Hz, mit „Flackern reduzieren“ ruhig
	if warnColor and t <= warnUntil then
		warnBar.Visible = true
		warnBar.BackgroundColor3 = warnColor :: Color3
		warnBar.BackgroundTransparency = if Settings.reducedFlicker()
			then 0.35
			else 0.3 + 0.2 * math.cos(os.clock() * math.pi * 2)
		for kind, icon in warnIcons do
			icon.Visible = kind == warnKind
		end
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

local function buildWarnBar()
	warnBar = Instance.new("Frame")
	warnBar.Size = UDim2.new(1, 0, 0, 34)
	warnBar.Position = UDim2.fromScale(0, 0)
	warnBar.BorderSizePixel = 0
	warnBar.Visible = false
	local gradient = Instance.new("UIGradient")
	gradient.Rotation = 90
	gradient.Transparency = NumberSequence.new(0, 1)
	gradient.Parent = warnBar
	warnBar.Parent = overlay
	-- Express: Schrank-Piktogramm (Rechteck mit zwei Schlitzen) = „verstecken“
	local wardrobe = Instance.new("Frame")
	wardrobe.Size = UDim2.fromOffset(18, 28)
	wardrobe.Position = UDim2.new(0.5, -9, 0, 3)
	wardrobe.BackgroundColor3 = Palette.ticketInk
	wardrobe.BorderSizePixel = 0
	for i = 0, 1 do
		local slit = Instance.new("Frame")
		slit.Size = UDim2.new(0.7, 0, 0, 2)
		slit.Position = UDim2.new(0.15, 0, 0, 8 + i * 5)
		slit.BackgroundColor3 = Palette.ticket
		slit.BorderSizePixel = 0
		slit.Parent = wardrobe
	end
	wardrobe.Parent = warnBar
	warnIcons.express = wardrobe
	-- Kofferlawine: Doppelpfeile nach vorn = „laufen“
	local run = UiKit.label(
		warnBar,
		"»»»",
		UDim2.fromOffset(90, 30),
		UDim2.new(0.5, -45, 0, 2),
		UiKit.FONT_STENCIL,
		Palette.ticketInk
	)
	warnIcons.chase = run
end

function Hud.init()
	gui = UiKit.screen("Hud", 10, false)
	overlay = UiKit.screen("HudOverlay", 9)
	shade = Instance.new("Frame")
	shade.Size = UDim2.fromScale(1, 1)
	shade.BackgroundColor3 = Palette.hudShade
	shade.BackgroundTransparency = 1
	shade.BorderSizePixel = 0
	shade.Parent = overlay

	carriageLabel =
		UiKit.label(gui, "", UDim2.fromOffset(240, 40), UDim2.fromOffset(16, 8), UiKit.FONT_STENCIL, Palette.stencil)
	carriageLabel.TextXAlignment = Enum.TextXAlignment.Left
	buildHealth()

	keyTicket = UiKit.ticket(gui, UDim2.fromOffset(150, 40), UDim2.fromOffset(276, 59))
	keyLabel = UiKit.label(keyTicket, "", UDim2.fromScale(1, 1), UDim2.fromScale(0, 0))

	sneakTicket = UiKit.ticket(gui, UDim2.fromOffset(150, 40), UDim2.fromOffset(16, 110))
	sneakTicket.Visible = false
	sneakLabel = UiKit.label(sneakTicket, "", UDim2.fromScale(1, 1), UDim2.fromScale(0, 0))

	settingsButton = UiKit.button(gui, "", UDim2.fromOffset(190, 36), UDim2.new(1, -16, 0, 8), false)
	settingsButton.AnchorPoint = Vector2.new(1, 0)
	UiKit.stroke(settingsButton, Palette.lampOn, 3)
	settingsButton.Activated:Connect(SettingsPanel.toggle)
	SettingsPanel.init(gui)

	coldFrame = Instance.new("Frame")
	coldFrame.Size = UDim2.fromScale(1, 1)
	coldFrame.BackgroundTransparency = 1
	coldFrame.Visible = false
	coldFrame.Parent = overlay
	local frost = Instance.new("UIStroke")
	frost.Color = Color3.fromRGB(200, 225, 240)
	frost.Thickness = 40
	frost.Transparency = 0.45
	frost.BorderStrokePosition = Enum.BorderStrokePosition.Inner -- Rand innen, sonst außerhalb des Bildes (LL-19)
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

	-- Pfeile stehen am Rand der Lichtseite und zeigen weg vom Licht.
	local arrowSpecs: { { name: string, text: string, x: number, anchor: number } } = {
		{ name = "left", text = "››", x = 0.02, anchor = 0 },
		{ name = "right", text = "‹‹", x = 0.98, anchor = 1 },
	}
	for _, spec in arrowSpecs do
		local arrow = UiKit.label(
			overlay,
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

	buildWarnBar()

	notesPanel = UiKit.ticket(gui, UDim2.fromOffset(150, 170), UDim2.new(1, -16, 0, 52), Vector2.new(1, 0))
	notesPanel.Visible = false
	local notesTitle =
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
		overlay,
		"",
		UDim2.fromOffset(420, 40),
		UDim2.new(0.5, -210, 0.7, 0),
		UiKit.FONT_TICKET,
		Palette.stencil
	)
	toastLabel.TextTransparency = 1

	local function relabel()
		refreshSettingsLabel()
		coldLabel.Text = Strings.format("hud.cold")
		notesTitle.Text = Strings.format("notes.title")
		Hud.setSneak(sneakTicket.Visible)
		refreshCarriage()
		refreshKey()
		lastSignKind = "" -- Kellen-Text nach dem Laden des Translators neu setzen
	end
	Strings.onReady(relabel)
	relabel()
	refreshNotes()
	UserInputService.LastInputTypeChanged:Connect(refreshSettingsLabel)

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
			descendant:GetAttributeChangedSignal("Phase"):Connect(function()
				if descendant:GetAttribute("Phase") == "warn" then
					warnStartedAt = os.clock()
				end
			end)
		end
	end)
	-- Rückmeldungen ohne eigenes Fenster (Playtest LP-16)
	Context.onPersonal("ruck", function()
		Hud.toast(Strings.format("toast.ruck"))
	end)
	Context.onWorld("solved", function()
		Hud.toast(Strings.format("validator.right"))
	end)
	Context.player.CharacterAdded:Connect(watchCharacter)
	if Context.player.Character then
		task.spawn(watchCharacter, Context.player.Character)
	end
	RunService.RenderStepped:Connect(update)
end

function Hud.setSneak(on: boolean)
	sneakTicket.Visible = on
	sneakLabel.Text = Strings.format("hud.sneak")
end

function Hud.showCold(on: boolean)
	coldFrame.Visible = on
end

function Hud.setOncoming(side: number, untilTime: number)
	oncomingSide = side
	oncomingUntil = untilTime
end

-- kind: "express" | "chase" (Symbol in der Leiste, zweites Merkmal neben der Farbe, LP-08)
function Hud.setWarning(color: Color3, untilTime: number, kind: string)
	warnColor = color
	warnUntil = untilTime
	warnKind = kind
end

function Hud.toast(text: string)
	toastLabel.Text = text
	toastLabel.TextTransparency = 0
	TweenService:Create(
		toastLabel,
		TweenInfo.new(1.6, Enum.EasingStyle.Quad, Enum.EasingDirection.In, 0, false, 1.5),
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
