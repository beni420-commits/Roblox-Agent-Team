--!strict
-- Build-Metadaten. Einzige Quelle für Projekt- und Schema-Version.

local BuildInfo = table.freeze({
	projectName = "LanternLine",
	sprint = 1,
	dataSchemaVersion = 0, -- 0 = kein Speicherstand (MVP „Linie 1“ speichert nichts)
})

export type BuildInfo = typeof(BuildInfo)

return BuildInfo
