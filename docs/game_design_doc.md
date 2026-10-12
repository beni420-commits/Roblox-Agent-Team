# Game Design Document – „Schwungturm“ (EN: „Momentum Tower“)

Rolle: Game Designer · Stand: 2026-10-12 (Sprint 1) · **Version 0.3**: v0.2 vom Owner freigegeben (D-022), v0.3 ergänzt Simulationsbefunde aus Sprint 1 (§13a) · Arbeitstitel (Markenprüfung offen)

Grundlage: `docs/research_report.md` (Konzept A, Empfehlung), `reports/compliance_check_sprint0.md` v1.1 (Auflagen in §11), `reports/playtest_report_sprint0.md` (Befunde P-01 bis P-29, Umsetzung in §13), `docs/telemetry_plan.md`, `docs/ux_spec.md`, `docs/tech_notes.md`.
Evidenz: Alle Spielspaß-, Zeit- und Balancing-Angaben sind `[ANNAHME]` bzw. `[SIMULIERT]`, bis Playtests (`[GETESTET]`) und Live-Daten (`[GEMESSEN]`) vorliegen.

---

## 1. Pitch (ein Satz)

**Klettere einen leuchtenden Turm aus Bausteinen hinauf, sammle Funken und schalte Bewegungs-Fähigkeiten frei, die dir neue Wege nach oben öffnen – fair, ohne Kaufdruck, mit Rücksetzpunkt auf jeder Etage.**

## 2. Designsäulen

| # | Säule | Bedeutet konkret | Prüfbar über |
|---|---|---|---|
| S1 | **Sofort klar: nach oben** | Das Ziel ist ohne Text verständlich. Das persistente Gipfel-Leuchtfeuer ist vom Spawn aus sichtbar; Führung läuft über eine reservierte Führungssprache (goldene Chevrons) | Onboarding-Funnel (H1) |
| S2 | **Jeder Lauf macht dich besser** | Fähigkeiten und Upgrades sind **spürbar** (große Stufen, sichtbare Wirkung) und öffnen neue Wege. Ab Lauf 2 ist der Turm neu gemischt | Zweitlauf-Quote (H4) |
| S3 | **Fair und freundlich** | Rücksetzpunkt auf jeder Etage, kein „Tod“ (Respawn mit „Plopp“), Hilfe nach 3/6 Fehlversuchen, Coyote-Time, keine Spieler-Kollision, kein Kaufdruck, nie eine Sackgasse | Abbruch je Etage (H2) |
| S4 | **Vielfalt aus Regeln** | Etagen entstehen prozedural aus Modulen. Ein Erreichbarkeitsprüfer simuliert die Flugbahn eines Referenzcharakters und garantiert Lösbarkeit | Generator-Tests (im Luau-CLI ausführbar) |
| S5 | **Zusammen klettern ohne Chat** | Freundes-Marker, Lager-Lift, drei vordefinierte Signale, gemeinsame Lager-Feier; keine Text-Abhängigkeit | Co-Play-Anteil |

## 3. Core Loop

### 3.1 30-Sekunden-Loop – „Sprungfolge meistern“
1. Die nächste Zielplattform ist hervorgehoben (hellstes Objekt, Neon nur für Ziele).
2. Laufen und Springen, ggf. mit Fähigkeit. Coyote-Time 0,12 s und Sprungpuffer 0,1 s verzeihen knappe Eingaben.
3. Landung mit Feedback (Ton, Partikel, Kamera-Punch). Funken einsammeln: Eine „+1“-Zahl fliegt in den Zähler.
4. Weiter zur nächsten Plattform. Bei einem **Fehlsprung** steht man nach ≤ 1,5 s wieder **am Anfang derselben Etage** („Plopp“-Effekt). Das zählt als 1 Fehlversuch, sonst gibt es keine Strafe.

**Designziel:** dichtes Erfolgsfeedback alle 3–6 s; ein Fehlschlag kostet höchstens eine Etage (≈ 30–45 s). [ANNAHME]

### 3.2 5-Minuten-Loop – „Abschnitt bis zum Lager“
1. 5 Etagen klettern (ein Abschnitt).
2. **Lager** erreichen: Speicher- und Rejoin-Punkt, Funkenschrein, Lager-Lift. Feier-Effekt beim ersten Erreichen pro Lauf.
3. Am **Funkenschrein** Funken gegen Upgrades bzw. den Gleiter tauschen (optional). Der Schrein pulsiert nur für das *empfohlene nächste Ziel* und zeigt den Sparstand (z. B. „✦ 96/150“).
4. Weiter zum nächsten Abschnitt. Am Ende von Zone 1 und Zone 2 gibt es **gratis** eine Kernfähigkeit (Doppelsprung bzw. Dash). Danach folgt eine **Übungsstrecke mit eigener Hilfe** (nie eine Sackgasse).

**Designziel:** natürliche Pausenpunkte alle ~4 Minuten (Mobile-Sessions); jeder Abschnitt endet mit einer Belohnung. [ANNAHME]

