# Projekt-Log (chronologisch)

## 2026-10-12 – Sprint 0, Sitzung 1

### Orchestrator – Fähigkeitsinventar (§0.2)
- Repo `beni420-commits/Roblox-Agent-Team` war leer (keine Commits). Arbeitsbranch: `claude/roblox-studio-masterprompt-v2-feuzkm`.
- Netzwerktests [GETESTET]:
  - `*.roblox.com` (create, devforum, en.help, apis, www) → per Egress-Policy gesperrt (CONNECT 403). `setup.rbxcdn.com` ist ebenfalls nicht erreichbar.
  - Werkzeug WebFetch → DNS-Fehler für **alle** Domains (auch wikipedia.org). Es gibt keinen direkten Seitenabruf.
  - Werkzeug WebSearch → funktioniert (Titel, URLs, Zusammenfassung).
  - crates.io, npm und `raw.githubusercontent.com` sind erreichbar. Öffentliche GitHub-Repos lassen sich anonym klonen.
- Lokale Werkzeuge vorher: `cargo`/`rustc`, `node`/`npm`, `python3`, `cmake`/`ninja`/`g++`/`clang++`. Es gab keine Luau-Werkzeuge.
- Installiert bzw. gebaut:
  - StyLua 2.6.0 (`cargo install stylua --features luau`) [GETESTET]
  - Selene 0.31.0 (`cargo install selene`) [GETESTET]
  - Rojo 7.7.1 (`cargo install rojo`) [GETESTET]
  - luau-lsp 1.70.1 und Luau-CLI aus dem Quellcode (Klon von github.com/JohnnyMorganz/luau-lsp, Commit 6f90396 vom 2026-10-10; Luau-Submodul 8387cfb vom 2026-10-09) – Ergebnis siehe `state.md`
  - Lune: Build abgebrochen, um CPU für luau-lsp freizumachen. Das Luau-CLI genügt für Logik-Tests (D-012).
- Selene kann die `roblox`-Std nicht erzeugen (API-Dump gesperrt) → eigene Std `roblox_lite` (D-011).

### Orchestrator – Projektgerüst
- Rojo-Projekt (`default.project.json`), `stylua.toml`, `selene.toml` + `roblox_lite.yml`, `rokit.toml`, `.gitignore`.
- `src/shared/BuildInfo.luau`, `src/server/Main.server.luau`, `src/client/Main.client.luau` (nur Bootstrap, keine Spiellogik).
- `tests/TestRunner.luau`, `tests/run.luau`, `tests/shared/BuildInfo.spec.luau`.
- `scripts/check.sh` (Format, Lint, Build, Typprüfung, Tests) und `scripts/setup_tools.sh` (lädt die Roblox-Typdefinitionen).

### Delegiert (parallel)
- Market Researcher → `docs/research_report.md`
- Compliance-Officer → `reports/compliance_rules_digest_2026-10-12.md` (Regelgrundlage)
- Systems Engineer (Recherche) → `docs/research_tech_facts_2026-10-12.md`

### Compliance-Officer – Regelgrundlage (Teil A)
- `reports/compliance_rules_digest_2026-10-12.md`: 73 Regeln mit IDs, Konzept-Checkliste K01–K23, Release-Checkliste R01–R20 und 20 nicht verifizierte Punkte. Grundlage sind nur Websuche-Zusammenfassungen; kein Regeltext wurde im Original gelesen.
- Launch-relevant: Spiele ohne Content-Label sind seit 30.09.2025 nicht spielbar. Kids-/Select-Konten gibt es seit Juni 2026. Die Publishing Requirements 2026 verlangen zunächst eine 16+-Sichtbarkeitsphase. Chat erfordert seit 07.01.2026 eine Altersprüfung.

### Orchestrator – Toolchain abgeschlossen
- Luau-CLI (`luau`, `luau-analyze`) und luau-lsp 1.70.1 gebaut. `scripts/check.sh` ist vollständig grün [GETESTET].
- luau-lsp fand einen echten Typfehler (eingefrorene Tabelle vs. Lese-/Schreib-Typ) in `BuildInfo.luau`; behoben.
- Gegenprobe: Ein absichtlich fehlschlagender Test liefert Exit-Code 1, ein absichtlicher Typfehler lässt `luau-analyze` mit Exit-Code 1 scheitern [GETESTET].
