# Tech Notes

Rolle: Systems Engineer · Stand: 2026-10-12 (Sprint 0) · Status: **Entwurf; gilt ab Owner-Freigabe des Konzepts**

Fakten-Kennzeichnung nach §0.2. Externe Fakten stammen aus `docs/research_tech_facts_2026-10-12.md`. Dort ist der Großteil **V1**, also im Primärtext gelesen: in der offiziellen Doku-Quelle `Roblox/creator-docs` @af5f853 (2026-10-10, per Git) bzw. in den Tool-Repos. Kennzeichnung hier: `[QUELLE: creator-docs <Pfad>]`. Unverifiziertes ist als `[VORWISSEN, nicht aktuell]` markiert.

---

## 1. Toolchain und Prüfkette

| Schritt | Werkzeug | Befehl (in `scripts/check.sh`) | Status in dieser Umgebung |
|---|---|---|---|
| Format | StyLua 2.6.0 | `stylua --check src tests` | [GETESTET] läuft |
| Lint | Selene 0.31.0 (neueste auf crates.io; GitHub-Tag 0.32.0 existiert), Std `roblox_lite` (D-011) | `selene src tests` | [GETESTET] läuft |
| Build | Rojo 7.7.1 | `rojo build default.project.json -o build/place.rbxlx` | [GETESTET] läuft |
| Typprüfung | luau-lsp 1.70.1 + Roblox-Typen (Stand 2026-10-10), neuer Solver | `luau-lsp analyze --platform=roblox --sourcemap=sourcemap.json --definitions=@roblox=… src` | [GETESTET] läuft (fand bereits einen echten Typfehler) |
| Typprüfung Tests | `luau-analyze` (Luau-Submodul 8387cfb, ≈ Luau 0.742) | `luau-analyze tests/` | [GETESTET] läuft |
| Logik-Tests | Luau-CLI + `tests/TestRunner.luau` | `luau tests/run.luau` | [GETESTET] läuft |
| Tests in der Engine | – (Studio fehlt; `apis.roblox.com` gesperrt) | – | **nicht verfügbar** → Owner-Checkliste (§7) |

**Option für später: CI in der Engine über Open Cloud Luau Execution.** Ablauf: Place per Open Cloud publizieren (BETA, ≤ 10 MiB), dann `POST /cloud/v2/universes/{u}/places/{p}/luau-execution-session-tasks` (Scope `universe.place.luau-execution-session:write`), danach pollen und Logs holen. Grenzen: Skript ≤ 4 MB, Laufzeit ≤ 5 min, keine Physik. **DataStores sind dabei echt**, deshalb ist ein eigener Test-Place bzw. ein eigenes Test-Universe Pflicht. [QUELLE: creator-docs reference/cloud/cloud.docs.json, cloud/guides/usage-place-publishing.md] Voraussetzungen: API-Key (Owner-Freigabe §8.7) und eine Umgebung mit Zugriff auf `apis.roblox.com`. → Backlog B-004.

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
2. **Typprüfung** jedes Arguments (`typeof`). Zahlen: endlich (`math.isfinite(x)`, neu in Luau; Fallback `x == x and math.abs(x) ~= math.huge`, denn NaN und ±inf sind gültige Remote-Werte [QUELLE: creator-docs scripting/security/client-server-boundary.md]), Ganzzahl-Check wo nötig, Bereichsgrenzen. Strings: Längenlimit, UTF-8-gültig (`utf8.len`). Tabellen: nur bekannte Schlüssel, Tiefe ≤ 2, Elementanzahl begrenzt. Instanzen: `typeof == "Instance"`, `IsDescendantOf(workspace)` bzw. erwartete Klasse/Tag.
3. **Rate-Limit** pro Spieler und Remote (Token Bucket, so auch von Roblox empfohlen; gilt ebenso für `Touched`, ProximityPrompts und ClickDetectors [QUELLE: creator-docs scripting/security/client-server-boundary.md]). Die Engine erlaubt ~500 Requests/s pro Client und Remote-Typ, unser Limit liegt weit darunter. Überschreitung ⇒ Aufruf verwerfen und Zähler erhöhen. Kein Kick bei normalem Spam. Erst bei extremem Missbrauch (> 10× Limit über 10 s) Kick mit neutraler Meldung. [ANNAHME: Schwelle wird im Playtest justiert]
4. **Plausibilität/Zustand** im Handler: Darf der Spieler das jetzt? (Abstand zum Objekt, Abklingzeit, Kosten, Reihenfolge der Schritte, Transaktions-Lock gegen Doppelkäufe)
5. **Fehler im Handler** werden per `pcall` isoliert. Sie werden geloggt (ohne personenbezogene Daten), und der Server-Zustand bleibt konsistent: erst prüfen, dann alles auf einmal anwenden.