### 3.3 Langzeit-Loop – „Gipfel, neuer Turm, Meisterschaft“
1. Der **Gipfel** (Etage 30) schließt den Lauf atomar ab: Gipfel-Fest, Bonus, persönliche Bestzeit und beim ersten Gipfel die erste Leuchtspur (Kosmetik, erspielt).
2. **Neuer Lauf** durch das Tor am Turmfuß: **Ab Lauf 2 ist der Turm neu gemischt** (Seed = Basis-Seed + Laufnummer, jeder Seed ist vom Prüfer abgesichert). Man startet mit allen Fähigkeiten; mit dem Gleiter sind optionale Funkenrouten erreichbar.
3. **Lebenszeit-Meilensteine:** 5 erspielte Leuchtspur-Farben bei 250, 600, 1 000, 1 600 und 2 500 gesammelten Funken insgesamt.
4. *(Should)* **Tagesturm:** 10 Etagen, jeden Tag ein neuer Seed, für alle gleich und mit **Normwerten** (Upgrades zählen nicht). Standardansicht ist die persönliche Bestmarke; fremde Namen erscheinen nur in der Roblox-PlayerList (C-A16).

**Kein Streak-Zwang:** Der Tagesturm belohnt nicht das tägliche Wiederkommen, er ist nur täglich *neu*. Verpasste Tage kosten nichts, und es gibt keine zeitlich exklusiven Belohnungen (C-A7, HR-FOMO).

## 4. Spielwelt und Inhalte (MVP)

- **Ein Turm, 3 Zonen à 10 Etagen** (30 Etagen) plus Gipfelplattform. **Lauf 1** nutzt einen festen Seed pro Spielversion (alle haben denselben ersten Turm, vergleichbar und besprechbar). Ab Lauf 2 wird neu gemischt (§3.3).
- **Turmform: Helix.** Jede Etage liegt im nächsten 90°-Sektor um eine zentrale Säule. Der Luftraum über einem Pfad ist erst nach 4 Etagen (64 Studs) wieder überbaut, das gibt Kopffreiheit für den Doppelsprung (P-04). Der Prüfer verlangt ≥ 20 Studs Kopffreiheit über jeder Sprungbahn.
- **Zone 1 „Wiese“** (Etage 1–10): Tutorial-Zone. Breite Plattformen, kleine Lücken, Treppen, langsame Förderbänder (Sprünge nur in Bandrichtung), Sprungpads. Lager auf Etage 5 und 10. Ende: **Doppelsprung** plus Übungsstrecke.
- **Zone 2 „Wolken“** (Etage 11–20): **Doppelsprung-Pflicht über hohe Kanten** (Anstieg 8–9,5 Studs bei ≤ 3,5 Studs Lücke) statt über Weite (§13a). Wolkenplattformen verschwinden kurz nach Betreten und kommen wieder (Wartefenster ≥ 1,5 s). Dazu bewegliche Plattformen. Plattformen haben eine dunkle Unterseite bzw. Kontur, Nebel beginnt erst ab ~120 Studs (Lesbarkeit). Ende: **Dash** plus Übungsstrecke (zweistufig: erst Dash, dann Sprung + Dash).
- **Zone 3 „Gewitter“** (Etage 21–30): Die Dash-Pflicht entsteht **über die Form**: niedrige Tunnel, in denen Springen nicht hilft, und Windwände, die nur ein Dash durchbricht. Lücken mit Sprung + Dash kommen zusätzlich vor. Dazu Kippblöcke und „Blitzplatten“ (Takt-Plattformen ≤ 1 Hz, sichtbarer Rhythmus, kein Schaden, nur Wegfallen). **Blitze schlagen nur in Plattformen ein, nie sichtbar in den Avatar; ein Rückstoß ist ein Windstoß** (sonst Violence ≥ Mild, Compliance Sprint 1). Zwischen zwei Dash-Pflichtstellen liegt mindestens die Basis-Abklingzeit plus 1 s.
- **Optionale Funkenrouten:** 3 pro Zone, je 4 Bonusfunken, erreichbar mit dem Gleiter (ab Lauf 2) oder mit hohem Können.
- **Etagen-Module** (Generator-Bausteine): Plattform, Stufe, Lücke, Förderband, Sprungpad, bewegliche Plattform, Wolkenplattform, Kippblock, Taktplatte, Tunnel, Windwand, Gleitstrecke. Der Wandsprung-Schacht ist Should.
- **Spawn und Sichtachse:** Die Spawn-Plaza liegt ~40 Studs neben dem Turm und hat freie Sicht auf das **persistente Gipfel-Leuchtfeuer** (wird nie ausgestreamt, P-13).
- **Art-Stil:** nur Primitive. **Neon ausschließlich für Ziele, Führung und interaktive Elemente (Sprungpads)**, Deko in SmoothPlastic, Glass und ForceField sparsam. Eine Palette pro Zone (Wiese Grün/Gelb, Wolken Weiß/Hellblau mit dunklen Konturen, Gewitter Violett/Orange). Für Führung und Hilfe ist eine eigene Sprache reserviert: **goldene Chevron-Pfeile am Boden**, sonst nirgends Gold (P-09). Es werden nur Engine-Inhalte genutzt (Asset-Kategorie 0); Sounds erst nach Owner-Entscheidung (§12).

## 5. Fähigkeiten, Steuerung und Upgrades

