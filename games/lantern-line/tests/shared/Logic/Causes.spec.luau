--!strict
local Causes = require("../../../src/shared/Logic/Causes")
local TestRunner = require("../../TestRunner")

local expect = TestRunner.expect
local suite = TestRunner.suite("lantern-line/Logic/Causes")

TestRunner.it(suite, "Hinweisschlüssel je Ursache und Variante (Texte prüft scripts/check.sh in der CSV)", function()
	expect(Causes.hintKey("express", 1)):toBe("HINT_EXPRESS_1")
	expect(Causes.hintKey("conductor", 9)):toBe("HINT_CONDUCTOR_2")
	expect(Causes.hintKey("eyes", 0)):toBe("HINT_EYES_1")
	expect(Causes.isValid("express")):toBe(true)
	expect(Causes.isValid("rush")):toBe(false)
	expect(function()
		Causes.hintKey("unknown", 1)
	end):toThrow()
	expect(#Causes.LIST):toBe(6)
end)

return suite
