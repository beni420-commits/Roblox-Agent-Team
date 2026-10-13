# Compliance-Nachprüfung „Lantern Line – Der Nachtzug“ (Umsetzung + GDD v0.2)

| Feld | Wert |
|---|---|
| Datum / Rolle | 2026-10-13 · Compliance-Officer (Veto-Recht: Kinderschutz, Roblox-Regeln, Recht) |
| Gegenstand | Commit `3dc2613`: `games/lantern-line/` (kurz `LL/` = `games/lantern-line/src/`), `default.project.json`, `GameStrings.csv` (59 Schlüssel), `docs/lantern-line/game_design_doc.md` v0.2, `scripts/lantern_line_checks.py`, D-032 bis D-039 |
| Grundlage | Eigene Vorprüfung `compliance_check_concept.md` (H-A1 bis H-A15, V1 bis V3); `compliance_check_sprint1.md` (T-1 bis T-4). Original-Doku creator-docs @af5f853, Pfade relativ zu `content/en-us/` |
| Methode | Vollständige Code-Lektüre der Wesen, Effekte, Einstellungen, Tod und Zuschauen; Volltextsuche; `lantern_line_checks.py` ausgeführt: **OK**. 2 Websuchen (`WS-S` = Fan-/Guide-Quellen). **Nichts in Studio ausgeführt**: Laufzeit- und Lichtwirkung sind aus dem Code abgeleitet `[ANNAHME]`. Keine Rechtsberatung |

## 1. Ergebnis

| Fall | Urteil |
|---|---|
| (a) Owner allein in Studio | **Freigabe**. Prüfaufträge stehen in §8 |
| (b) Privater Test-Place mit Dritten | **Freigabe mit Auflagen**: T-1 bis T-4, neu T-5 und **H-A16 umgesetzt** (Fotosensibilität) sowie Owner-Sichtprüfung (§8) |
| (c) Öffentliche Veröffentlichung | **Aufschiebendes Veto**, bis H-A1, H-A2 (e), H-A15, H-A16 bis H-A18 und die Owner-Freigaben (§9) erledigt sind |

- **Die bedingten Vetos V1 bis V3 sind nicht ausgelöst.** Es gibt keine Bezüge zum Vorbild im Spiel, keine Bar und keine Käufe.
- **Label Mild bestätigt** (§5). Der Fragebogen-Entwurf liegt in `docs/lantern-line/questionnaire.md`.
- Die Umsetzung ist insgesamt sorgfältig: kein Roblox-Tod, keine Gesichter, keine Namen, keine Texteingabe, ein Flacker-Planer mit Test.
- **Zwei echte Lücken:**
  - Die Lichter des Gegenzugs flackern wahrscheinlich mit etwa 8 Hz.
  - Die Kofferlawine hat noch keine eigene Kernmechanik.

## 2. Status der Auflagen H-A1 bis H-A15