| Fähigkeit | Typ | Freischaltung | Wirkung (Basis) | Touch / Tastatur / Gamepad |
|---|---|---|---|---|
| Doppelsprung (DJ) | Kern (Pflicht ab Zone 2) | gratis nach Etage 10 | zweiter Sprung in der Luft: **setzt** die vertikale Geschwindigkeit auf den Wert für 85 % Sprunghöhe (≈ 6,1 Studs zusätzlich) | Sprungknopf erneut drücken (neue Drück-Flanke) / Leertaste / A |
| Dash | Kern (Pflicht ab Zone 3) | gratis nach Etage 20 | **48 Studs/s horizontal für 0,25 s, Schwerkraft währenddessen aus** („Schwebe-Dash“, ≈ 12 Studs), Abklingzeit 2,5 s | Dash-Knopf / Shift oder Q / X |
| Gleiter | optional (**Must**, Ziel für Lauf 2) | 150 Funken | begrenzte Sinkrate; aktiv nur nach verbrauchtem DJ, in der Fallphase und bei ≥ 0,2 s gehaltenem Sprung | Sprung halten / Leertaste halten / A halten |
| Wandsprung | optional *(Should)* | 200 Funken | Absprung von markierten Wänden | Sprung an der Wand |

**Steuerungs-Komfort (Must, P-05):**
- **Coyote-Time** 0,12 s und **Sprungpuffer** 0,1 s für alle Sprünge.
- Der DJ löst nur auf einer **neuen Drück-Flanke** aus (Input Action System, „Pressed“). Eine zu frühe zweite Eingabe wird gepuffert und frühestens 0,15 s nach dem Absprung ausgeführt. Damit greift schnelles Doppeltippen nicht ins Leere.
- Lernsignal ohne Text: In der Luft pulsiert am Sprungknopf ein **„2×“**, sobald der DJ möglich ist. Ein Geist-Avatar zeigt den Ablauf beim Freischalten einmal vor.
- *(Prüfen im Gerätetest)* Touch-Hilfe „Dash am Boden = kleiner Hüpfer + Dash“ (eine Taste statt zwei).
- AutoJump auf Touch: Zone 1 an, ab Zone 2 aus (P-25, Gerätetest).

| Upgrade | Kosten je Stufe (Funken) | Wirkung (kumuliert) | Sichtbar machen |
|---|---|---|---|
| Sprungkraft | 20 / 60 / 120 | +8 % / +16 % / +24 % Sprunghöhe | Stufen-Ring an den Füßen; Messlatte am Schrein mit Geist-Sprung „vorher/nachher“ |
| Lauftempo | 30 / 70 / 140 | +10 % / +20 % / +30 % WalkSpeed | Tempo-Streifen hinter dem Avatar |
| Dash-Abklingzeit | 80 / 160 | 2,0 s / 1,5 s | Abklingkreis am Dash-Knopf füllt sich schneller |

**Regeln:**
- Der Generator garantiert Lösbarkeit mit **Basiswerten** (ohne Upgrades). Upgrades machen nur leichter oder schneller und sind nie notwendig (S3, keine Grind-Mauer).
- Upgrades sind **niemals** gegen Robux kaufbar, auch nicht nach dem MVP (C-A8). Spätere Monetarisierung nur kosmetisch und mit Owner-Freigabe (§8.2).
- Should-Fähigkeiten (Wandsprung) lehnt der Server per Feature-Flag ab, solange sie nicht freigeschaltet sind (P-23).
- *(Could)* Schalter „Upgrades verwenden“ für Läufe mit Normwerten.

## 6. Progression und Economy

### 6.1 Währung
- **Funken** sind die einzige Währung und nur erspielbar.
  - **Quellen:** 6 Funken pro Etage auf dem Hauptweg; Bonusrouten 3 pro Zone mit je 4 Funken; Lager-Bonus +5 beim ersten Erreichen eines Lagers pro Lauf (Lager 5, 10, 15, 20, 25); Gipfel-Bonus +50 einmal pro Lauf.
  - **Senken:** Upgrades und Gleiter. Keine Robux-Umwandlung, kein Handel.
- Jeder Funke, jeder Lager-Bonus und der Gipfel-Bonus sind **pro Lauf genau einmal** einlösbar. Das prüft der Server und speichert es über Rejoin hinweg (`run.collected`, `run.campsClaimed`, `run.state`), es gibt also kein Rejoin- oder Respawn-Farming (P-11).
- Ein neuer Lauf startet nur über das Tor am Turmfuß, nachdem der aktuelle Lauf den Gipfel erreicht hat.

### 6.2 Balancing-Tabelle (Erstspieler 9–14 auf Mobile, mit Etagen-Rücksetzpunkt)

Grundlage: das Zeitmodell aus dem Persona-Playtest (Monte-Carlo, `[SIMULIERT]`, Parameter `[ANNAHME]`), Profil „Zielgruppe 9–14“ mit Etagen-Rücksetzpunkt, Median Gipfel ≈ 24 min. **Designziel ist ein Median von ≈ 20 min.** Der Hebel dafür ist die Pfadlänge pro Etage in den Zonen 2 und 3. Kalibriert wird mit Owner-Playtest-Zeiten (`[GETESTET]`).

