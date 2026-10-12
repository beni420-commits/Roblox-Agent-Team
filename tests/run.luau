--!strict
-- Einstieg für alle Logik-Tests: `luau tests/run.luau` (siehe scripts/check.sh).
-- Neue Spec-Dateien hier explizit eintragen (das Luau-CLI hat keine Verzeichnis-API).
local TestRunner = require("./TestRunner")

TestRunner.run({
	require("./shared/BuildInfo.spec"),
	require("./shared/Util/Prng.spec"),
	require("./shared/Util/Validator.spec"),
	require("./shared/Util/RateLimiter.spec"),
	require("./shared/Util/Trove.spec"),
})