| Auflage | Status | Beleg (Datei:Zeile) | Rest |
|---|---|---|---|
| H-A1 keine Kennzeichen des Vorbilds | **umgesetzt (Spiel)**, offen (Metadaten) | Blockliste gegen CSV und Code `scripts/lantern_line_checks.py:27-39,62-86`; Lauf grün. Prompts heißen „Climb in“, nicht „Hide“ (`LL/server/TrainBuilder.luau:381`) | Titel, Beschreibung, Icon, Thumbnails und Badges vor (c) |
| H-A2 eigene Gestaltung | **umgesetzt im Code**, Nachweis offen | (a) Kontrolleur: Mantel, Kopfblock ohne Gesicht, Mütze, Laterne, Kelle (`TrainBuilder.luau:806-875`). Schaffner: Säule mit Schultern, Mütze, Kopflampe; kein Kopf, kein Gesicht, keine Zähne (`:879-931`). Augen: genau 2 Kugeln, kein Mund (`:471-494`). Express: Lichtkugel ohne Gesicht (`LL/client/Controllers/EntityController.luau:82-114`). Lawine: Koffer (`:116-152`). Kein `ParticleEmitter`/`Smoke`/`Decal`/`Mesh` in `LL/`. (b) Schablonennummer weiß (`TrainBuilder.luau:129-144,522`; Farbe `Palette.luau` `stencil`). (c) Notiz als Fahrkarte des Bahnhofsvorstehers (`DeathController.luau:105-112`). (d) kein Herzschlag-Spiel, Kälte als Raureif ohne Rot (`HidingController.luau:3`; `Hud.luau:225-242`). (f) keine Asset-IDs | Studio-Screenshot je Wesen und UI (vorgesehen „vor dem Merge“, jetzt vor (b)); (e) Logo/Icon fehlt noch |
| H-A3 Finale | **umgesetzt** (Pflicht: (b) plus (a)) | (b) Lochmuster 3×3 statt Symbol → Ziffer → Reihenfolge (`TrainBuilder.luau:538-588`; `ValidatorController.luau`). (a) Lichtkegel 16 Studs, ±30°, freie Sicht (`LL/shared/Logic/Conductor.luau:124-138`); Silhouette in Uniform. (c) nicht umgesetzt (Finale bleibt bei Wagen 50) | Hörradius beim Laufen (22) ist größer als die Sichtweite (16) (`GameConfig.luau:101,103`). Damit sind Geräusche kein reiner Nebenfaktor → H-A17 (b) |
| H-A4 keine weiteren 1:1-Entsprechungen | **teilweise** | Gegenzug und Augen eigenständig; Kofferlawine nur in der Optik eigenständig (§3) | H-A17 (a) |
| H-A5 Zuordnungstabelle | **umgesetzt** | GDD §2 mit den Spalten „Genre-Prinzip / Unsere Umsetzung / Ausdrücklich nicht übernommen“ (`game_design_doc.md:20-35`). Owner-Wortlaut in D-032. Prüfung `lantern_line_checks.py:126-133`. Keine Bilder im Repo | – |
| H-A6 keine Bar, kein Alkohol | **umgesetzt** | Teesalon mit Samowar (`CarriageCatalog.luau:285`; `TrainBuilder.luau:296-309`). Küche ohne Flaschen. Wortliste Alkohol in der CSV-Prüfung | Screenshot von Teesalon und Speisewagen |
| H-A7 private Räume, Betten | **umgesetzt** | Schlafwagen ≤ 25 % (`TrainGenerator.luau:25,41`; Test `TrainGenerator.spec.luau:239`). Abteile mit offenen Öffnungen (`CarriageCatalog.luau:167`). Keine Seats (Prüfung). Keine WC- oder Waschräume. Springen aus (`default.project.json` `CharacterJumpHeight 0`, `AutoJumpEnabled false`). Versteck für genau 1 Person (`HideState.spec.luau:9`), jederzeit verlassbar (`HidingController.luau:52`). Keine Spieler-Kollision (`WorldSetup.luau:69`) | Bett (2 Studs) und Sofa (1,4) nicht betretbar? `[ANNAHME]`, Owner-Test |
| H-A8 Fragebogen, Mild-Grenzen | **umgesetzt im Code**; Einreichung offen | Lebenspunkte fallen nie auf 0 (`PlayerService.luau:148`), `BreakJointsOnDeath=false` (`:32`), Verblassen 0,6 s, dann entfernt (`:156-177`). Fragebogen-Entwurf neu: `docs/lantern-line/questionnaire.md` | Owner reicht vor (b) ein (T-1) |
| H-A9 kindgerechte Schreckmomente | **umgesetzt** | Jede Gefahr hat eine Vorwarnung (2,5 bis 4 s; Augen ab 8 Studs heller). Todesbild 0,2 s Tönung + 0,6 s Abblende (`Hud.luau:379-387`). Keine Sounds. Sanfter Modus: kein Blitz, gedämpfter Express, kein Wackeln (`Hud.luau:380`; `EntityController.luau:89`; `Settings.luau:59`). Einstellungsknopf pulsiert am Bahnsteig (`Hud.luau:192`) | Sanfter Modus schließt „Flackern reduzieren“ nicht ein → H-A16 (b) |
| H-A10 Fotosensibilität | **teilweise** | Lampen: ein synchroner Plan, ≤ 2 Pulse je 1-s-Fenster (`FlickerPlanner.luau:13-30`; Test über 500 Pläne `FlickerPlanner.spec.luau:8-20`). Kein Gelb/Rot-Flackern: Laterne wechselt weich (`EntityController.luau:300-309`), Kelle pulsiert mit 0,8 Hz (`Hud.luau:139`). Bloom begrenzt (`WorldSetup.luau:59-63`). „Flackern reduzieren“ mit Übergängen ≥ 0,3 s (Test `:27-40`) | **Gegenzug ca. 8 Hz, Express-Kugel bildfüllend, Einstellungen greifen nicht überall** → H-A16 |
| H-A11 nicht nur Farbe, Bewegung abschaltbar | **weitgehend umgesetzt** | Express: Warnleiste (`Hud.luau:179-187`), schwingende Lampen. Gegenzug: Pfeil `‹‹`/`››` und Bodenband. Kelle: Form und Text (`Hud.luau:121-148`). Augen: Größe. Schaffner: Lichtkegel. „Bewegung reduzieren“ übernimmt `ReducedMotionEnabled` (`Settings.luau:15`) und schaltet Schwanken, Lampenschwingen und Lawinen-Rütteln ab | UI-Wackeln am Entwerter (`ValidatorController.luau:95-99`) und Kellen-Puls ignorieren „Bewegung reduzieren“ → H-A18 (b). Bodenband ist sehr blass (Transparenz 0,92). Graustufen-Screenshots fehlen |
| H-A12 Texte, Eingabe, Namen, Chat | **umgesetzt** | Kein `TextBox`. Lochmuster als Ganzzahl 0–511, 0,5/s (`Net/Definitions.luau:23-24`), Reichweite 12 (`RunController.luau:919`). Zuschauen als „Mitreisender n/m“ ohne Namen (`DeathController.luau:73`). Ergebnis ohne Namen. Kein `TextChatService`, keine eigenen Kanäle. Gemeinsamer Notizzettel (`RunController.luau:897`) | – |
| H-A13 keine Käufe | **umgesetzt** | Kein `MarketplaceService` (Prüfung); keine Wiederbelebung (GDD §7) | – |
| H-A14 nur Kat. 0 | **umgesetzt** | Keine Asset-IDs, keine Sounds. Systemschriften `Enum.Font.SpecialElite`/`Michroma` (`UiKit.luau:11-12`). Keine Bahnmarken (Blockliste) | Zeile „Lantern Line: nur Kat. 0“ in `docs/assets.md` ergänzen |
| H-A15 Titel, Marke, Medien | **offen** | Der Titel folgt nicht dem Muster des Vorbilds (zwei Wörter, kein Plural) | Markenrecherche, Thumbnails, Icon vor (c) |

