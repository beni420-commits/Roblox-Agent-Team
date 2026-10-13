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

### Market Researcher – Research-Report
- `docs/research_report.md`: 34 Websuchen, 8 Genres, 9 Referenzspiele, 3 Konzepte. Empfehlung A „Schwungturm“ (gewichtet 16/20), Plan B „Formwächter“.

### Systems Engineer – Tech-Faktensammlung
- `docs/research_tech_facts_2026-10-12.md`: Die Fakten sind überwiegend im Original gelesen (Git-Klon `Roblox/creator-docs` @af5f853 und Tool-Repos).
- Korrekturen in den Tech Notes: ProfileStore steht unter Apache-2.0 (nicht MIT); die 6-s-Schreibregel ist überholt; neue DataStore-Budgets; `math.isfinite`; `ModelStreamingBehavior = Improved`.

### Orchestrator – Original-Doku als Quelle (D-017)
- `Roblox/creator-docs` per Git geklont. Humanoid- und Workspace-Defaults (WalkSpeed 16, JumpHeight 7,2, Gravity 196,2, `CharacterUseJumpPower = true`) im Original geprüft.

### Compliance – Konzept-Vorprüfung
- A, B und C erhalten jeweils „Freigabe mit Auflagen“; A hat das geringste Risiko (Label Minimal).
- Im Original geklärt: Publishing-Hürde (1.000 R$ oder Plus/Premium, 250 Spielstarts durch zahlende 16+-Spieler in 60 Tagen); Social Hangouts erst ab 16; `FilterStringAsync` scheitert bei Offline-Autoren, deshalb erscheinen fremde Namen nur in der Roblox-PlayerList.

### Game Designer / Data Analyst / UX / Systems Engineer – Design v0.1
- GDD, Telemetrie-Plan, UX Teil B und Tech Notes §6 für Konzept A.

### Playtest-Simulator – Persona-Walkthrough [SIMULIERT]
- 5 Personas. Gate Spielspaß **nicht bestanden**: 8 Befunde „hoch“ (P-01 bis P-08), 21 weitere.

### Game Designer u. a. – Design v0.2
- Alle „hoch“-Befunde und die meisten mittleren im Design behoben (GDD §13). Compliance-Nachtrag zu v0.2: neue Auflagen C-A29 bis C-A32, keine Blocker.

### Orchestrator – Sprint-0-Abschluss
- Owner-Bericht geschrieben, state.md aktualisiert, `scripts/check.sh` grün. **Stopp: Warten auf Owner-Freigabe.**

## 2026-10-12 – Sprint 1, Sitzung 1

### Owner – Freigaben
- Konzept A freigegeben, Compliance-Auflagen verbindlich, Asset-Regel „solange ohne Copyright“ (D-022 bis D-024). Veröffentlichungskosten noch offen (D-025).

### Orchestrator – Sprintstart
- Sprintziel, Erfolgskriterium und Umfang stehen in `state.md`.

### Systems Engineer / QA – Logik und Tests
- Util-Module (Prng, Validator, RateLimiter, Trove) mit 25 Tests [GETESTET].
- Movement + Reachability: Flugbahn-Simulation mit Referenzcharakter. Befund: DJ-Pflicht über Weite ist nicht fair → Höhe (D-026).
- TowerGenerator Zone 1 (Helix, Funken, Lager, Hilfsstufen, Pads). 200 Seeds × 10 Etagen lösbar [GETESTET]. Mutationstests bestätigen die Aussagekraft der Tests.
- RunState, LandingLocator, Net-Definitions und Guard samt Exploit-Suite [GETESTET].

### Systems Engineer – Roblox-Schicht
- Server (WorldSetup, TowerBuilder, NetService, PlayerService, TelemetryService) und Client (HUD, Funken, Führung, Bewegung, Sturz, Eingabe, Kamera-Intro).
- Nur typgeprüft (luau-lsp mit Roblox-Typen); nicht in der Engine ausgeführt.

### QA – Code-Review (unabhängig)
- 30 Befunde, kein Blocker, 1 kritischer Verdacht (Sprungpad-Impuls). Die Fixes für CR-01 bis CR-28 stehen in `c7f81b1`; CR-14, CR-29 und CR-30 sind für Sprint 2 im Backlog.

### Orchestrator – Infrastruktur und Compliance-Vorbereitung
- CI-Workflow angelegt (nicht auf GitHub ausgeführt, D-029). Fragebogen-Entwurf. Owner-Testvorlage P0.

### QA – Nachprüfung der Fixes (unabhängig) und Runde 2
- Am Stand `c7f81b1`: 23 behoben, 4 teilweise, 3 bewusst offen, 8 neu (CR-31 bis CR-38). Fixes in `0d9d440`: Sturzerkennung je Sektor mit Boden-Regel (gemeinsam für Server und Client), oberste Etage, Coyote ohne Debounce u. a. Tests: 81.
- Vorfall: Ein Bearbeitungsskript hat `reports/qa_report_sprint1.md` versehentlich geleert; aus dem letzten Commit wiederhergestellt, bevor etwas verloren ging.

