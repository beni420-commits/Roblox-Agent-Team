--!strict
local Eyes = require("../../../src/shared/Logic/Eyes")
local Fixtures = require("../../Fixtures")
local GameConfig = require("../../../src/shared/Config/GameConfig")
local TestRunner = require("../../TestRunner")

local expect = TestRunner.expect
local suite = TestRunner.suite("lantern-line/Logic/Eyes")

TestRunner.it(suite, "Augen in Weltkoordinaten; Zugriff nur im Fangradius und nur einmal", function()
	local c = Fixtures.carriage({ index = 9, originX = 100, length = 40, eyes = { { 20, 4 }, { 30, -4 } } })
	local list = Eyes.fromCarriage(c)
	expect(#list):toBe(2)
	expect(list[1].x):toBe(120)
	local r = GameConfig.EYES_SNATCH_RADIUS
	expect(Eyes.snatch(list, 120, 4 - r - 0.1)):toBe(nil)
	local hit = Eyes.snatch(list, 120, 4 - r + 0.1)
	expect(hit ~= nil and hit.id == 1):toBe(true)
	expect(Eyes.snatch(list, 120, 4)):toBe(nil) -- schon benutzt
	expect(Eyes.isAwake(list[2], 130, -4 + GameConfig.EYES_WAKE_RADIUS - 0.5)):toBe(true)
	expect(Eyes.isAwake(list[2], 130, -4 + GameConfig.EYES_WAKE_RADIUS + 0.5)):toBe(false)
	expect(Eyes.isAwake(list[1], 120, 4)):toBe(false) -- benutzt
end)

return suite
