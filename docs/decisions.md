# Entscheidungsregister

Format: ID · Datum · Rolle · Entscheidung · Begründung · Evidenz · Status.
`ANNAHME`-Einträge sind Defaults oder Vermutungen ohne Beleg; sie werden geprüft, sobald Belege vorliegen.

## Projekt-Parameter (Sprint 0)

Der Owner hat in §0.1 keine Werte ausgefüllt. Es gelten die Defaults:

| ID | Parameter | Verwendeter Wert | Typ |
|---|---|---|---|
| D-001 | Genre / Thema | offen – Research entscheidet | ANNAHME (Default) |
| D-002 | Zielgruppe | 9–14 Jahre, Mobile zuerst, PC/Konsole unterstützt | ANNAHME (Default) |
| D-003 | Sprintlänge | eine Arbeitssitzung (es wird ohne Kalenderzeit gearbeitet) | ANNAHME (Default) |
| D-004 | Umfang MVP | 1 Kern-Loop, 1 Map, ca. 15–20 Min. Erstinhalt, 2–3 Sprints | ANNAHME (Default) |
| D-005 | Monetarisierung | keine im MVP; danach höchstens kosmetische Game Passes | ANNAHME (Default) |
| D-006 | Budget | 0 Robux, keine kostenpflichtigen Dienste | ANNAHME (Default) |
| D-007 | Verfügbare Tools | im Fähigkeitsinventar ermittelt (`docs/state.md`) | Fakt [GETESTET] |
| D-008 | Sprache im Spiel | Englisch + Deutsch, alle Texte über Lokalisierungstabelle | ANNAHME (Default) |

## Technische und organisatorische Entscheidungen

### D-010 · 2026-10-12 · Orchestrator · Marktrecherche nur über Websuche-Zusammenfassungen
- **Entscheidung:** Research und Regelprüfung stützen sich auf das Websuche-Werkzeug. Jede Zahl trägt den Zusatz „via Websuche-Zusammenfassung“.
- **Begründung:** Direkter Seitenabruf (WebFetch) scheitert für alle Domains (DNS); `*.roblox.com` ist per Egress-Policy gesperrt (HTTP 403 beim CONNECT). Mehr ist in dieser Umgebung nicht möglich (§7: nicht umgehen, sondern dokumentieren).
- **Evidenz:** [GETESTET] – Abrufversuche am 2026-10-12, siehe `docs/log.md`.
- **Folge:** Regeln wurden nicht im Originaltext gelesen. Vor öffentlichem Release muss der Owner die markierten Punkte im Original nachlesen.

### D-011 · 2026-10-12 · Systems Engineer · Selene mit eigener Std `roblox_lite` statt `roblox`
- **Entscheidung:** `selene.toml` nutzt `roblox_lite.yml` (Luau-Basis plus Roblox-Globals als `any`).
- **Begründung:** Selene erzeugt die `roblox`-Std aus dem API-Dump von `setup.rbxcdn.com`, der hier gesperrt ist. Die Roblox-API-Prüfung übernimmt luau-lsp mit aktuellen Typdefinitionen (Stand 2026-10-10).
- **Evidenz:** [GETESTET] – `selene` mit `std = "roblox"` bricht mit „error when getting API dump“ ab; mit `roblox_lite` läuft es.
- **Rückfall:** Auf der Owner-Maschine kann `std = "roblox"` wieder aktiviert werden, sobald der API-Dump erreichbar ist.

### D-012 · 2026-10-12 · QA · Eigener Mini-Testrunner statt TestEZ/Jest-Lua in Sprint 0
- **Entscheidung:** `tests/TestRunner.luau` (ohne Abhängigkeiten) führt reine Logik-Tests im Luau-CLI aus.
- **Begründung:** Externe Bibliotheken brauchen Owner-Freigabe (§8.5). Für reine Logik reicht ein kleiner Runner. Jest-Lua wird als Freigabe vorgeschlagen, sobald Tests in Roblox selbst laufen müssen.
- **Evidenz:** [GETESTET] – siehe `docs/state.md` → Toolchain-Nachweis.

### D-013 · 2026-10-12 · Systems Engineer · Toolchain aus Quellcode bzw. crates.io
- **Entscheidung:** Rojo 7.7.1, Selene 0.31.0 und StyLua 2.6.0 werden über `cargo install` installiert. luau-lsp 1.70.1 und das Luau-CLI werden aus dem öffentlichen Quellcode gebaut (Git-Klon, nur lesend).
- **Begründung:** GitHub-Releases und Toolchain-Manager (Rokit/Aftman) sind hier nicht nutzbar; crates.io und anonyme Git-Klone öffentlicher Repos funktionieren.
- **Evidenz:** [GETESTET]
- **Folge:** `rokit.toml` pinnt dieselben Versionen für die Owner-Maschine (dort nicht getestet).

### D-014 · 2026-10-12 · Orchestrator · Kein CI-Workflow in Sprint 0
- **Entscheidung:** Es wird noch kein GitHub-Actions-Workflow angelegt.
- **Begründung:** Er ließe sich hier nicht testen, und ein ungetesteter roter Workflow wäre nur Rauschen. Die Aufgabe steht im Backlog (B-003).
- **Evidenz:** [ANNAHME]

