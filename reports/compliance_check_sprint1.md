# Compliance-Prüfung Sprint 1 – „Schwungturm“, Zone 1

| Feld | Wert |
|---|---|
| Datum / Rolle | 2026-10-12 · Safety- & Compliance-Officer |
| Gegenstand | `src/` @ c7f81b1, `docs/compliance/questionnaire.md`, `reports/playtest_report_sprint0.md` §6.1, `docs/decisions.md` D-022…D-030 |
| Grundlage | Digest v1.1, Konzeptcheck v1.1 inkl. Nachtrag §11. Original: creator-docs @af5f853 |
| Methode | Code-Lektüre und Volltextsuche im Code (u. a. nach `rbxasset`, `Sound`, `TextBox`, `MarketplaceService`, `DataStore`, `UserId`, `SocialService`, Tweens). **Nicht in Studio ausgeführt**: Laufzeitverhalten ist `[ANNAHME]`, bis der Owner testet. |

## 1. Auflagen-Status (Sprint-1-Umfang)

| Auflage | Status | Fundstelle / Beleg |
|---|---|---|
| C-A1 Fragebogen vor Zugang Dritter | **offen** (Owner) | Entwurf `docs/compliance/questionnaire.md` liegt vor (Korrekturen §2). Noch nicht eingereicht. |
| C-A2 kein Spieler-Freitext | umgesetzt | Kein `TextBox` in `src/`. Es gibt nur `TextLabel`s mit festen Schlüsseln (`client/Controllers/HudController.luau:22-41`, `localization/GameStrings.csv`). |
| C-A3 generierte Namen | nicht relevant S1 | Zonennamen sind fest (`client/Controllers/Strings.luau:10-16`). Turm- oder Sortennamen gibt es nicht. |
| C-A4 nur Standard-Chat | umgesetzt | Weder `TextChatService` noch eigene Kanäle. Signale folgen in Sprint 2. |
| C-A5 keine Links, keine Engagement- oder Einladungsbelohnungen | umgesetzt | Weder `SocialService` noch Invite, `GroupService`, Favorite, URLs oder Handles im Code. |
| C-A6 Daten, RTBF | nicht relevant S1 / **offen S2** | Keine Persistenz (`server/Services/PlayerService.luau:3`). Die UserId dient nur als Key im Arbeitsspeicher (`server/Services/NetService.luau:19`). Für Sprint 2: `player.User`, statisches `{UserId}`-Muster, RTBF-Templates. |
| C-A7 HR-FOMO | umgesetzt | Keine Tagesinhalte, Streaks oder `ExperienceNotificationService`. |
| C-A8 keine Monetarisierung | umgesetzt | Kein `MarketplaceService`. |
| C-A9 Asset-Regel | umgesetzt (nur Kat. 0) | Siehe §4. |
| C-A10 Prinzipien statt Kopie | umgesetzt (S1) | Keine Namen oder Begriffe von Referenzspielen im Code. Eigene Palette und Helix (`shared/Visual/Palette.luau`). |
| C-A11 Markenprüfung | nicht relevant (privat) | Vor öffentlichem Release. |
| C-A12 Store-Medien | nicht relevant (privat) | Vor öffentlichem Release. |
| C-A13 keine Spieler-Kollision | umgesetzt | `server/WorldSetup.luau:12-19` (Gruppe nicht kollidierbar), `:68-79` (alle Charakter-Teile inkl. später hinzukommender), Aufruf `server/Services/PlayerService.luau:230`. |
| C-A14 Flackern ≤ 3 Hz | umgesetzt | Einzige wiederholte Abdunklung ist die Sturz-Vignette, ≤ 1 pro s (`client/Controllers/FallController.luau:16,51-54`; Server-Debounce `PlayerService.luau:41`). Schwarz bis 55 %, kein heller Blitz (`HudController.luau:43-53`). Keine Endlos-Pulse. |
| C-A15 Publishing Requirements | **offen** (D-025) | Für den privaten Test gelten nur die 16+-Anforderungen (§7). |
| C-A16 Bestenliste | nicht relevant S1 | Keine `leaderstats` und kein OrderedDataStore. |
| C-A17 Seilschaft | nicht relevant S1 | – |
| C-A18 Frustschutz kostenlos | umgesetzt | Hilfe nach 3 bzw. 6 Fehlversuchen (`shared/Logic/RunState.luau:33-34,125-135`; `PlayerService.luau:44,160-169`). Hilfsstufen sind nur lokal (`client/Controllers/GuidanceController.luau:120-131`). Kein Kaufbezug. Die Zone „Gewitter“ ist noch nicht gebaut. |
| C-A29 Metadaten ohne Hangout-Begriffe | **offen** (Owner) | Gilt schon für Titel und Beschreibung des Test-Place (der Fragebogen klassifiziert auch nach der Beschreibung). |
| C-A30 Signale / C-A31 Seilschaft / C-A32 Avatar-Transparenz und Marker | nicht relevant S1 | Nicht implementiert (kein `LocalTransparencyModifier`). Prüfung in Sprint 2. |

