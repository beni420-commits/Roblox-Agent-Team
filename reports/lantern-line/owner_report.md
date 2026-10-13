# Owner-Bericht „Lantern Line – Der Nachtzug“ (2026-10-13)

**Kurzfassung:** Dein Horror-Spiel (Auftrag D-032: nah am Genre-Vorbild, aber mit eigenem, wiedererkennbarem Stil) ist als erste vollständige Fassung gebaut: 51 Wagen, 6 Wesen, Finale mit Rätsel, 1–4 Spieler, Deutsch und Englisch. Alles, was ohne Roblox Studio prüfbar ist, ist geprüft und grün. **Ob es sich in Roblox gut spielt, ist noch nicht geprüft**, weil es hier kein Studio gibt. Der nächste Schritt ist dein Test (45–60 min) nach `reports/lantern-line/owner_test_template.md`.

## 1. Was du bekommst
- **Spiel:** `build/LanternLine.rbxlx`. Doppelklick öffnet es in Roblox Studio, dann **Play** (F5). Für 2 Spieler: **Test → Clients and Servers → 2 Players**.
- **Installer:** `installer/LanternLine-Installieren.bat` baut immer den aktuellen Stand und legt eine Desktop-Verknüpfung an (Anleitung: `installer/ANLEITUNG.md`).
- **Abkürzung zum Finale (nur in Studio):** Attribut `DebugStartCarriage` = 50 am Workspace (Checkliste, Abschnitt D).

## 2. Nah am Genre-Vorbild, eigener Stil
| Genre-Gefühl wie im Vorbild | Eigene Umsetzung in Lantern Line |
|---|---|
| Raum für Raum vorwärts, Nummern zählen hoch | Nachtzug mit 51 Wagen; Wagennummer als weiße Schablonenschrift |
| Wesen, das man hört und sieht, bevor es kommt → verstecken | **Express**: weißes Licht von hinten, Lampen schwingen → in den Schrank |
| Licht als Warnsignal | **Gegenzug**: ruhiges blaues Licht auf einer Seite → auf die andere Wagenhälfte |
| Dunkle Räume | **Blinder Passagier**: grüne Augenpaare, die bei Nähe heller werden |
| „Nicht bewegen“-Wesen | **Kontrolleur** mit Kelle: rund = gehen, Streifen = stillstehen |
| Verfolgungsjagd | **Kofferlawine** mit eigenem Kern: Gemeinsam den **Kupplungshebel** ziehen, dann bleibt die Lawine mit den hinteren Wagen zurück |
| Finale mit Rätsel und Wächter | **Postwagen**: Der Schaffner sieht nur, was sein Lichtkegel trifft. Fahrkartenschnipsel sammeln, dann ein **Lochmuster** am Entwerter stanzen |
| Hinweis nach dem Tod | **Fahrkarten-Notiz des Bahnhofsvorstehers** |

**Stil „Laternen-Noir“:** Holz, Messing, Laternenlicht. Kein Blut, keine Gesichter, kein Ragdoll. Die Figur verblasst nur. Jede Gefahr hat ein zweites Merkmal neben der Farbe. Es gibt Einstellungen für reduziertes Flackern, einen Sanften Modus und reduzierte Bewegung.

**Kein Vorbild-Material:** keine Namen, Bilder, Sounds oder Assets aus dem Vorbild (deine Freigabe „ohne Copyright“). Eine automatische Prüfung (`scripts/check.sh`) sucht im Code und in allen Spieltexten nach verbotenen Begriffen.

## 3. Prüfungen und Gate-Status
- **Prüfkette grün** [GETESTET]: 78 Logik-Tests für Lantern Line (u. a. 150 Seeds × 51 Wagen Fairness), Typprüfung, Linter, Build, Compliance-Textprüfung, 18 Installer-Tests.
- **Unabhängiges Code-Review:** 24 Befunde, alle behoben. Der wichtigste: Verstecken hätte ab Wagen 1 nicht funktioniert, weil die Prompts weit neben dem Schrank saßen. Das wäre ohne Review erst in deinem Test aufgefallen.
- **Simulierter Spielertest** [SIMULIERT]: 18 Befunde, 15 behoben. Die übrigen 2 brauchen dich (§5), einer bleibt bewusst so.

