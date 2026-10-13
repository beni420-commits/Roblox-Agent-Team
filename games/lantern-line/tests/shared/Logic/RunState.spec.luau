--!strict
local GameConfig = require("../../../src/shared/Config/GameConfig")
local RunState = require("../../../src/shared/Logic/RunState")
local TestRunner = require("../../TestRunner")
local TrainGenerator = require("../../../src/shared/Logic/TrainGenerator")
local Types = require("../../../src/shared/Logic/Types")

local expect = TestRunner.expect
local suite = TestRunner.suite("lantern-line/Logic/RunState")

local function lockedPlan(): (Types.Plan, number)
	for s = 1, 100 do
		local plan = TrainGenerator.generate(s)
		for _, c in plan.carriages do
			if c.locked then
				return plan, c.index
			end
		end
	end
	error("no locked carriage")
end

local function openTo(state: RunState.State, door: number)
	for d = state.opened + 1, door do
		local c = state.plan.carriages[d] -- Wagen d − 1
		if c.locked then
			for id, container in c.containers do
				if container.content == "key" then
					RunState.openContainer(state, "a", c.index, id)
				end
			end
		end
		assert(RunState.openDoor(state, d), "door " .. d)
	end
end

TestRunner.it(suite, "Türen nur der Reihe nach und nur während des Laufs", function()
	local state = RunState.new(TrainGenerator.generate(1))
	expect((RunState.canOpenDoor(state, 1))):toBe(false) -- Bahnsteig
	RunState.start(state, { "a", "b" }, 0)
	expect((RunState.canOpenDoor(state, 2))):toBe(false)
	local first = state.plan.carriages[1]
	expect(first.locked):toBe(false)
	expect((RunState.openDoor(state, 1))):toBe(true)
	expect(state.opened):toBe(1)
	expect((RunState.openDoor(state, 1))):toBe(false)
	expect((RunState.canOpenDoor(state, state.plan.lastIndex + 1))):toBe(false)
end)

TestRunner.it(suite, "verschlossen: erst mit dem Schlüssel aus dem Behälter desselben Wagens", function()
	local plan, k = lockedPlan()
	local state = RunState.new(plan)
	RunState.start(state, { "a" }, 0)
	openTo(state, k)
	local ok, why = RunState.canOpenDoor(state, k + 1)
	expect(ok):toBe(false)
	expect(why):toBe("locked")
	local c = plan.carriages[k + 1]
	local keyId = 0
	for id, container in c.containers do
		if container.content == "key" then
			keyId = id
		end
	end
	local opened, content = RunState.openContainer(state, "a", k, keyId)
	expect(opened):toBe(true)
	expect(content):toBe("key")
	expect(state.keys[k + 1]):toBe(true)
	expect((RunState.openDoor(state, k + 1))):toBe(true)
	expect(state.keys[k + 1]):toBe(nil) -- verbraucht
end)

TestRunner.it(suite, "Behälter: einmal je Lauf, nur in erreichten Wagen, Abrisse zählen", function()
	local plan = TrainGenerator.generate(3)
	local state = RunState.new(plan)
	RunState.start(state, { "a" }, 0)
	expect((RunState.openContainer(state, "a", 1, 1))):toBe(false) -- Wagen 1 noch zu
	expect((RunState.openContainer(state, "a", 0, 99))):toBe(false) -- gibt es nicht
	local _, _, stubs = RunState.openContainer(state, "a", 0, 1)
	expect((RunState.openContainer(state, "a", 0, 1))):toBe(false)
	expect(state.players.a.stubs):toBe(stubs)
end)

TestRunner.it(suite, "Tod einmal; alle tot ⇒ verloren; Tote öffnen keine Behälter", function()
	local state = RunState.new(TrainGenerator.generate(4))
	RunState.start(state, { "a", "b" }, 10)
	expect(RunState.kill(state, "a", "express", 7)):toBe(true)
	expect(RunState.kill(state, "a", "express", 7)):toBe(false)
	expect((RunState.openContainer(state, "a", 0, 1))):toBe(false)
	expect(RunState.alivePlayers(state)):toEqual({ "b" })
	expect(RunState.checkEnd(state, 20, false)):toBe(nil)
	RunState.kill(state, "b", "eyes", 7)
	expect(RunState.checkEnd(state, 21, false)):toBe("lost")
	expect(state.phase):toBe("ended")
	expect(RunState.kill(state, "zzz", "eyes", 1)):toBe(false)
end)