Bewegungs-Plausibilität (Speed/Teleport): Der Server vergleicht die Charakterposition je Spieler alle 0,5 s mit `WalkSpeed`/`JumpPower`-Grenzen plus Toleranz. Bei Abweichung gibt es **keine** sofortige Strafe; aber Aktionen, die Nähe erfordern, prüfen die Server-Position. [ANNAHME: reicht für ein MVP ohne PvP]

## 4. Datenpersistenz

**Ansatz (Vorschlag):** eigenes Modul `PlayerDataService` nach bewährten Prinzipien (Session-Lock, Retry mit Backoff, versioniertes Schema, Migration), mit **injizierbarem DataStore-Backend**. So läuft die Datenverlust-Suite im Luau-CLI gegen einen Mock, der Fehler, Drosselung, Sessionkonflikte und Shutdown simuliert, und erreicht `[GETESTET]`.
Alternative mit Owner-Freigabe: ProfileStore 1.0.3 (**Apache-2.0**, LICENSE im Repo gelesen; Nachfolger des nicht mehr unterstützten ProfileService). Es arbeitet mit `UpdateAsync` und MessagingService, nicht mit MemoryStore (Autosave 300 s, Session-Steal 40 s). Vorteil: praxiserprobt. Nachteil: hier nicht ausführbar testbar und eine externe Abhängigkeit (§8.5). → Freigabeanfrage im Owner-Bericht. Unser Entwurf folgt demselben bewährten Muster (Lock im Datensatz, `UpdateAsync`).

