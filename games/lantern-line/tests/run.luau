--!strict
-- Einstieg für alle Logik-Tests von „Lantern Line“: `luau games/lantern-line/tests/run.luau`.
-- Neue Spec-Dateien hier explizit eintragen (das Luau-CLI hat keine Verzeichnis-API).
local TestRunner = require("./TestRunner")

TestRunner.run({
	require("./shared/Logic/NavGrid.spec"),
	require("./shared/Logic/Fairness.spec"),
	require("./shared/Logic/TrainGenerator.spec"),
	require("./shared/Logic/Rush.spec"),
	require("./shared/Logic/Oncoming.spec"),
	require("./shared/Logic/Eyes.spec"),
	require("./shared/Logic/Inspector.spec"),
	require("./shared/Logic/NavGraph.spec"),
	require("./shared/Logic/Conductor.spec"),
	require("./shared/Logic/HideState.spec"),
	require("./shared/Logic/MotionTracker.spec"),
	require("./shared/Logic/Puzzle.spec"),
	require("./shared/Logic/RunState.spec"),
	require("./shared/Logic/Lobby.spec"),
	require("./shared/Logic/FlickerPlanner.spec"),
	require("./shared/Logic/Causes.spec"),
	require("./shared/Telemetry.spec"),
	require("./exploit/RemoteExploit.spec"),
})
