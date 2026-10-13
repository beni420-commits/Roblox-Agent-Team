# Spiele auf dem PC testen (Windows)

Ein Roblox-Spiel ist kein eigenständiges PC-Programm: Es läuft immer in **Roblox Studio** (zum Testen) bzw. in Roblox (nach der Veröffentlichung). Dieser Installer richtet alles ein, um die Spiele des Projekts auf deinem Windows-PC in Roblox Studio zu öffnen und zu spielen. Du brauchst **keine Administratorrechte**.

| Spiel | Einrichten (Doppelklick) | Später starten | Testcheckliste |
|---|---|---|---|
| **Lantern Line – Der Nachtzug** (Horror, 1–4 Spieler) | `LanternLine-Installieren.bat` | Desktop-Verknüpfung „Lantern Line testen“ bzw. `LanternLine-Starten.bat` | `reports\lantern-line\owner_test_template.md` |
| **Schwungturm** (Klettern) | `Schwungturm-Installieren.bat` | Desktop-Verknüpfung „Schwungturm testen“ bzw. `Schwungturm-Starten.bat` | `reports\owner_test_template.md` |

## Schnellweg ohne Installation
Wenn du nur die fertige Spieldatei hast (`LanternLine.rbxlx` oder `Schwungturm.rbxlx`, z. B. als Anhang): Roblox Studio installieren, anmelden, dann die Datei per Doppelklick öffnen (oder in Studio: **Datei → Öffnen**). Danach oben auf **Play** klicken (oder **F5**).

**Lantern Line mit mehreren Spielern testen:** In Studio unter **Test → Clients and Servers** z. B. „2 Players“ wählen und **Start** klicken. Studio öffnet dann einen Server und zwei Spielerfenster.

## Installation (immer aktueller Stand)
1. **Projekt herunterladen:** Auf GitHub im Repository `beni420-commits/Roblox-Agent-Team` den Branch `claude/roblox-studio-masterprompt-v2-feuzkm` wählen → **Code → Download ZIP**. Die ZIP-Datei entpacken (Rechtsklick → **Alle extrahieren**).
2. Im entpackten Ordner `installer` öffnen und die passende **`…-Installieren.bat`** doppelklicken (siehe Tabelle oben).
   - Erscheint „Der Computer wurde durch Windows geschützt“: **Weitere Informationen → Trotzdem ausführen**. Das ist der Standardhinweis von Windows für Skripte aus dem Internet.
3. Der Installer macht dann automatisch:
   1. Projekt prüfen
   2. Build-Werkzeug **Rojo 7.7.1** aus dem offiziellen GitHub-Release `rojo-rbx/rojo` laden und die **Prüfsumme kontrollieren**. Es landet nur im Projektordner unter `.tools\bin`.
   3. Spieldatei bauen (`build\LanternLine.rbxlx` bzw. `build\Schwungturm.rbxlx`)
   4. **Roblox Studio** suchen. Fehlt es, öffnet sich die offizielle Roblox-Seite (create.roblox.com). Dort Studio herunterladen, installieren, anmelden und im Installer-Fenster **Enter** drücken.
   5. Rojo-Plugin für Studio installieren (nur für späteres Live-Sync nötig) und die Desktop-Verknüpfung anlegen
4. Roblox Studio öffnet das Spiel. Oben auf **Play** klicken (oder **F5**) und spielen.

## Steuerung in Lantern Line
- **Bewegen:** WASD bzw. linker Stick oder Touch-Joystick. Springen ist bewusst aus.
- **Aktionen:** Durchsuchen, Verstecken, Lesen und den Entwerter benutzen mit **E** (Gamepad X, Touch: Knopf antippen)
- **Schleichen:** **C**, Gamepad **L3** (linken Stick drücken), Touch-Knopf „Schleichen“
- **Einstellungen:** **M** oder Gamepad **Y**: Flackern reduzieren, Sanfter Modus, Bewegung reduzieren
- **Verstecken:** Am Schrank **E**. Du schaust durch die Sehschlitze in den Wagen.
- **Versteck verlassen:** **E** oder Gamepad **B**
- **Zuschauen nach dem Ausscheiden:** **Q**/**E** bzw. Schultertasten zum Wechseln
- **Losfahren:** Am Bahnsteig auf die markierten Pfeile vor der Zugtür stellen. Der Countdown läuft 15 s, mit allen Spielern 3 s. Bei Abfahrt steigen alle Spieler am Bahnsteig ein.

## Nach einem Update
Neue ZIP herunterladen und entpacken (oder den alten Ordner ersetzen). Danach die Desktop-Verknüpfung starten oder die passende `…-Starten.bat` doppelklicken. Das baut neu und öffnet Studio.

## Deinstallieren
`installer\Schwungturm-Deinstallieren.bat` entfernt **für beide Spiele** Rojo, die gebauten Spieldateien, die Desktop-Verknüpfungen und das Rojo-Plugin. Roblox Studio selbst bleibt installiert; deinstallieren lässt es sich wie jedes Programm über die Windows-Einstellungen.

## Probleme
| Meldung | Lösung |
|---|---|
| „Projektordner nicht gefunden“ | Das Skript muss im Ordner `installer` des entpackten Projekts liegen, nicht einzeln kopiert. Die ZIP vorher vollständig entpacken. |
| Download von Rojo schlägt fehl | Internetverbindung prüfen; Firmennetz oder Proxy können GitHub sperren. Später erneut versuchen. |
| „Prüfsumme stimmt nicht“ | Der Download war beschädigt oder verändert. Nicht ignorieren, später erneut versuchen. |
| Studio öffnet die Datei nicht | Studio einmal von Hand starten und anmelden, dann erneut die Desktop-Verknüpfung nutzen. Oder die Datei aus `build\` in Studio über **Datei → Öffnen** laden. |
| Fenster schließt sich sofort | Die `…-Installieren.bat` per Doppelklick starten (nicht `install.ps1` direkt). Die Fehlermeldung bleibt dann stehen. |
| Lantern Line: Maus lässt sich nicht bewegen | Das Spiel ist in der Ich-Perspektive. Menüs geben die Maus frei, Einstellungen öffnest du mit **M**. Mit **Shift+F5** beendest du den Test in Studio. |

## Was der Installer nicht tut
- Er verändert nichts außerhalb des Projektordners, außer den Desktop-Verknüpfungen und dem Rojo-Plugin in Studios Plugin-Ordner.
- Er lädt Roblox Studio **nicht** selbst herunter, sondern öffnet nur die offizielle Seite.
- Er veröffentlicht nichts auf Roblox.

**Getestet:** Die Logik des Installers ist automatisiert geprüft: 18 Tests mit PowerShell 7, beide Spiele, inklusive Prüfung der Syntax-Kompatibilität mit Windows PowerShell 5.1. Auf einem echten Windows-PC ist er noch **nicht** gelaufen. Bitte melde Probleme mit der genauen Meldung aus dem Fenster.
