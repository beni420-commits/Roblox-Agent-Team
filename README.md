# Roblox Agent Team

Ein autonomes, KI-gestütztes Roblox-Entwicklerstudio nach dem „Masterprompt v2“. Spiele werden recherchiert, konzipiert, gebaut, getestet und iterativ verbessert. Jede Entscheidung wird dokumentiert und belegt.

**Aktueller Stand:** siehe [`docs/state.md`](docs/state.md). Jede Sitzung beginnt dort.

## Struktur

```
docs/      Planung und Stand (state, log, decisions, backlog, GDD, UX, Telemetrie, Tech Notes, Assets)
reports/   Sprint-Berichte (QA, Playtest, Metriken, Compliance, Owner-Bericht)
src/       Rojo-Projekt: server/ → ServerScriptService, client/ → StarterPlayerScripts, shared/ → ReplicatedStorage
tests/     Logik-Tests (laufen im Luau-CLI ohne Roblox)
scripts/   check.sh (Format, Lint, Build, Typprüfung, Tests), setup_tools.sh
```

## Lokal arbeiten (Owner-Maschine)

1. Werkzeuge installieren: `rokit install` (Versionen in `rokit.toml`) und das Luau-CLI von https://github.com/luau-lang/luau/releases.
2. Roblox-Typdefinitionen laden: `scripts/setup_tools.sh`
3. Alle Prüfungen: `scripts/check.sh`
4. Mit Studio synchronisieren: `rojo serve` + Rojo-Plugin, oder `rojo build -o build/place.rbxlx` und die Datei in Studio öffnen.