| Meilenstein | Etage | Erwartete Zeit (Modell) | Funken kumuliert (80 % Sammelquote) | Belohnung |
|---|---|---|---|---|
| Ziel verstanden, erste Etage | 1 | ≤ 60 s | ~5 | Feier-Effekt |
| Erstes Lager | 5 | ~3,5 min | 24 + 5 = 29 | erstes Upgrade leistbar (Sprungkraft I = 20) |
| Zone 1 fertig | 10 | ~7 min (+ ~1,5 min Freischaltung und Übung) | 48 + 10 = 58 | **Doppelsprung** (gratis) |
| Lager Zone 2 | 15 | ~12 min | 72 + 15 = 87 | zweites Upgrade |
| Zone 2 fertig | 20 | ~16 min (+ ~1,5 min) | 96 + 20 = 116 | **Dash** (gratis) |
| Gipfel | 30 | ~24 min (Ziel ≈ 20) | 144 + 25 = 169, dann + 50 = 219 | erste Leuchtspur, Tagesturm frei *(Should)* |
| Gleiter | – | Lauf 2 (Sparer: Ende Lauf 1) | Kosten 150 | Bonusrouten (+36 pro Lauf) |
| Alle Must-Senken gekauft | – | ~4 Läufe (~55–65 min gesamt) | Summe 830 | Meisterschaft |
| Lebenszeit-Meilensteine | – | 250 … 2 500 Funken (~10 Läufe) | – | 5 Leuchtspur-Farben |

Einkommen pro Lauf: ~219 Funken bei 80 % Sammelquote, ~255 mit Gleiterrouten. Geübte Läufe dauern ~9–12 min. Nach den Must-Senken tragen neu gemischte Türme, Bestzeit, Lebenszeit-Meilensteine und *(Should)* der Tagesturm. [ANNAHME]

### 6.3 Hilfe-System (Frustschutz, S3, C-A18)
- **3 Fehlversuche** auf derselben Etage → goldene **Führungs-Chevrons** zeigen den Weg (Geist-Pfad).
- **6 Fehlversuche** → zusätzliche **Hilfsstufen** erscheinen. Das ist eine vom Generator vorberechnete leichtere Variante, die **nur lokal** für den betroffenen Spieler erzeugt wird.
- Gilt auch in den **Übungsstrecken**: nach 3 Fehlversuchen Vorführung durch den Geist, nach 6 eine Hilfsplattform. **Nie eine Sackgasse.**
- Hilfe ist kostenlos, ohne jeden Hinweis auf Kaufen, und in den Optionen abschaltbar. Im Tagesturm ist sie erlaubt; die Bestmarke bekommt dann ein „Hilfe genutzt“-Symbol.

## 7. Onboarding (≤ 60 s, ohne Text)

| Sek. | Was der Spieler sieht/tut | Wie wir führen (visuell) | Funnel-Schritt |
|---|---|---|---|
| 0–5 | Spawn auf der Plaza neben dem Turm | Kamera schwenkt den Turm hinauf zum Gipfel-Leuchtfeuer (2 s, jede Eingabe überspringt). Nur beim ersten Join | 1 `Spawned` |
| 5–15 | erste Bewegung | goldene Chevrons am Boden zur ersten Treppe, Funken liegen auf dem Pfad | 2 `FirstMove`, 3 `FirstSpark` |
| 15–30 | erste Sprünge | breite, flache Stufen; jede Landung gibt Feedback | 4 `FirstJump` |
| 30–60 | Etage 1 geschafft | Tor-Bogen leuchtet, Etagenzähler „1/30“ springt hoch | 5 `Floor1` |
| bei Fall | Rücksetzung an den Anfang der Etage | „Plopp“-Effekt, Chevrons leuchten erneut auf | – (erfasst über `FloorSummary`) |
| ~3,5 min | erstes Lager mit Funkenschrein | Schrein pulsiert für das empfohlene Upgrade; ProximityPrompt | 6 `FirstCamp`, 7 `FirstUpgrade` |
| ~7 min | Zone 1 geschafft | Freischalt-Bühne für den Doppelsprung, Geist-Vorführung, Übungsstrecke | 8 `Zone1Done` |

**Wiedereinstieg (Rejoin):** Man erscheint am letzten erreichten Lager des laufenden Laufs; die Chevrons leuchten 3 s zur nächsten Plattform. Eine absolvierte Übung ist gespeichert und muss nicht wiederholt werden.
Kein Kauf- oder Shop-Hinweis im Onboarding (Compliance). Texte höchstens als 1–3-Wort-Labels zu Icons, über Lokalisierung.

## 8. Social Features (ohne Chat, S5)

