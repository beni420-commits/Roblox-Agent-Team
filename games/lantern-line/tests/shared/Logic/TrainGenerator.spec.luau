--!strict
local CarriageCatalog = require("../../../src/shared/Logic/CarriageCatalog")
local Fairness = require("../../../src/shared/Logic/Fairness")
local GameConfig = require("../../../src/shared/Config/GameConfig")
local NavGraph = require("../../../src/shared/Logic/NavGraph")
local Puzzle = require("../../../src/shared/Logic/Puzzle")
local TestRunner = require("../../TestRunner")
local TrainGenerator = require("../../../src/shared/Logic/TrainGenerator")
local Types = require("../../../src/shared/Logic/Types")

local expect = TestRunner.expect
local suite = TestRunner.suite("lantern-line/Logic/TrainGenerator")

local SEEDS = 150 -- Pläne für die Garantien (jeder Plan prüft alle 51 Wagen)
local LAST = GameConfig.RUN_LAST_CARRIAGE

local plans: { Types.Plan } = {}
local function allPlans(): { Types.Plan }
	if #plans == 0 then
		for s = 1, SEEDS do
			table.insert(plans, TrainGenerator.generate(s * 7919 + 13))
		end
	end
	return plans
end

local function fail(plan: Types.Plan, index: number, message: string)
	error(string.format("seed %d carriage %d: %s", plan.seed, index, message), 2)
end

TestRunner.it(suite, "deterministisch: gleicher Seed gleicher Plan, anderer Seed anderer Plan", function()
	local a = TrainGenerator.generate(12345)
	local b = TrainGenerator.generate(12345)
	local c = TrainGenerator.generate(12346)
	expect(TrainGenerator.fingerprint(a)):toBe(TrainGenerator.fingerprint(b))
	expect(TrainGenerator.fingerprint(a) ~= TrainGenerator.fingerprint(c)):toBe(true)
end)

