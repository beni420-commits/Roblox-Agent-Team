# QA-Bericht „Lantern Line – Der Nachtzug“ (Stand `ee3a813`)

**Datum:** 2026-10-13 · **Rolle:** QA · **Grundlage:** `scripts/check.sh`, Code-Review `code_review_sprint1.md`, Playtest-Simulation `playtest_report_sim.md`, Compliance-Nachprüfung `compliance_check_sprint1_ll.md`

> **Kernaussage:** Alles, was ohne Roblox-Engine prüfbar ist, ist geprüft und grün. In der Engine lief das Spiel noch **nie**. Deshalb ist nichts davon „fertig“ im Sinne von „spielbar bestätigt“.

## 1. Ausgeführt vs. nur geschrieben

| Bereich | Status | Evidenz |
|---|---|---|
| Logik-Module (Generator, Fairness, Wesen, Verstecke, Rätsel, Laufzustand, Bahnsteig, Flackern, Bewegung) | **ausgeführt** | [GETESTET] 78/78 Tests mit der Luau-CLI, davon 150 Seeds × 51 Wagen für die Fairness-Garantien und eine Exploit-Suite für alle Remotes |
| Generator-Laufzeit | **gemessen** | [GEMESSEN] Luau-CLI, 60 Seeds: Median 48 ms, p90 69 ms, Maximum 119 ms. Läuft am Bahnsteig (LL-23), nicht während der Fahrt |
| Roblox-Schicht (Server, Client, UI) | **nur geschrieben** | luau-lsp mit Roblox-Typen ohne Fehler, Selene 0/0. **Nicht ausgeführt** |
| Build | **ausgeführt** | Rojo 7.7.1 baut `build/LanternLine.rbxlx` |
| Compliance-Textprüfung | **ausgeführt** | `scripts/lantern_line_checks.py`: Blockliste, keine TextBox/Seat/Käufe/Asset-IDs, 74 Textschlüssel EN/DE, Util-Kopien identisch |
| Installer | **ausgeführt** (Linux, PowerShell 7) | 18/18 Tests; echtes Windows ungetestet |
| Spielgefühl, Licht, Latenz, Touch, Performance | **nicht geprüft** | nur [SIMULIERT] bzw. [ANNAHME]; Owner-Test |

## 2. Befunde und Status

| Quelle | Befunde | Behoben | Offen |
|---|---|---|---|
| Code-Review (LL) | 24 (1 Blocker, 1 kritisch, 10 mittel, 12 gering) | alle 24 im Code (`7e147c9`, D-041) | Wirkung in Studio: Prüfpunkte S-01 bis S-24 |
| Eigene Nachprüfung | 1 (mittel): Bewegungsprüfung mit Fehlalarm direkt nach Server-Teleports | `ee3a813` + Test | – |
| Playtest-Simulation (LP) | 18 | 15 (`b39aecc`) | LP-03 und LP-15 brauchen eine Owner-Entscheidung (L-011, L-012). LP-18 bleibt bewusst (keine Namen, H-A12) |
| Compliance-Nachprüfung (H-A16–H-A18) | 3 Auflagen | umgesetzt (`dd5abc5`, D-040) | Sichtprüfung der Lichtwirkung im Owner-Test (E1, E2) |

**Wichtigster echter Fehler des Durchgangs:** LL-01. Die Versteck-Prompts lagen ab Wagen 1 bis zu 1.800 Studs neben dem Schrank: Das Attachment wurde positioniert, bevor es ein Parent hatte. Damit wäre das Kernelement Verstecken kaputt gewesen. Kein Logik-Test hätte das gefunden, nur die Code-Lektüre. Der Fix enthält jetzt ein `assert`, das den Fehler im Studio-Output sofort sichtbar macht.

## 3. Nachprüfung der Fixes
- Alle Fixes stammen vom selben Team und sind **nicht unabhängig nachreviewt**. Gesichert sind sie durch Typprüfung, Tests und die Owner-Test-Punkte.
- Neue bzw. erweiterte Tests:
  - Express-Fairness inklusive k−2/k−3 und Vierergruppe
  - Messfenster und 40-s-Limit des Kontrolleurs
  - Ursache „lost“ mit Hinweistexten
  - Leerlauf-Abbruch
  - Revision des Schaffners bei Tempowechsel
  - Probenspanne der Bewegungsprüfung inklusive Jitter-Szenario
- Gegenproben (Mutationen) gab es in diesem Durchgang nur für die Prüfskripte und den Installer (D-039), nicht für die neuen Tests.

## 4. Gate-Bewertung (Masterprompt §5)

| Gate | Status | Begründung |
|---|---|---|
| Spielspaß | **offen** | nur [SIMULIERT]; Owner-Test P0 steht aus |
| Stabilität | **offen** | Logik [GETESTET]. Für Figurverlust, Leerlauf und Absturz gibt es jetzt Behandlungen; ob die Konsole fehlerfrei bleibt, zeigt nur Studio |
| Sicherheit | **teilweise** | Remotes validiert und rate-limitiert [GETESTET]; Bewegungsprüfung neu, Schwellen ohne echte Netzdaten [ANNAHME] |
| Daten | nicht anwendbar | kein Speicherstand, keine personenbezogenen Daten |
| Performance | **offen** | Schatten nur an jeder 3. Lampe; ≤ 6 Wagen gleichzeitig; am Gerät ungemessen |
| Compliance | **Freigabe mit Auflagen** (privater Test-Place) | `compliance_check_sprint1_ll.md`; öffentlich aufschiebendes Veto bis zu den Owner-Freigaben |

## 5. Die drei größten Restrisiken
1. **Engine-Verhalten weicht vom Code-Modell ab:** Kamera im Versteck, LocalTransparencyModifier, Prompts, Netzwerkbesitz nach `Anchored`. Prüfpunkte S-01 bis S-05, S-09.
2. **Lichtwirkung und Fotosensibilität** sind nur rechnerisch belegt (≤ 2 Pulse/s). Wie hell und flächig das in der Engine wirkt, zeigt erst das Video aus dem Owner-Test.
3. **Spielfluss über 25 Minuten ohne Wiedereinstieg (LP-03):** Das ist ein Designrisiko, kein Bug, und eine Owner-Entscheidung.