| Gate | Status |
|---|---|
| Spielspaß | **offen**: dein Test |
| Stabilität | **offen**: Logik getestet, Studio-Konsole ungeprüft |
| Sicherheit | **teilweise**: Remotes geprüft; Bewegungsprüfung neu, ohne echte Netzdaten |
| Daten | nicht anwendbar (kein Speicherstand) |
| Performance | **offen**: am Gerät ungemessen |
| Compliance | **Freigabe mit Auflagen** für einen privaten Test-Place; öffentlich erst nach deinen Freigaben (§4) |

## 4. Freigaben, die nur du geben kannst (Masterprompt §8)
Für deinen eigenen Test in Studio ist **keine** Freigabe nötig.
1. **Altersfreigabe:** Erwartet ist das Label „Mild“ (Gewalt und Angst, mild/wiederholt). Soll das Spiel auch für **Roblox Kids (5–8)** offen sein? Empfehlung: zuerst nur ab 9.
2. **Eigenes Universe** für Lantern Line mit eigenem Fragebogen (Entwurf: `docs/lantern-line/questionnaire.md`) und Servergröße 4.
3. **Test mit anderen Personen** (privater Test-Place), Auflagen T-1 bis T-5:
   - Fragebogen vorher einreichen (T-1).
   - Konto mit Altersprüfung; Zugang nur „Limited → Playtesters“ (T-2).
   - Kinder nur auf deinem Gerät oder als Trusted Friends mit Zustimmung der Eltern (T-3).
   - Keine Hangout-Begriffe im Titel (T-4).
   - Eltern auf Grusel hinweisen, niemand mit bekannter Fotosensibilität testet, vorerst nur Kinder ab 9 (T-5).
4. **Öffentliche Veröffentlichung:**
   - Titel und Markenrecherche („Lantern Line“, „Der Nachtzug“)
   - Icon und Thumbnails aus echten Aufnahmen
   - Veröffentlichungskosten (D-025)
5. **Sounds und hochgeladene Bilder:** Bisher gibt es keine (das Spiel ist stumm). Jede Quelle prüfst du vorher (D-030).
6. **Monetarisierung:** keine eingebaut. Jede Form käme als eigene Freigabe zu dir.
7. **Optional:** Die Konzeptdokumente liegen im **öffentlichen** GitHub-Repo. Sollen sie dort bleiben?

## 5. Zwei Designfragen an dich
- **LP-03 Laufdauer:** Ein ganzer Lauf dauert ca. 25 Minuten. Wer früh ausscheidet, schaut lange zu. Vorschlag: alle 10 Wagen ein Bahnhof, an dem Ausgeschiedene wieder zusteigen (Backlog L-011). Ja oder nein?
- **LP-15 Fahrkarten-Abrisse:** Man sammelt sie, aber sie haben noch keinen Zweck. Vorschlag: rein kosmetisches Fahrtenbuch mit Stempeln, ohne Kauf und ohne Zufall (L-012). Oder weglassen?

## 6. Was nicht geprüft werden konnte
- **Alles in der Engine:** Kamera im Versteck, Lichtwirkung, Latenz, Touch, Gamepad, Bildrate. Die 24 technischen Prüfpunkte stehen in `reports/lantern-line/code_review_sprint1.md` §6; die wichtigsten sind in deiner Checkliste.
- **Installer auf echtem Windows.**
- **Spielspaß:** Alle Aussagen dazu sind [SIMULIERT] oder [ANNAHME].

## 7. Vorschlag für den nächsten Schritt
1. Dein Test nach `owner_test_template.md`. Rote Meldungen aus dem Output bitte mitschicken.
2. Dann ein Sprint mit: Befunden aus deinem Test (L-002), deinen Antworten zu §5 und, nach deiner Freigabe, Sounds (L-003).