### Compliance – Check Sprint 1
- Freigabe mit Auflagen T-1 bis T-4 für einen privaten Test-Place; Fragebogen-Entwurf korrigiert (Fear und Violence für Zone 3, regionales Ergebnis, „Allow strong language“ aus).

### Orchestrator – Sprint-1-Abschluss
- Owner-Bericht Sprint 1 geschrieben. **Stopp: wartet auf Owner-Test P0.**

## 2026-10-12 – Owner-Wunsch: Installer für PC
- Windows-Installer (`installer/`) erstellt: Rojo-Download mit Prüfsumme, Build, Studio-Erkennung, Plugin, Verknüpfung, Deinstallation (D-031).
- 14 Installer-Tests mit PowerShell 7 [GETESTET]; Teil von `scripts/check.sh` (wird übersprungen, wenn `pwsh` fehlt). Echtes Windows ist ungetestet.

## 2026-10-13 – Owner-Auftrag: Horror-Spiel „wie Doors“ → „Lantern Line – Der Nachtzug“

### Orchestrator
- Neues Projekt `games/lantern-line/` (D-032). Konzept „Nachtzug / Laternen-Noir“ als GDD v0.1 (D-033).
- Delegiert (parallel): Market Researcher → `docs/lantern-line/research_doors.md`; Compliance → `reports/lantern-line/compliance_check_concept.md`.

### Market Researcher
- Doors-Analyse (ca. 40 Websuchen). Ergebnisse:
  - Keine Namenskollision gefunden.
  - Konkurrenz im Setting: „LastStop“ (in Entwicklung).
  - Empfehlung: Pendel, Blinder Passagier und Finale weiter vom Vorbild abrücken, Kontrolleur und „Ruck“ betonen.

### Compliance
- Freigabe mit Auflagen H-A1 bis H-A15, bedingte Vetos V1 bis V3.
- Funde: Bar im Salonwagen führt zu 18+; das Finale ist zu nah am Vorbild; das Repo ist öffentlich.
- Erwartetes Label Mild.

### Game Designer
- GDD v0.2 mit Gegenzug, Abstands-Augen, Entwerter-Lochmuster, Schaffner mit Lichtkegel, Teesalon und Kofferlawine (D-034).
- Arbeitstitel „Lantern Line – Der Nachtzug“.

### Systems Engineer / QA
- **Logik (reine Luau-Module):**
  - Zuggenerator mit 7 Wagentypen
  - Begehbarkeits-Raster und Fairness-Prüfer
  - Express- und Lawinen-Kinematik (`Sweep`), Gegenzug, Augen, Kontrolleur, Schaffner (Wegenetz, Lichtkegel, Sicht, Hören), Verstecke mit Kälte
  - Bewegungsmessung, Entwerter-Rätsel, Laufzustand, Bahnsteig-Countdown
  - Flacker-Planer (≤ 2 Pulse/s, synchron)
  - Telemetrie-Katalog
- **Tests:** 71 [GETESTET], davon 150 Seeds × 51 Wagen für die Fairness-Garantien und eine Exploit-Suite.
- **Fairness-Messung [GETESTET]:** Express-Ereignisse wurden in Gepäckwagen anfangs zu 3 % abgelehnt (Überseekoffer zu weit weg). Danach liegt je ein Koffer in der hinteren und vorderen Hälfte; jetzt 0 Ablehnungen bei 2.640 Proben.
- **Roblox-Schicht:**
  - Server: Bahnsteig, Zugbau, Lauf, Wesen, Verstecke, Rätsel, Telemetrie.
  - Client: HUD, Einstellungen, Atmosphäre, Wesen-Darstellung, Versteck-Ansicht, Ausscheiden und Zuschauen, Entwerter, Abfahrtstafel.
  - Typgeprüft, nicht in der Engine ausgeführt.
- **Statische Compliance-Prüfungen:** `scripts/lantern_line_checks.py`. Die Gegenprobe mit eingeschleustem verbotenem Wort und einer TextBox wurde erkannt. Echte Funde, die behoben wurden: das Wort „doors“ in einem Hinweistext und der Vorbild-Name in der GDD.
- **Umbenennung:** Das Modul `Rush` heißt jetzt `Sweep` (keine Vorbild-Namen im Code).
- **`scripts/check.sh`** prüft jetzt beide Spiele: 81 + 71 Logik-Tests, Typprüfung, Lint, Build, Compliance-Checks, Installer-Tests.
- **Installer:** `-Game LanternLine` (D-039), 18 Tests.

