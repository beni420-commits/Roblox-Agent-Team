--!strict
local TestRunner = require("../TestRunner")
local BuildInfo = require("../../src/shared/BuildInfo")

local expect = TestRunner.expect
local suite = TestRunner.suite("shared/BuildInfo")

TestRunner.it(suite, "hat einen Projektnamen", function()
	expect(type(BuildInfo.projectName)):toBe("string")
	expect(#BuildInfo.projectName > 0):toBeTruthy()
end)

TestRunner.it(suite, "ist eingefroren (keine Laufzeitänderung möglich)", function()
	expect(table.isfrozen(BuildInfo)):toBeTruthy()
	expect(function()
		(BuildInfo :: any).sprint = 99
	end):toThrow()
end)

TestRunner.it(suite, "Schema-Version ist eine nicht-negative Ganzzahl", function()
	local v = BuildInfo.dataSchemaVersion
	expect(v >= 0 and v % 1 == 0):toBeTruthy()
end)

return suite