### D-015 · 2026-10-12 · Systems Engineer · Rojo-Struktur nach Masterprompt §10
- **Entscheidung:** `src/shared` → `ReplicatedStorage.Shared`, `src/server` → `ServerScriptService.Server`, `src/client` → `StarterPlayer.StarterPlayerScripts.Client`. Dateiendung `.luau`.
- **Begründung:** Vorgabe aus §1.5 und §10.
- **Evidenz:** [GETESTET] – `rojo build` erzeugt `build/place.rbxlx` ohne Fehler.

### D-016 · 2026-10-12 · Orchestrator · Kein Spielcode vor Owner-Freigabe des Konzepts
- **Entscheidung:** Sprint 0 enthält nur Toolchain, Projektgerüst und Dokumente. Der Vertical Slice beginnt erst nach der Owner-Freigabe (§11, Schritt 6).
- **Begründung:** Das Datenschema und die Systeme hängen vom gewählten Konzept ab. So fließt kein Aufwand in ein Konzept, das der Owner nicht wählt.

### D-017 · 2026-10-12 · Orchestrator · Offizielle Doku per Git als Primärquelle (verbessert D-010)
- **Entscheidung:** Fakten aus create.roblox.com/docs werden im Quell-Repo `Roblox/creator-docs` gelesen (anonymer Git-Klon, Commit af5f853 vom 2026-10-10, lokal unter `/home/user/roblox/creator-docs`). Belege tragen dann „im Original gelesen“ bzw. `[QUELLE: creator-docs <Pfad>]`.
- **Begründung:** Ein Git-Klon öffentlicher Repos funktioniert, WebFetch nicht. Das ist der regelkonforme Weg zur Primärquelle, kein Umgehen einer Sperre.
- **Evidenz:** [GETESTET]: Klon erfolgreich; Compliance-Digest und Tech-Faktensammlung dagegen abgeglichen.
- **Grenze:** Community Standards, ToS und Advertising Standards liegen nicht in diesem Repo. Sie sind weiterhin nur über Websuche belegt (B-006).

### D-018 · 2026-10-12 · Orchestrator · Konzeptempfehlung „Schwungturm“ (Konzept A) – **wartet auf Owner-Freigabe**
- **Entscheidung (Empfehlung):** Konzept A wird als MVP ausgearbeitet (GDD); B ist Plan B.
- **Begründung:** höchste gewichtete Chancen-Bewertung (16/20 vs. 13/20); Spielspaß entsteht aus Systemen, deren riskanter Teil (Lösbarkeit) per Logik-Tests absicherbar ist; Compliance: geringstes Risiko (Label Minimal, Freigabe mit Auflagen); passt zur 16+-Startphase besser als B.
- **Evidenz:** [QUELLE: research_report.md, compliance_check_sprint0.md v1.1]; Spielspaß [SIMULIERT].
- **Kippt, wenn:** siehe research_report.md §6 (u. a. Bewegung auf Mobile frustriert im Owner-Test).

### D-019 · 2026-10-12 · Game Designer · Compliance-Auflagen C-A1 bis C-A18 übernommen
- **Entscheidung:** Alle Auflagen für A stehen im GDD §11 und gehören zur Definition of Done. Wichtigste Design-Folgen: fremde Namen nur über die Roblox-PlayerList; kein Streak; Spieler-Kollision aus; Hilfe immer kostenlos; keine Referral- oder Engagement-Belohnungen.
- **Evidenz:** [QUELLE: compliance_check_sprint0.md v1.1, Regeln teils im Original gelesen]

### D-020 · 2026-10-12 · Systems Engineer · Eigener PlayerDataService statt ProfileStore (Vorschlag)
- **Entscheidung (Vorschlag):** Session-Lock-Persistenz als eigenes Modul mit injizierbarem DataStore-Backend. ProfileStore (Apache-2.0) bleibt die Alternative mit Owner-Freigabe.
- **Begründung:** Nur so läuft die Datenverlust-Suite hier ausführbar (`[GETESTET]` statt `[SIMULIERT]`). Das Muster (Lock im Datensatz, `UpdateAsync`) entspricht dem bewährten Vorgehen von ProfileStore (Quellcode gelesen).
- **Risiko:** Eigenbau-Fehler. Gegenmaßnahme: Datenverlust-Suite mit Fehler-, Drossel-, Konflikt- und Shutdown-Simulation vor jedem Release; Owner-Studio-Test mit echtem DataStore im Test-Place.

### D-021 · 2026-10-12 · Data Analyst · A/B-Tests über Roblox Experiments
- **Entscheidung:** A/B-Hypothesen (H2, H5, H7) laufen über Roblox Experiments (Config-Key, `ConfigService:GetConfigForPlayerAsync`, 14–60 Tage, max. 2 Varianten). Die Variante wird beim ersten Kontakt im Datensatz gespeichert.
- **Evidenz:** [QUELLE: creator-docs production/experiments.md, configs.md]

<!-- Weitere Entscheidungen werden unten angehängt. -->
