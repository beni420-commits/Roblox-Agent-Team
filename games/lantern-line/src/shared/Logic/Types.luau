--!strict
-- Gemeinsame Datentypen des Zug-Bauplans (reine Daten, keine Roblox-Instanzen).
-- Koordinaten eines Wagens sind lokal: x von 0 (hintere Tür) bis length (vordere Tür),
-- z von -INNER_WIDTH/2 bis +INNER_WIDTH/2, y ab Wagenboden. Weltkoordinate x = originX + x.

-- Hindernis (Möbel, Wände, Kisten) als achsenparallele Box. h = Höhe ab Boden.
export type Box = {
	cx: number,
	cz: number,
	sx: number,
	sz: number,
	h: number,
	kind: string,
}

-- Versteck (Schrank, Überseekoffer, Schließfach) für eine Person.
-- (fx, fz) = Blickrichtung der Tür (Einheitsvektor), (ax, az) = Standpunkt zum Hineingehen.
export type HidingSpot = {
	id: number,
	kind: string,
	x: number,
	z: number,
	sx: number,
	sz: number,
	h: number,
	fx: number,
	fz: number,
	ax: number,
	az: number,
}

-- Behälter (Koffer, Ablage, Schublade, Kiste). content: "none" | "stubs" | "key".
export type Container = {
	id: number,
	kind: string,
	x: number,
	y: number,
	z: number,
	ax: number,
	az: number,
	content: string,
	stubs: number,
}

export type Lamp = {
	x: number,
	z: number,
}

-- Ereignis beim Betreten des Wagens.
-- kind: "express" | "oncoming" (Gegenzug) | "inspector" | "chase" (Kofferlawine) | "conductor".
-- side: Fensterseite des Gegenzugs (±1). Nicht genutzte Felder sind 0.
export type Event = {
	kind: string,
	delay: number,
	speed: number,
	side: number,
	seed: number,
}

-- Grüne Augen des Blinden Passagiers (nur in dunklen Wagen); x/z lokal, y = Höhe.
export type Eye = {
	id: number,
	x: number,
	y: number,
	z: number,
}

export type NavNode = {
	x: number,
	z: number,
}

-- Fahrkarten-Fragment im Postwagen: zeigt eine Reihe (1–3) des 3×3-Lochmusters.
-- holes: Bitmaske der Reihe (Bit 0 = linke Spalte).
export type Fragment = {
	row: number,
	holes: number,
	x: number,
	y: number,
	z: number,
	ax: number,
	az: number,
}

-- Nur im Postwagen (Finale). code = 9-Bit-Lochmuster (Reihe 1 in Bits 0–2, Reihe 2 in 3–5, Reihe 3 in 6–8).
export type PostLayout = {
	nodes: { NavNode },
	edges: { { number } },
	fragments: { Fragment },
	code: number,
	validatorX: number,
	validatorZ: number,
	conductorStart: number,
}

export type Carriage = {
	index: number,
	kind: string,
	length: number,
	originX: number,
	dark: boolean,
	locked: boolean,
	obstacles: { Box },
	hidingSpots: { HidingSpot },
	containers: { Container },
	lamps: { Lamp },
	eyes: { Eye },
	chase: boolean, -- Teil der Verfolgungsjagd (Türen öffnen sich automatisch)
	event: Event?,
	post: PostLayout?,
}

export type Plan = {
	seed: number,
	carriages: { Carriage }, -- carriages[i + 1] ist Wagen i
	lastIndex: number,
}

return table.freeze({})
