--!strict
-- Gemeinsamer Kontext für alle Client-Controller.

local TowerGenerator = require("@game/ReplicatedStorage/Shared/Logic/TowerGenerator")

export type Context = {
	player: Player,
	tower: TowerGenerator.TowerSpec,
	fire: (name: string, ...any) -> (),
	fxFolder: Folder,
}

return {}
