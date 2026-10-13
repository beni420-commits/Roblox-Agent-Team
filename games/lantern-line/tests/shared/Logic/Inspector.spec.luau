--!strict
local GameConfig = require("../../../src/shared/Config/GameConfig")
local Inspector = require("../../../src/shared/Logic/Inspector")
local TestRunner = require("../../TestRunner")

local expect = TestRunner.expect
local suite = TestRunner.suite("lantern-line/Logic/Inspector")

local function view(
	key: string,
	distance: number,
	moved: number,
	alive: boolean?,
	inCarriage: boolean?
): Inspector.PlayerView
	return {
		key = key,
		alive = if alive == nil then true else alive,
		inCarriage = if inCarriage == nil then true else inCarriage,
		distance = distance,
		moved = moved,
	}
end

-- Spult bis zum Beginn der nächsten Phase `phase` vor (ohne Spieler).
local function advanceTo(state: Inspector.State, phase: Inspector.Phase, now: number): number
	local t = now
	for _ = 1, 10000 do
		if state.phase == phase then
			return t
		end
		t = state.phaseEndsAt
		Inspector.update(state, t, {})
	end
	error("phase not reached")
end

TestRunner.it(suite, "Phasenfolge Einleitung → Gehen → Achtung → Halt → Gehen mit Dauern im Rahmen", function()
	local state = Inspector.new(42, 0)
	expect(state.phase):toBe("intro")
	local tGo = advanceTo(state, "go", 0)
	expect(tGo):toBe(GameConfig.INSPECTOR_INTRO)
	local goLen = state.phaseEndsAt - tGo
	expect(goLen >= GameConfig.INSPECTOR_AMBER_MIN and goLen <= GameConfig.INSPECTOR_AMBER_MAX):toBe(true)
	local tWarn = advanceTo(state, "warn", tGo)
	expect(state.phaseEndsAt - tWarn):toBeNear(GameConfig.INSPECTOR_WARN, 1e-9)
	local tStop = advanceTo(state, "stop", tWarn)
	local stopLen = state.phaseEndsAt - tStop
	expect(stopLen >= GameConfig.INSPECTOR_RED_MIN and stopLen <= GameConfig.INSPECTOR_RED_MAX):toBe(true)
	advanceTo(state, "go", tStop)
	expect(Inspector.isDangerous("stop")):toBe(true)
	expect(Inspector.isDangerous("warn")):toBe(false)
end)

TestRunner.it(
	suite,
	"Bewegung kostet nur bei Halt, gemessen nach der Gnadenzeit, höchstens einmal je Haltphase",
	function()
		local state = Inspector.new(7, 0)
		local tStop = advanceTo(state, "stop", 0)
		local moving = { view("a", 30, 3), view("b", 30, 0.5) }
		local measureFrom = tStop + GameConfig.INSPECTOR_GRACE + GameConfig.INSPECTOR_MOVE_WINDOW
		expect(#Inspector.update(state, tStop + GameConfig.INSPECTOR_GRACE + 0.01, moving).hits):toBe(0) -- Fenster reicht noch in die Gnadenzeit
		expect(#Inspector.update(state, measureFrom - 0.01, moving).hits):toBe(0)
		local r = Inspector.update(state, measureFrom + 0.01, moving)
		expect(#r.hits):toBe(1)
		expect(r.hits[1]):toBe("a")
		expect(#Inspector.update(state, measureFrom + 0.2, moving).hits):toBe(0)
		-- nächste Haltphase: wieder genau ein Treffer möglich
		local tGo = advanceTo(state, "go", tStop)
		expect(#Inspector.update(state, tGo + 0.1, moving).hits):toBe(0) -- Gehen ist sicher
		local tStop2 = advanceTo(state, "stop", tGo)
		expect(#Inspector.update(state, tStop2 + 1, moving).hits):toBe(1)
	end
)

TestRunner.it(suite, "Kontrollierte, tote und Spieler außerhalb des Wagens werden nie getroffen", function()
	local state = Inspector.new(9, 0)
	local tStop = advanceTo(state, "stop", 0)
	local players = {
		view("near", GameConfig.INSPECTOR_CHECK_DISTANCE - 0.1, 5),
		view("dead", 20, 5, false),
		view("outside", 20, 5, true, false),
	}
	local r = Inspector.update(state, tStop + 1, players)
	expect(#r.hits):toBe(0)
	expect(state.checked.near):toBe(true)
end)

TestRunner.it(suite, "Fertig erst, wenn alle Lebenden im Wagen kontrolliert sind (mind. einer)", function()
	local state = Inspector.new(3, 0)
	expect(Inspector.update(state, 3, { view("a", 30, 0) }).done):toBe(false)
	expect(Inspector.update(state, 3.1, {}).done):toBe(false) -- niemand kontrolliert
	expect(Inspector.update(state, 3.2, { view("a", 5, 0), view("b", 20, 0) }).done):toBe(false)
	local r = Inspector.update(state, 3.3, { view("a", 5, 0), view("b", 6, 0), view("c", 20, 0, false) })
	expect(r.done):toBe(true)
	expect(state.phase):toBe("gone")
	expect(#Inspector.update(state, 100, { view("d", 30, 9) }).hits):toBe(0)
end)

TestRunner.it(suite, "großer Zeitsprung durchläuft mehrere Phasen ohne Fehler", function()
	local state = Inspector.new(11, 0)
	local t = GameConfig.INSPECTOR_MAX_DURATION - 5
	local r = Inspector.update(state, t, { view("a", 30, 0) })
	expect(r.phaseChanged):toBe(true)
	expect(state.phaseEndsAt > t):toBe(true)
end)

TestRunner.it(suite, "Zeitlimit: nach INSPECTOR_MAX_DURATION geht er auch ohne Kontrolle ab (H-A18)", function()
	local state = Inspector.new(12, 100)
	local laggard = { view("a", 30, 0) }
	expect(Inspector.update(state, 100 + GameConfig.INSPECTOR_MAX_DURATION - 0.1, laggard).done):toBe(false)
	local r = Inspector.update(state, 100 + GameConfig.INSPECTOR_MAX_DURATION, laggard)
	expect(r.done):toBe(true)
	expect(#r.hits):toBe(0)
	expect(state.phase):toBe("gone")
end)

return suite
