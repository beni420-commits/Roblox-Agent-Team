--!strict
-- Farben und Materialien (GDD v0.2 §4 Art-Stil, UX A5). RGB 0–255 als Zahlen, damit das Modul
-- auch im Luau-CLI ladbar bleibt; Umwandlung in Color3 erfolgt im Builder bzw. Client.
-- Regeln: Neon nur für Ziele/Interaktives; Gold ist ausschließlich für Führung reserviert.

export type RGB = { read r: number, read g: number, read b: number }

local function rgb(r: number, g: number, b: number): RGB
	return table.freeze({ r = r, g = g, b = b })
end

local Palette = {}

Palette.GUIDANCE_GOLD = rgb(255, 196, 40) -- nur Führungs-Chevrons und Hilfe
Palette.SPARK = rgb(150, 235, 255) -- Funken: hell-cyan, bewusst nicht gold
Palette.GOAL_LIGHT = rgb(255, 255, 255) -- Lichtsäule über der nächsten Etagenplattform
Palette.HELPER = rgb(190, 225, 255)
Palette.REACHED = rgb(120, 255, 170)
Palette.BEACON = rgb(255, 245, 200)

local zones: { [string]: { [string]: RGB } } = {
	meadow = {
		platform = rgb(126, 186, 104),
		platformAlt = rgb(104, 160, 88),
		conveyor = rgb(96, 130, 170),
		jumpPad = rgb(255, 120, 70),
		landing = rgb(236, 226, 196),
		camp = rgb(186, 140, 96),
		gate = rgb(245, 245, 240),
		ground = rgb(88, 140, 76),
		column = rgb(214, 212, 222),
	},
}
Palette.ZONES = table.freeze(zones)

local materials: { [string]: string } = {
	platform = "SmoothPlastic",
	conveyor = "DiamondPlate",
	jumpPad = "Neon",
	landing = "SmoothPlastic",
	camp = "WoodPlanks",
	gate = "SmoothPlastic",
	helper = "Glass",
	ground = "Grass",
	column = "Marble",
}
Palette.MATERIALS = table.freeze(materials)

return table.freeze(Palette)
