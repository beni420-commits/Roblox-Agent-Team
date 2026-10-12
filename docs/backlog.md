# Backlog (priorisiert nach ICE)

ICE = Impact × Confidence × Ease, je 1–10. Confidence richtet sich nach der Evidenz: GEMESSEN 8–10 · GETESTET 6–8 · SIMULIERT/QUELLE 4–6 · ANNAHME 1–3.
Stand: 2026-10-12 (Sprint 0, nach GDD v0.2). Sprint-Zuordnung ist ein Vorschlag und gilt erst nach Owner-Freigabe des Konzepts. Hinweis: Durch den Persona-Playtest ist der Must-Umfang gewachsen; realistisch braucht das MVP **3 Sprints** statt 2.

## Infrastruktur und Prozess

| ID | Eintrag | I | C | E | ICE | Evidenz | Status / Sprint |
|---|---|---|---|---|---|---|---|
| B-001 | Owner-Studio-Smoke-Test: `build/place.rbxlx` öffnen, Play, Konsole fehlerfrei, String-Require-Test (tech_notes §7) | 8 | 7 | 9 | 504 | GETESTET (Build) | offen – Owner, vor Sprint 1 |
| B-002 | Gemeinsame Util-Module: Validator, RateLimiter (Token Bucket), Trove, Signal – mit Tests | 9 | 7 | 7 | 441 | QUELLE (creator-docs V1) | Sprint 1 |
| B-003 | CI-Workflow (GitHub Actions): StyLua, Selene, luau-lsp, luau-analyze, Logik-Tests | 7 | 6 | 7 | 294 | ANNAHME (hier nicht testbar) | Sprint 1 |
| B-004 | Engine-Tests per Open Cloud Luau Execution gegen eigenen Test-Place (braucht API-Key → Freigabe §8.7, Netzzugang zu apis.roblox.com) | 8 | 5 | 3 | 120 | QUELLE (creator-docs V1) | nach Freigabe |
| B-005 | Plan für echte Playtests vor Release umsetzen (siehe playtest_report_sprint0.md) | 9 | 6 | 6 | 324 | SIMULIERT | vor Release |
| B-006 | Regeln aus Community Standards/ToS im Original nachlesen (Liste „nicht verifiziert“ im Regel-Digest) | 9 | 5 | 6 | 270 | QUELLE (nur Websuche) | Owner, vor Release |
| B-007 | Lune als Test-Runtime (Datei-API, automatische Spec-Suche), sobald Build-Zeit verfügbar | 3 | 6 | 6 | 108 | GETESTET (Build abgebrochen) | später |
| B-008 | Selene-`roblox`-Std auf Owner-Maschine aktivieren (statt roblox_lite) | 3 | 5 | 8 | 120 | GETESTET (hier blockiert) | Owner optional |
| B-009 | `rokit.toml` gegen Owner-Installation testen (Selene 0.31.0 vs. neuester Tag 0.32.0 entscheiden) | 3 | 5 | 8 | 120 | QUELLE | Sprint 1 |

## Konzept A „Schwungturm“ (nach Owner-Freigabe)

| ID | Eintrag | I | C | E | ICE | Evidenz | Sprint |
|---|---|---|---|---|---|---|---|
| A-001 | `Logic/TowerGenerator` (Helix) + deterministischer PRNG + Bauteil-Budget-Test | 10 | 6 | 6 | 360 | ANNAHME / Design | 1 |
| A-002 | `Logic/Reachability` mit Referenzcharakter-Simulation (Flugbahn, Hitbox, Kopffreiheit, Latenz, Pflicht-Fähigkeit) + Tests für 200 Seeds | 10 | 6 | 5 | 300 | SIMULIERT (P-02) | 1 |
| A-003 | TowerBuilder (Instanzen), Zone 1, Lager, Etagen-Rücksetzpunkt, Gipfel-Leuchtfeuer, Spieler-Kollision aus | 10 | 5 | 6 | 300 | SIMULIERT (P-01, P-13) | 1 |
| A-004 | Funken: Generator-IDs, `CollectSpark`-Validierung, HUD | 9 | 5 | 7 | 315 | ANNAHME | 1 |
| A-005 | Onboarding ohne Text (Kamera-Schwenk, Leuchtpfad), Funnel-Events | 9 | 4 | 6 | 216 | ANNAHME (H1) | 1 |
| A-006 | InputController (IAS, PreferredInput), Mobile-Knopf-Layout relativ zum JumpButton; Coyote-Time, Sprungpuffer, DJ-Flanke; eigene Verfolgerkamera | 9 | 5 | 5 | 225 | QUELLE + SIMULIERT (P-04, P-05) | 1 |
| A-007 | PlayerDataService mit Session-Lock, Mock-Backend, Datenverlust-Suite | 10 | 6 | 4 | 240 | QUELLE (Muster V1) | 2 |
| A-008 | Zonen 2–3, Doppelsprung, Schwebe-Dash, Tunnel/Windwand, Übungsstrecken mit Hilfe, Gipfel-Abschluss | 9 | 5 | 5 | 225 | SIMULIERT (P-03, P-05) | 2 |
| A-009 | Funkenschrein + Upgrades + Gleiter (Economy-Logik + UI), Hilfe-System 3/6 | 8 | 5 | 6 | 240 | SIMULIERT (P-12, H2, H4) | 2 |
| A-010 | Lokalisierung EN/DE (LocalizationTable, Key-Konstanten) | 7 | 7 | 7 | 343 | QUELLE | 2 |
| A-011 | MovementCheck (Fensterbudget, Fähigkeiten-Grenzen, Luftzeit, lückenlose Etagenfolge) + Tests mit synthetischen Spuren | 8 | 5 | 5 | 200 | SIMULIERT (P-06) | 2 |
| A-017 | Social ohne Chat: Freundes-Marker, Lager-Lift, 3 Signale (C-A30), gemeinsame Lager-Feier | 8 | 4 | 6 | 192 | SIMULIERT (P-07) | 2 |
| A-018 | Neu gemischter Turm ab Lauf 2 + Lebenszeit-Meilensteine (5 Leuchtspur-Farben) | 7 | 4 | 7 | 196 | SIMULIERT (P-08) | 2 |
| A-012 | Tagesturm mit Normwerten + Bestmarke (Bestenliste nur über Roblox-PlayerList, C-A16) | 7 | 3 | 5 | 105 | ANNAHME (H5) | 3 (Should) |
| A-013 | Wandsprung (Should); optionale Funkenrouten sind mit dem Gleiter Teil von A-009 | 5 | 4 | 5 | 100 | ANNAHME | 3 (Should) |
| A-014 | Schwung-Leiste | 5 | 3 | 7 | 105 | ANNAHME (H7) | 3 (Should) |
| A-015 | Seilschaft-Bonus (C-A31) | 5 | 3 | 6 | 90 | ANNAHME | nach MVP (Could) |

## Verworfene bzw. zurückgestellte Ideen
- Monetarisierung jeder Art: im MVP ausgeschlossen (D-005). Später höchstens kosmetische Game Passes, nur mit Owner-Freigabe (§8.2).
- Konzept B „Formwächter“ und C „Kreuzbeet“: Plan B bzw. C laut Research. Neu bewerten, wenn die Kipp-Bedingungen aus `research_report.md` §6 eintreten.
