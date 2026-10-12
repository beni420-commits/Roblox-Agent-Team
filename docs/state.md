# Projektstand (state.md)

> Jede Rolle liest diese Datei zu Beginn jeder Sitzung zuerst. Max. 1 Seite.

**Datum:** 2026-10-12 · **Sprint:** 0 (Research & Konzept) · **Status:** ⏸ **abgeschlossen – wartet auf Owner-Freigabe** (`reports/owner_report_sprint0.md`)

## Sprint-0-Ergebnis
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
| `docs/game_design_doc.md` | Game Designer | **v0.2** (Entwurf zur Freigabe) |
| `docs/telemetry_plan.md` | Data Analyst | v0.2 |
| `docs/ux_spec.md` | UX-Designer | v0.2 |
| `docs/tech_notes.md` | Systems Engineer | fertig (inkl. Schema v1, Remotes, Budgets) |
| `docs/backlog.md` | Live-Ops | fertig (ICE) |
| `reports/owner_report_sprint0.md` | Orchestrator | fertig |

## Offene Freigaben an den Owner
1. Konzept A als MVP (GDD v0.2)
2. Compliance-Auflagen als verbindlich (§8.6)
3. Asset-Regel Kat. 0/1 (§8.5)
4. Veröffentlichungskosten 1.000 R$ bzw. Plus/Premium (§8.2), spätestens vor öffentlichem Release

## Nächster Schritt
**Warten auf den Owner.** Nach der Freigabe startet Sprint 1 (Vertical Slice Zone 1) laut Owner-Bericht §6. Vorher erledigt der Owner idealerweise B-001 (Studio-Smoke-Test).