## 3. Neue Wesen (H-A4): Abstand zum Vorbild

| Wesen | Eigene Kernmechanik? | Bewertung |
|---|---|---|
| Gegenzug | **Ja.** Man wechselt die Wagenseite (Position quer statt Verstecken). Im Vorbild ist kein Wesen dieser Art bekannt `[WS-S, nicht vollständig verifiziert]` | ausreichend |
| Blinder Passagier | **Ja.** Abstand statt Ansehen; feste Augenpaare. Restnähe: dunkle Räume und 35 Schaden; das Vorbild verursacht laut Guides 35–40 Schaden [WS-S] | ausreichend; Schaden nicht weiter angleichen |
| Kofferlawine | **Nein, nur Optik.** Kern ist reine Flucht nach vorn: Türen öffnen sich, Verstecke sind aus. Sie kommt einmal je Lauf, Start in Wagen 25–38 (`GameConfig.luau:88`). Die Jagd im Vorbild liegt laut Guides bei Tür 25–45 bzw. 30–45 [WS-S]. Ohne Augen an Wänden, ohne Lichtfunken, ohne Hindernisse ✓ | **teilweise**. D-034 („mit eigener Kernmechanik“) trifft nicht zu → H-A17 (a) |
| Schaffner | Lichtkegel als Hauptsinn ✓, Lochmuster ✓. Postwagen mit zwei Regalgängen, Schließfächern und „falsches Muster ist laut“ bleibt strukturell nah | ausreichend mit H-A17 (b) |

## 4. Spieltexte (`LL/localization/GameStrings.csv`, EN und DE)

