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

<!-- Weitere Entscheidungen (Konzeptwahl, Compliance-Ergebnis) werden unten angehängt. -->
