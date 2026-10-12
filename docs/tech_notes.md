# Tech Notes

Rolle: Systems Engineer · Stand: 2026-10-12 (Sprint 0) · Status: **Entwurf; gilt ab Owner-Freigabe des Konzepts**

Fakten-Kennzeichnung nach §0.2. Externe Fakten stammen aus `docs/research_tech_facts_2026-10-12.md` (nur Websuche-Zusammenfassungen) oder sind als `[VORWISSEN, nicht aktuell]` markiert.

---

## 1. Toolchain und Prüfkette

| Schritt | Werkzeug | Befehl (in `scripts/check.sh`) | Status in dieser Umgebung |
|---|---|---|---|
| Format | StyLua 2.6.0 | `stylua --check src tests` | [GETESTET] läuft |
| Lint | Selene 0.31.0, Std `roblox_lite` (D-011) | `selene src tests` | [GETESTET] läuft |
| Build | Rojo 7.7.1 | `rojo build default.project.json -o build/place.rbxlx` | [GETESTET] läuft |
| Typprüfung | luau-lsp 1.70.1 + Roblox-Typen (Stand 2026-10-10) | `luau-lsp analyze --platform=roblox --sourcemap=sourcemap.json --definitions=@roblox=… src` | siehe `state.md` |
| Logik-Tests | Luau-CLI + `tests/TestRunner.luau` | `luau tests/run.luau` | siehe `state.md` |
| Tests in der Engine | – (Studio fehlt; Open Cloud gesperrt) | – | **nicht verfügbar** → Owner-Checkliste (§7) |

**Testbarkeits-Prinzip:** Die gesamte Spiellogik, die „zählt“ (Economy, Validierung, Rate-Limiting, Progression, Datenschema/Migration, Session-Lock-Zustandsmaschine), wird **Roblox-unabhängig** geschrieben. Engine-Dienste (DataStore, Players, Zeit, Zufall) werden als Parameter übergeben (Dependency Injection). Dadurch laufen diese Module im Luau-CLI mit Mocks und erreichen `[GETESTET]`. Die Roblox-„Klebeschicht“ (Instanzen, Remotes, UI) bleibt dünn und wird über die Owner-Studio-Checkliste geprüft. Bis dahin gilt sie als **nicht geprüft**.

**Requires:** Logik-Module in `src/shared` nutzen relative String-Requires (`require("./Module")`). Diese funktionieren im Luau-CLI und laut luau-lsp-Changelog auch im Roblox-Modus (relative Requires laufen über den DataModel-Baum) [QUELLE: luau-lsp CHANGELOG.md, Commit 6f90396, gelesen 2026-10-12]. Dass die Laufzeit in Roblox selbst so auflöst, ist `[VORWISSEN, nicht aktuell]` und gehört deshalb zur ersten Owner-Studio-Prüfung.

## 2. Architektur

```
ServerScriptService.Server            (src/server)
  Main.server.luau        – Bootstrap: startet Services in fester Reihenfolge, danach Players-Events
  Services/
    PlayerDataService     – Laden/Speichern, Session-Lock, Autosave, BindToClose
    NetService            – registriert alle Remotes mit Validierung + Rate-Limit
    <Spiel>Service        – Kernsystem(e) des MVP, ruft nur Logik-Module + PlayerDataService
    AnalyticsService-Wrapper (TelemetryService) – einziges Modul, das AnalyticsService aufruft
ReplicatedStorage.Shared              (src/shared)
  Logic/                  – reine Logik (Economy, Progression, Regeln) – Roblox-unabhängig, getestet
  Net/                    – Remote-Definitionen (Name, Argument-Schema, Rate-Limit) – geteilt Client/Server
  Data/                   – Datenschema, Defaults, Migrationen – Roblox-unabhängig, getestet
  Util/                   – Validator, RateLimiter, Signal, Maid/Trove-ähnliches Cleanup (eigene Implementierung)
  Localization/           – Schlüssel-Konstanten (Texte selbst in LocalizationTable)
StarterPlayer.StarterPlayerScripts.Client  (src/client)
  Main.client.luau        – Bootstrap Client
  Controllers/            – Input (Touch/Maus/Gamepad), Kamera, UI, Feedback (Sound/Partikel)
  UI/                     – UI-Komponenten (prozedural erzeugt, keine externen Bibliotheken)
```

Regeln:
- **Ein Modul = eine Verantwortung.** Kein Modul greift auf den Zustand eines anderen zu, sondern nur über dessen API.
- **Server-Autorität:** Der Client sendet nur Absichten (z. B. „möchte Aktion X auf Objekt Y“). Der Server prüft Reichweite, Abklingzeit, Kosten und Zustand und berechnet das Ergebnis. Der Client zeigt nur an (optimistische Anzeige ist erlaubt, der Server-Zustand gewinnt immer).
- **Keine RemoteFunction Server→Client.** Client→Server-RemoteFunctions nur dort, wo eine Antwort nötig ist; ansonsten RemoteEvents.
- **Cleanup:** Jede Verbindung und jede erzeugte Instanz gehört einem Besitzer-Objekt (Trove-Muster) und wird bei `PlayerRemoving` bzw. Objektzerstörung freigegeben.
- **Keine Schleifen ohne Yield.** Taktbasierte Logik läuft über einen zentralen `Heartbeat`-Scheduler mit Zeitbudget statt über viele `while true`-Schleifen.