- **Gemeinsamer Turm:** bis zu 12 Spieler pro Server klettern im selben Turm (Lauf 1: gleicher Seed für alle).
- **Freundes-Marker** *(Must)*: Roblox-Freunde im selben Server bekommen einen farbigen Ring und ein Icon über dem Kopf, sichtbar auch durch Wände. Der Marker trägt **keinen eigenen Namenstext** (C-A32). Es gibt keine Aufforderung, Freundschaften zu schließen.
- **Lager-Lift** *(Must)*: An jedem Lager kann man zu jedem **selbst erreichten** Lager des laufenden Laufs wechseln, auch nach unten, um einem Freund zu helfen. „Zum Freund“ führt nur zu Lagern, die man selbst schon erreicht hat. Es gibt kein Überspringen.
- **Drei vordefinierte Signale** *(Must)*: Winken, Daumen hoch und ein „Hier!“-Ping. Pings gehen **nur auf Orte, nie auf Avatare**. Ohne Text, mit serverseitigem Rate-Limit (1 pro 2 s) und pro Spieler stummschaltbar. Signale von Nicht-Freunden sind nur in Etagen-Nähe (±1 Etage) sichtbar; Option „Signale nur von Freunden“; blockierte Nutzer sind ausgeblendet (C-A4, C-A30).
- **Gemeinsame Lager-Feier** *(Must, rein visuell)*: Erreichen Spieler dasselbe Lager innerhalb von 20 s, feiern sie gemeinsam. Freundschaft ist dafür nicht nötig (P-16, C-A17).
- *(Could)* **Seilschaft-Bonus:** +2 Funken für alle, die ein Lager innerhalb von 20 s gemeinsam erreichen, höchstens einmal pro Lager und Lauf, unabhängig von Freundschaft und Gruppengröße. Nur für serverseitig lückenlos erreichte Lager; keine Aufforderung zum Warten oder Einladen; kein Einfluss auf Tagesturm oder Bestenliste (C-A31).
- **Keine Spieler-Kollision** (C-A13). Fremde Avatare im Umkreis von 6 Studs werden einheitlich halbtransparent (alle Teile inkl. Layered Clothing gleich) **oder** als neutrale Geist-Silhouette dargestellt, damit sie keine Kanten verdecken (P-27, C-A32; Owner prüft das Erscheinungsbild in Studio). Spuren anderer sind dünn und kurz (≤ 1 s), nie in der Führungsfarbe, und abschaltbar.
- **Keine eigenen Text-Features**, keine Freitext-Schilder. Es gibt nur den Roblox-Standard-Chat (C-A2, C-A4).
- *(Should)* **Tagesturm-Bestenliste:** Standardansicht ist die persönliche Bestmarke. Fremde Namen erscheinen **nur in der Roblox-eigenen PlayerList**; unsere UI zeigt nur den eigenen Rang bzw. Score. Es zählen nur lückenlose Läufe ohne Plausibilitätsverstoß, Scores schreibt nur der Server, und für Ranglistenplätze gibt es keine Belohnungen (C-A16). **Voraussetzung:** Die verschärfte Bewegungsprüfung (Tech Notes §6.6) besteht ihre Tests. Ein Spike zu Roblox „Server Authority“ ist erfolgt.

## 9. Feature-Liste (MoSCoW)

| Prio | Feature | Sprint (Vorschlag) |
|---|---|---|
| **Must** | Turm-Generator (Helix, Seed → Bauteilbeschreibung) + Erreichbarkeitsprüfer mit Referenzcharakter-Simulation | 1 |
| **Must** | Zone 1 (10 Etagen), Etagen-Rücksetzpunkt, Lager, Respawn ohne „Tod“, persistentes Gipfel-Leuchtfeuer | 1 |
| **Must** | Funken sammeln (serverseitig validiert), HUD (Funken, Etage) | 1 |
| **Must** | Steuerung Touch/Gamepad/KBM inkl. Coyote-Time, Sprungpuffer; eigene Verfolgerkamera; Onboarding ohne Text | 1 |
| **Must** | Remote-Sicherheitsschicht, Telemetrie-Grundgerüst | 1 |
| **Must** | Zonen 2–3, Doppelsprung, Dash, Übungsstrecken mit Hilfe, Gipfel-Abschluss | 2 |
| **Must** | Funkenschrein + Upgrades + Gleiter, Hilfe-System (3/6) | 2 |
| **Must** | Speicherstand (PlayerDataService, Schema v1, Session-Lock, Datenverlust-Suite) | 2 |
| **Must** | Neu gemischter Turm ab Lauf 2, Lebenszeit-Meilensteine (5 Leuchtspur-Farben) | 2 |
| **Must** | Social ohne Chat: Freundes-Marker, Lager-Lift, 3 Signale, gemeinsame Lager-Feier | 2 |
| **Must** | Lokalisierung EN/DE, Optionen (Hilfe, Spuren anderer, Musik/Effekte) | 2 |
| **Must** | Bewegungs-Plausibilitätsprüfung (Fensterbudget, Fähigkeiten-Grenzen, Luftzeit, lückenlose Etagenfolge) | 2 |
| Should | Tagesturm mit Normwerten + Bestmarke (+ Bestenliste über die Roblox-PlayerList) | 3 |
| Should | Wandsprung | 3 |
| Should | Schwung-Leiste („+1“-Gefühl: Tempo +2 % je sauberer Landung, max. +10 %, Reset bei Fall) | 3 |
| Could | Seilschaft-Bonus (nach Compliance-Prüfung), Schalter „Upgrades verwenden“, Tagesturm-Archiv | nach MVP |
| Won't (MVP) | Monetarisierung, Handel, PvP, eigene Chat-/Text-Features, Zufallsbelohnungen, Engagement-/Gruppen-/Social-Media-Belohnungen, Benachrichtigungen | – |

**MVP = alle Must-Features** (Sprints 1–2; realistisch eher 1–3, da Must gewachsen ist, siehe Owner-Bericht). Should-Features gibt es nur, wenn die Gates erfüllt sind.

## 10. Hypothesen

Format: *Wenn wir X einführen, dann ändert sich Kennzahl K um Y, gemessen über Event E, Auswertung nach Zeitraum T.* Mindeststichproben und Entscheidungsregeln stehen in `telemetry_plan.md` §4; darunter gibt es **kein Urteil**.