- **Kindgerecht:** keine Gewalt- oder Todeswörter (kill, die, dead, blood, töten, Blut, sterben). Der Tod heißt „Deine Reise endete in Wagen {1}“ bzw. „Endstation“. Die Hinweise sind handlungsorientiert, z. B. „ab in einen Schrank“, „bleib stehen“, „nach vorn laufen“.
- **Sauber:** keine Namen aus dem Vorbild, kein Alkohol, keine Marken, keine Links, keine Kaufaufforderungen. Die Blockliste prüft das bei jedem Lauf.
- **Hinweis (keine Auflage):**
  - `HINT_ONCOMING_1` nennt „Hupe/horn“, obwohl es keine Sounds gibt (D-030). Das führt in die Irre; den Text bis zur Sound-Freigabe ohne Hupe formulieren.
  - Der „OK“-Knopf der Notiz ist unlokalisiert; das ist unkritisch.

## 5. Content Maturity: Mild bleibt richtig
- **Violence Ja · Mild · Repeated.** Wesen fügen Schaden zu und lassen Figuren ausscheiden. Die Folge ist unrealistisch: Die Figur verblasst, wie im Original-Beispiel „bodies disappearing the moment their health reaches zero“. Begegnungen gibt es oft, daher Repeated.
- **Fear Ja · Mild · Repeated.** Gruselige NPC, Spannung und Schreckmomente; nichts aus der Moderate-Liste (Münder mit Blut, Organe, Wunden, blutende Augen).
- **Romantic themes/private spaces: Nein.** Schlafwagen ≤ 25 %; das Spiel findet nicht „primarily“ in privaten Räumen statt.
- **Alle übrigen Kategorien: Nein.** Das Lochmuster am Entwerter ist **keine** Free-form-Erstellung: Das Raster ist lokal, nur der Server sieht die Maske, andere sehen nichts (`ValidatorController.luau:24,85`).
- **Ergebnis:** Label Mild; Roblox Kids und Select sind erreichbar [QUELLE: `production/promotion/content-maturity.md`, `production/publishing/kids-and-select.md` @af5f853, abgerufen 2026-10-13].
- **Kippt zu Moderate** schon bei einer einzigen realistischen Todesfolge („even if the realistic violence only occurs once“).

## 6. Neue Risiken durch die Umsetzung

1. **Gegenzug flackert (hoch).**
   - Sechs Lichter (Helligkeit 5, Reichweite 26) im Abstand von 20 Studs fahren mit 160 Studs/s am Fenster vorbei und springen alle 0,75 s gemeinsam zurück (`EntityController.luau:200-222`).
   - An jeder Wandstelle ergibt das Schübe von 3 bis 6 Lichtdurchgängen mit **etwa 8 Hz**, dann ca. 0,34 s Dunkel und einen harten Sprung. Beim Treffer springt die Helligkeit zudem von 1,5 auf 5.
   - In einem sehr dunklen Wagen (Ambient 0,02, `default.project.json`) liegt das wahrscheinlich über der WCAG-Grenze von 3 Blitzen pro Sekunde.
   - Der Effekt läuft am FlickerPlanner vorbei, „Flackern reduzieren“ wirkt nicht, und der Sanfte Modus dämpft nur auf 60 %.
   - Das widerspricht GDD §9.9 („über den ganzen Bildschirm ≤ 2“). `[ANNAHME: aus dem Code berechnet, nicht in Studio gemessen]`
