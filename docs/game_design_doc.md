# Game Design Document – „Schwungturm“ (EN: „Momentum Tower“)

Rolle: Game Designer · Stand: 2026-10-12 (Sprint 0) · Status: **Entwurf zur Owner-Freigabe** · Arbeitstitel (Markenprüfung offen)

Grundlage: `docs/research_report.md` (Konzept A, Empfehlung), `reports/compliance_check_sprint0.md` (Vorprüfung; Auflagen in §11), `docs/telemetry_plan.md`, `docs/ux_spec.md`, `docs/tech_notes.md`.
Evidenz: Alle Spielspaß-, Zeit- und Balancing-Angaben sind `[ANNAHME]` bzw. `[SIMULIERT]`, bis Playtests (`[GETESTET]`) und Live-Daten (`[GEMESSEN]`) vorliegen.

---

## 1. Pitch (ein Satz)

**Klettere einen leuchtenden Turm aus Bausteinen hinauf, sammle Funken und schalte Bewegungs-Fähigkeiten frei, die dir neue Wege nach oben öffnen – fair, ohne Kaufdruck, mit Checkpoints für alle.**

## 2. Designsäulen

| # | Säule | Bedeutet konkret | Prüfbar über |
|---|---|---|---|
| S1 | **Sofort klar: nach oben** | Ziel ohne Text verständlich; das Ziel ist immer das hellste Objekt | Onboarding-Funnel (H1) |
| S2 | **Jeder Lauf macht dich besser** | Fähigkeiten und Upgrades sind spürbar, öffnen neue Wege; Können zählt mehr als Werte | Zweitlauf-Quote (H4) |
| S3 | **Fair und freundlich** | Checkpoints, kein „Tod“ (Respawn mit „Plopp“), Hilfe nach Fehlversuchen, keine Spieler-Kollision, kein Kaufdruck | Abbruch je Etage (H2) |
| S4 | **Vielfalt aus Regeln** | Etagen entstehen prozedural aus Modulen; ein Erreichbarkeitsprüfer garantiert Lösbarkeit | Generator-Tests [GETESTET-fähig] |
| S5 | **Zusammen klettern ohne Chat** | andere Kletterer sichtbar (Leuchtspuren), später Seilschaft-Bonus; keine Text-Abhängigkeit | Co-Play-Anteil (Could) |

## 3. Core Loop

### 3.1 30-Sekunden-Loop – „Sprungfolge meistern“
1. Nächste Plattform leuchtet (Zielmarkierung) →
2. Laufen/Springen (ggf. Fähigkeit) →
3. Landung mit Feedback (Ton, Partikel, Kamera-Punch), Funken einsammeln (+1-Zahl fliegt in den Zähler) →
4. Nächste Plattform. **Fehlsprung** → nach ≤ 1,5 s am letzten Checkpoint zurück („Plopp“-Effekt, keine Strafe außer Weg).

**Designziel:** dichtes Erfolgsfeedback alle 3–6 s; Fehlschläge kosten wenig Zeit. [ANNAHME]

### 3.2 5-Minuten-Loop – „Abschnitt bis zum Lager“
1. 5 Etagen klettern (ein Abschnitt) →
2. **Lager (Checkpoint)** erreichen: Fortschritt gesichert, Feier-Effekt →
3. Am **Funkenschrein** des Lagers Funken in Upgrades tauschen (optional) →
4. Nächster Abschnitt. Am Ende jeder Zone (alle 10 Etagen) wird **gratis** eine Kernfähigkeit freigeschaltet (Doppelsprung nach Zone 1, Dash nach Zone 2), die die nächste Zone verlangt.

**Designziel:** natürliche Pausenpunkte alle ~3 Minuten (Mobile-Sessions), jeder Abschnitt endet mit Belohnung. [ANNAHME]

