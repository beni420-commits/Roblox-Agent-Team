--!strict
-- Build-Metadaten. Einzige Quelle für Projekt- und Schema-Version.

local BuildInfo = table.freeze({
	projectName = "Schwungturm",
	sprint = 1,
	dataSchemaVersion = 0, -- 0 = noch kein Speicherstand (Schema v1 kommt in Sprint 2, tech_notes §6.4)
})

export type BuildInfo = typeof(BuildInfo)

return BuildInfo