2. **Express-Kugel in der Ich-Perspektive (mittel).** Ich-Perspektive ist erzwungen (`CameraMode LockFirstPerson`). Die Kugel aus weißem Neon (Durchmesser 6, Transparenz 0,3) fliegt auf Augenhöhe (y = 5) durch die Kamera aller Spieler, die nicht versteckt sind. Kurz vor dem Ausscheiden ist das Bild also fast ganz weiß. Das ist ein einzelner Blitz, WCAG-konform, widerspricht aber H-A10 (d) und H-A9 (Sanfter Modus). Versteckte Spieler sehen nur den Sehschlitz.
3. **Einstellungen greifen nicht überall (mittel).** „Flackern reduzieren“ beruhigt nur Lampen und Warnleiste, nicht Gegenzug und vorbeiziehende Lichter (`AmbienceController.luau:144-167`; diese liegen mit ca. 0,9 Hz je Seite unkritisch). Der Sanfte Modus schaltet „Flackern reduzieren“ nicht mit ein. Zwei gleichzeitige Pläne für denselben Wagen würden sich addieren; wegen des Abstands ≥ 4 Wagen ist das unwahrscheinlich, ein Test fehlt.
4. **Zuschauen in fremder Ich-Perspektive (mittel, Komfort).** Weil die Kamera fest in der Ich-Perspektive ist, sitzt der Zuschauer im Kopf des Mitreisenden (`DeathController.luau:70`). Die Bewegung, die man nicht selbst steuert, begünstigt Bewegungskrankheit `[ANNAHME]`.
5. **Kamera-Schwanken (gering).** Rollen von ±0,35° bei ca. 0,2 Hz (`AmbienceController.luau:177`). Es ist abschaltbar und übernimmt `ReducedMotionEnabled`. In Ordnung.
6. **Kontrolleur als Hebel für Störer (gering bis mittel, für (c)).** Die Tür bleibt zu, bis alle im Wagen kontrolliert sind (`Inspector.luau:93-103`). Ein Spieler, der stillsteht und nie hingeht, blockiert die Gruppe ohne Zeitlimit. Das Original rät, Spiele nicht so zu gestalten, dass sie „abusive user behavior“ fördern [QUELLE: `safety.md`].
7. **Unkritisch:**
   - **Spielerlicht:** Reichweite 9, ohne Schalter, kein Blitzen (`PlayerService.luau:38-48`).
   - **Chat:** nur der Roblox-Standard; Kids haben ihn ohnehin standardmäßig aus.
   - **Namensschilder** zeigt nur Roblox selbst.
   - **Telemetrie** ohne personenbezogene Daten (`TelemetryService.luau:18-27`).
   - **`DebugStartCarriage`** wirkt nur in Studio (`RunController.luau:474`).

## 7. Neue Auflagen

**H-A16 Fotosensibilität vollständig (vor (b))**
- **Regel/Quelle:** H-A10, WCAG 2.3.1 [WS-O, Vorprüfung]; `accessibility.md`.
- **Umsetzung:**
  - (a) **Gegenzug** an jeder Bildstelle höchstens 2 Helligkeitswechsel pro Sekunde, z. B. ein durchgehendes Lichtband, das ein- und ausblendet, oder Lichtabstand ≥ 80 Studs. Kein Sprung beim Treffer, Rampe ≥ 0,3 s.
  - (b) „Flackern reduzieren“ gilt für **alle** Lichteffekte (Gegenzug als ruhiges Glühen, vorbeiziehende Lichter gedimmt). Der Sanfte Modus schließt „Flackern reduzieren“ ein.
  - (c) Die Express-Kugel ist **nie bildfüllend**: Kern ausblenden, wenn er näher als ca. 10 Studs an der Kamera ist, oder die Bahn über Augenhöhe legen. Im Sanften Modus ganz ohne sichtbaren Kern.
  - (d) Überlagerung: Pläne je Wagen zusammenführen oder per Test ausschließen.
- **Prüfbar:** Unit-Test in `shared/Logic` (Helligkeit an Messpunkten über die Zeit, gleitendes 1-s-Fenster ≤ 2); Owner-Aufnahme mit und ohne Einstellungen.

**H-A17 Abstand bei Kofferlawine und Finale (vor (c))**
- **Regel/Quelle:** H-A3, H-A4; „Non-unique games“ [OG `discovery.md`].
- **Umsetzung:**
  - (a) Die Kofferlawine bekommt ein **eigenes Kernelement** statt reiner Flucht. Beispiele: seitliche Nischen oder Abteile, in denen man die Lawine vorbeirollen lässt, oder eine Notbremse als Teamaufgabe. Keine weitere Annäherung: keine Augen an Wänden, keine Lichtfunken als Wegweiser, kein Hindernis-Parcours mit Ducken, keine Türwahl, keine zweite Jagd. D-034 entsprechend korrigieren.
  - (b) Hörradius beim Laufen ≤ Sichtweite, z. B. 14 statt 22, damit der Lichtkegel der Hauptsinn bleibt.
- **Prüfbar:** GDD v0.3 und Compliance-Check vor der Umsetzung.

