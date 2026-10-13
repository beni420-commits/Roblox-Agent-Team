# Projektstand (state.md)

> Jede Rolle liest diese Datei zu Beginn jeder Sitzung zuerst. Max. 1 Seite.

**Datum:** 2026-10-13 · **Zwei Spiele im Repo**, beide ⏸ **warten auf Owner-Test P0**:

| Spiel | Ordner | Stand | Owner-Bericht | Checkliste |
|---|---|---|---|---|
| **Lantern Line – Der Nachtzug** (Horror, 1–4 Spieler, Owner-Auftrag D-032) | `games/lantern-line/` | erste vollständige Fassung (51 Wagen, 6 Wesen, Finale); Review umgesetzt (D-041) | `reports/lantern-line/owner_report.md` | `reports/lantern-line/owner_test_template.md` |
| **Schwungturm** (Klettern, Konzept A) | Repo-Wurzel (`src/`) | Sprint 1: Zone 1 | `reports/owner_report_sprint1.md` | `reports/owner_test_template.md` |

## Lantern Line – Stand
- **Geprüft** [GETESTET]: `scripts/check.sh` grün (78 Logik-Tests, luau-lsp, Selene, Compliance-Textprüfung mit 74 Schlüsseln, Build). Code-Review: 24 Befunde, alle umgesetzt. Playtest [SIMULIERT]: 15 von 18 Befunden behoben.
- **Nicht geprüft:** alles in der Engine (Prüfpunkte S-01 bis S-24 in `reports/lantern-line/code_review_sprint1.md` §6).
- **Compliance:** Owner in Studio: frei. Privater Test-Place: Freigabe mit Auflagen T-1 bis T-5. Öffentlich: aufschiebendes Veto bis zu den Owner-Freigaben (`reports/lantern-line/compliance_check_sprint1_ll.md` §9).
- **Offene Owner-Fragen:** Kids 5–8 ja/nein, eigenes Universe, Zugang Dritter, Titel/Marke, Sounds, Konzeptdokumente im öffentlichen Repo, LP-03 (Laufdauer/Wiedereinstieg), LP-15 (Zweck der Abrisse).
- **Nächster Schritt:** Owner-Test P0, danach Befunde (L-002) und Owner-Antworten umsetzen.

## Schwungturm – Sprint 1
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

## Artefakte
Schwungturm: `docs/` (GDD v0.2, Recherche, Telemetrie, UX, Tech Notes) und `reports/` (Sprint 0/1). Lantern Line: `docs/lantern-line/` und `reports/lantern-line/`. Entscheidungen: `docs/decisions.md`; Verlauf: `docs/log.md`; Backlog beider Spiele: `docs/backlog.md`.

## Schwungturm – offene Freigaben
1. Veröffentlichungskosten 1.000 R$ bzw. Plus/Premium (§8.2), spätestens vor dem öffentlichen Release
2. Offene Fragen: Publisher-Konto oder -Gruppe; Studio- und Handy-Test pro Sprint möglich?

## Schwungturm – Sprint-1-Stand
- **Gebaut:** Zone 1 (Etagen 1–10) mit Generator, Erreichbarkeitsprüfer, Funken, Lagern, Rücksetzpunkt je Etage, Hilfe 3/6, Führung, Coyote-Time, Sprungpads, HUD (EN/DE), Telemetrie (inkl. Etagen-Funnel), Remote-Guard, Reset-Knopf ohne Tod.
- **Geprüft:** `scripts/check.sh` grün, 81/81 Tests [GETESTET]. Code-Review in 2 Runden: 38 Befunde, alle mittleren und kritischen behoben (Stand `0d9d440`), außer CR-14.
- **Compliance:** Freigabe mit Auflagen T-1 bis T-4 für einen privaten Test-Place (`reports/compliance_check_sprint1.md`).
- **Nicht geprüft:** alles in der Engine; die Fixes aus `0d9d440` noch nicht unabhängig nachgeprüft.
- **Bewusst offen (Sprint 2):** MovementCheck vor dem Speicherstand (CR-14), Feedback-Katalog (CR-29), Avatar-Transparenz (C-A32), Sounds (D-030).

## Schwungturm – nächster Schritt
**Owner-Test P0** (Studio und Handy) nach `reports/owner_test_template.md`. Danach Sprint 2 (Vorschlag im Owner-Bericht §6): Primärziel ist der sichere Fortschritt (MovementCheck → Speicherstand), Nebenziele sind Zone 2 mit DJ und Schrein/Upgrades/Gleiter.
