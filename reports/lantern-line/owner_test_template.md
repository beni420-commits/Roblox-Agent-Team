# Owner-Test „Lantern Line“ – Checkliste P0 (ca. 45–60 min)

Ziel: herausfinden, ob das Spiel in Roblox Studio läuft, verständlich ist und Spaß macht. Hier konnte nichts in der Engine ausgeführt werden; dein Test ist die erste echte Prüfung.

## Vorbereitung
- [ ] Spiel öffnen: `installer\LanternLine-Installieren.bat` oder die Datei `LanternLine.rbxlx` in Studio öffnen
- [ ] In Studio **View → Output** einblenden. Rote Fehlermeldungen bitte abfotografieren oder kopieren
- [ ] Test 1: **Play** (F5), allein
- [ ] Test 2: **Test → Clients and Servers → 2 Players → Start**

## A. Start und Bahnsteig
| # | Prüfen | ok? | Notiz |
|---|---|---|---|
| A1 | Du erscheinst am Bahnsteig in Ich-Perspektive; die Abfahrtstafel zeigt „LANTERN LINE“ und „Der Nachtzug“ | | |
| A2 | Output ohne rote Fehler | | |
| A3 | Der Knopf „Einstellungen [M]“ pulsiert; mit M öffnet sich die Fahrkarte mit 3 Schaltern | | |
| A4 | Auf die Pfeile vor der Zugtür stellen: Die Tafel zählt „Abfahrt in …“ herunter und zeigt „1/2 bereit“. Danach sind alle Spieler im Zug (Wagen 0), auch wer nicht auf den Pfeilen stand | | |
| A5 | Wagen 0: An der Wand hängt die Fahrgastinformation mit 6 Zeichen. Ist sie lesbar und verständlich? | | |

## B. Zug und Grundablauf
| # | Prüfen | ok? | Notiz |
|---|---|---|---|
| B1 | Die Tür vorn öffnet sich beim Herantreten; oben links steht „WAGEN 01“ | | |
| B2 | Draußen ziehen Lichter vorbei; die Kamera schwankt leicht (mit „Bewegung reduzieren“ nicht) | | |
| B3 | Durchsuchen (E) an Ablage, Koffer, Schublade und Kiste geht; danach ist der Behälter dunkler und nicht mehr nutzbar | | |
| B4 | Verschlossene Tür (Lampe neben der Tür leuchtet): Den Schlüssel im Wagen finden; das HUD zeigt „Schlüssel“, die Tür geht dann auf | | |
| B5 | Verstecken (E am Schrank): Die Sicht geht durch die Schlitze, „Aussteigen [E]“ funktioniert, du stehst danach vor dem Schrank | | |
| B6 | Nach ca. 14 s im Versteck: Raureif. Nach 20 s wirst du hinausgeschoben (ohne Schaden) | | |
| B7 | Schleichen (C, Gamepad L3): langsamer, Anzeige „Schleichen“; schaltet sich bei Express und Kofferlawine selbst aus | | |
| B8 | Ältere Wagen verschwinden hinter dir; zurücklaufen geht nur bis 4 Wagen zurück | | |

## C. Wesen
Die Reihenfolge ist zufällig. Notiere, was dir begegnet.
| # | Prüfen | ok? | Notiz |
|---|---|---|---|
| C1 | **Express**: Lampen schwingen und flackern, unten erscheint eine helle Leiste, von hinten kommt weißes Licht. Im Schrank überlebst du, außerhalb scheidest du aus | | |
| C2 | **Gegenzug**: Blaue Pfeile am Rand der Lichtseite zeigen zur sicheren Seite, ein blauer Bodenstreifen liegt auf der Gefahrenseite, das Licht an den Fenstern wird ruhig heller (kein Flackern). Auf der anderen Seite gibt es keinen Schaden | | |
| C3 | **Dunkler Wagen**: Nur dein eigenes Licht leuchtet. Grüne Augenpaare werden in der Nähe heller; zu nah kostet Leben, danach verschwinden sie | | |
| C4 | **Kontrolleur** (Schlafwagen): Bei runder Kelle darfst du gehen. Vor dem Stillstehen erscheint oben „Gleich stillstehen“ mit Ablaufbalken, bei der Streifen-Kelle „Stillstehen“. Wer erst bei „Stillstehen“ anhält, bekommt **keinen** Schaden. Wer bei ihm ankommt, sieht „Kontrolliert“ | | |
| C5 | **Kofferlawine** (Wagen 25–42): Lampen hinten werden orange, eine Kofferwand rollt. Wenn du nach vorn läufst, entkommst du | | |
| C5b | **Kupplung**: Im Übergang zwei Wagen weiter leuchtet ein Hebel orange, sobald alle vorbei sind. 1 s halten: Die Tür schließt sich, die Lawine fällt zurück | | |
| C6 | **Ausscheiden**: Kurz wird es dunkel, dann erscheint die Fahrkarten-Notiz mit Hinweis. „OK“ (oder nach 8 s automatisch) startet das Zuschauen mit Kamera hinter dem Mitreisenden (nur mit 2 Spielern), Wechseln mit Q/E. Allein: Der Hinweis steht auf der Ergebnis-Fahrkarte | | |

## D. Finale (Wagen 50) – Abkürzung zum Testen
Bis Wagen 50 dauert es 20–30 Minuten. **Abkürzung (wirkt nur in Studio):**
1. Im Explorer **Workspace** auswählen.
2. Im Eigenschaften-Fenster ganz unten **Attribute hinzufügen (+)**: Name `DebugStartCarriage`, Typ **Number**, Wert `50`.
3. Dann **Play** drücken und einsteigen: Der Lauf beginnt direkt im Postwagen.

Mit z. B. `30` testest du die Kofferlawine bzw. die mittleren Wagen. Danach das Attribut wieder löschen. Im veröffentlichten Spiel hat es keine Wirkung.
| # | Prüfen | ok? | Notiz |
|---|---|---|---|
| D1 | Der Schaffner erwacht nach ca. 6 s; sein Lichtkegel ist sichtbar | | |
| D2 | Im Kegel oder beim Laufen in seiner Nähe kommt er auf dich zu; beim Schleichen hinter ihm nicht | | |
| D3 | Drei Fahrkartenschnipsel lesen (E); der Notizzettel oben rechts füllt sich | | |
| D4 | Am Entwerter das Muster stanzen: Falsch zeigt „Falsches Muster!“ und lockt ihn an, richtig öffnet das Tor | | |
| D5 | Durchs Tor gehen: Die Ergebnis-Fahrkarte erscheint, nach 15 s bist du zurück am Bahnsteig | | |

## E. Einstellungen und Kinderschutz
| # | Prüfen | ok? | Notiz |
|---|---|---|---|
| E1 | „Flackern reduzieren“: Bei Express gibt es kein Flackern, nur sanftes Abdunkeln | | |
| E2 | „Sanfter Modus“: Beim Ausscheiden gibt es keinen farbigen Blitz, die Lichtwesen sind gedämpft und es wackelt nichts | | |
| E3 | Nichts wirkt für Kinder zu brutal (kein Blut, keine Gesichter, kein Ragdoll) | | |
| E4 | Einmal **ohne Ton** spielen: Sind alle Gefahren am Licht erkennbar? | | |

## F. Gesamteindruck (1–5)
- Gruselfaktor: __ · Fairness: __ · Spaß: __ · Verständlichkeit ohne Erklärung: __
- Größte Frust-Stelle: ________________________________
- Ist das Setting „Nachtzug“ für dich wiedererkennbar und gut? ja / nein, weil …