Mechanik (Entwurf):
- **Key:** `player_<UserId>` in DataStore `PlayerData_v1` (der Store-Name enthält die Hauptversion, damit ein harter Schnitt möglich ist).
- **Session-Lock:** Der Datensatz enthält `lock = { jobId, placeId, timestamp }`. Laden geschieht per `UpdateAsync`: Ist der Lock frei oder älter als 30 min, wird er übernommen. Ist er fremd und frisch, wird bis zu 5× mit Backoff (1, 2, 4, 8, 16 s) neu versucht. Danach Kick mit Hinweis „Daten werden noch gespeichert, bitte gleich erneut beitreten“.
- **Speichern:** nur per `UpdateAsync` und nur, wenn der Lock noch uns gehört. Sonst gibt der Callback `nil` zurück, dann bricht der Write ab und wird protokolliert. Der Callback darf nicht yielden und muss `keyInfo:GetUserIds()`/`GetMetadata()` durchreichen [QUELLE: creator-docs cloud-services/data-stores/index.md, GlobalDataStore.yaml]. `GetAsync` cacht 4 s, deshalb laufen Lock-Prüfungen nur über `UpdateAsync`.
- **Autosave** alle 120 s pro Spieler, zeitlich verteilt. Dazu Speichern bei `PlayerRemoving` (mit Lock-Freigabe) und `BindToClose` (alle parallel, Zeitbudget ≤ 25 s; der Server wartet höchstens 30 s [QUELLE: creator-docs reference/engine/classes/DataModel.yaml]).
- **Retry:** jede DataStore-Operation bis zu 3× mit exponentiellem Backoff plus Jitter. Bei Queue-Überlauf (Fehler 301–306) keine enge Schleife. Budget-Prüfung über `GetRequestBudgetForRequestType` vor nicht-kritischen Schreibvorgängen. Server-Budget/min: Read/Write je 60 + 40 × Spieler. Experience-weit: Write 300 + 20 × CCU, geteilt mit Open Cloud; `UpdateAsync` zählt als Read **und** Write [QUELLE: creator-docs cloud-services/data-stores/error-codes-and-limits.md].
- **Schema-Versionierung:** Feld `schemaVersion`. Beim Laden läuft `Migrations[v → v+1]` schrittweise bis zur aktuellen Version. Migrationen sind reine Funktionen und haben Tests. Das Speichern einer **neueren** Version, als der Server kennt, wird verweigert (Schutz bei gemischten Server-Versionen).
- **Transaktionen** (Kauf mit Spielwährung, Belohnung): zuerst im Speicher prüfen, dann atomar anwenden und als „dirty“ markieren. Bei Rejoin während einer Transaktion gilt der zuletzt gespeicherte Zustand. Es gibt keine halben Zustände, weil eine Transaktion nur aus einer einzigen Tabellenänderung besteht.
- **Datensparsamkeit:** keine personenbezogenen Daten außer der UserId im Key. Jeder Write übergibt `{player.UserId}` als `userIds` (von Roblox „highly recommended“ für DSGVO). Beim Launch wird ein **RTBF-Löschtemplate** `PlayerData_v1` / `player_{UserId}` im Creator Hub angelegt [QUELLE: creator-docs GlobalDataStore.yaml, cloud-services/data-stores/right-to-be-forgotten.md].
- **Größe:** Datensatz-Ziel < 100 KB (Limit 4.194.304 Zeichen JSON). Größen-Check per `JSONEncode` im Save-Pfad. Nicht selbst komprimieren [QUELLE: creator-docs error-codes-and-limits.md].
- **Studio-Tests** schreiben auf **echte** Daten. Deshalb in Studio den Store-Namen mit dem Präfix `STUDIO_` verwenden (Umschaltung per `RunService:IsStudio()`) [QUELLE: creator-docs cloud-services/data-stores/index.md].
- **Rollback-Runbook:** `GetVersionAtTimeAsync` (Versionen bleiben 30 Tage). Vor jedem Release mit Schemaänderung einen Snapshot per Open Cloud ziehen (Owner).
- **Datenschema v1:** siehe §6 (konzeptabhängig, wird nach Konzeptwahl finalisiert).

## 5. Performance-Budgets (Sprint-0-Festlegung; Defaults aus §5 konkretisiert)

