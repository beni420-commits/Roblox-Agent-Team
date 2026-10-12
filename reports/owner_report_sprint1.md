# Owner-Bericht Sprint 1 (2026-10-12) – Vertical Slice Zone 1

**Kurzfassung:** Zone 1 („Wiese“, Etagen 1–10) ist vollständig gebaut, logisch getestet und zweimal unabhängig reviewt. Ob sie sich in Roblox gut spielt, ist **noch nicht geprüft**, weil es hier kein Studio gibt. Der nächste Schritt ist dein Selbsttest (ca. 60 min) nach `reports/owner_test_template.md`.

## 1. Sprintziel erreicht?
**Ziel:** Zone 1 in Studio spielbar, Generator und Prüfer getestet. → **Teilweise.**
- Code und Tests sind fertig.
- Die Spielbarkeit in der Engine ist offen (Owner-Test P0).
- Erfolgskriterium: `scripts/check.sh` grün ✓ · Owner-Test (Etage 1 in ≤ 60 s, keine Frust-Stelle „hoch“) **offen**.
- Nebenziele: Remote-Schutz mit Exploit-Suite ✓ · CI-Workflow angelegt, auf GitHub noch nicht gelaufen ◐ · Fragebogen-Entwurf ✓.

## 2. Wichtigste Ergebnisse
- **Turm-Generator + Erreichbarkeitsprüfer** [GETESTET]:
  - 200 Seeds × 10 Etagen sind für ein „Referenzkind“ lösbar. Das Modell simuliert Flugbahn, Hitbox, Kopffreiheit und 0,1 s Reaktionszeit.
  - Hilfsstufen sind nie leer.
  - Sprungpads sind auch ohne Pad-Impuls lösbar (Sicherheitsnetz).
  - Mutationstests bestätigen, dass die Tests Fehler finden.
- **Designbefund aus der Simulation** [GETESTET]: Doppelsprung-Pflicht über weite Lücken ist nicht fair machbar. In Zone 2 entsteht sie deshalb über hohe Kanten (GDD v0.3, D-026).
- **Gebaut** (nur typgeprüft, nicht ausgeführt):
  - Server: Etagenerkennung, Rücksetzpunkt je Etage (kein Tod), Funken und Lager-Bonus nur serverseitig gewertet, Hilfe nach 3/6 Stürzen, Telemetrie.
  - Client: HUD auf EN/DE, goldene Führungs-Chevrons, Ziel-Lichtsäule, Coyote-Time und Sprungpuffer, Sprungpads, Kamera-Intro, Reset-Knopf ohne Tod, keine Spieler-Kollision.
- **Qualität:**
  - 81/81 Logik-Tests, darunter eine Exploit-Suite mit NaN/inf, Spam, Teleport und Bonus-Farming [GETESTET].
  - Das Code-Review fand 38 Befunde, keinen Blocker. Alle mittleren und kritischen sind behoben, außer der bewusst verschobenen Bewegungsprüfung (CR-14).
- **Compliance:** Für einen privaten Test-Place mit Dritten gilt Freigabe mit Auflagen T-1 bis T-4 (siehe 4). Nur Engine-Inhalte, keine personenbezogenen Daten, erwartetes Label Minimal.

## 3. Gate-Status

| Gate | Status | Evidenz |
|---|---|---|
| Spielspaß | **offen** | nur [SIMULIERT]; Owner-Test P0 steht aus |
| Stabilität | **offen** | Logik [GETESTET]; Konsole fehlerfrei nur in Studio prüfbar |
| Sicherheit | **teilweise** | Remotes validiert und rate-limitiert [GETESTET]; Bewegungsprüfung fehlt (Sprint 2, vor dem Speicherstand) |
| Daten | nicht anwendbar | noch kein Speicherstand |
| Performance | **offen** | nur am Gerät messbar |
| Compliance | **Freigabe mit Auflagen** (privater Test-Place) | `reports/compliance_check_sprint1.md` |

## 4. Offene Freigaben und Aufgaben für dich
- **Keine neue Freigabe nötig für Sprint 2.** Offen bleibt die Entscheidung zu den Veröffentlichungskosten (D-025), aber erst vor dem öffentlichen Release.
- **Selbsttest P0** (Studio + möglichst schwaches Android): `reports/owner_test_template.md`. Wichtigste Punkte:
  - Sprungpad auf Etage 3/4 schleudert hoch.
  - Sturz → Etagenanfang ohne falschen Fehlversuch beim Respawn.
  - Rückweg zu einem Funken ohne Zurücksetzen.
  - Kamera im Turm.
  - Etage 1 in ≤ 60 s.
- **Vor Tests mit anderen** (Compliance T-1 bis T-4):
  - Fragebogen einreichen (Entwurf: `docs/compliance/questionnaire.md`).
  - Konto altersgeprüft und ≥ 2 Tage alt.
  - Zugang nur über Limited → Playtesters.
  - Kinder nur auf deinem Gerät oder als Trusted Friends, unter 13 mit Zustimmung der Eltern.
- **Fragen:**
  1. Darf ich eingebaute Roblox-Standardklänge (Kategorie 0) nutzen? Bitte in Studio prüfen, ob ein Pfad wie `rbxasset://sounds/electronicpingshort.wav` abspielbar ist.
  2. CI: Du kannst den Workflow unter Actions → CI → „Run workflow“ einmal manuell starten.

## 5. Größte Risiken und was nicht geprüft werden konnte
1. **Nichts lief in der Engine:** Pad-Impuls, Coyote-Time, Invisicam-Kamera, Streaming, Reset-Knopf-Callback und die Raycast-Sturzerkennung entsprechen Doku und Typen, sind aber nicht ausgeführt. Die Fixes der zweiten Review-Runde (`0d9d440`) sind noch nicht unabhängig nachgeprüft.
2. **Bewegung ist clientseitig:** Ohne Bewegungsprüfung kann ein Cheater sich Etage für Etage hochteleportieren. Das ist harmlos, solange nichts gespeichert wird, und wird in Sprint 2 vor dem Speicherstand behoben.
3. **Schwierigkeit:** Zone 1 ist bewusst sehr leicht (Lücken ≤ ca. 3,4 Studs). Ob das Spaß macht oder langweilt, zeigt nur dein Test.
4. **Launch-Hürde 16+** (aus Sprint 0) bleibt das größte strategische Risiko.

## 6. Vorschlag Sprint 2
- **Primärziel:** Fortschritt sicher machen, d. h. Bewegungsprüfung (A-011) und Speicherstand mit Session-Lock (A-007); Datenverlust-Suite und Exploit-Tests grün `[GETESTET]`.
- **Nebenziele:**
  1. Zone 2 mit Doppelsprung (Kanten 8–9,5 Studs) und Übungsstrecke.
  2. Funkenschrein mit Upgrades und Gleiter.
  3. Befunde aus deinem P0-Test.
- Zone 3/Dash und die Social-Funktionen folgen in Sprint 3. **Priorität nach deinem Test ggf. anpassen.**
