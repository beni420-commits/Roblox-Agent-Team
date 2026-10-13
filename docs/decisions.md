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

## Owner-Freigaben

### D-022 · Owner-Freigabe · Konzept A „Schwungturm“ als MVP
- **Freigabe:** Der Owner hat Konzept A auf Basis von GDD v0.2 freigegeben (Antwort auf den Owner-Bericht Sprint 0). D-018 ist damit entschieden.
- **Folge:** Sprint 1 (Vertical Slice Zone 1) startet.

### D-023 · Owner-Freigabe · Compliance-Auflagen verbindlich (§8 Punkt 6)
- **Freigabe:** Die Auflagen C-A1 bis C-A18 und C-A29 bis C-A32 gelten verbindlich und sind Teil der Definition of Done.

### D-024 · Owner-Freigabe · Asset-Regel „solange ohne Copyright“ (§8 Punkt 5)
- **Freigabe (Wortlaut sinngemäß):** „Freigabe erteilt, solange ohne Copyright.“
- **Auslegung (die strengere, Compliance):**
  - **Kat. 0** (Engine-Inhalte, `rbxasset://`) ist frei.
  - **Kat. 1** gilt **nur** für Assets, die Roblox selbst erstellt hat und an denen **keine Urheberrechte Dritter** bestehen. Lizenzierte Partner-/Label-Musik (z. B. aus Musikbibliotheken) ist **ausgeschlossen**, auch wenn sie auf Roblox nutzbar wäre.
  - Kat. 2–4 brauchen weiterhin eine Einzelfreigabe.
- **Begründung:** Im Zweifel gilt „ohne Copyright“ als „keine Inhalte mit Rechten Dritter“.
- **Folge:** Im MVP gibt es keine Musik. Soundeffekte kommen zunächst nur aus Kat. 0, die Asset-Pfade prüft der Owner in Studio.

### D-025 · Offen · Veröffentlichungskosten (§8 Punkt 2)
- Noch keine Owner-Entscheidung. Sie wird spätestens vor dem öffentlichen Release gebraucht (Owner-Bericht Sprint 0 §4). Bis dahin gilt Budget 0.

## Sprint 1

### D-026 · 2026-10-12 · Game Designer · Doppelsprung-Pflicht über Höhe statt Weite
- **Entscheidung:** In Zone 2 verlangen Kanten mit 8–9,5 Studs Anstieg den Doppelsprung, nicht weite Lücken (GDD v0.3 §13a).
- **Evidenz:** [GETESTET] Die Simulation zeigt, dass ein weitenbasiertes Fenster nicht existiert (Referenz-DJ ≈ 7,2 < großzügiger Einzelsprung ≈ 9,7).

### D-027 · 2026-10-12 · Systems Engineer · Kamera in Sprint 1: Roblox-Standard mit Invisicam
- **Entscheidung:** Statt einer eigenen Kamera nutzen wir in Sprint 1 die Standardkamera mit `DevCameraOcclusionMode = Invisicam`: Verdeckende Teile werden durchsichtig statt heranzuzoomen. Zoom 8–30 Studs.
- **Begründung:** Damit ist das P-04-Ziel (Ausblenden statt Heranzoomen) mit Bordmitteln erfüllt; eine eigene Kamera ist ohne Studio nicht abstimmbar. Neubewertung nach dem Owner-Test.
- **Evidenz:** [ANNAHME]; Rojo-Build setzt die Eigenschaft [GETESTET].

### D-028 · 2026-10-12 · Systems Engineer · Funken, Führung und Hilfsstufen clientseitig aus demselben Seed
- **Entscheidung:** Der Server baut nur die gemeinsamen Bauteile. Jeder Client erzeugt den Turm mit dem Generator aus `workspace.TowerSeed` selbst und baut seine Funken, Chevrons und Hilfsstufen lokal. Gewertet wird nur auf dem Server (Reichweite 10 Studs, einmalig je Lauf).
- **Begründung:** Funken und Hilfe sind pro Spieler verschieden; so entsteht kein Replikationsverkehr. Der Generator ist deterministisch [GETESTET], weil er nur bit32-Zufall und exakte Arithmetik nutzt.

### D-029 · 2026-10-12 · Orchestrator · CI-Workflow nur bei Push auf `main`, PRs und manuell
- **Entscheidung:** `.github/workflows/ci.yml` läuft nicht bei Pushes auf den Arbeitsbranch.
- **Begründung:** Der Workflow ist hier nicht auf GitHub-Runnern testbar. Die Schritte zum Holen und Bauen sind identisch zu denen, die hier liefen [GETESTET lokal], aber ein ungetesteter roter Lauf wäre nur Rauschen. Der Owner kann ihn manuell starten.