| Bereich | Budget | Messung | Begründung |
|---|---|---|---|
| Client-FPS Low-End-Mobile | ≥ 30 FPS (Normalbetrieb), P5 ≥ 25 FPS | MicroProfiler / Owner-Gerät | Gate §5 |
| Client-Skriptzeit | ≤ 4 ms pro Frame (Mittel) | MicroProfiler | ≈ 12 % des 33-ms-Frames [ANNAHME] |
| Client-Speicher | ≤ 800 MB gesamt auf Low-End-Mobile | Developer Console → Memory | [ANNAHME] Low-End-Geräte stürzen bei hohem Speicher ab |
| Instanzen Map | ≤ 15 000 BaseParts gesamt, ≤ 3 000 im Sichtbereich | Skript-Zählung im Test (Generator-Test zählt Bauteile) | Primitive-Stil, Mobile [ANNAHME] |
| Draw Calls / Dreiecke | < 1 000 Draw Calls, < 1 000 000 Dreiecke (Low-End) | MicroProfiler / Render-Stats am Gerät | Startwert aus der Roblox-Doku (dort als Beispiel) [QUELLE: creator-docs performance-optimization/design.md] |
| Lichter | ≤ 12 dynamische Lichter mit Schatten; dekorative Lichter `Shadows = false` | Code-Review | Mobile-GPU [ANNAHME] |
| Partikel | ≤ 25 aktive Emitter, Summe `Rate` ≤ 250/s | Code-Review + Test | Mobile [ANNAHME] |
| Server-Heartbeat | ≥ 55/s bei voller Belegung (Ziel ~60/s; Engine-Deckel 60 Hz) | Developer Console → Server Jobs → Heartbeat Steps/Sec | Gate §5 [QUELLE: creator-docs performance-optimization/identify.md] |
| Server-Skriptzeit | ≤ 6 ms pro Heartbeat (Mittel) | ScriptProfiler / MicroProfiler | [ANNAHME] |
| Speicherwachstum | ≤ 5 % über 30 min (Server und Client) | Developer Console, Messpunkte bei 5 und 35 min; **nur auf echten Geräten** (Studio-Emulator ist dafür ungeeignet) | Gate §5 [QUELLE: creator-docs performance-optimization/identify.md] |
| Netzwerk | ≤ 20 Remote-Aufrufe/s pro Spieler (Client→Server); Server→Client ≤ 30 KB/s pro Spieler im Mittel | Rate-Limiter-Zähler, Network-Stats | [ANNAHME] |
| Max. Spieler pro Server | 12 | Place-Einstellung | kleinere Server = stabiler auf Mobile, sozial ausreichend [ANNAHME] |
| DataStore | Autosave 120 s (zeitlich verteilt); Durchsatz pro Key ≤ 4 MB/min Write | Zähler im PlayerDataService | Die alte „6-s-Regel“ steht nicht mehr in der Doku; maßgeblich sind die Durchsatzlimits [QUELLE: creator-docs error-codes-and-limits.md] |

**StreamingEnabled:** **an** (Entscheidung; bei neuen Places ohnehin Default, per Skript nicht setzbar). Zusätzlich `Workspace.ModelStreamingBehavior = Improved` (empfohlen) [QUELLE: creator-docs workspace/streaming/index.md]. Begründung: Speicher und Ladezeit auf Mobile. Folge: Der Client darf nicht davon ausgehen, dass entfernte Instanzen existieren (`WaitForChild` mit Timeout bzw. `CollectionService`-Signale nutzen). Kritische, kleine Modelle (z. B. Spawn, Onboarding-Pfad) bekommen `ModelStreamingMode = Persistent` oder `Atomic`, wo nötig. Wird nach der Konzeptwahl bestätigt (§6).

## 6. Konzeptabhängiger Teil – „Schwungturm“ (gilt nach Owner-Freigabe von Konzept A)

### 6.1 Systeme

| Modul | Ort | Verantwortung | Testbar im Luau-CLI |
|---|---|---|---|
| `Logic/TowerGenerator` | shared | Seed + Zonen-Konfiguration → Liste von Bauteil-Beschreibungen (reine Daten: Typ, Position, Größe, Bewegung, Funken-IDs) | **ja** (Determinismus, Bauteil-Budget) |
| `Logic/Reachability` | shared | prüft jede Etage gegen das Bewegungsmodell (6.3) mit Sicherheitsfaktoren; liefert Hilfsstufen-Variante | **ja** (jede Etage aller Seeds im Test lösbar) |
| `Logic/Economy` | shared | Funken-Gutschrift, Upgrade-Kauf (Kosten, Max-Stufe), reine Transaktionsfunktionen `(state, action) -> (ok, newState, delta)` | **ja** |
| `Logic/Progression` | shared | Etagen-/Lager-Fortschritt, Lauf-Zustand, Fähigkeits-Freischaltung, Plausibilitäts-Mindestzeiten | **ja** |
| `Logic/MovementCheck` | shared | Positionsproben → Verstoß ja/nein (Geschwindigkeit, Höhengewinn, Fähigkeiten, Toleranz) | **ja** (mit synthetischen Spuren) |
| `Data/Schema`, `Data/Migrations` | shared | Default-Datensatz v1, Validierung, Migrationen | **ja** |
| `Util/Validator`, `Util/RateLimiter`, `Util/Trove`, `Util/Signal` | shared | Remote-Validierung, Token Bucket, Cleanup, Signale | **ja** |
| `TowerBuilder` | server | baut Instanzen aus Beschreibungen (Etagen um Spieler herum, Streaming) | nein → Owner-Studio-Test |
| `PlayerDataService` | server | Laden/Speichern/Lock (Backend injizierbar, Mock in Tests) | **Logik ja** (mit DataStore-Mock), echtes DataStore nein |
| `NetService` | server | Remotes registrieren, Validator + Rate-Limit erzwingen | Logik ja, Engine-Glue nein |
| `TowerService` | server | Funken-Einsammeln validieren, Lager erkennen, Respawn, Fähigkeiten freischalten | Logik über `Logic/*` ja |
| `TelemetryService` | server | einziger Aufrufer von `AnalyticsService` (Signaturen laut Faktensammlung 3.1); in Studio/Tests ein Log-Stub | Stub ja |
| `MovementController`, `AbilityController` | client | Doppelsprung/Dash/Gleiter (Charakterphysik ist clientseitig), Eingabe über Input Action System (IAS) | nein → Owner-Test |
| `HudController`, `ShrineUi`, `OnboardingController` | client | HUD, Upgrade-Menü, visuelle Führung | nein → Owner-Test |

