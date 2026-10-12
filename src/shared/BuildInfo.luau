--!strict
-- Build-Metadaten. Einzige Quelle für Projekt- und Schema-Version.
-- Sprint 0: noch keine Spiellogik; das Konzept wartet auf Owner-Freigabe.

local BuildInfo = table.freeze({
	projectName = "RobloxAgentTeam",
	sprint = 0,
	dataSchemaVersion = 0, -- 0 = noch kein Live-Schema; v1 ist in docs/tech_notes.md entworfen
})

export type BuildInfo = typeof(BuildInfo)

return BuildInfo
