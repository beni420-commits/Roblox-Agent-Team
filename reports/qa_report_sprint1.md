# QA-Bericht Sprint 1 – Vertical Slice Zone 1

Rolle: QA-Engineer · Datum: 2026-10-12 · Build: Commit `0d9d440` (Code-Stand), `BuildInfo.sprint = 1`
Methode: automatisierte Prüfkette `scripts/check.sh` im Luau-CLI, Mutationstests, unabhängiges Code-Review der Roblox-Schicht (`reports/code_review_sprint1.md`).
**Grenze:** Keine Ausführung in der Roblox-Engine (kein Studio). Alles, was Instanzen, Physik, Netzwerk, UI oder Geräte betrifft, ist **nicht geprüft**, bis der Owner-Test vorliegt.

## 1. Ausgeführt vs. nur geschrieben

| Prüfung | Status | Ergebnis |
|---|---|---|
| Format (StyLua 2.6.0) | **ausgeführt** [GETESTET] | grün |
| Lint (Selene 0.31.0, Std `roblox_lite`) | **ausgeführt** [GETESTET] | 0 Fehler, 0 Warnungen |
| Rojo-Build (7.7.1) | **ausgeführt** [GETESTET] | baut; Einstellungen (Invisicam, Streaming „Improved“, CharacterUseJumpPower = false, LocalizationTable EN/DE) im `.rbxlx` nachgewiesen |
| Typprüfung `src` (luau-lsp 1.70.1, Roblox-Typen 2026-10-10, neuer Solver) | **ausgeführt** [GETESTET] | 0 Fehler. Gegenprobe: ein absichtlicher Typfehler im Client wird erkannt |
| Typprüfung `tests` (luau-analyze) | **ausgeführt** [GETESTET] | 0 Fehler |
| Logik-Tests (81 in 11 Suites) | **ausgeführt** [GETESTET] | **81/81 grün** (Laufzeit < 1 s) |
| Mutationstests (3 absichtliche Fehler) | **ausgeführt** [GETESTET] | alle 3 erkannt (zu große Lücken, fehlende Deckenprüfung, falsche Doppelsprung-Physik) |
| Exploit-Suite (10 Tests) | **ausgeführt** [GETESTET] | grün: Müll-Argumente (NaN, ±inf, Bruch, riesig, falsche Typen, zusätzliche/fehlende Argumente), Spam (1000/s), unbekannte Remotes, Teleport an die Spitze, Doppel-Einsammeln, Funken entfernter Etagen, Lager-Bonus-Farming, Onboarding-Spam, Reset-Spam |
| Datenverlust-Suite | **nicht vorhanden** | Kein Speicherstand in Sprint 1 (kommt mit A-007 in Sprint 2) |
| CI-Workflow (`.github/workflows/ci.yml`) | **geschrieben, nicht auf GitHub ausgeführt** | Hol- und Submodul-Schritte lokal identisch ausgeführt [GETESTET]; Bau-Schritte wie hier gelaufen |
| Code-Review Roblox-Schicht (16 Dateien) | **ausgeführt** (statisch + Doku-Abgleich, 2 Runden) | 38 Befunde, kein Blocker; Fixes in `c7f81b1` und `0d9d440`; Status siehe §3 |
| Engine-Tests (Studio, Gerät, Mehrspieler) | **nicht ausgeführt** | Owner-Test `reports/owner_test_template.md` |
| Performance (FPS, Speicher, Heartbeat) | **nicht gemessen** | nur am Gerät möglich |