### 3.3 Langzeit-Loop – „Gipfel, Meisterschaft, Tagesturm“
1. **Gipfel** (Etage 30) erreichen → großes Gipfel-Fest, erste Kosmetik-Leuchtspur (erspielt) →
2. **Neuer Lauf** mit allen Fähigkeiten: schneller, Abkürzungen über optionale Routen (Gleiter, Wandsprung), Funken für weitere Upgrades, persönliche Bestzeit →
3. *(Should)* **Tagesturm**: 10 Etagen, täglich neuer Seed, für alle gleich, mit **Normwerten** (Upgrades zählen nicht → fair, nie kaufbar), persönliche Bestmarke und Server-Bestenliste →
4. Meilenstein-Kosmetik (erspielt): z. B. 3 Gipfel, 10 Gipfel, erster Tagesturm.

**Kein Streak-Zwang:** Der Tagesturm belohnt nicht das tägliche Wiederkommen, sondern ist nur täglich *neu*. Verpasste Tage kosten nichts; es gibt keine zeitlich exklusiven Belohnungen. (Hausregel HR-MON, Compliance)

## 4. Spielwelt und Inhalte (MVP)

- **Ein Turm, 3 Zonen à 10 Etagen** (30 Etagen) + Gipfelplattform. Fester Seed pro Spielversion (alle Spieler gleicher Turm → vergleichbar, sozial besprechbar).
- **Zone 1 „Wiese“** (Etage 1–10): Tutorial-Zone. Breite Plattformen, kleine Lücken, Treppen, langsame Förderbänder, Sprungpads. Lager auf Etage 5 und 10. Ende: **Doppelsprung**.
- **Zone 2 „Wolken“** (Etage 11–20): Lücken, die einen Doppelsprung verlangen, Wolkenplattformen (verschwinden kurz nach Betreten und kommen wieder), bewegliche Plattformen. Ende: **Dash**.
- **Zone 3 „Gewitter“** (Etage 21–30): Dash-Lücken, kippende Blöcke, Wind-Förderzonen, „Blitzplatten“ (Takt-Plattformen, sichtbarer Rhythmus – kein Schaden, nur Wegfallen).
- **Optionale Funkenrouten** pro Zone: kleine Abzweige mit Bonusfunken, erreichbar mit optionalen Fähigkeiten (Gleiter, Wandsprung) oder höherem Können.
- **Etagen-Module** (Generator-Bausteine): Plattform, Stufe, Lücke, Förderband, Sprungpad, bewegliche Plattform, Wolkenplattform, Kippblock, Taktplatte, Wandsprung-Schacht (optional), Gleitstrecke (optional).
- **Art-Stil:** nur Primitive; Materialien Neon/Glass/SmoothPlastic/ForceField; eine Palette pro Zone (Wiese: Grün/Gelb, Wolken: Weiß/Hellblau, Gewitter: Violett/Orange); Ziele leuchten, Umgebung gedämpft. Kein externes Asset (sofern Owner-Regel zu Standard-Texturen/Sounds nicht anders entscheidet, siehe §11).

## 5. Fähigkeiten und Upgrades

| Fähigkeit | Typ | Freischaltung | Wirkung (Startwert) | Eingabe Touch / Tastatur / Gamepad |
|---|---|---|---|---|
| Doppelsprung | Kern (Pflicht ab Zone 2) | gratis nach Etage 10 | zweiter Sprung in der Luft, 85 % der Sprunghöhe | Sprungknopf erneut / Leertaste / A |
| Dash | Kern (Pflicht ab Zone 3) | gratis nach Etage 20 | kurzer horizontaler Schub (≈ 2× Laufgeschwindigkeit, 0,25 s), Abklingzeit 2,5 s | Fähigkeitenknopf / Shift oder Q / X |
| Gleiter | optional | 150 Funken | langsamer Fall (Sinkrate begrenzt) solange Sprung gehalten | Sprung halten / Leertaste halten / A halten |
| Wandsprung | optional *(Should)* | 200 Funken | Absprung von markierten Wänden | Sprung an Wand / Leertaste / A |

| Upgrade | Stufen und Kosten (Funken) | Wirkung je Stufe | Max. |
|---|---|---|---|
| Sprungkraft | 25 / 60 / 120 | +6 % Sprunghöhe | +18 % |
| Lauftempo | 30 / 70 / 140 | +8 % WalkSpeed | +24 % |
| Dash-Abklingzeit | 80 / 160 | −0,5 s | 1,5 s |