## 2. Fragebogen-Entwurf vs. Original (`production/promotion/content-maturity.md` @af5f853)

**Vollständig:** Alle 15 Kategorien des Originals sind abgedeckt: Violence, Blood, Fear, Crude humor, Unplayable gambling, Strong language, Romantic themes, Alcohol, Social hangout, Free-form, Sensitive issues, Paid random items, Paid item trading, Media und AI interaction. Folgefragen (Intensität, Häufigkeit, PolicyService) entfallen korrekt bei „Nein“. Der Pfad Configure → Questionnaire ist richtig.
**Label „Minimal“ passt.** Ohne jeden Deskriptor ist es die niedrigste Stufe und für Kids und Select zugelassen. Die Antworten für Build s1 sind sachlich richtig: kein Schaden, kein Tod, keine Musik, keine Räume.

**Korrekturen bzw. Ergänzungen (bitte einarbeiten):**
1. **Fear, Zone 3:** Ersetze „Ziel bleibt Nein“ durch „Antwort folgt dem Inhalt. Im Zweifel **Mild / Occasional** angeben“. Laut Original zählen schon „ominous music“ und „gameplay that builds suspense“ als Mild. Mild kostet keine Zielgruppe, eine Fehlangabe dagegen führt zu Moderation (CM-04).
2. **Violence, Zone 3:** Trifft ein Blitz sichtbar den Avatar, ist das Gewalt, mindestens Mild. „Electrocution“ steht sogar in der Restricted-Liste, falls realistisch dargestellt. Design-Empfehlung: Blitze schlagen in Plattformen oder Ableiter ein, und der Rückstoß kommt als Windstoß. Dann bleibt Violence „Nein“, sonst „Mild / Occasional“.
3. **Neues Feld „Regionale Compliance“:** Die Vorschau zeigt Regionen, in denen das Spiel nach den Antworten nicht konform ist. Diese Angabe neben dem Label eintragen.
4. **Strong language:** Den Zusatz „Spieleinstellung ‚Allow strong language‘ bleibt aus“ ergänzen.
5. **Hinweis Fremd-Playtests:** präzisieren wie in §7 (Audience **Limited → Playtesters**, Trusted Friends).

## 3. Telemetrie

Nur Roblox-eigener `AnalyticsService` (`server/Services/TelemetryService.luau:5`), keine Calls an Dritte (AD-01, DS-03). In Studio wird nur protokolliert (`:28-32`).
**Gesendete Felder:** Eingabegerät, Build und ein Kontext mit geringer Kardinalität (`:17-26`). Der Kontext enthält Etage, Etagen-Bündel, Sekunden-Bündel, Laufnummer, Hilfsart oder Remote-Name (`shared/Telemetry/Events.luau`; `PlayerService.luau:148-191,296-303`).
- Das Eingabegerät kommt per Whitelist vom Client (`shared/Net/Definitions.luau:37-40`).
- Ablehnungsschlüssel sind nur Remote-Namen oder „unknown“ (`shared/Net/Guard.luau:30`), der Client kann also keinen Freitext einschleusen.

**Keine personenbezogenen Daten** in den Feldern: weder Namen noch UserIds, Chat oder Geräte-IDs (CS-07, DS-01, HR-DATA). ✅

## 4. Assets

Es kommt **ausschließlich Kat. 0** zum Einsatz:
- Parts, Engine-Materialien (`Palette.luau:36-46`: SmoothPlastic, DiamondPlate, Neon, WoodPlanks, Glass, Grass, Marble)
- Lighting, Atmosphere, Bloom, ColorCorrection (`server/WorldSetup.luau:22-41`)
- die System-Schrift `Enum.Font.BuilderSansBold` (`HudController.luau:28`)

Im Code gibt es **keine** `rbxasset://`- oder `rbxassetid://`-Referenzen, keine Decals, Meshes, Sounds oder Musik (D-030, D-024) und keine Fremd-IP. ✅