### Testinventar
| Suite | Tests | Schwerpunkt |
|---|---|---|
| shared/Util/Prng | 7 | Determinismus, Verteilung, Grenzwerte, Seed-Kombination |
| shared/Util/Validator | 7 | Remote-Argumente inkl. NaN/inf/Typen/Anzahl |
| shared/Util/RateLimiter | 5 | Token Bucket, Spam, Uhr rückwärts |
| shared/Util/Trove | 3 | Aufräumen, Fehlerisolation |
| shared/Logic/Reachability | 12 | Sprungphysik, Referenz vs. großzügig, Decke, Pad, Pflicht-Fähigkeiten (Befunde für Zone 2/3) |
| shared/Logic/TowerGenerator | 13 | Determinismus, **200 Seeds × 10 Etagen lösbar**, Hilfsstufen lösbar und nie leer, Pad-Sicherheitsnetz, Funken, Budget, Helix, Kopffreiheit, Fingerabdruck |
| shared/Logic/RunState | 8 | lückenlose Etagen, Lager-Bonus einmalig, Hilfe 3/6, oberste Etage, Funken, Onboarding |
| shared/Logic/LandingLocator | 10 | Etagenerkennung, 10-Hz-Abtastung, Fall-Schwelle je Sektor, Boden-Regel, oberste Etage, Rand |
| exploit/RemoteExploit | 10 | siehe oben |
| shared/Telemetry/Events | 3 | Katalog-Grenzen, Funnel-Schritte, Kardinalität |
| shared/BuildInfo | 3 | Metadaten |

## 2. Fehler nach Schweregrad (Stand `0d9d440`)

| Schwere | Anzahl offen | Details |
|---|---|---|
| Blocker | 0 | – |
| Kritisch | 0 offen | CR-01 (Sprungpad-Impuls) behoben, Bestätigung im Studio nötig (Owner-Test B6). Zusätzliches Sicherheitsnetz: Pad-Anstieg ≤ 6,5, ist auch ohne Pad lösbar [GETESTET] |
| Mittel | 1 bewusst offen | CR-14 Server-Autorität für Bewegung (sequenzielles Hochteleportieren). In Sprint 1 ohne Speicherstand geringer Schaden; MovementCheck (A-011) kommt in Sprint 2 **vor** dem Speicherstand |
| Gering | 2 bewusst offen | CR-29 Feedback-Katalog (A-019), CR-30 Avatar-Transparenz C-A32 (A-020) |

Reproduktionsschritte und Belege je Befund: `reports/code_review_sprint1.md`.

## 3. Nachprüfung der Fixes
- **Runde 1 (unabhängig):** Nachprüfung am Stand `c7f81b1`. Ergebnis: 23 behoben, 4 teilweise, 3 bewusst offen; 8 neue Befunde (CR-31 bis CR-38, davon 1 mittel).
- **Runde 2 (Orchestrator):** Fixes in `0d9d440` (CR-31 bis CR-37, Rest von CR-05), siehe `code_review_sprint1.md` §0a. Eine erneute unabhängige Prüfung von `0d9d440` steht aus.
- **Offen ab Mittel:** nur CR-14 (MovementCheck, bewusst Sprint 2).

## 4. Gate-Bewertung (Masterprompt §5)

| Gate | Status | Begründung |
|---|---|---|
| Stabilität | **offen** | Logik 0 Fehler [GETESTET]; „keine Fehler in der Ausgabe-Konsole“ nur im Studio prüfbar (Owner-Test A2) |
| Sicherheit | **teilweise** | Remotes validiert + rate-limitiert, Exploit-Suite grün [GETESTET]; Bewegungs-Plausibilität fehlt (CR-14 → Sprint 2) |
| Daten | nicht anwendbar | kein Speicherstand in Sprint 1 |
| Performance | **offen** | nicht messbar ohne Gerät; Budgets eingehalten, soweit statisch prüfbar (≤ 120 Bauteile je Etage [GETESTET]) |

## 5. Die drei größten Restrisiken
1. **Engine-Verhalten ungeprüft:** Pad-Impuls, Coyote-Time, Invisicam-Kamera, Streaming, Reset-Knopf-Callback, Raycast-Sturzerkennung. Alles korrekt nach Doku und Typen, aber nicht ausgeführt.
2. **Bewegung ist clientseitig:** Ohne MovementCheck sind Etagen und Funken per Teleport-Exploit erreichbar (bewusst Sprint 2, vor dem Speicherstand).
3. **Kalibrierung:** Zone 1 ist mit Referenzfaktor 0,75 bewusst sehr leicht. Ob das Spaß macht oder langweilt, zeigt erst der Owner-Test.
