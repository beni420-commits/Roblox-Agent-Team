--!strict
-- Server-Einstiegspunkt „Lantern Line – Der Nachtzug“: Welt → Spieler → Netz → Lauf.

local NetService = require("./Services/NetService")
local PlayerService = require("./Services/PlayerService")
local RunController = require("./Services/RunController")
local WorldSetup = require("./WorldSetup")

WorldSetup.apply()
PlayerService.init()
NetService.init(RunController.handlers())
RunController.start()
