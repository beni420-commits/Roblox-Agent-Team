--!strict
-- Todes- und Schadensursachen mit Hinweisschlüsseln für die Fahrkarten-Notiz (§7, Compliance H-A2 c).
-- Die Texte stehen in der LocalizationTable (HINT_<CAUSE>_<n>), eigene Formulierungen.

local Causes = {}

Causes.LIST = table.freeze({ "express", "oncoming", "eyes", "inspector", "chase", "conductor" })

local VARIANTS = 2

local valid: { [string]: boolean } = {}
for _, cause in Causes.LIST do
	valid[cause] = true
end

function Causes.isValid(cause: string): boolean
	return valid[cause] == true
end

-- variant ∈ 1 … VARIANTS (z. B. erster und wiederholter Tod durch dieselbe Ursache).
function Causes.hintKey(cause: string, variant: number): string
	assert(valid[cause], "unknown cause " .. cause)
	local v = math.clamp(math.floor(variant), 1, VARIANTS)
	return string.format("HINT_%s_%d", string.upper(cause), v)
end

Causes.VARIANTS = VARIANTS

return table.freeze(Causes)