### D-030 · 2026-10-12 · Orchestrator · Keine Sounds in Sprint 1
- **Entscheidung:** Sprint 1 hat keine Sounds. Die Pfade der Engine-Sounds (Kat. 0) sind in der Doku nicht belegt und hier nicht prüfbar; Kat. 1 bräuchte Asset-IDs aus dem Creator Store (nicht erreichbar).
- **Folge:** Feedback läuft nur visuell. Sounds folgen in Sprint 2, nachdem der Owner Pfade bzw. IDs in Studio geprüft hat (Asset-Register).

### D-031 · 2026-10-12 · Orchestrator · Windows-Installer zum Testen (Owner-Wunsch „Installer für PC“)
- **Entscheidung:** `installer/` mit `install.ps1`, Doppelklick-Startern (`.bat`) und `ANLEITUNG.md`. Ablauf: Rojo 7.7.1 aus dem offiziellen GitHub-Release laden (SHA-256 gegen den veröffentlichten Digest prüfen, sonst Hash anzeigen), Spieldatei bauen, Roblox Studio am dokumentierten Ort finden (sonst offizielle Seite öffnen), Rojo-Plugin und Desktop-Verknüpfung anlegen, Studio mit `--task EditFile --localPlaceFile` öffnen. Dazu gibt es eine Deinstallation. Keine Adminrechte nötig.
- **Begründung:** Roblox-Spiele sind keine eigenständigen PC-Programme. Der realistische Weg „auf dem PC spielen“ ist Roblox Studio, und der Installer macht ihn zum Doppelklick.
- **Evidenz:** [GETESTET] 14 Tests mit PowerShell 7 unter Linux, darunter nachgebildeter Download inkl. Prüfsumme, Build, Gesamtlauf, Deinstallation, AST-Prüfung auf Syntax nur für PowerShell 7 und Dateiformate. Mutationstest bestanden. Die Tests fanden 2 echte Fehler (typografische Anführungszeichen als String-Ende, Rojo-Ausgabe im Rückgabewert). **Nicht getestet:** echtes Windows, Windows PowerShell 5.1, Desktop-Verknüpfung (COM), Studio-Start, echter GitHub-Download.

## Lantern Line – Der Nachtzug (zweites Spiel)

### D-032 · 2026-10-13 · Orchestrator · Owner-Auftrag: Horror-Spiel als eigenes Projekt
- **Owner-Auftrag (wörtlich):** „erstelle ein Horror Game das wie ''Doors'' es soll nah am original sein aber trotzdem einen eigenen wiedererkennbaren style haben“.
- **Entscheidung:** neues, eigenständiges Rojo-Projekt `games/lantern-line/` im selben Repo. Schwungturm bleibt unverändert (wartet weiter auf Owner-Test P0).
- **„Nah am Original“** heißt hier: vertrautes Genre-Gefühl und dieselben Genre-Prinzipien (Raum für Raum, Warnung durch Licht, Verstecken, Schlüssel, Rätsel-Finale), aber keine übernommene Gestaltung (Namen, Figuren, Texte, UI, Sounds). Grundlage ist die Compliance-Vorprüfung (Freigabe mit Auflagen H-A1 bis H-A15).
- **Prozess (Sprint-0-Ablauf, verdichtet):** Recherche und Compliance laufen parallel zur Logik. Gebaut wurde nur, was keine Owner-Freigabe nach §8 braucht: keine Veröffentlichung, keine Käufe, keine Assets außer Kat. 0, keine Daten. Die Freigaben stehen im Owner-Bericht.

### D-033 · 2026-10-13 · Game Designer · Setting „Nachtzug“, Stil „Laternen-Noir“, Arbeitstitel „Lantern Line – Der Nachtzug“
- **Entscheidung:** Ein Nachtzug statt eines Gebäudes. Wagen sind die Räume, jede Gefahr kündigt sich durch Licht an. Dazu kommt eine UI in Fahrkarten-Ästhetik.
- **Begründung:**
  - Der Stil ist eigenständig und wiedererkennbar.
  - Ein linearer Zug macht Wesen-Wege und Generator robust: kein Überlappen von Räumen, Wesen fahren entlang x.
  - Licht als Warnsprache funktioniert ohne Sounds (D-030) und ist barrierearm.
- **Titel:** Laut Compliance H-A15 keine Wortmarke im Muster des Vorbilds, deshalb wurde „CARRIAGES“ verworfen. Die Recherche fand ein Konkurrenzprojekt im Zug-Setting („LastStop“, in Entwicklung).
- **Evidenz:** `docs/lantern-line/research_doors.md` [QUELLE/ANNAHME gekennzeichnet]. Markenrecherche offen (Owner-Freigabe).