**Regeln:**
- Der Generator garantiert Lösbarkeit mit **Basiswerten** (ohne Upgrades). Upgrades machen nur leichter/schneller – nie notwendig. (S3, keine Grind-Mauer)
- Upgrades sind **niemals** gegen Robux kaufbar (auch nicht nach dem MVP). Spätere Monetarisierung nur kosmetisch (Leuchtspuren/Farben), Owner-Freigabe nötig (§8.2).
- Optionen-Schalter „Upgrades verwenden“ (Standard: an) – erlaubt Können-Läufe mit Normwerten. *(Could)*

## 6. Progression und Economy

### 6.1 Währung
- **Funken** (einzige Währung, nur erspielbar). Quellen: Funken auf Etagen (≈ 6 pro Etage auf dem Hauptweg, 2–4 Bonus auf optionalen Routen), Lager-Bonus (+5 beim ersten Erreichen pro Lauf), Gipfel-Bonus (+50 pro Lauf). Senken: Upgrades, optionale Fähigkeiten. **Keine** Robux-Umwandlung, kein Handel.
- Jeder Funke ist **pro Lauf einmal** sammelbar (serverseitig gespeichert, auch über Rejoin → kein Rejoin-Farming).
- Neuer Lauf startet nach dem Gipfel (oder per „Neuer Lauf“ am Fuß des Turms nach dem ersten Gipfel).

### 6.2 Balancing-Tabelle (erwartete Zeiten, Erstspieler 9–14 auf Mobile) [ANNAHME → zu prüfen in Playtest/Telemetrie]

| Meilenstein | Etage | Erwartete Zeit ab Spielbeginn | Funken (kumuliert, ~80 % Sammelquote) | Belohnung |
|---|---|---|---|---|
| Ziel verstanden, erste Etage | 1 | ≤ 60 s | ~5 | Feier-Effekt |
| Erstes Lager | 5 | ~3 min | ~25 (+5) | erstes Upgrade leistbar (Sprungkraft I = 25) |
| Zone 1 fertig | 10 | ~6–7 min | ~55 | **Doppelsprung** (gratis) |
| Lager Zone 2 | 15 | ~10 min | ~85 | zweites Upgrade |
| Zone 2 fertig | 20 | ~13–14 min | ~120 | **Dash** (gratis) |
| Gipfel | 30 | ~18–20 min | ~190 (+50) | Gipfel-Leuchtspur (Kosmetik), Tagesturm frei *(Should)* |
| Gleiter | – | 2. Lauf (~30 min gesamt) | 150 Kosten | optionale Routen |
| Alle Upgrades max. | – | ~4 Läufe (~1–1,5 h gesamt) | Summe Kosten 835 (+200 Wandsprung) | Meisterschaft |

Einkommen pro Lauf ≈ 230 Funken; Erstlauf ~20 min, geübte Läufe ~8–10 min. Summe aller Senken ≈ 1 035 Funken → ca. 4–5 Läufe. Danach tragen Bestzeit, Tagesturm und Kosmetik-Meilensteine. [ANNAHME]

### 6.3 Hilfe-System (Frustschutz, S3)
- 5 Fehlversuche auf derselben Etage → **Leuchtspur** zeigt den Weg (Geist-Pfad).
- 10 Fehlversuche → zusätzliche **Hilfsstufen** erscheinen (vom Generator vorberechnete leichtere Variante).
- Hilfe ist kostenlos, ohne Hinweis auf Kaufen; abschaltbar in den Optionen. Kein Einfluss auf Bestenliste im Hauptturm (es gibt dort keine).

## 7. Onboarding (≤ 60 s, ohne Text)