## 3. Remote-Sicherheit (gilt für jedes Remote)

Jedes Remote wird **deklarativ** in `Shared/Net` definiert:

```luau
-- Beispiel (Entwurf)
Remotes.RequestAction = {
	kind = "event",                         -- "event" | "function"
	args = { Validator.enumOf(ACTION_IDS), Validator.instanceTag("Interactable") },
	rateLimit = { perSecond = 5, burst = 10 },
}
```

Der `NetService` erzwingt vor jedem Handler:
1. **Anzahl der Argumente** ist exakt richtig; überzählige Argumente ⇒ verwerfen.
2. **Typprüfung** jedes Arguments (`typeof`). Zahlen: `x == x` (kein NaN), `math.abs(x) ~= math.huge`, Ganzzahl-Check wo nötig, Bereichsgrenzen. Strings: Längenlimit, UTF-8-gültig (`utf8.len`). Tabellen: nur bekannte Schlüssel, Tiefe ≤ 2, Elementanzahl begrenzt. Instanzen: `typeof == "Instance"`, `IsDescendantOf(workspace)` bzw. erwartete Klasse/Tag.
3. **Rate-Limit** pro Spieler und Remote (Token Bucket). Überschreitung ⇒ Aufruf verwerfen und Zähler erhöhen. Kein Kick bei normalem Spam. Erst bei extremem Missbrauch (> 10× Limit über 10 s) Kick mit neutraler Meldung. [ANNAHME: Schwelle wird im Playtest justiert]
4. **Plausibilität/Zustand** im Handler: Darf der Spieler das jetzt? (Abstand zum Objekt, Abklingzeit, Kosten, Reihenfolge der Schritte, Transaktions-Lock gegen Doppelkäufe)
5. **Fehler im Handler** werden per `pcall` isoliert. Sie werden geloggt (ohne personenbezogene Daten), und der Server-Zustand bleibt konsistent: erst prüfen, dann alles auf einmal anwenden.

Bewegungs-Plausibilität (Speed/Teleport): Der Server vergleicht die Charakterposition je Spieler alle 0,5 s mit `WalkSpeed`/`JumpPower`-Grenzen plus Toleranz. Bei Abweichung gibt es **keine** sofortige Strafe; aber Aktionen, die Nähe erfordern, prüfen die Server-Position. [ANNAHME: reicht für ein MVP ohne PvP]

## 4. Datenpersistenz

**Ansatz (Vorschlag):** eigenes Modul `PlayerDataService` nach bewährten Prinzipien (Session-Lock, Retry mit Backoff, versioniertes Schema, Migration), mit **injizierbarem DataStore-Backend**. So läuft die Datenverlust-Suite im Luau-CLI gegen einen Mock, der Fehler, Drosselung, Sessionkonflikte und Shutdown simuliert, und erreicht `[GETESTET]`.
Alternative mit Owner-Freigabe: ProfileStore (MIT) [ANNAHME zur Lizenz, nicht im Original geprüft]. Vorteil: praxiserprobt. Nachteil: in dieser Umgebung nicht ausführbar testbar und externe Abhängigkeit (§8.5). → Freigabeanfrage im Owner-Bericht.

Mechanik (Entwurf):
- **Key:** `player_<UserId>` in DataStore `PlayerData_v1` (der Store-Name enthält die Hauptversion, damit ein harter Schnitt möglich ist).
- **Session-Lock:** Der Datensatz enthält `lock = { jobId, placeId, timestamp }`. Laden geschieht per `UpdateAsync`: Ist der Lock frei oder älter als 30 min, wird er übernommen. Ist er fremd und frisch, wird bis zu 5× mit Backoff (1, 2, 4, 8, 16 s) neu versucht. Danach Kick mit Hinweis „Daten werden noch gespeichert, bitte gleich erneut beitreten“.
- **Speichern:** nur per `UpdateAsync` und nur, wenn der Lock noch uns gehört. Sonst Abbruch und Protokoll, damit kein Überschreiben fremder Sessions passiert.
- **Autosave** alle 120 s pro Spieler, zeitlich verteilt. Dazu Speichern bei `PlayerRemoving` (mit Lock-Freigabe) und `BindToClose` (alle parallel, Zeitbudget ≤ 25 s) [VORWISSEN, nicht aktuell: BindToClose hat max. 30 s].
- **Retry:** jede DataStore-Operation bis zu 3× mit exponentiellem Backoff plus Jitter. Budget-Prüfung über `GetRequestBudgetForRequestType` vor nicht-kritischen Schreibvorgängen.
- **Schema-Versionierung:** Feld `schemaVersion`. Beim Laden läuft `Migrations[v → v+1]` schrittweise bis zur aktuellen Version. Migrationen sind reine Funktionen und haben Tests. Das Speichern einer **neueren** Version, als der Server kennt, wird verweigert (Schutz bei gemischten Server-Versionen).
- **Transaktionen** (Kauf mit Spielwährung, Belohnung): zuerst im Speicher prüfen, dann atomar anwenden und als „dirty“ markieren. Bei Rejoin während einer Transaktion gilt der zuletzt gespeicherte Zustand. Es gibt keine halben Zustände, weil eine Transaktion nur aus einer einzigen Tabellenänderung besteht.
- **Datensparsamkeit:** keine personenbezogenen Daten außer UserId als Key. `SetAsync`/`UpdateAsync` übergeben die UserId im `userIds`-Parameter, damit Löschanfragen (DSGVO/„Right to be forgotten“) zuordenbar sind [VORWISSEN, nicht aktuell].
- **Datenschema v1:** siehe §6 (konzeptabhängig, wird nach Konzeptwahl finalisiert).

