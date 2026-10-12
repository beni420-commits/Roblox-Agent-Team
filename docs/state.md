# Projektstand (state.md)

> Jede Rolle liest diese Datei zu Beginn jeder Sitzung zuerst. Max. 1 Seite.

**Datum:** 2026-10-12 · **Sprint:** 1 (Vertical Slice Zone 1) · **Status:** ▶ in Arbeit

## Sprint 1
- **Owner-Freigaben** (D-022–D-024): Konzept A, Compliance-Auflagen, Asset-Regel „ohne Copyright“ (Kat. 0 frei; Kat. 1 nur Roblox-eigen ohne Rechte Dritter, keine Musik). **Offen:** Veröffentlichungskosten (D-025).
- **Primärziel:** Zone 1 (Etagen 1–10) ist in Studio spielbar: Generator und Erreichbarkeitsprüfer `[GETESTET]` (200 Seeds), Etagen-Rücksetzpunkt, Lager, Funken (serverseitig validiert), Onboarding ohne Text, Steuerung für Touch, Maus/Tastatur und Gamepad.
- **Erfolgskriterium:** `scripts/check.sh` grün, alle Logik-Tests ausgeführt. Der Owner-Test in Studio und auf dem Handy zeigt: Etage 1 in ≤ 60 s, Zone 1 ohne Frust-Stelle „hoch“. Der Owner-Test liegt außerhalb dieser Umgebung und wird als **offen** gemeldet, bis Ergebnisse vorliegen.
- **Nebenziele:** (1) Remote-Sicherheitsschicht mit Exploit-Tests, (2) CI-Workflow, (3) Entwurf der Fragebogen-Antworten (C-A1).
- **Nicht im Umfang** (Sprint 2): Speicherstand, Zonen 2–3, Fähigkeiten, Schrein, Social-Funktionen.

## Sprint-0-Ergebnis (abgeschlossen)
- **Primärziel** „freigabefähiges MVP-Konzept“: **erreicht.** Empfehlung ist Konzept A **„Schwungturm“** (GDD v0.2), Plan B ist „Formwächter“.
- **Gate Spielspaß:** offen. Bisher nur `[SIMULIERT]`; die 8 „hoch“-Befunde sind im Design behoben, ungetestet.
- **Compliance:** Freigabe mit Auflagen (C-A1–C-A18, C-A29–C-A32), Label Minimal.
- **Toolchain:** `[GETESTET]` – `scripts/check.sh` grün.

## Fähigkeitsinventar (§0.2), geprüft am 2026-10-12

| Fähigkeit | Verfügbar? | Details / Konsequenz |
|---|---|---|
| Webzugriff | **teilweise** | Websuche ja. WebFetch nein (DNS). `*.roblox.com` und `setup.rbxcdn.com` gesperrt. **Öffentliche GitHub-Repos per Git lesbar**, darunter die Roblox-Doku-Quelle `Roblox/creator-docs` (lokal `/home/user/roblox/creator-docs`; in neuer Sitzung neu klonen, D-017) |
| Dateisystem / Git | ja | Branch `claude/roblox-studio-masterprompt-v2-feuzkm` |
| Roblox Studio | **nein** | Engine-Tests macht der Owner (Tech Notes §7) |
| Luau-Ausführung | ja (ohne Engine) | Luau-CLI (`luau`, `luau-analyze`, Submodul 8387cfb). Open Cloud Luau Execution: nein (`apis.roblox.com` gesperrt, kein API-Key) |
| Lint / Format / Typen | ja | Selene 0.31.0 (Std `roblox_lite`, D-011), StyLua 2.6.0, luau-lsp 1.70.1 + Roblox-Typen 2026-10-10 |
| Build | ja | Rojo 7.7.1 |
| Creator-Analytics / Live-Daten | **nein** | kein Live-Spiel |

**Werkzeuge in einer neuen Sitzung wiederherstellen:** `cargo install stylua --features luau && cargo install selene rojo`. luau-lsp und Luau-CLI aus dem Quellcode bauen: `git clone --recurse-submodules https://github.com/JohnnyMorganz/luau-lsp`, dann `cmake` + `ninja` mit den Zielen `Luau.LanguageServer.CLI`, `Luau.Repl.CLI` und `Luau.Analyze.CLI` (~25 min). Danach `scripts/setup_tools.sh`.

## Artefakte Sprint 0
| Artefakt | Rolle | Status |
|---|---|---|
| `docs/research_report.md` | Market Researcher | fertig |
| `docs/research_tech_facts_2026-10-12.md` | Systems Engineer | fertig (überwiegend V1) |
| `reports/compliance_rules_digest_2026-10-12.md` | Compliance | fertig (v1.1, Abgleich mit dem Original) |
| `reports/compliance_check_sprint0.md` | Compliance | fertig (v1.1 + Nachtrag zu GDD v0.2) |
| `reports/playtest_report_sprint0.md` | Playtest-Simulator | fertig `[SIMULIERT]` |
| `docs/game_design_doc.md` | Game Designer | **v0.2** (vom Owner freigegeben, D-022) |
| `docs/telemetry_plan.md` | Data Analyst | v0.2 |
| `docs/ux_spec.md` | UX-Designer | v0.2 |
| `docs/tech_notes.md` | Systems Engineer | fertig (inkl. Schema v1, Remotes, Budgets) |
| `docs/backlog.md` | Live-Ops | fertig (ICE) |
| `reports/owner_report_sprint0.md` | Orchestrator | fertig |

## Offene Freigaben an den Owner
1. Veröffentlichungskosten 1.000 R$ bzw. Plus/Premium (§8.2), spätestens vor dem öffentlichen Release
2. Offene Fragen: Publisher-Konto oder -Gruppe; Studio- und Handy-Test pro Sprint möglich?

## Sprint-1-Stand
- **Gebaut:** Zone 1 (Etagen 1–10) mit Generator, Erreichbarkeitsprüfer, Funken, Lagern, Rücksetzpunkt, Hilfe 3/6, Führung, Coyote-Time, Sprungpads, HUD (EN/DE), Telemetrie, Remote-Guard, Reset-Knopf ohne Tod.
- **Geprüft:** `scripts/check.sh` grün, 76/76 Tests [GETESTET]; Code-Review mit 30 Befunden, Fixes in `c7f81b1`.
- **Nicht geprüft:** alles in der Engine. Owner-Test P0 nach `reports/owner_test_template.md` steht aus.
- **Bewusst offen (Sprint 2):** MovementCheck vor dem Speicherstand (CR-14), Feedback-Katalog (CR-29), Avatar-Transparenz (C-A32).

## Nächster Schritt
Owner-Test P0 (Studio und Handy). Danach Sprint-2-Planung: MovementCheck → Speicherstand → Zonen 2–3, Fähigkeiten, Schrein, Social.
