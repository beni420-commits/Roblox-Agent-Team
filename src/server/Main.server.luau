--!strict
-- Server-Einstiegspunkt: Turm erzeugen und bauen, Remotes registrieren, Spieler verwalten.
-- Reihenfolge ist wichtig (tech_notes §2): Welt → Turm → Netz → Spieler.

local TowerConfig = require("@game/ReplicatedStorage/Shared/Logic/TowerConfig")
local TowerGenerator = require("@game/ReplicatedStorage/Shared/Logic/TowerGenerator")

local NetService = require("./Services/NetService")
local PlayerService = require("./Services/PlayerService")
local TowerBuilder = require("./TowerBuilder")
local WorldSetup = require("./WorldSetup")

local seed = TowerConfig.FIRST_RUN_SEED
local tower = TowerGenerator.generate(seed)

WorldSetup.apply()
TowerBuilder.build(tower, workspace)
workspace:SetAttribute("TowerSeed", seed)
workspace:SetAttribute("BuiltFloors", tower.builtFloors)

local handlers = PlayerService.init(tower, NetService)
NetService.init(handlers)
PlayerService.start()