## 5. Performance-Budgets (Sprint-0-Festlegung; Defaults aus §5 konkretisiert)

| Bereich | Budget | Messung | Begründung |
|---|---|---|---|
| Client-FPS Low-End-Mobile | ≥ 30 FPS (Normalbetrieb), P5 ≥ 25 FPS | MicroProfiler / Owner-Gerät | Gate §5 |
| Client-Skriptzeit | ≤ 4 ms pro Frame (Mittel) | MicroProfiler | ≈ 12 % des 33-ms-Frames [ANNAHME] |
| Client-Speicher | ≤ 800 MB gesamt auf Low-End-Mobile | Developer Console → Memory | [ANNAHME] Low-End-Geräte stürzen bei hohem Speicher ab |
| Instanzen Map | ≤ 15 000 BaseParts gesamt, ≤ 3 000 im Sichtbereich | Skript-Zählung im Test | Primitive-Stil, Mobile [ANNAHME] |
| Lichter | ≤ 12 dynamische Lichter mit Schatten; dekorative Lichter `Shadows = false` | Code-Review | Mobile-GPU [ANNAHME] |
| Partikel | ≤ 25 aktive Emitter, Summe `Rate` ≤ 250/s | Code-Review + Test | Mobile [ANNAHME] |
| Server-Heartbeat | ≥ 55/s bei voller Belegung (Ziel ~60/s) | `workspace:GetRealPhysicsFPS()` + Stats im Lasttest | Gate §5 |
| Server-Skriptzeit | ≤ 6 ms pro Heartbeat (Mittel) | ScriptProfiler / MicroProfiler | [ANNAHME] |
| Speicherwachstum | ≤ 5 % über 30 min (Server und Client) | Developer Console, Messpunkte bei 5 und 35 min | Gate §5 |
| Netzwerk | ≤ 20 Remote-Aufrufe/s pro Spieler (Client→Server); Server→Client ≤ 30 KB/s pro Spieler im Mittel | Rate-Limiter-Zähler, Network-Stats | [ANNAHME] |
| Max. Spieler pro Server | 12 | Place-Einstellung | kleinere Server = stabiler auf Mobile, sozial ausreichend [ANNAHME] |
| DataStore | Autosave 120 s; ≤ 1 Schreibvorgang/Key je 6 s | Zähler im PlayerDataService | [VORWISSEN, nicht aktuell: 6-s-Schreibabstand je Key] |

**StreamingEnabled:** **an** (Entscheidung). Begründung: Speicher und Ladezeit auf Mobile. Folge: Der Client darf nicht davon ausgehen, dass entfernte Instanzen existieren (`WaitForChild` mit Timeout bzw. `CollectionService`-Signale nutzen). Kritische, kleine Modelle (z. B. Spawn, Onboarding-Pfad) bekommen `ModelStreamingMode = Persistent` oder `Atomic`, wo nötig. Wird nach der Konzeptwahl bestätigt (§6).

## 6. Konzeptabhängiger Teil

*Wird nach Abschluss der Konzeptwahl im selben Sprint ergänzt (Datenschema v1, Systemliste, konkrete Remotes).*

## 7. Owner-Studio-Checkliste (Engine-Prüfungen, die hier nicht möglich sind)

Wird pro Sprint gepflegt. Sprint 0:
1. `rojo serve` + Rojo-Plugin oder `build/place.rbxlx` in Studio öffnen. Erwartung: Der Place öffnet ohne Fehler in der Ausgabe-Konsole.
2. Play-Test (F5): keine Fehler/Warnungen aus `Server.Main`/`Client.Main`.
3. Prüfen, ob relative String-Requires (`require("./X")`) in einem ModuleScript unter `ReplicatedStorage.Shared` funktionieren (wichtig für die Testbarkeit, §1).

## 8. Bekannte Grenzen

- Keine Ausführung in der Roblox-Engine in dieser Umgebung. Alles, was Instanzen, Physik, Rendering, Netzwerk-Replikation, DataStore-Realverhalten oder Geräteleistung betrifft, ist hier höchstens `[SIMULIERT]`.
- Performance-Gates können nur der Owner (bzw. später Open-Cloud-Tests) prüfen.
- Selene prüft keine Roblox-API-Nutzung (D-011); das übernimmt luau-lsp.