TestRunner.it(
	suite,
	"Studio-Abkürzung: nur zu Beginn, nur gültige Wagen, liefert das Ereignis des Zielwagens",
	function()
		local plan = TrainGenerator.generate(9)
		local state = RunState.new(plan)
		expect((RunState.debugSkipTo(state, 10))):toBe(false) -- noch Bahnsteig
		RunState.start(state, { "a" }, 0)
		expect((RunState.debugSkipTo(state, 0))):toBe(false)
		expect((RunState.debugSkipTo(state, plan.lastIndex + 1))):toBe(false)
		local ok, event = RunState.debugSkipTo(state, plan.lastIndex)
		expect(ok):toBe(true)
		expect(state.opened):toBe(plan.lastIndex)
		expect((event :: Types.Event).kind):toBe("conductor")
		expect((RunState.debugSkipTo(state, 5))):toBe(false) -- nur einmal, nur von Wagen 0 aus
	end
)

TestRunner.it(suite, "Abbruch ohne Fortschritt: verloren, nur während des Laufs, danach unverändert", function()
	local state = RunState.new(TrainGenerator.generate(10))
	expect(RunState.abort(state, 1)):toBe(nil) -- Bahnsteig
	RunState.start(state, { "a" }, 0)
	expect(RunState.abort(state, 400)):toBe("lost")
	expect(state.phase):toBe("ended")
	expect(state.endedAt):toBe(400)
	expect(RunState.abort(state, 500)):toBe("lost")
	expect(state.endedAt):toBe(400)
end)

TestRunner.it(suite, "Verlassen zählt nicht als Tod, beendet aber den Lauf, wenn niemand übrig ist", function()
	local state = RunState.new(TrainGenerator.generate(8))
	RunState.start(state, { "a" }, 0)
	RunState.removePlayer(state, "a")
	expect(state.players.a.cause):toBe(nil)
	expect(RunState.checkEnd(state, 1, false)):toBe("lost")
end)

TestRunner.it(suite, "Entwerter: nur im Postwagen, Fragmente nur dort lesbar, gewonnen erst am Ausgang", function()
	local plan = TrainGenerator.generate(5)
	local state = RunState.new(plan)
	RunState.start(state, { "a" }, 0)
	local post = plan.carriages[plan.lastIndex + 1].post :: Types.PostLayout
	expect(RunState.submitPattern(state, post.code)):toBe(false) -- noch nicht im Postwagen
	expect(RunState.readFragment(state, 1)):toBe(false)
	openTo(state, plan.lastIndex)
	expect(RunState.readFragment(state, 1)):toBe(true)
	expect(RunState.readFragment(state, 1)):toBe(false)
	expect(RunState.readFragment(state, 4)):toBe(false)
	expect(RunState.submitPattern(state, bit32.bxor(post.code, 1))):toBe(false)
	expect(RunState.submitPattern(state, post.code)):toBe(true)
	expect(RunState.submitPattern(state, post.code)):toBe(false) -- nur einmal
	expect(RunState.checkEnd(state, 100, false)):toBe(nil)
	expect(RunState.checkEnd(state, 101, true)):toBe("won")
end)

TestRunner.it(suite, "Abkoppeln und Vorausbau folgen dem höchsten geöffneten Wagen", function()
	local state = RunState.new(TrainGenerator.generate(6))
	RunState.start(state, { "a" }, 0)
	expect(RunState.retainFrom(state)):toBe(0)
	expect(RunState.buildUpTo(state)):toBe(GameConfig.BUILD_AHEAD)
	openTo(state, 9)
	expect(RunState.retainFrom(state)):toBe(9 - GameConfig.RETAIN_BEHIND)
	openTo(state, state.plan.lastIndex)
	expect(RunState.buildUpTo(state)):toBe(state.plan.lastIndex)
end)

return suite
