--!strict
-- Entwerter-Rätsel im Postwagen (Compliance H-A3 b): 3 × 3 Lochfelder.
-- Jedes der drei Fahrkarten-Fragmente zeigt eine Reihe; das vollständige Muster öffnet das Tor.
-- Eingabe nur über Lochfelder (keine TextBox, H-A12). Maske: Reihe r, Spalte s → Bit 3·(r−1) + (s−1).

local Types = require("./Types")

local Puzzle = {}

Puzzle.MAX_MASK = 511

function Puzzle.isValidMask(value: unknown): boolean
	if type(value) ~= "number" then
		return false
	end
	local n = value :: number
	return n == n and n % 1 == 0 and n >= 0 and n <= Puzzle.MAX_MASK
end

function Puzzle.bit(row: number, column: number): number
	return bit32.lshift(1, 3 * (row - 1) + (column - 1))
end

function Puzzle.rowOf(mask: number, row: number): number
	return bit32.band(bit32.rshift(mask, 3 * (row - 1)), 7)
end

function Puzzle.toggle(mask: number, row: number, column: number): number
	return bit32.bxor(mask, Puzzle.bit(row, column))
end

function Puzzle.check(post: Types.PostLayout, mask: number): boolean
	return Puzzle.isValidMask(mask) and mask == post.code
end

-- Notizzettel: welche Reihen sind bekannt (Reihe → Lochmaske der Reihe)?
function Puzzle.notesFor(post: Types.PostLayout, readRows: { [number]: boolean }): { [number]: number }
	local notes: { [number]: number } = {}
	for _, fragment in post.fragments do
		if readRows[fragment.row] then
			notes[fragment.row] = fragment.holes
		end
	end
	return notes
end

return table.freeze(Puzzle)
