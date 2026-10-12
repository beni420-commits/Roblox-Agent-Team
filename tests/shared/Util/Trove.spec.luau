--!strict
local TestRunner = require("../../TestRunner")
local Trove = require("../../../src/shared/Util/Trove")

local expect = TestRunner.expect
local suite = TestRunner.suite("shared/Util/Trove")

TestRunner.it(suite, "räumt Funktionen, Verbindungen und Objekte in umgekehrter Reihenfolge auf", function()
	local log = {}
	local trove = Trove.new()
	trove.add(function()
		table.insert(log, "fn")
	end)
	trove.add({
		Disconnect = function(_self)
			table.insert(log, "disconnect")
		end,
	})
	trove.add({
		Destroy = function(_self)
			table.insert(log, "destroy")
		end,
	})
	expect(trove.size()):toBe(3)
	trove.clean()
	expect(log):toEqual({ "destroy", "disconnect", "fn" })
	expect(trove.size()):toBe(0)
end)

TestRunner.it(suite, "ein fehlerhaftes Element stoppt das Aufräumen der anderen nicht", function()
	local cleaned = 0
	local trove = Trove.new()
	trove.add(function()
		cleaned += 1
	end)
	trove.add(function()
		error("boom")
	end)
	trove.add(function()
		cleaned += 1
	end)
	trove.clean()
	expect(cleaned):toBe(2)
end)

TestRunner.it(suite, "zweimal clean ist sicher", function()
	local count = 0
	local trove = Trove.new()
	trove.add(function()
		count += 1
	end)
	trove.clean()
	trove.clean()
	expect(count):toBe(1)
end)

return suite