| ID | Hypothese | Kennzahl | Event(s) | Auswertung |
|---|---|---|---|---|
| H1 | Wenn das Onboarding nur über Gipfel-Leuchtfeuer, goldene Chevrons und Funken führt (ohne Text), dann erreichen **≥ 80 %** der neuen Spieler Etage 1 innerhalb von 60 s. | Anteil `Floor1` ≤ 60 s | Onboarding-Funnel Schritte 1–5 | nach 14 Tagen bzw. ≥ 500 neuen Spielern |
| H2 | Wenn die Führungs-Chevrons nach **3** Fehlversuchen erscheinen statt nach **6** (A/B 50/50), dann sinkt die **Abbruchrate auf schweren Etagen um ≥ 30 % relativ**. | Session-Ende auf einer Etage nach ≥ 3 Fehlversuchen | `FloorSummary`, `HelpShown`, `SessionEnded` | nach 14 Tagen, ≥ 400 Spieler je Variante |
| H3 | Wenn die Kernfähigkeit am Zonenende gratis mit Geist-Vorführung und Übungsstrecke mit Hilfe freigeschaltet wird, dann erreichen **≥ 70 %** derer, die Etage 10 schaffen, auch Etage 15. | Funnel Etage 10 → 15 | Progression | nach 14 Tagen, ≥ 300 Spieler mit Etage 10 |
| H4 | Wenn ab Lauf 2 ein neu gemischter Turm und der Gleiter als Sparziel warten, dann starten **≥ 35 %** der Gipfel-Erreicher einen zweiten Lauf in derselben Session. | Zweitlauf-Quote | `RunStarted`, `SummitReached` | nach 21 Tagen, ≥ 200 Gipfel-Erreicher |
| H5 *(Should)* | Wenn der Tagesturm nach dem ersten Gipfel freigeschaltet wird, dann steigt **D1** der Gipfel-Erreicher um **≥ 5 Prozentpunkte** ggü. einer Kontrollgruppe ohne Tagesturm (A/B 50/50). | D1-Retention (Kohorte) | `DailyTowerStarted` + Retention | nach 21 Tagen, ≥ 300 je Gruppe |
| H6 | Wenn der Dash-Knopf im Daumenbogen über dem Sprungknopf sitzt, dann liegt die **Dash-Erfolgsquote auf Touch höchstens 10 Prozentpunkte** unter Maus/Tastatur. Erfolg bestimmt der **Server** über die Landung auf der Zielplattform. | Erfolgsquote je Eingabeart | `AbilityResult` | nach 14 Tagen, ≥ 200 Spieler je Eingabeart |
| H7 *(Should)* | Wenn die Schwung-Leiste aktiv ist, dann steigt die **mittlere Sessiondauer um ≥ 10 %** ggü. der Variante ohne Leiste (A/B). | Median Sessiondauer | `SessionEnded` | nach 14 Tagen, ≥ 400 je Variante |
| H8 | Wenn Freundes-Marker, Lager-Lift und Signale aktiv sind, dann ist die **Sessiondauer von Spielern mit ≥ 1 Freund im Server um ≥ 20 % höher** als ohne Freund. Das ist beobachtend, kein A/B; nur als Indikator für S5. | Median Sessiondauer nach Freundesstatus | `SessionEnded` (F03 = mit/ohne Freund) | nach 21 Tagen, ≥ 150 Spieler mit Freund |

Vor dem Release ist keine Hypothese geprüft. Vor-Release-Indikatoren: Owner-Playtest (Zeiten je Etage, Fehlversuche, Beobachtungsbogen) und Persona-Simulation `[SIMULIERT]`.

## 11. Compliance-Auflagen (aus `reports/compliance_check_sprint0.md` v1.1)

Urteil Compliance: **Freigabe mit Auflagen**, erwartetes Label **Minimal**. Die Auflagen C-A1 bis C-A18 und C-A29 bis C-A32 (Nachtrag zu v0.2, `compliance_check_sprint0.md` §11) sind verbindlich und Teil der Definition of Done.