### D-034 · 2026-10-13 · Game Designer · Design-Änderungen nach Recherche und Compliance (GDD v0.2)
- **Entscheidung:**
  - „Pendel“ (Hin-und-her-Durchgänge) wird ersetzt durch den **Gegenzug**: Licht flutet eine Fensterseite, man wechselt die Wagenhälfte.
  - Der **Blinde Passagier** verlangt **Abstand** zu festen Augenpaaren statt „ansehen“.
  - Das Finale nutzt das **Entwerter-Lochmuster** (3 Reihen-Fragmente, 3×3-Feld) statt eines Symbol-Ziffern-Codes.
  - Der **Schaffner** nimmt über einen Lichtkegel wahr und hört Schritte; er ist nicht blind.
  - **Teesalon** statt Salonwagen mit Bar.
  - Neu: **Kofferlawine** (Verfolgung) mit eigener Kernmechanik.
- **Begründung:**
  - Die Recherche stufte Pendel, Passagier und Finale als mechanisch zu nah ein.
  - Compliance H-A3 ist kernnah (Finale).
  - H-A6: Eine Bar würde das Label 18+ auslösen.
- **Evidenz:** Fairness der neuen Wesen geprüft [GETESTET, 150 Seeds]. Die Compliance-Nachprüfung steht in `reports/lantern-line/compliance_check_sprint1_ll.md`.

### D-035 · 2026-10-13 · Systems Engineer · Server-Autorität, Darstellung aus gemeinsamen Fahrplänen
- **Entscheidung:**
  - Der Server erzeugt den Bauplan (Seed nur auf dem Server), baut die Wagen und wertet alle Treffer.
  - Bewegte Wesen (Express, Kofferlawine, Schaffner) zeichnet jeder Client selbst. Grundlage sind die Fahrpläne bzw. Wege, die der Server schickt; beide Seiten nutzen dieselbe Logik (`Sweep`, `Conductor`).
  - Phasen des Kontrolleurs und Augen laufen über Attribute.
- **Begründung:** flüssige Bewegung ohne ruckelnde Replikation verankerter Teile. Der Client kann nichts entscheiden.
- **Folge:** Spielerbewegung ist (wie überall in Roblox) clientseitig. Ein Teleport-Cheat könnte Wagen überspringen. Ohne Speicherstand und Käufe ist der Schaden klein; eine Bewegungsprüfung kommt vor jedem Speicherstand.

### D-036 · 2026-10-13 · Systems Engineer · Kein Roblox-Tod: Verblassen statt Ragdoll
- **Entscheidung:**
  - Bei 0 Lebenspunkten setzt der Server die Lebenspunkte auf 1, verankert die Figur, blendet sie in 0,6 s aus und entfernt sie.
  - Der Client zeigt danach die Hinweis-Notiz und das Zuschauen.
  - Regeneration ist aus (leeres Skript „Health“); Reset ist aus.
- **Begründung:** Compliance H-A8: unrealistische Todesdarstellung, kein Ragdoll, Label Mild.

### D-037 · 2026-10-13 · Systems Engineer · Gemeinsame Util-Module als geprüfte Kopie
- **Entscheidung:** `Util/*` und `Net/Guard.luau` sind nach `games/lantern-line/src/shared/` kopiert. `scripts/lantern_line_checks.py` prüft byte-genau, dass die Kopien gleich bleiben.
- **Begründung:** Symlinks gehen beim ZIP-Download unter Windows verloren (Installer), und ein Paketmanager bräuchte eine Owner-Freigabe (§8.5). Die Tests der Originale decken die Kopien mit ab.

### D-038 · 2026-10-13 · Game Designer · Schlüssel gehören der Gruppe; StreamingEnabled aus
- **Schlüssel:** Ein gefundener Schlüssel gilt für alle (Schlüsselbund im HUD). So entsteht keine Sackgasse, wenn der Finder ausscheidet.
- **Streaming:** `StreamingEnabled = false`, weil höchstens ca. 6 Wagen gleichzeitig existieren (ältere werden abgekoppelt). Verstecke und Prompts müssen immer da sein. [ANNAHME: Speicher auf Mobilgeräten ausreichend, im Owner-Test prüfen]

### D-039 · 2026-10-13 · Orchestrator · Installer für beide Spiele
- **Entscheidung:** `install.ps1 -Game LanternLine` mit eigenen Startern (`LanternLine-Installieren.bat`, `LanternLine-Starten.bat`) und einer Desktop-Verknüpfung „Lantern Line testen“. Die Deinstallation entfernt beide Spiele.
- **Evidenz:**
  - [GETESTET] 18 Installer-Tests mit PowerShell 7, davon 4 neu für Lantern Line.
  - Der Mutationstest (falscher Projektpfad) wurde von 3 Tests erkannt.
  - Echtes Windows ist weiterhin ungetestet.