| Sek. | Was der Spieler sieht/tut | Wie wir führen (visuell) | Funnel-Schritt |
|---|---|---|---|
| 0–5 | Spawn auf leuchtendem Startpad am Turmfuß | Kamera schwenkt kurz den Turm hinauf zum leuchtenden Gipfel (2 s), dann zurück | 1 `Spawned` |
| 5–15 | erste Bewegung | Leuchtpfad (Beam) am Boden zur ersten Treppe; Funken liegen auf dem Pfad | 2 `FirstMove`, 3 `FirstSpark` |
| 15–30 | erste Sprünge | breite, flache Stufen; jede Landung gibt Feedback | 4 `FirstJump` |
| 30–60 | Etage 1 geschafft | Tor-Bogen leuchtet auf, Etagenzähler „1/30“ springt hoch, Fanfare | 5 `Floor1` |
| bei Fall | Respawn am Tutorial-Lager (Etage 0) | „Plopp“-Effekt, Pfad leuchtet erneut | (kein Funnel-Schritt; erfasst über `FloorSummary`) |
| ~3 min | erstes Lager mit Funkenschrein | Schrein pulsiert, wenn ein Upgrade leistbar ist; ProximityPrompt | 6 `FirstCamp`, 7 `FirstUpgrade` |
| ~6–7 min | Zone 1 geschafft, Doppelsprung | Freischalt-Bühne + Übungsstrecke | 8 `Zone1Done` |

Kein Kauf-/Shop-Hinweis im Onboarding (Compliance). Texte maximal als 1–3-Wort-Icon-Labels über Lokalisierung.

## 8. Social Features

- **Gemeinsamer Turm:** bis zu 12 Spieler pro Server klettern im selben Turm, sehen sich und ihre Leuchtspuren.
- **Keine Spieler-Kollision** (CollisionGroup), damit niemand andere herunterschubsen kann (Anti-Griefing).
- **Keine eigenen Text-Features**, keine Freitext-Schilder, keine Freundschafts-Aufforderungen. Nur der Roblox-Standard-Chat (TextChatService, altersabhängig von Roblox gesteuert).
- *(Could)* **Seilschaft:** Freunde im selben Server erhalten +2 Funken, wenn sie ein Lager innerhalb von 20 s nacheinander erreichen; Freunde werden mit farbigem Leucht-Marker gezeigt. Kein Chat nötig.
- *(Should)* **Bestenliste Tagesturm:** nur Server-Bestenliste, Anzeige gemäß Compliance-Auflage (§11); nur Läufe ohne Plausibilitätsverstoß.

## 9. Feature-Liste (MoSCoW)

| Prio | Feature | Sprint (Vorschlag) |
|---|---|---|
| **Must** | Turm-Generator (Seed → Bauteilbeschreibung) + Erreichbarkeitsprüfer | 1 |
| **Must** | Zone 1 (10 Etagen), Lager/Checkpoints, Respawn ohne „Tod“ | 1 |
| **Must** | Funken sammeln (serverseitig validiert), HUD (Funken, Etage) | 1 |
| **Must** | Mobile-/Gamepad-/KBM-Steuerung, Onboarding ohne Text | 1 |
| **Must** | Remote-Sicherheitsschicht, Telemetrie-Grundgerüst | 1 |
| **Must** | Zonen 2–3, Doppelsprung, Dash, Gipfel-Fest | 2 |
| **Must** | Funkenschrein + Upgrades, Hilfe-System | 2 |
| **Must** | Speicherstand (PlayerDataService, Schema v1, Session-Lock) | 2 |
| **Must** | Lokalisierung EN/DE, Optionen (Hilfe, Musik/Effekte) | 2 |
| **Must** | Bewegungs-Plausibilitätsprüfung (serverseitig) | 2 |
| Should | Tagesturm mit Normwerten + Server-Bestenliste | 3 |
| Should | Gleiter + Wandsprung, optionale Funkenrouten | 3 |
| Should | Schwung-Leiste („+1“-Gefühl: Tempo +2 % je sauberer Landung, max. +10 %, Reset bei Fall) | 3 |
| Could | Seilschaft-Bonus, Kosmetik-Leuchtspuren (erspielt), „Upgrades verwenden“-Schalter | nach MVP |
| Won't (MVP) | Monetarisierung, Handel, PvP, eigene Chat-/Text-Features, Zufallsbelohnungen, Gruppen-/Social-Media-Belohnungen | – |

**MVP = alle Must-Features** (Sprints 1–2). Should-Features nur, wenn Gates erfüllt sind (Sprint 3).

## 10. Hypothesen