### 6.2 Generator (Entwurf)
- **Eingabe:** `seed: number`, `zoneConfig` (Module-Gewichte, Schwierigkeitskurve, Palette), Bewegungsparameter.
- **Ausgabe:** `{ floors = { { index, zone, parts = { PartSpec }, sparks = { SparkSpec }, camp = CampSpec?, helperParts = { PartSpec } } } }`.
- **Zufall:** eigener deterministischer PRNG im Code (z. B. PCG32/xorshift), **nicht** `Random.new` – so ist die Ausgabe in Luau-CLI und Roblox bitgleich und testbar. [ANNAHME: `Random` ist plattformabhängig nicht garantiert gleich]
- **Etagenhöhe** 16 Studs, Grundfläche ~64 × 64 Studs; Lager = breite Plattform mit Funkenschrein.
- **Bewegliche Teile:** Physikbasiert (`PrismaticConstraint`/`AlignPosition` an nicht verankerten Parts mit Server-Network-Owner), damit Charaktere mitgenommen werden. CFrame-Tweens verankerter Parts nehmen Charaktere nicht mit [VORWISSEN, nicht aktuell]. Förderbänder über `AssemblyLinearVelocity` an verankerten Parts.
- **Bauteil-Budget pro Etage** ≤ 120 Parts (inkl. Deko) → 30 Etagen ≤ 3 600 Parts (Budget §5: ≤ 15 000). Der Generator-Test prüft das.

### 6.3 Bewegungsmodell für den Erreichbarkeitsprüfer
Basiswerte (wir setzen sie explizit, statt Defaults zu vertrauen):

| Konstante | Wert | Quelle |
|---|---|---|
| Gravitation | 196,2 Studs/s² | Default [QUELLE: creator-docs Workspace.yaml] |
| `CharacterUseJumpPower` | **false** (wir nutzen JumpHeight) | Default ist `true` mit JumpPower 50 [QUELLE: creator-docs Humanoid.yaml, StarterPlayer.yaml] |
| JumpHeight | 7,2 Studs → Absprunggeschwindigkeit v₀ = √(2·g·h) ≈ 53,15 Studs/s | Default 7,2 [QUELLE: creator-docs StarterPlayer.yaml] |
| WalkSpeed | 16 Studs/s | Default [QUELLE: creator-docs StarterPlayer.yaml] |
| Flugzeit (gleiche Höhe) | t = 2·v₀/g ≈ 0,542 s → horizontale Reichweite ≈ 8,7 Studs | [EIGENE RECHNUNG] |
| Doppelsprung | zweiter Impuls mit 85 % Höhe (≈ 6,1 Studs zusätzlich) | Designwert (GDD §5) |
| Dash | 48 Studs/s horizontal für 0,25 s, vertikale Geschwindigkeit beim Start auf 0 → ≈ 12 Studs | Designwert (GDD §5) |

