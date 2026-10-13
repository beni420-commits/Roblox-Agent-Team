--!strict
-- Farbwelt „Laternen-Noir“ (GDD §3): Teal-Schwarz, warmes Laternenlicht, Cremepapier.
-- Jedes Wesen hat eine eigene Lichtfarbe UND ein zweites Merkmal (Form/Bewegung, Compliance H-A11).

local Palette = table.freeze({
	-- Zug
	wall = Color3.fromRGB(30, 44, 48),
	wallTrim = Color3.fromRGB(52, 70, 72),
	floor = Color3.fromRGB(58, 40, 30),
	ceiling = Color3.fromRGB(22, 30, 34),
	wood = Color3.fromRGB(74, 50, 36),
	woodDark = Color3.fromRGB(48, 33, 25),
	fabric = Color3.fromRGB(46, 62, 66),
	cream = Color3.fromRGB(226, 214, 186),
	metal = Color3.fromRGB(60, 66, 70),
	lockerGreen = Color3.fromRGB(44, 64, 54),
	leather = Color3.fromRGB(92, 58, 38),
	glass = Color3.fromRGB(14, 20, 30),
	stencil = Color3.fromRGB(236, 236, 228),
	lampOn = Color3.fromRGB(255, 184, 104),
	lampOff = Color3.fromRGB(40, 38, 36),
	lampLight = Color3.fromRGB(255, 196, 132),

	-- Bahnsteig
	platform = Color3.fromRGB(70, 72, 76),
	platformEdge = Color3.fromRGB(230, 230, 220),
	trainOutside = Color3.fromRGB(26, 46, 52),

	-- Wesen (Licht + Form)
	express = Color3.fromRGB(235, 240, 255), -- weißes Scheinwerferlicht, schwingende Lampen
	oncoming = Color3.fromRGB(150, 190, 255), -- bläuliches Seitenlicht, Pfeil im HUD
	eyes = Color3.fromRGB(90, 255, 140), -- zwei grüne Punkte
	inspectorGo = Color3.fromRGB(255, 190, 90), -- runde Kelle
	inspectorStop = Color3.fromRGB(220, 70, 60), -- Kelle mit Streifen (Rot nur klein, H-A10 c)
	chase = Color3.fromRGB(200, 120, 60), -- rumpelndes Gepäck, orange Lampen dahinter
	conductorBeam = Color3.fromRGB(255, 226, 170),

	-- UI (Fahrkarten-Ästhetik)
	ticket = Color3.fromRGB(236, 226, 200),
	ticketInk = Color3.fromRGB(44, 40, 36),
	ticketStamp = Color3.fromRGB(56, 92, 110),
	hudShade = Color3.fromRGB(8, 12, 14),
})

export type Palette = typeof(Palette)

return Palette