| Auflage | Umsetzung in diesem GDD |
|---|---|
| C-A1 Maturity-Fragebogen vor jedem Zugang Dritter (auch Playtests); Antworten versioniert ablegen | Owner-Aufgabe vor dem ersten Fremd-Playtest; Antworten-Entwurf in `docs/compliance/questionnaire.md` (Sprint 1) |
| C-A2 kein Spieler-Freitext im MVP | Es gibt keine Benennungen und keine Schilder (§8) |
| C-A3 generierte Namen nur aus kuratierten Wortlisten + Blocklist-Test | Der Tagesturm bekommt höchstens Namen aus Wortlisten (DE/EN). Ein Unit-Test prüft alle Kombinationen gegen eine Blocklist. |
| C-A4 nur unveränderter Standard-Chat; nur vordefinierte, nicht körperliche Signale | §8; keine eigenen Kanäle |
| C-A5 keine Links, Handles, Invite-Codes; keine Belohnungen für Like/Favorite/Follow/Gruppe/Einladen | kein Referral-Bonus (Hausregel); Seilschaft nur für gemeinsames Spielen (C-A17) |
| C-A6 nur UserId + Spielstand; RTBF-Templates mit statischem `{UserId}`-Muster | Schema v1 (`player_<UserId>`) erfüllt das. Die Tagesbestenliste darf keine täglich wechselnden Store-Namen nutzen (Tech Notes §6). |
| C-A7 HR-FOMO: keine Streaks, keine „nur heute“-Belohnungen, keine Benachrichtigungen, kein Verlust bei Abwesenheit | §3.3: Tagesturm ohne Streak, Belohnungen flach; vergangene Tagestürme später als Archiv spielbar *(Could)* |
| C-A8 später nur Kosmetik, kein Pay-to-Skip, keine Zufallskäufe | §5 (Upgrades nie gegen Robux), §9 Won't |
| C-A9 Asset-Kategorien-Regel (nach Owner-Freigabe) | §4 Art-Stil nutzt nur Kategorie 0 (Engine-Inhalte). Sounds aus Kategorie 1 erst nach Sammelfreigabe. |
| C-A10 Prinzipien statt Kopie | Tabelle §11.1 |
| C-A11 Markenprüfung des Titels durch den Owner; kein „Roblox“ oder „Blox“ im Namen | Arbeitstitel bleibt bis zur Prüfung vorläufig |
| C-A12 Store-Medien nur aus echten Captures; keine fremden Spielnamen in den Metadaten | Release-Checkliste |
| C-A13 Spieler-Kollision aus; keine Avatar-zu-Avatar-Interaktion | §8, Tech Notes §6.7 |
| C-A14 kein Flackern > 3 Blitze/s | Zone 3: Taktplatten ≤ 1 Hz (UX B5) |
| C-A15 Publishing Requirements und 16+-Startphase einplanen | Owner-Bericht (Freigabe/Frage); Telemetrie §6 trennt Phase-1-Daten |
| C-A16 Bestenliste: persönliche Bestmarke zuerst, fremde Namen nur über die Roblox-PlayerList, keine Platzierungs-Belohnungen, serverseitige Validierung | §8 |
| C-A17 Seilschaft-Bonus nur für gemeinsames Erreichen, nicht an Einladen geknüpft | §8 (Could) |
| C-A18 Frustschutz kostenlos, nie „Etage überspringen“ gegen Robux; Gewitter ohne Schaden/Schreck | §6.3, §4 Zone 3 |
| C-A29 keine Hangout-Begriffe in Titel, Beschreibung und Tags | Release-Checkliste (Store-Texte) |
| C-A30 Pings nur auf Orte; Server-Rate-Limit; Nicht-Freunde nur in Etagen-Nähe; Option „nur Freunde“; blockierte Nutzer ausgeblendet | §8 |
| C-A31 Seilschaft ohne Warte-/Einladeaufforderung, unabhängig von Gruppengröße, nur bei lückenlosem Erreichen, ohne Einfluss auf Bestenliste | §8 (Could) |
| C-A32 Halbtransparenz einheitlich oder Geist-Silhouette; Marker ohne Namenstext; Studio-Test durch den Owner | §8 |

### 11.1 Prinzipien statt Kopie (C-A10)

| Referenzspiel | Übernommenes Prinzip | Ausdrücklich NICHT übernommen |
|---|---|---|
| Tower of Hell | Turm aus zufällig kombinierten Modulen, klares Ziel „nach oben“ | Name/Titelmuster, Modulkatalog, Layouts, Timer-Runden, Look |
| „+1 Speed“-Escape-Obbies | spürbares Stärkerwerden durch Aktionen | „+1 …“-Titelmuster, Keyboard-/Meme-Thematik, Zahlen-Inflation ohne Fähigkeiten |
| Grow a Garden | ruhiger, gewaltfreier Einstieg, verständliche Schleife | jede Garten-/Samen-Thematik, Shop-Restock, Handel |
| 99 Nights in the Forest | sichtbarer Zähler als Ziel (Etage x/30), Koop als Antrieb | Survival/Horror, Nacht-Thematik, Kreaturen |
| Fisch | kleine Geschicklichkeits-Aktion im Kern plus Langzeit-Sammelziel | Angel-Thematik, Enzyklopädie-Layout |

Keine Namen von Referenzspielen in Titel, Beschreibung, Tags oder Thumbnails.

## 12. Offene Designfragen

1. **Seed:** Lauf 1 und der Tagesturm haben einen festen Seed, ab Lauf 2 wird neu gemischt (entschieden in v0.2). Ab Sprint 3 neu bewerten.
2. **Kamera:** eigene Verfolgerkamera mit fester Neigung (~35°), Zoom-Untergrenze und Ausblenden verdeckender Teile statt Heranzoomen. Feinabstimmung im Owner-Gerätetest Sprint 1.
3. **Audio:** Ohne Ton halbiert sich die Feedback-Dichte. Owner-Entscheidung zur Asset-Kategorie 1 (Roblox-eigene Sounds) bis Sprint 1; Fallback ist stärkeres visuelles und haptisches Feedback (P-28).
4. **Turmhöhe vs. Zielzeit:** Bleiben es 30 Etagen und kürzere Pfade (Ziel-Median ≈ 20 min), oder werden es 24 Etagen? Entscheidung nach dem ersten Owner-Playtest.
5. **Lager-Modus** (klassisch: Rücksetzung nur auf das Lager) als Option für Könner? Could, nach MVP.

## 13. Änderungen v0.1 → v0.2 (Persona-Playtest, `reports/playtest_report_sprint0.md`)