### D-040 · 2026-10-13 · Game Designer / Compliance · Umsetzung der Compliance-Nachprüfung (H-A16 bis H-A18)
- **Entscheidung:**
  - **Gegenzug:** ruhiges, weich anschwellendes Seitenlicht an festen Positionen statt vorbeirasender Lichter (vorher ca. 8 Lichtwechsel pro Sekunde).
  - **Express:** kleinerer Lichtkern über Augenhöhe, der nahe an der Kamera ausblendet (nie bildfüllend).
  - **Sanfter Modus** schließt „Flackern reduzieren“ ein. „Bewegung reduzieren“ wirkt auch auf UI-Wackeln und den Kellen-Puls.
  - **Zuschauen:** Verfolgerkamera hinter dem Mitreisenden statt Ich-Perspektive.
  - **Kontrolleur:** geht spätestens nach 40 s ab.
  - **Schaffner:** Hörradius Laufen 16 (= Sichtweite).
  - **Kofferlawine:** neue Kernmechanik „Kupplung lösen“ (Teamaufgabe).
- **Evidenz:**
  - [GETESTET] Logik: Zeitlimit, Kupplung (Freigabe nur, wenn alle vorbei sind; Anhalten), Hörradius ≤ Sicht.
  - Lichtwirkung in der Engine nicht geprüft (Owner-Test E1, E2). D-034 („eigene Kernmechanik“) ist erst damit erfüllt.

### D-041 · 2026-10-13 · Systems Engineer / Game Designer · Umsetzung des Code-Reviews Lantern Line (LL-01 bis LL-24)
- **Anlass:** `reports/lantern-line/code_review_sprint1.md` mit 24 Befunden (1 Blocker, 1 kritisch, 10 mittel, 12 gering). Alle sind im Code umgesetzt (Commits `7e147c9`, `ee3a813`).
- **Entscheidungen mit Wirkung aufs Spiel:**
  - **Verstecke (LL-01, LL-02, LL-08, LL-09):**
    - Prompts sitzen an der Schranktür.
    - Der eigene Schrank ist lokal durchsichtig; die Sehschlitze kommen aus der UI.
    - Die versteckte Figur ist für andere unsichtbar.
    - Im Versteck sind fremde Prompts aus.
  - **Express-Fairness (LL-03):** Die Garantie gilt jetzt für alle Wagen, die der Express trifft (k−3 bis k), nicht nur k−1/k, und für eine Vierergruppe gemeinsam. Unfaire Pläne verwirft der Generator.
  - **Kontrolleur (LL-04):**
    - Er misst nur in einem Fenster nach dem Stillstand plus 0,7 s Gnadenzeit.
    - Das HUD zeigt in der Achtungsphase „Gleich stillstehen“ mit Ablaufbalken.
    - Er geht spätestens nach 40 s ab.
  - **Robustheit (LL-05, LL-06, LL-21):**
    - Eine verlorene Figur gilt nach 5 s als ausgeschieden (Ursache „lost“ mit eigenem Hinweis).
    - Ein Lauf ohne neue Tür endet nach 5 min.
    - Figuren werden mit Wiederholung geladen.
  - **Bewegungsprüfung (LL-10):**
    - Wer über ca. 1 s schneller als 24 Studs/s ist, kommt zurück auf die letzte gültige Position.
    - Nach Server-Teleports gilt eine Beruhigungszeit (0,3 s ohne Proben, Urteil erst ab 0,8 s Probenspanne).
    - Damit ist die Folge aus D-035 („Bewegungsprüfung vor dem Speicherstand“) für Lantern Line erledigt.
  - **Kofferlawine (LL-15):** Verstecke in ihrer Bahn sind während der Lawine gesperrt, denn ein Schrank schützt nicht vor der Kofferwand.
  - **Gamepad (LL-24):** Die Einstellungen liegen auf **Y** statt Select, weil Select in Roblox die UI-Navigation schaltet.
- **Evidenz:**
  - [GETESTET] Prüfkette: Selene 0/0, luau-lsp sauber, 78/78 Logik-Tests, Compliance-Prüfung OK.
  - Neue Tests: Express k−2/k−3, Kontrolleur-Messfenster und Zeitlimit, Ursache „lost“, Leerlauf-Abbruch, Schaffner-Revision, Probenspanne.
  - [ANNAHME] Wirkung in der Engine ungeprüft. Die Prüfpunkte S-01 bis S-24 im Review sind Teil des Owner-Tests.

<!-- Weitere Entscheidungen werden unten angehängt. -->
