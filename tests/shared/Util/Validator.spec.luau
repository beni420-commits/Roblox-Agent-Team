--!strict
local TestRunner = require("../../TestRunner")
local Validator = require("../../../src/shared/Util/Validator")

local expect = TestRunner.expect
local suite = TestRunner.suite("shared/Util/Validator")

local nan = 0 / 0

TestRunner.it(suite, "integer: akzeptiert gültige Ganzzahlen im Bereich", function()
	local check = Validator.integer(1, 10)
	expect((check(1))):toBe(true)
	expect((check(10))):toBe(true)
end)

TestRunner.it(suite, "integer: lehnt Exploit-Werte ab (NaN, ±inf, Bruch, außerhalb, Typen)", function()
	local check = Validator.integer(1, 10)
	for _, bad in { nan, math.huge, -math.huge, 1.5, 0, 11, -5, 1e308, "5", true, {}, nil :: any } do
		expect((check(bad))):toBe(false)
	end
end)

TestRunner.it(suite, "number: lehnt NaN und inf ab, akzeptiert Brüche im Bereich", function()
	local check = Validator.number(0, 1)
	expect((check(0.5))):toBe(true)
	expect((check(nan))):toBe(false)
	expect((check(math.huge))):toBe(false)
	expect((check(1.0001))):toBe(false)
end)

TestRunner.it(suite, "enum: nur erlaubte Strings", function()
	local check = Validator.enum({ "Touch", "Gamepad" })
	expect((check("Touch"))):toBe(true)
	expect((check("touch"))):toBe(false)
	expect((check(string.rep("A", 100000)))):toBe(false)
	expect((check(1))):toBe(false)
end)

TestRunner.it(suite, "boolean: nur echte Booleans", function()
	local check = Validator.boolean()
	expect((check(false))):toBe(true)
	expect((check(0))):toBe(false)
	expect((check("true"))):toBe(false)
end)

TestRunner.it(suite, "args: exakte Anzahl, zusätzliche oder fehlende Argumente werden abgelehnt", function()
	local check = Validator.args({ Validator.integer(1, 5), Validator.boolean() })
	expect((check({ 3, true }, 2))):toBe(true)
	expect((check({ 3 }, 1))):toBe(false)
	expect((check({ 3, true, "extra" }, 3))):toBe(false)
	expect((check({ 3, nil :: any }, 2))):toBe(false)
	local ok, reason = check({ 9, true }, 2)
	expect(ok):toBe(false)
	expect(reason):toBe("arg 1: out of range")
end)

TestRunner.it(suite, "isFinite", function()
	expect(Validator.isFinite(1)):toBe(true)
	expect(Validator.isFinite(nan)):toBe(false)
	expect(Validator.isFinite(-math.huge)):toBe(false)
end)

return suite
