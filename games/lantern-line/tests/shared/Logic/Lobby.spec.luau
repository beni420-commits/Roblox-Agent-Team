--!strict
local GameConfig = require("../../../src/shared/Config/GameConfig")
local Lobby = require("../../../src/shared/Logic/Lobby")
local TestRunner = require("../../TestRunner")

local expect = TestRunner.expect
local suite = TestRunner.suite("lantern-line/Logic/Lobby")

TestRunner.it(suite, "Countdown startet mit dem ersten Bereiten und endet nach LOBBY_COUNTDOWN", function()
	local state = Lobby.new()
	expect(Lobby.update(state, 0, 0, 3)):toBe(false)
	expect(Lobby.remaining(state, 0)):toBe(nil)
	expect(Lobby.update(state, 1, 1, 3)):toBe(false)
	expect(Lobby.remaining(state, 1)):toBe(GameConfig.LOBBY_COUNTDOWN)
	expect(Lobby.update(state, 5, 1, 3)):toBe(false) -- Ende verschiebt sich nicht
	expect(Lobby.update(state, 1 + GameConfig.LOBBY_COUNTDOWN, 1, 3)):toBe(true)
end)

TestRunner.it(suite, "alle bereit verkürzt; niemand bereit bricht ab", function()
	local state = Lobby.new()
	Lobby.update(state, 0, 1, 2)
	Lobby.update(state, 2, 2, 2)
	expect(Lobby.remaining(state, 2)):toBe(GameConfig.LOBBY_COUNTDOWN_ALL_READY)
	expect(Lobby.update(state, 2 + GameConfig.LOBBY_COUNTDOWN_ALL_READY, 2, 2)):toBe(true)
	local s2 = Lobby.new()
	Lobby.update(s2, 0, 1, 2)
	Lobby.update(s2, 3, 0, 2)
	expect(Lobby.remaining(s2, 3)):toBe(nil)
	expect(Lobby.update(s2, 100, 0, 0)):toBe(false)
end)

return suite
