# Owner-Test – Vorlage (P0-Selbsttest nach Sprint 1)

Bitte diese Datei kopieren nach `reports/owner_test_sprint1.md`, ausfüllen und committen (oder die Ergebnisse als Nachricht schicken). Ausgefüllte Punkte gelten als `[GETESTET]`.
Grundlage: `tech_notes.md` §7, Testplan in `playtest_report_sprint0.md` §6 (Session P0). **Für den Selbsttest mit eigenem Konto in Studio ist der Fragebogen nicht nötig**; vor Tests mit Dritten schon (C-A1, `docs/compliance/questionnaire.md`).

**Kopf:** Datum ______ · Build/Commit ______ · Gerät(e) ______ · Eingabe(n) ______

## A. Start und Stabilität (Studio)
| # | Schritt | Erwartung | Ergebnis (✓/✗ + Notiz) |
|---|---|---|---|
| A1 | Lokal `rojo build default.project.json -o build/place.rbxlx`, Datei in Studio öffnen (oder `rojo serve` + Plugin) | Place öffnet ohne Fehler | |
| A2 | Play (F5), 2 min herumlaufen | **keine roten Fehler** in der Ausgabe; `[Telemetry]`-Zeilen erscheinen | |
| A3 | Explorer: `Workspace.Tower` mit `Statics`, `SummitBeacon`, `Floor_01`–`Floor_10`; `ReplicatedStorage.Remotes` | vorhanden | |
| A4 | Workspace: `StreamingEnabled` = an, `ModelStreamingBehavior` = Improved | wie erwartet | |

## B. Spielgefühl Zone 1 (Studio, dann echtes Handy)
| # | Schritt | Erwartung | Ergebnis |
|---|---|---|---|
| B1 | Spawn auf der Plaza | Kamera schwenkt 2 s zum Leuchtfeuer (überspringbar), Turm im Bild | |
| B2 | Ohne Vorwissen loslaufen (Stoppuhr) | **Etage 1 in ≤ 60 s**; goldene Chevrons und Lichtsäule zeigen den Weg | Zeit: ___ s |
| B3 | Funken einsammeln | Funke verschwindet sofort, Zähler +1, „+1“-Popup | |
| B4 | Absichtlich fallen | ≤ 1,5 s später am **Anfang derselben Etage**, kurze Abdunklung | |
| B5 | 3× fallen auf einer Etage, dann 6× | ab 3: Chevrons; ab 6: glasige Hilfsstufen erscheinen und tragen | |
| B6 | Sprungpad (ab Etage 3, orange leuchtend) | schleudert hoch, Ziel erreichbar | |
| B7 | Förderband (blau-grau, Riffelblech) | schiebt in Laufrichtung, nicht vom Weg | |
| B8 | Knappe Kante: kurz nach dem Verlassen springen | Sprung klappt noch (Coyote-Time) | |
| B9 | Etage 5 und 10 | größere Holz-Plattform (Lager), Funken +5 | |
| B10 | Etage 10 | Banner „Meadow cleared!“ bzw. auf Deutsch „Wiese geschafft!“ | |
| B11 | Kamera im Turm | Säule bzw. Etagen darüber werden durchsichtig statt heranzuzoomen (Invisicam) | |
| B12 | Kopfstoß beim Springen? | kein Kopfstoß an Etagen darüber | |
| B13 | Zeit bis Etage 10 | Erwartung ca. 6–8 min für Erstspieler (Modell) | Zeit: ___ min |
| B14 | Gefühl: zu leicht / passend / zu schwer? Stellen, an denen du gezögert hast | Freitext | |

## C. Geräte und Eingabe
| # | Schritt | Erwartung | Ergebnis |
|---|---|---|---|
| C1 | Studio Device Emulator: kleines Telefon, großes Telefon, Tablet | HUD (Funken oben links, Etage oben Mitte) nicht verdeckt von Topbar, Joystick oder Sprungknopf; lesbar | |
| C2 | Gamepad (falls vorhanden) | bewegen, springen | |
| C3 | Echtes, möglichst schwaches Android: Modell ______ | flüssig spielbar; FPS (Einstellungen → MicroProfiler bzw. Developer Console) ≥ 30 | FPS: ___ |
| C4 | Sprache Deutsch im Roblox-Konto | Banner auf Deutsch | |

## D. Mehrspieler (Studio: Test → Clients and Servers, 2 Spieler)
| # | Schritt | Erwartung | Ergebnis |
|---|---|---|---|
| D1 | Spieler laufen ineinander | **keine Kollision**, niemand wird geschubst | |
| D2 | Beide sammeln denselben Funken | jeder für sich (Funken sind pro Spieler) | |

## E. Offene Fragen an dich
1. Soll Zone 1 schwerer werden (Zonenfaktor 0,75 → 0,8)?
2. Kamera: reicht die Standardkamera mit Invisicam, oder brauchen wir eine eigene Verfolgerkamera?
3. Sounds: Darf ich die eingebauten Roblox-Standardklänge nutzen (Kat. 0)? Falls ja, bitte prüfen, ob in Studio z. B. `rbxasset://sounds/electronicpingshort.wav` abspielbar ist.