Sicherheitsfaktoren (Anteil der theoretischen Reichweite/Höhe, die eine Lücke höchstens verlangen darf): Zone 1 ≤ 0,55 · Zone 2 ≤ 0,70 · Zone 3 ≤ 0,75 · Tagesturm ≤ 0,80 [ANNAHME → Owner-Playtest]. Upgrades fließen **nicht** in die Prüfung ein (Lösbarkeit mit Basiswerten, GDD §5). Hilfsstufen halbieren die größte Lücke.

### 6.4 Datenschema v1 (`PlayerData_v1`, Key `player_<UserId>`)

```luau
export type PlayerDataV1 = {
	schemaVersion: number,            -- = 1
	sparks: number,                   -- Ganzzahl, 0 … 1e9
	lifetimeSparks: number,           -- Ganzzahl, nur steigend
	abilities: { doubleJump: boolean, dash: boolean, glide: boolean, wallJump: boolean },
	upgrades: { jump: number, speed: number, dashCooldown: number }, -- Stufen 0..3 / 0..3 / 0..2
	progress: {
		highestFloor: number,         -- 0..30 (bester je erreichter Stand)
		summits: number,
		bestRunSeconds: number?,      -- nil = noch kein Gipfel
	},
	run: {                            -- aktueller Lauf (überlebt Rejoin → kein Funken-Farming)
		index: number,                -- 1, 2, … (Lauf-Nummer)
		checkpointFloor: number,      -- 0, 5, 10, …
		collected: { [string]: number }, -- Etage (als String-Key) → Bitmaske eingesammelter Funken (≤ 16 Bits)
		startedAt: number,            -- os.time() des Laufbeginns
		elapsedSeconds: number,       -- aktive Spielzeit im Lauf (für Bestzeit; pausiert bei Abwesenheit)
		flagged: boolean,             -- Plausibilitätsverstoß → keine Bestzeit/Bestenliste
	},
	daily: { dayId: number, bestFloor: number, bestSeconds: number? }, -- Should
	cosmetics: { owned: { [string]: boolean }, equipped: string? },    -- nur erspielte Kosmetik
	settings: { helpers: boolean, music: boolean, effects: boolean },
	onboarding: { stepsDone: number },  -- Bitmaske der Funnel-Schritte (keine Doppelmeldung)
	meta: { firstJoin: number, lastJoin: number, sessions: number, lastPlaceVersion: number },
}
```

- **Keine personenbezogenen Daten** (keine Namen, keine Texte). Größe ≈ 1–2 KB.
- String-Keys für `collected`, weil DataStore-JSON gemischte Tabellen nicht sauber abbildet [VORWISSEN, nicht aktuell].
- Validierung beim Laden: Typen, Bereiche, unbekannte Felder verwerfen, fehlende mit Defaults auffüllen (`Schema.reconcile`). Tests decken alle Felder ab.
- Migration v0 → v1: v0 = „kein Datensatz“ → Default v1. Künftige Migrationen v1 → v2 als reine Funktionen + Tests; Schemaänderungen im Live-Spiel brauchen Owner-Freigabe (§8.3).

### 6.5 Remotes (Client → Server, alle über `NetService`)