TestRunner.it(suite, "Aufbau: Wagen 0–50, Einstieg vorn, Postwagen am Ende, lückenlose x-Positionen", function()
	for _, plan in allPlans() do
		expect(#plan.carriages):toBe(LAST + 1)
		expect(plan.carriages[1].kind):toBe("boarding")
		expect(plan.carriages[LAST + 1].kind):toBe("post")
		for i, c in plan.carriages do
			if c.index ~= i - 1 then
				fail(plan, i - 1, "index mismatch")
			end
			if i > 1 then
				local prev = plan.carriages[i - 1]
				if math.abs(c.originX - (prev.originX + prev.length + GameConfig.GANGWAY)) > 1e-9 then
					fail(plan, c.index, "origin gap")
				end
			end
			if c.kind ~= "boarding" and c.kind ~= "post" and CarriageCatalog.RANDOM_KINDS[c.kind] == nil then
				fail(plan, c.index, "unknown kind " .. c.kind)
			end
		end
	end
end)

TestRunner.it(
	suite,
	string.format("Garantie: jeder Wagen in %d Plänen ist begehbar (Fairness-Grundprüfung)", SEEDS),
	function()
		for _, plan in allPlans() do
			for _, c in plan.carriages do
				local ok, why = Fairness.checkCarriage(c)
				if not ok then
					fail(plan, c.index, why or "?")
				end
			end
		end
	end
)

TestRunner.it(suite, "Garantie: Express und Gegenzug sind unabhängig nachgeprüft fair", function()
	local express, oncoming = 0, 0
	for _, plan in allPlans() do
		for i = 2, #plan.carriages do
			local c = plan.carriages[i]
			local event = c.event
			if event and (event.kind == "express" or event.kind == "oncoming") then
				local prev = plan.carriages[i - 1]
				local ok, why
				if event.kind == "express" then
					express += 1
					ok, why = Fairness.checkExpress(prev, c, event)
					if event.delay < GameConfig.EXPRESS_DELAY_MIN or event.delay > GameConfig.EXPRESS_DELAY_MAX then
						fail(plan, c.index, "express delay out of range")
					end
				else
					oncoming += 1
					ok, why = Fairness.checkOncoming(prev, c, event)
				end
				if not ok then
					fail(plan, c.index, why or "?")
				end
			end
		end
	end
	-- Plausible Häufigkeit (sonst wäre der Test leer): im Mittel 2–6 Express und ≥ 0,5 Gegenzüge je Lauf
	expect(express / SEEDS >= 2 and express / SEEDS <= 6):toBe(true)
	expect(oncoming / SEEDS >= 0.5):toBe(true)
end)

TestRunner.it(suite, "Regeln: Schonfrist, Abstände, Kontrolleur nur im Schlafwagen, ruhiges Ende", function()
	for _, plan in allPlans() do
		local lastSweep, lastInspector = -100, -100
		for _, c in plan.carriages do
			local event = c.event
			local i = c.index
			if event then
				if i <= GameConfig.GRACE_CARRIAGES then
					fail(plan, i, "event in grace period")
				end
				if event.kind == "express" or event.kind == "oncoming" then
					if i - lastSweep < GameConfig.EXPRESS_GAP then
						fail(plan, i, "express gap")
					end
					if i < GameConfig.EXPRESS_MIN_INDEX or i > GameConfig.EVENT_LAST_INDEX then
						fail(plan, i, "express index")
					end
					if event.kind == "oncoming" and i < GameConfig.ONCOMING_MIN_INDEX then
						fail(plan, i, "oncoming too early")
					end
					lastSweep = i
				elseif event.kind == "inspector" then
					if c.kind ~= "sleeper" or c.dark or c.locked then
						fail(plan, i, "inspector placement")
					end
					if i - lastInspector < GameConfig.INSPECTOR_GAP or i < GameConfig.INSPECTOR_MIN_INDEX then
						fail(plan, i, "inspector gap")
					end
					lastInspector = i
				elseif event.kind == "conductor" then
					if i ~= LAST then
						fail(plan, i, "conductor outside post car")
					end
				elseif event.kind ~= "chase" then
					fail(plan, i, "unknown event " .. event.kind)
				end
			end
			if i > GameConfig.EVENT_LAST_INDEX and (c.dark or c.locked) then
				fail(plan, i, "dark/locked at the end")
			end
		end
		expect((plan.carriages[LAST + 1].event :: Types.Event).kind):toBe("conductor")
	end
end)

TestRunner.it(
	suite,
	"Regeln: verschlossen ⇒ genau ein Schlüssel im selben Wagen; nie zweimal in Folge (auch dunkel)",
	function()
		for _, plan in allPlans() do
			for i, c in plan.carriages do
				local keys = 0
				for _, container in c.containers do
					if container.content == "key" then
						keys += 1
					end
					if container.content == "stubs" and (container.stubs < 1 or container.stubs > 3) then
						fail(plan, c.index, "stub count")
					end
				end
				if (c.locked and keys ~= 1) or (not c.locked and keys ~= 0) then
					fail(plan, c.index, "key/lock mismatch")
				end
				if i > 1 then
					local prev = plan.carriages[i - 1]
					if (c.locked and prev.locked) or (c.dark and prev.dark) then
						fail(plan, c.index, "two in a row")
					end
				end
				if not c.dark and #c.eyes > 0 then
					fail(plan, c.index, "eyes in lit carriage")
				end
				if c.dark and c.index < GameConfig.DARK_MIN_INDEX then
					fail(plan, c.index, "dark too early")
				end
			end
		end
	end
)

TestRunner.it(suite, "Dunkle Wagen haben fast immer Augen (Platzierung scheitert höchstens selten)", function()
	local dark, withEyes = 0, 0
	for _, plan in allPlans() do
		for _, c in plan.carriages do
			if c.dark then
				dark += 1
				if #c.eyes >= 1 then
					withEyes += 1
				end
				if #c.eyes > GameConfig.EYES_MAX then
					fail(plan, c.index, "too many eyes")
				end
			end
		end
	end
	expect(dark > SEEDS * 2):toBe(true)
	expect(withEyes / dark >= 0.95):toBe(true)
end)

TestRunner.it(suite, "Kofferlawine: genau eine, 5 gerade Wagen, ruhig davor und danach, fair", function()
	for _, plan in allPlans() do
		local starts = {}
		for _, c in plan.carriages do
			if c.event and (c.event :: Types.Event).kind == "chase" then
				table.insert(starts, c.index)
			end
		end
		if #starts ~= 1 then
			fail(plan, 0, "chase count " .. #starts)
		end
		local s = starts[1]
		if s < GameConfig.CHASE_START_MIN or s > GameConfig.CHASE_START_MAX then
			fail(plan, s, "chase start range")
		end
		for i = s, s + GameConfig.CHASE_LENGTH - 1 do
			local c = plan.carriages[i + 1]
			if not c.chase then
				fail(plan, i, "not flagged as chase")
			end
			local ok, why = Fairness.checkChaseCarriage(c)
			if not ok then
				fail(plan, i, why or "?")
			end
		end
		for _, i in { s - 1, s + GameConfig.CHASE_LENGTH } do
			local c = plan.carriages[i + 1]
			if c.event or c.dark or c.locked or c.chase then
				fail(plan, i, "chase neighbour not quiet")
			end
		end
	end
end)

TestRunner.it(suite, "Schlafwagen höchstens 25 % je Lauf (Compliance H-A7), nie ein Typ dreimal in Folge", function()
	for _, plan in allPlans() do
		local sleepers = 0
		for i, c in plan.carriages do
			if c.kind == "sleeper" then
				sleepers += 1
			end
			if i > 2 and c.kind == plan.carriages[i - 1].kind and c.kind == plan.carriages[i - 2].kind then
				fail(plan, c.index, "kind three times")
			end
		end
		if sleepers > math.floor(GameConfig.SLEEPER_MAX_SHARE * #plan.carriages) then
			fail(plan, 0, "too many sleepers: " .. sleepers)
		end
	end
end)

TestRunner.it(
	suite,
	"Postwagen: Wegenetz zusammenhängend, Schaffner startet weit weg, Code passt zu den Fragmenten",
	function()
		for _, plan in allPlans() do
			local c = plan.carriages[LAST + 1]
			local post = c.post :: Types.PostLayout
			expect(NavGraph.isConnected(NavGraph.new(post.nodes, post.edges))):toBe(true)
			local start = post.nodes[post.conductorStart]
			if math.sqrt(start.x * start.x + start.z * start.z) < GameConfig.CONDUCTOR_MIN_START_DISTANCE then
				fail(plan, LAST, "conductor starts too close")
			end
			local rows: { [number]: boolean } = {}
			local mask = 0
			for _, fragment in post.fragments do
				rows[fragment.row] = true
				if fragment.holes < 1 or fragment.holes > 6 then
					fail(plan, LAST, "row pattern")
				end
				mask = bit32.bor(mask, bit32.lshift(fragment.holes, 3 * (fragment.row - 1)))
			end
			expect(rows[1] and rows[2] and rows[3]):toBe(true)
			expect(mask):toBe(post.code)
			expect(Puzzle.check(post, post.code)):toBe(true)
		end
	end
)

TestRunner.it(suite, "carriageAt: Übergang gehört zum folgenden Wagen, außerhalb nil", function()
	local plan = allPlans()[1]
	local c3 = plan.carriages[4]
	expect(TrainGenerator.carriageAt(plan, c3.originX + 1)):toBe(3)
	expect(TrainGenerator.carriageAt(plan, c3.originX - 1)):toBe(3) -- im Übergang davor
	expect(TrainGenerator.carriageAt(plan, c3.originX + c3.length - 0.1)):toBe(3)
	expect(TrainGenerator.carriageAt(plan, -5)):toBe(nil)
	local last = plan.carriages[#plan.carriages]
	expect(TrainGenerator.carriageAt(plan, last.originX + last.length + 1)):toBe(nil)
end)

return suite