## 5. Texte und UI

- **Kein Freitext, keine Links, keine Kaufaufforderungen** (§1). Die einzigen Texte sind „Meadow/Wiese“, „{1} cleared!“ und „{n}/30“, alle über Lokalisierung. ✅
- **Flackern:** ≤ 1 Hz, nur Abdunklung (C-A14). ✅
- **Information nicht nur über Farbe:** Fortschritt als Zahl „n/30“ plus Balken (`HudController.luau:160-161`). Lager als Form-Kerben (`:128-137`). Führung als Chevron-Form in Gold. Sprungpads unterscheiden sich durch Neon-Leuchten, Förderbänder durch das DiamondPlate-Material. ✅ *UX-Hinweis, kein Compliance-Punkt:* Die Förderband-Richtung ist nur über die Bewegung erkennbar, Pfeile wären besser.
- **Reset ohne Tod:**
  - Sturz bedeutet Teleport an den Etagenanfang (`PlayerService.luau:152-171`).
  - Der Roblox-Reset-Knopf wird umgeleitet (`client/Main.client.luau:80-95` → `PlayerService.luau:348-355`).
  - Es gibt keine Schadens- oder Todesdarstellung. ✅
  - Restfall: Verpasst der Server einen Sturz, greift die Roblox-Void-Grenze mit Standard-Respawn. Das ist keine Gewaltdarstellung, also unkritisch.

## 6. Datenschutz bei Owner-Playtests (`playtest_report_sprint0.md` §6.1)

Die Vorgaben passen, gemessen an CS-07, DS-01 und KS-05:
- Eltern-Einwilligung und anwesendes Elternteil
- keine Gesichtsaufnahmen, Bildschirmaufnahmen nur mit Zustimmung und mit Löschung
- Code-Notizen statt Namen, nichts Personenbezogenes im Repo
- keine Konten für fremde Kinder
- eigenes Test-Universe, keine Exploit-Tools

**Präzisierung aus dem Original** (ersetzt die beiden `[VORWISSEN]`-Stellen):
- „Private“ heißt **nur Edit-Berechtigte**.
- Dritte kommen über **Audience → Limited → Playtesters** dazu. Das setzt beim Owner-Konto die 16+-Anforderungen voraus: Altersprüfung, Konto ≥ 2 Tage, Fragebogen.
- Tester unter 16 können nur als **Trusted Friends** des altersgeprüften Owners teilnehmen. Bei unter 13 braucht das die Zustimmung der Eltern. Die Alternative ist das Owner-Gerät mit Owner-Test-Konto.
- Limited-Spiele erscheinen nicht in Suche und Startseite.
- Belege: `production/publishing/publish-games-and-places.md`, `kids-and-select.md` (FAQ), `projects/collaboration.md`.

Die Telemetrie aus dem Test-Place ist frei von personenbezogenen Daten (§3). RTBF wird erst mit der Persistenz in Sprint 2 relevant.

## 7. Urteil: privater Test-Place mit Dritten

**Freigabe mit Auflagen.** Gegen Build s1 bestehen keine inhaltlichen Bedenken. Die Auflagen sind organisatorisch und liegen beim Owner:
- **T-1** Fragebogen einreichen, korrigiert nach §2, das vergebene Label (erwartet Minimal) und regionale Ergebnisse in `questionnaire.md` eintragen, **bevor** ein Dritter Zugang erhält (C-A1).
- **T-2** Owner-Konto mit Altersprüfung, Konto ≥ 2 Tage. Audience **Limited → Playtesters**. Public ist auch mit „Exclude from Recommendations“ kein Ersatz, weil das Spiel dann trotzdem öffentlich ist (KS-05).
- **T-3** Kinder testen nur auf dem Owner-Gerät oder als Trusted Friends mit Eltern-Zustimmung. Es gelten die Grundsätze aus §6.1 des Playtest-Berichts.
- **T-4** Titel und Beschreibung des Test-Place enthalten keine Hangout-Begriffe (C-A29). „Allow strong language“ bleibt aus.

**Offen für Sprint 2** (Prüfung beim nächsten Check): C-A6 (Persistenz mit `player.User` und RTBF-Templates), C-A30 und C-A32 (Signale, Transparenz, Marker), die Optionen „Hilfe“ und „Spuren anderer“ sowie die Fragebogen-Neuprüfung für Zonen 2 und 3. **Vor öffentlichem Release:** C-A11, C-A12, C-A15 (D-025) und C-A29.