| Remote | Argumente | Rate-Limit | Server-Prüfungen |
|---|---|---|---|
| `CollectSpark` | `sparkId: number` (Ganzzahl, existiert in aktueller Etagenliste) | 10/s, Burst 20 | Spieler lebt; Distanz Charakter ↔ Funke ≤ 8 Studs (+ Latenz-Toleranz); Funke im aktuellen Lauf noch nicht gesammelt; Etage ≤ höchste plausible Etage + 1 |
| `RequestUpgrade` | `upgradeId: "jump" \| "speed" \| "dashCooldown" \| "glide" \| "wallJump"` | 2/s, Burst 4 | Spieler in Reichweite eines Funkenschreins (≤ 12 Studs); Kosten ≤ Guthaben; Stufe < Max.; Transaktions-Lock (kein Doppelkauf) |
| `RequestRespawn` | – | 1/s, Burst 2 | setzt an `run.checkpointFloor` zurück |
| `ReportAbilityUsed` | `abilityId` (Enum), `inputType` (Enum) | 5/s, Burst 10 | Fähigkeit freigeschaltet; nur Telemetrie und Plausibilitäts-Kontext (Physik bleibt clientseitig) |
| `ReportOnboardingStep` | `step: number` (1..8) | 2/s | Schritt nicht doppelt (Bitmaske), Reihenfolge plausibel; Server loggt den Funnel |
| `SetSetting` | `key` (Enum), `value: boolean` | 2/s | nur bekannte Keys |
| `StartNewRun` | – | 1/10 s | nur nach mindestens einem Gipfel; am Turmfuß |

Server → Client: `StateChanged` (Funken, Etage, Fähigkeiten, Upgrades – nur eigener Spieler), `FeedbackEvent` (kosmetisch; `UnreliableRemoteEvent`, Payload ≤ 900 Bytes). **Keine** RemoteFunction Server → Client. Lager-Erreichen und Etagenwechsel erkennt der **Server** aus der Charakterposition (Höhe + Etagen-Bounding-Box), nicht der Client.

### 6.6 Bewegungs-Plausibilität und Bestenliste
- Charakterphysik ist clientseitig (Standard). Der Server tastet die Position mit 2 Hz ab (`Logic/MovementCheck`): horizontale Geschwindigkeit ≤ max(WalkSpeed · Upgrades, Dash) · 1,5 Toleranz; Höhengewinn je Probe ≤ erreichbare Sprunghöhe (mit Doppelsprung) + Plattform-Bewegung + Toleranz; Etagen-Sprünge > 1 Etage ohne Zwischenprobe = Verstoß.
- Folgen eines Verstoßes: **kein** Kick, **keine** Strafe im Hauptturm (Kinder, Lag-Fehlalarme). Nur `run.flagged = true` → dieser Lauf zählt nicht für Bestzeit/Tagesturm-Bestenliste; Zähler in Telemetrie. [ANNAHME: verhältnismäßig, da kein PvP/Handel]
- Mindestzeit je Abschnitt aus dem Generator (Wegstrecke ÷ Höchstgeschwindigkeit) als zweite Plausibilitätsgrenze.
- Option für später: Roblox „Server Authority“ (laut Research inzwischen Full Release, benötigt „Next Generation Replication“) → Spike, falls Bestenlisten-Cheats auftreten.

### 6.7 Spieler-Kollision
Eigene CollisionGroup `Players`, die mit sich selbst nicht kollidiert (`PhysicsService:RegisterCollisionGroup`, `CollisionGroupSetCollidable`) [QUELLE: creator-docs PhysicsService.yaml] → kein Herunterschubsen (GDD §8).

## 7. Owner-Studio-Checkliste (Engine-Prüfungen, die hier nicht möglich sind)

Wird pro Sprint gepflegt. Sprint 0:
1. `rojo serve` + Rojo-Plugin oder `build/place.rbxlx` in Studio öffnen. Erwartung: Der Place öffnet ohne Fehler in der Ausgabe-Konsole.
2. Play-Test (F5): keine Fehler/Warnungen aus `Server.Main`/`Client.Main`.
3. Prüfen, ob relative String-Requires (`require("./X")`) in einem ModuleScript unter `ReplicatedStorage.Shared` funktionieren (wichtig für die Testbarkeit, §1).

## 8. Bekannte Grenzen

- Keine Ausführung in der Roblox-Engine in dieser Umgebung. Alles, was Instanzen, Physik, Rendering, Netzwerk-Replikation, DataStore-Realverhalten oder Geräteleistung betrifft, ist hier höchstens `[SIMULIERT]`.
- Performance-Gates können nur der Owner (bzw. später Open-Cloud-Tests) prüfen.
- Selene prüft keine Roblox-API-Nutzung (D-011); das übernimmt luau-lsp.