Format: *Wenn wir X einführen, dann ändert sich Kennzahl K um Y, gemessen über Event E, Auswertung nach Zeitraum T.* Mindeststichproben legt der Data Analyst in `telemetry_plan.md` fest; darunter **kein Urteil**.

| ID | Hypothese | Kennzahl | Event(s) | Auswertung |
|---|---|---|---|---|
| H1 | Wenn das Onboarding nur über Leuchtpfad, Funken und Kamera-Schwenk führt (ohne Text), dann erreichen **≥ 80 %** der neuen Spieler Etage 1 innerhalb von 60 s. | Anteil `Floor1` ≤ 60 s | Onboarding-Funnel Schritte 1–5 (+ `t`) | nach 14 Tagen bzw. ≥ 500 neuen Spielern |
| H2 | Wenn nach 5 Fehlversuchen auf einer Etage die Leuchtspur erscheint, dann sinkt die **Abbruchrate auf schweren Etagen um ≥ 30 % relativ** ggü. Variante „Hilfe erst nach 10 Fehlversuchen“ (A/B 50/50). | Session-Ende auf Etage nach ≥ 5 Fehlversuchen | `FloorFailed`, `HelpShown`, `SessionEnded` | nach 14 Tagen, ≥ 400 Spieler je Variante |
| H3 | Wenn die Kernfähigkeit am Zonenende gratis mit Feier und Übungsstrecke freigeschaltet wird, dann erreichen **≥ 70 %** derer, die Etage 10 schaffen, auch Etage 15. | Funnel Etage 10 → 15 | Progression `FloorReached` | nach 14 Tagen, ≥ 300 Spieler mit Etage 10 |
| H4 | Wenn Funken-Upgrades am Lager kaufbar sind, dann starten **≥ 35 %** der Gipfel-Erreicher einen zweiten Lauf in derselben Session. | Zweitlauf-Quote | `RunStarted` (runIndex), `SummitReached` | nach 21 Tagen, ≥ 200 Gipfel-Erreicher |
| H5 *(Should)* | Wenn der Tagesturm nach dem ersten Gipfel freigeschaltet wird, dann steigt **D1** der Gipfel-Erreicher um **≥ 5 Prozentpunkte** ggü. Kontrollgruppe ohne Tagesturm (A/B 50/50). | D1-Retention (Kohorte) | `DailyTowerStarted` + Retention | nach 21 Tagen, ≥ 300 je Gruppe |
| H6 | Wenn der Fähigkeitenknopf im Daumenbogen über dem Sprungknopf sitzt, dann liegt die **Dash-Erfolgsquote auf Touch höchstens 10 Prozentpunkte** unter Maus/Tastatur. | Erfolgsquote `AbilityUsed` (gelandet) je Eingabegerät | `AbilityUsed` (inputType, success) | nach 14 Tagen, ≥ 200 Spieler je Gerätetyp |
| H7 *(Should)* | Wenn die Schwung-Leiste aktiv ist, dann steigt die **mittlere Sessiondauer um ≥ 10 %** ggü. Variante ohne Leiste (A/B). | Median Sessiondauer | `SessionEnded` (Dauer) | nach 14 Tagen, ≥ 400 je Variante |

Vor dem Release sind alle Hypothesen ungeprüft. Vor-Release-Indikatoren: Owner-Playtest (Zeiten je Etage, Fehlversuche), Persona-Simulation `[SIMULIERT]`.

## 11. Compliance-Auflagen (aus `reports/compliance_check_sprint0.md`)

*Wird nach Abschluss der Compliance-Vorprüfung übernommen.*

## 12. Offene Designfragen

1. Ist ein fester Seed für den Hauptturm (alle gleich) besser als ein Seed pro Server? → Entscheidung: fest (Vergleichbarkeit, Testbarkeit); ab Sprint 3 neu bewerten.
2. Kamera: Roblox-Standardkamera oder leicht angehobene Verfolgerkamera für bessere Sprungsicht auf Mobile? → Owner-Playtest Sprint 1.
3. Musik/Sound: Ohne freigegebene Audio-Assets nur stumme Prototypen bzw. Roblox-Standardklänge? → Owner-Entscheidung (§11 / Freigabe 5).
