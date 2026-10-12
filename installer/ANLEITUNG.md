# Schwungturm auf dem PC testen (Windows)

Ein Roblox-Spiel ist kein eigenständiges PC-Programm: Es läuft immer in **Roblox Studio** (zum Testen) bzw. in Roblox (nach der Veröffentlichung). Dieser Installer richtet alles ein, um „Schwungturm“ auf deinem Windows-PC in Roblox Studio zu öffnen und zu spielen. Du brauchst **keine Administratorrechte**.

## Schnellweg ohne Installation
Wenn du nur die fertige Spieldatei `Schwungturm.rbxlx` hast (z. B. als Anhang bekommen): Roblox Studio installieren, anmelden, dann die Datei per Doppelklick öffnen (oder in Studio: **Datei → Öffnen**). Danach oben auf **Play** klicken (oder **F5**).

## Installation (immer aktueller Stand)
1. **Projekt herunterladen:** Auf GitHub im Repository `beni420-commits/Roblox-Agent-Team` den Branch `claude/roblox-studio-masterprompt-v2-feuzkm` wählen → **Code → Download ZIP**. Die ZIP-Datei entpacken (Rechtsklick → **Alle extrahieren**).
2. Im entpackten Ordner `installer` öffnen und **`Schwungturm-Installieren.bat`** doppelklicken.
   - Erscheint „Der Computer wurde durch Windows geschützt“: **Weitere Informationen → Trotzdem ausführen**. Das ist der Standardhinweis von Windows für Skripte aus dem Internet.
3. Der Installer macht dann automatisch:
   1. Projekt prüfen
   2. Build-Werkzeug **Rojo 7.7.1** aus dem offiziellen GitHub-Release `rojo-rbx/rojo` laden und die **Prüfsumme kontrollieren**. Es landet nur im Projektordner unter `.tools\bin`.
   3. Spieldatei `build\Schwungturm.rbxlx` bauen
   4. **Roblox Studio** suchen. Fehlt es, öffnet sich die offizielle Roblox-Seite (create.roblox.com). Dort Studio herunterladen, installieren, anmelden und im Installer-Fenster **Enter** drücken.
   5. Rojo-Plugin für Studio installieren (nur für späteres Live-Sync nötig) und die Desktop-Verknüpfung **„Schwungturm testen“** anlegen
4. Roblox Studio öffnet das Spiel. Oben auf **Play** klicken (oder **F5**) und spielen.
5. Testcheckliste: `reports\owner_test_template.md` im Projektordner.

## Nach einem Update
Neue ZIP herunterladen und entpacken (oder den alten Ordner ersetzen). Danach die Desktop-Verknüpfung **„Schwungturm testen“** starten oder `installer\Schwungturm-Starten.bat` doppelklicken. Das baut neu und öffnet Studio.

## Deinstallieren
`installer\Schwungturm-Deinstallieren.bat` entfernt Rojo, die gebaute Spieldatei, die Desktop-Verknüpfung und das Rojo-Plugin. Roblox Studio selbst bleibt installiert; deinstallieren lässt es sich wie jedes Programm über die Windows-Einstellungen.

## Probleme
| Meldung | Lösung |
|---|---|
| „Projektordner nicht gefunden“ | Das Skript muss im Ordner `installer` des entpackten Projekts liegen, nicht einzeln kopiert. Die ZIP vorher vollständig entpacken. |
| Download von Rojo schlägt fehl | Internetverbindung prüfen; Firmennetz oder Proxy können GitHub sperren. Später erneut versuchen. |
| „Prüfsumme stimmt nicht“ | Der Download war beschädigt oder verändert. Nicht ignorieren, später erneut versuchen. |
| Studio öffnet die Datei nicht | Studio einmal von Hand starten und anmelden, dann erneut die Desktop-Verknüpfung nutzen. Oder `build\Schwungturm.rbxlx` in Studio über **Datei → Öffnen** laden. |
| Fenster schließt sich sofort | `installer\Schwungturm-Installieren.bat` per Doppelklick starten (nicht `install.ps1` direkt). Die Fehlermeldung bleibt dann stehen. |

## Was der Installer nicht tut
- Er verändert nichts außerhalb des Projektordners, außer der Desktop-Verknüpfung und dem Rojo-Plugin in Studios Plugin-Ordner.
- Er lädt Roblox Studio **nicht** selbst herunter, sondern öffnet nur die offizielle Seite.
- Er veröffentlicht nichts auf Roblox.

Getestet: Die Logik des Installers ist automatisiert geprüft (14 Tests mit PowerShell 7, inklusive Prüfung der Syntax-Kompatibilität mit Windows PowerShell 5.1). Auf einem echten Windows-PC ist er noch **nicht** gelaufen. Bitte melde Probleme mit der genauen Meldung aus dem Fenster.