| Befund | Schwere | Umsetzung |
|---|---|---|
| P-01 Rücksetzung nur aufs Lager | hoch | Etagen-Rücksetzpunkt; Lager = Speicher-, Schrein- und Rejoin-Punkt; Hilfe nach 3/6 (§3, §6.3, H2) |
| P-02 Sicherheitsfaktoren je Achse | hoch | Referenzcharakter-Simulation der Flugbahn (Tech Notes §6.3) |
| P-03 Dash widersprüchlich / ohne eigene Lücken | hoch | 48 Studs/s, Schwerkraft aus; Dash-Pflicht über Tunnel und Windwand; zweistufige Übung (§4, §5) |
| P-04 Kopffreiheit / Kamera | hoch | Helix-Layout, ≥ 20 Studs Kopffreiheit im Prüfer, eigene Kamera (§4, §12) |
| P-05 DJ ohne Lernsignal, Übung ohne Hilfe | hoch | Drück-Flanke, Puffer, Coyote-Time, „2×“-Puls, Geist; Hilfe in Übungen (§5, §6.3) |
| P-06 Plausibilitätsprüfung wirkungslos | hoch | neues Prüfmodell (Tech Notes §6.6); Bestenliste erst nach bestandenen Tests (§8) |
| P-07 Social ohne Chat nicht tragfähig | hoch | Freundes-Marker, Lager-Lift, 3 Signale, Lager-Feier ins Must (§8) |
| P-08 Langzeit-Loop leer | hoch | neu gemischter Turm ab Lauf 2, Gleiter ins Must, Lebenszeit-Meilensteine (§3.3, §9) |
| P-09 Führung kollidiert | mittel | reservierte Führungssprache (goldene Chevrons), Neon nur für Ziele (§4) |
| P-10 dynamische Module fehlen im Prüfer | mittel | Modulregeln in Tech Notes §6.3 |
| P-11 Lauf-Zustand unvollständig | mittel | Schema `run` erweitert (Tech Notes §6.4) |
| P-12 Upgrades kaum spürbar | mittel | größere Stufen, sichtbare Wirkung, Puls nur für das empfohlene Ziel (§5, §3.2) |
| P-13 Gipfel nicht sicher sichtbar | mittel | persistentes Leuchtfeuer, Spawn mit Sichtachse (§4) |
| P-14 Wiedereinstieg | mittel | Rejoin-Chevrons, `practiceDone` (§7) |
| P-15 Fremd-Effekte | mittel | Feier nur beim ersten Erreichen; Fremd-Effekte gedrosselt (UX B5) |
| P-16 Seilschaft an Freundschaft | mittel | unabhängig von Freundschaft; Bonus erst nach Compliance-Prüfung (§8) |
| P-17 Inkonsistenzen | mittel | bereinigt (Dash-Wert, Bonusfunken je Route, Bestenliste, Gipfel-Leuchtspur ist Must) |
| P-18 Zeittabelle zu optimistisch | mittel | neu kalibriert (Modell ≈ 24 min, Ziel ≈ 20 min) (§6.2) |
| P-19 „Kaufen“ | gering | Knopf heißt „Tauschen“ (UX B3) |
| P-20 Sprungkraft I nicht leistbar | gering | Kosten 20 (§5) |
| P-21 Client-Telemetrie fälschbar | gering | Erfolg serverseitig (H6, Telemetrie-Plan) |
| P-22 `elapsedSeconds` undefiniert | gering | Definition in Tech Notes §6.4 |
| P-23 Should-Fähigkeiten annehmbar | gering | Feature-Flags (§5) |
| P-24 Gleiter vs. DJ | gering | Aktivierungsregel (§5) |
| P-25 AutoJump | gering | Zone 1 an, ab Zone 2 aus, Gerätetest (§5) |
| P-26 Hilfsstufen-Sichtbarkeit | gering | nur lokal (§6.3) |
| P-27 Fremd-Avatare verdecken | gering | Halbtransparenz im 6-Studs-Umkreis (§8) |
| P-28 Audio offen | gering | Owner-Entscheidung (§12) |
| P-29 KPI-Messpunkt | gering | im Telemetrie-Plan festgelegt |

Status nach v0.2: Alle „hoch“-Befunde sind **im Design adressiert**. Das ist `[SIMULIERT]`, nicht `[GETESTET]`, und das Gate „Spielspaß“ bleibt offen, bis ein Owner-Playtest vorliegt.

## 13a. Änderungen v0.2 → v0.3 (Simulation des Erreichbarkeitsprüfers, Sprint 1)

| Befund | Evidenz | Änderung |
|---|---|---|
| Doppelsprung-Pflicht **über Weite** ist nicht fair möglich: Ohne DJ reicht ein flacher Sprung im großzügigen Modell bis ≈ 9,7 Studs; mit DJ schafft der Referenzcharakter (Faktor 0,85, Latenz 0,1 s, DJ-Zeitpunkt Scheitel ± 0,1 s) nur ≈ 7,2 Studs. | [GETESTET] Test „Befund P-03: DJ-Pflicht allein über Weite ist nicht fair möglich“ | Zone 2 verlangt den DJ über **Höhe**: Kanten mit 8–9,5 Studs Anstieg sind ohne DJ unerreichbar (max. Sprunghöhe 7,2), mit DJ für den Referenzcharakter lösbar (Lücke ≤ 3,5). |
| Dash-Pflicht über Weite ist praktisch nicht fair abgrenzbar (Fenster < 1 Stud). Über **Form** funktioniert sie: Tunnel (Decke 6,5 Studs) und Windwand. | [GETESTET] Test „Dash-Pflicht über Form“ | bestätigt GDD v0.2 §4 Zone 3 |
| Zone-1-Lücken liegen beim Referenzcharakter (Faktor 0,75) bei höchstens ≈ 3,4 Studs (flach) bzw. ≈ 2,9 Studs (2 Studs Anstieg). | [GETESTET] Generator-Tests, 200 Seeds | Zone 1 ist bewusst sehr leicht (Tutorial). Feinjustierung über den Zonenfaktor nach dem Owner-Test. |