**H-A18 Komfort und Fairness im Mehrspieler (vor (c), im Owner-Test schon prüfen)**
- **Regel/Quelle:** „Reduce Motion“ [OG `accessibility.md`]; „abusive user behavior“ [OG `safety.md`].
- **Umsetzung:**
  - (a) Zuschauen mit Kamera hinter oder über dem Mitreisenden, geglättet, statt in seinem Kopf.
  - (b) „Bewegung reduzieren“ auch für UI-Wackeln und Kellen-Puls; den Puls ersetzen durch Farbe und Text.
  - (c) Zeitlimit beim Kontrolleur, z. B. öffnet sich die Tür nach 30 s auch ohne alle.
- **Prüfbar:** Code-Review, Owner-Test mit 2 Clients.

**T-5 (neu, für (b))**
- Eltern vorab auf Grusel-Inhalt hinweisen.
- Den Sanften Modus und „Flackern reduzieren“ erklären.
- Abbruch ist jederzeit möglich.
- Niemand mit bekannter Fotosensibilität testet.
- Bis zur Owner-Entscheidung zu Kids (§9.1) testen nur Kinder ab 9 Jahren.

## 8. Prüfaufträge für den Owner-Test
Diese Punkte gehören in `reports/lantern-line/owner_test_template.md`, Abschnitt E:
- **Gegenzug:** mit und ohne „Flackern reduzieren“ ansehen und filmen (H-A16).
- **Express:** ohne Versteck erleben; wie hell wird das Bild?
- **Möbel:** Lässt sich ein Bett oder Sofa betreten (H-A7)?
- **Zuschauen:** mit 2 Clients 1 Minute zuschauen; wird einem übel (H-A18)?
- **Screenshots:** je Wesen, Teesalon, Todes-Notiz und HUD, zusätzlich in Graustufen (H-A2, H-A6, H-A11).

## 9. Owner-Freigaben nötig (Masterprompt §8)
1. **Label Mild und Roblox Kids (5–8):** Soll das Spiel für 5- bis 8-Jährige offen sein (Vorprüfung §7.2, GDD §15.2)? Dazu den Ersatz von C-A19 durch H-A9 bestätigen (Vorprüfung §7.1).
2. **Eigenes Universe** für Lantern Line mit eigenem Fragebogen (`docs/lantern-line/questionnaire.md`), Servergröße 4.
3. **Zugang Dritter (b):** T-1 bis T-5 (T-2: altersgeprüftes Konto, Audience Limited → Playtesters).
4. **Veröffentlichung (c):** Titel und Markenrecherche (H-A15), Icon und Thumbnails, Publishing Requirements und Gebühr (D-025, C-A15).
5. **Weiter offen:** Sounds und Bild-Uploads (D-030, H-A14) sowie jede Monetarisierung (H-A13).

## 10. Nicht verifiziert
- Wirkung der Lichter in der Engine (Abfall der PointLight-Helligkeit, Flächenanteil am Bild). Flackerfrequenz nur aus dem Code berechnet; keine Harding-/PEAT-Messung.
- Stufenhöhe, ab der ein Humanoid ohne Sprung auf ein Möbelstück kommt.
- Kamera und Durchsichtigkeit beim Zuschauen mit `LockFirstPerson` und fremdem `CameraSubject`.
- Angaben zum Vorbild (Jagd-Räume, Schaden, Wesenliste) stammen nur aus Fan-Guides und widersprechen sich teils [WS-S].
- Das Label vergibt Roblox; das regionale Ergebnis kommt erst aus der Fragebogen-Vorschau.

## 11. Quellen (abgerufen 2026-10-13)
- **Original-Doku** creator-docs @af5f853: `production/promotion/content-maturity.md`, `production/publishing/kids-and-select.md`, `production/publishing/accessibility.md`, `safety.md`, `discovery.md`.
- **Jagd im Vorbild [WS-S]:** [Scratch-Guide](https://scratch.mit.edu/discuss/post/6616275), [Pocket Tactics](https://www.pockettactics.com/roblox/doors), [Dot Esports](https://dotesports.com/roblox/news/how-to-beat-seek-in-roblox-doors).
- **Schaden und Fallen im Vorbild [WS-S]:** [Fan-Wiki „Snare“](https://doors-game.fandom.com/wiki/Snare), [Pro Game Guides](https://progameguides.com/roblox/roblox-doors-walkthrough-all-monsters-and-how-to-survive-them/).
