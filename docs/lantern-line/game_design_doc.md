# Game Design Document – „CARRIAGES“ (DE-Untertitel: „Der Nachtzug“)

Rolle: Game Designer · Stand: 2026-10-13 · **Version 0.1** · Arbeitstitel (Namensprüfung siehe `docs/lantern-line/research_doors.md`)
Auftrag des Owners (2026-10-13): „Erstelle ein Horror Game wie ‚Doors‘. Es soll nah am Original sein, aber trotzdem einen eigenen, wiedererkennbaren Stil haben.“
Evidenz: Alle Werte zu Spielspaß, Zeiten und Balancing sind `[ANNAHME]`, bis Playtests (`[GETESTET]`) vorliegen. Werte, die der Fairness-Prüfer garantiert, sind als **Garantie** markiert und durch Tests abgesichert.

---

## 1. Pitch

**Bis zu vier Mitreisende kämpfen sich durch einen endlosen Nachtzug, Wagen für Wagen, Tür für Tür. Was ihnen begegnet, kündigt sich immer durch Licht an. Wer die Zeichen lesen kann, überlebt bis zum Postwagen.**

## 2. Wie nah am Original? (Abgrenzung, D-032)

„Nah am Original“ heißt bei uns: **gleiches Spielgefühl und gleiche Spielmechanik-Konventionen**, aber **keine übernommene Gestaltung**. Spielmechaniken und Genre-Konventionen sind nicht geschützt; Namen, Figuren, Optik, Klänge, Texte, Logos und UI des Originals schon (Compliance, `reports/lantern-line/compliance_check_concept.md`).

| Doors-Konvention (Genre) | So ist sie bei uns umgesetzt (eigene Gestaltung) |
|---|---|
| Raum für Raum, nummerierte Türen | Wagen für Wagen; Wagennummer als weiße Schablonenschrift auf der Übergangstür („WAGEN 07“ / „CAR 07“) |
| Fahrstuhl-Lobby mit Countdown | Bahnsteig mit Abfahrtstafel und Bahnhofsuhr, die herunterzählt |
| Wesen, das durch die Räume rast; verstecken im Schrank | **Der Express** – ein gleißendes Scheinwerferlicht, das von hinten durch die Wagen donnert |
| Wesen, das mehrmals hin und her rast | **Der Pendel** – bläuliches Licht, pendelt 2–4-mal |
| Wesen in dunklen Räumen, das man ansehen muss | **Der Blinde Passagier** – zwei grüne Augen in der Gepäckablage |
| Wesen, vor dem man in bestimmter Weise reagieren muss | **Der Kontrolleur** – eigene Mechanik „Stillstehen bei rotem Laternenlicht“ |
| Blinder Wächter mit Rätsel bei Raum 50 | **Der Schaffner** im Postwagen – blind, hört Schritte; 3 Gepäckanhänger ergeben den Schloss-Code |
| Schlüssel für verschlossene Türen, Schubladen durchsuchen | Schaffnerschlüssel in Koffern und Gepäckfächern |
| Hinweise nach dem Tod | Fahrkarten-Notiz des Bahnhofsvorstehers |
| Zurückgebliebene werden nachgeholt | „Der Ruck“: Wer zu weit zurückfällt, wird nach vorn geschoben, bevor hintere Wagen abgekoppelt werden |

**Nicht übernommen:** Namen von Wesen, Orten, Währung und Gegenständen; Figurendesigns; Klänge; Texte; Schriftarten-Look; UI-Layout; Logo; Thumbnail-Stil. In Titel, Beschreibung und Schlagworten taucht „Doors“ nicht auf (keine Irreführung, Compliance).

## 3. Designsäulen (eigener Stil „Laternen-Noir“)

| # | Säule | Bedeutet konkret | Prüfbar über |
|---|---|---|---|
| S1 | **Licht verrät alles** | Jedes Wesen hat eine eigene Lichtfarbe und kündigt sich **sichtbar** an (weiß = Express, blau = Pendel, grün = Passagier, rot = Kontrolleur). Kein Wesen ist nur hörbar. Das ist auch Barrierefreiheit (gehörlos spielbar) | Todesursachen je Wesen (Telemetrie) |
| S2 | **Der Zug fährt** | Vorbeiziehende Lichter vor den Fenstern, leichtes Schwanken, Wagentypen eines echten Nachtzugs | Owner-Test (Atmosphäre) |
| S3 | **Fahrkarten-Ästhetik** | UI als gelochte Fahrkarte (Schreibmaschinenschrift, Cremepapier, Stempel); Hinweise als Notizen des Bahnhofsvorstehers | UX-Spezifikation |
| S4 | **Gruselig, nicht grausam** | Kein Blut, keine Verletzungen, keine Leichen; Schreckmomente kurz; Flackern ≤ 3 Hz; Einstellung „Sanfter Modus“ | Compliance-Check, Fragebogen „Fear: Mild“ |
| S5 | **Fair gemein** | Jede Gefahr ist überlebbar, wenn man das Zeichen richtig liest: Versteck in Reichweite, Warnzeit ausreichend (Fairness-Prüfer, §9) | Logik-Tests über viele Seeds |

## 4. Core Loop

### 4.1 30-Sekunden-Loop – „Ein Wagen“
1. Übergangstür öffnet sich beim Herantreten; die Wagennummer zählt hoch.
2. Wagen erkunden: Koffer und Fächer durchsuchen (Fahrkartenabrisse = Punkte, manchmal der Schlüssel).
3. Auf Zeichen achten (Lampen schwingen, grüne Augen, rote Laterne) und richtig reagieren.
4. Weiter zur nächsten Tür.

### 4.2 5-Minuten-Loop – „Strecke“
Etwa 8–12 Wagen. Dazwischen mindestens eine Begegnung mit einem Wesen, ein verschlossener Wagen, ein dunkler Wagen (ab Wagen 8). Die Spannung steigt mit der Wagennummer (mehr und häufigere Wesen).

### 4.3 Lauf – „Linie 1“ (MVP)
Bahnsteig → Wagen 0 (Einstieg, ungefährlich) → Wagen 1–49 → **Wagen 50: Postwagen mit dem Schaffner** → Ausgang = „Linie 1 geschafft“. Zielzeit für einen erfolgreichen Lauf: 20–30 Minuten [ANNAHME]. Spätere Linien (Wagen 51–100, Verfolgungsjagd) folgen nach dem Owner-Test.

## 5. Welt: Wagentypen

Gemeinsame Maße: Innenbreite 12 Studs, Innenhöhe 11, Übergang 4 Studs, Tür 5 × 8. Laufgeschwindigkeit 16 Studs/s (Roblox-Standard), Schleichen 8.

| Typ | Länge | Verstecke | Behälter | Besonderheit | Ab Wagen |
|---|---|---|---|---|---|
| Einstiegswagen | 40 | 2 Schränke | 2 | Start, nie gefährlich | 0 |
| Großraumwagen | 56 | 2 Gepäckschränke (an den Enden) | 3–4 Gepäckablagen | Sitzreihen, Mittelgang | 1 |
| Schlafwagen | 64 | 4–5 Kleiderschränke (je Abteil einer) | je Abteil 1 Koffer | Seitengang + Abteile; Kontrolleur möglich | 2 |
| Speisewagen | 56 | 2 Vorratsschränke (Küche) | 3 Schubladen | Tische beidseitig | 3 |
| Gepäckwagen | 60 | 2–3 Überseekoffer | 4 Kisten | Kisten-Slalom; oft dunkel | 4 |
| Salonwagen | 48 | 2 Garderobenschränke | 2 | Sofas, Bar | 6 |
| Postwagen (Finale) | 96 | 6 Postschließfächer | – | Regalgänge, Schaffner, Code-Schloss | 50 |

Prozedural: Sitzreihen, Abteilzahl, Kisten-Slalom, Verstecke und Behälter variieren je Seed; Wagentyp nach Gewichtung, kein Typ dreimal in Folge.

## 6. Wesen (Linie 1)

Allgemein: 100 Lebenspunkte, **keine Regeneration**. Wesen erscheinen frühestens ab Wagen 5 (Schonfrist).

| Wesen | Zeichen (sichtbar + hörbar) | Richtige Reaktion | Folge bei Fehler | Ab Wagen | Häufigkeit |
|---|---|---|---|---|---|
| **Express** | Lampen in den letzten Wagen schwingen und flackern (≤ 3 Hz), weißer Lichtschein von hinten wird heller, Schienenrhythmus wird schneller | In einen Schrank/Koffer, bis das Licht vorbei ist | Tod | 5 | 15 % je Wagen, steigt bis 28 %; Abstand ≥ 4 Wagen |
| **Pendel** | wie Express, aber bläulich und lauter; kehrt 2–4-mal um | Versteckt bleiben, bis alle Durchgänge vorbei sind | Tod | 18 | 8 % (ersetzt Express) |
| **Blinder Passagier** | nur in dunklen Wagen: zwei grüne Augen leuchten in Spielernähe auf, Flüstern | Innerhalb von 2,2 s hinsehen | 35 Schaden | 8 (dunkle Wagen) | pro Spieler alle 8–18 s im Dunkeln |
| **Kontrolleur** | steht vorn im Schlafwagen mit Laterne. Gelb = gehen; flackert gelb/rot (1,2 s) = gleich stehen bleiben; Rot = still stehen | Bei Rot nicht bewegen; bis zu ihm vorgehen, dann ist man „kontrolliert“ | 40 Schaden je Rotphase | 12 (Schlafwagen) | 25 % der Schlafwagen, Abstand ≥ 6 Wagen |
| **Schaffner** | Postwagen: blinde, sehr große Gestalt mit gedimmter Kopflampe; Schritte hörbar | Schleichen (leise), in Schließfächern verstecken; 3 Anhänger finden, Code eingeben | Tod bei Berührung | 50 | immer |

### 6.1 Express (Kinematik, Garantie)
- Auslöser: Öffnen der Tür in Wagen *k*. Warnung (Flackern) 2,5–3,5 s, dann Start 140 Studs hinter dem Heck von Wagen *k−1*, Tempo 70 Studs/s, Ende an der Front von Wagen *k*.
- Wer nicht versteckt ist und auf seiner Bahn steht, scheidet aus (der Express füllt den ganzen Wagenquerschnitt).
- **Garantie (§9):** Von jedem Punkt in Wagen *k−1* und *k* ist das nächste Versteck rechtzeitig erreichbar (Laufzeit + 1,0 s Reaktion + 0,5 s Einsteigen ≤ Ankunftszeit an diesem Punkt). In *k−1* und *k* gibt es zusammen mindestens 4 Verstecke (eins pro Spieler).

### 6.2 Pendel
Wie Express, aber 2–4 Durchgänge mit 2–4 s Pause. Die Garantie gilt für den ersten Durchgang; danach sind alle schon versteckt. Während ein Wesen aktiv ist, gilt die Kälte-Regel (§7) nicht.

### 6.3 Blinder Passagier
Serverseitiger Zeitgeber je Spieler im dunklen Wagen. Angriff: Augen erscheinen 6–9 Studs entfernt seitlich/hinter dem Spieler in Ablagehöhe. Der Client meldet „angesehen“ (Blickwinkel < 25°, freie Sicht); der Server prüft das Zeitfenster (≥ 0,15 s, ≤ 2,2 s + 0,4 s Latenz). Ohne gültige Meldung: 35 Schaden. Danach 14 s Pause.

### 6.4 Kontrolleur (eigene Mechanik)
Phasen: Gelb 3,5–5,5 s → Warnung 1,2 s → Rot 2,0–3,0 s → Gelb … Bei Rot misst der Server die waagerechte Bewegung jedes Spielers im Wagen (Gnadenzeit 0,35 s nach Beginn der Rotphase; ab 1,5 Studs in 0,3 s gilt man als „bewegt“). Treffer: 40 Schaden, höchstens einmal je Rotphase. Wer bis auf 8 Studs an den Kontrolleur herankommt, ist „kontrolliert“ (sicher). Die Ausgangstür bleibt verschlossen, bis alle lebenden Spieler im Wagen kontrolliert sind; dann geht der Kontrolleur durch die Tür ab.

### 6.5 Schaffner (Finale Wagen 50)
- Erwacht 6 s nach Betreten, startet am anderen Ende.
- Hören: Spieler mit > 10 Studs/s erzeugen Geräusche im Radius 22; schleichend (2–10 Studs/s) Radius 6; Stillstand 0. Falscher Code am Schloss: Radius 60.
- Bewegt sich auf einem Wegenetz (Regalgänge): Streife 7 Studs/s, Jagd 13 Studs/s (langsamer als Laufen 16, schneller als Schleichen 8). Berührung (3,5 Studs) = Tod. Versteckte Spieler sind sicher.
- Rätsel: 3 Gepäckanhänger mit Symbol (●, ▲, ■) und Ziffer liegen in den Regalen. Das Schloss zeigt die Reihenfolge der Symbole. Gelesene Anhänger erscheinen für alle im Notizzettel. Richtiger Code → Tor öffnet sich → „Linie 1 geschafft“.

## 7. Interaktionen und Regeln

- **Türen:** öffnen sich automatisch, wenn ein lebender Spieler ≤ 6 Studs davor steht und die Tür nicht verschlossen ist. Öffnen von Tür *k* baut Wagen *k+1* hinter der nächsten Tür.
- **Verschlossene Türen** ab Wagen 3 (20 %): Der Schlüssel liegt immer in einem Behälter **desselben** Wagens (Garantie). Wer ihn trägt, öffnet die Tür beim Herantreten.
- **Behälter** (Koffer, Fächer, Schubladen): Halten zum Öffnen (ProximityPrompt), Inhalt: nichts, 1–3 Abrisse oder der Schlüssel.
- **Verstecke** (Schrank, Überseekoffer, Schließfach): 1 Person; Sicht durch Türschlitze. Verlassen per Knopf.
- **Kälte:** Wer ohne aktives Wesen 14 s versteckt ist, sieht Raureif; nach 20 s wird man hinausgeschoben (kein Schaden).
- **Schleichen:** Umschalten (Taste C / Touch-Knopf / Gamepad B), Tempo 8.
- **Der Ruck:** Hinter dem höchsten geöffneten Wagen bleiben nur 4 Wagen bestehen; wer dahinter ist, wird vorher nach vorn versetzt.
- **Tod:** Zuschauen bei Mitspielern; Fahrkarten-Notiz mit Hinweis zur Todesursache. Keine Wiederbelebung (auch nicht kaufbar).
- **Lauf-Ende:** alle tot oder Ziel erreicht → Ergebnis-Fahrkarte (Wagen, Abrisse, Zeit) → nach 15 s zurück zum Bahnsteig.

## 8. Bahnsteig (Lobby) und Mehrspieler
- Ein Server = eine Gruppe, höchstens 4 Spieler (Servergröße beim Veröffentlichen auf 4 setzen).
- Wer im Einstiegsfeld vor der Zugtür steht, ist bereit. Countdown 15 s, sobald einer bereit ist; 3 s, wenn alle bereit sind.
- Wer während eines Laufs beitritt, wartet auf dem Bahnsteig und sieht die Abfahrtstafel („Zug unterwegs – Wagen 23“).
- Spätere Version: eigener Lobby-Place mit Matchmaking (TeleportService), nicht im MVP.

## 9. Fairness-Garantien (Fairness-Prüfer, in Tests über 500 Seeds)
1. Jeder Lauf hat genau 51 Wagen (0–50); Wagen 0 ist Einstieg, Wagen 50 der Postwagen.
2. Keine Wesen in Wagen 0–4; nie zwei Wesen im selben Wagen.
3. Express/Pendel: Garantie aus §6.1 (Versteck rechtzeitig, ≥ 4 Verstecke in *k−1* ∪ *k*), Abstand ≥ 4 Wagen; nicht in Wagen 49/50.
4. Verschlossene Tür ⇒ Schlüssel im selben Wagen; nie in Wagen mit Kontrolleur; nie zwei in Folge.
5. Dunkle Wagen nie zweimal in Folge, nie Wagen 49/50; nie mit Kontrolleur.
6. Kontrolleur nur im Schlafwagen (gerade Sichtachse).
7. Postwagen: Wegenetz zusammenhängend, jedes Schließfach und jeder Anhänger erreichbar; Startabstand Schaffner ≥ 60 Studs zum Eingang.

## 10. UI/UX und Einstellungen (Kurzfassung; Details in `docs/lantern-line/ux_spec.md`)
- HUD: Wagennummer (Schablone), Lebensbalken als Fahrkarte mit Lochungen, Schlüssel-Symbol, Schleichen-Anzeige, Notizzettel im Postwagen.
- Einstellungen: **Flackern reduzieren** (kein Lampenflackern, nur Farbwechsel), **Sanfter Modus** (kein Kamerawackeln, kein Vollbild-Aufblitzen beim Tod). Beides im Menü, ohne Text verständlich (Symbole) und auf EN/DE.
- Sprache: Englisch und Deutsch (LocalizationTable).

## 11. Kinderschutz und Compliance (vorläufig, verbindlich ist der Compliance-Bericht)
- Erwartetes Label **Mild** (Fear: Mild – Jumpscares, gruselige NPCs, Spannung; laut Roblox-Doku `content-maturity.md` gehören Jumpscares zu „Mild“) [QUELLE: Roblox/creator-docs @af5f853, content-maturity.md, abgerufen 2026-10-13]. Kein Blut, keine Verletzungen. Häufigkeit vermutlich „Repeated“.
- Keine Käufe im MVP (keine Wiederbelebung gegen Robux, keine Zufallsgegenstände). Kein Chat-Zwang; keine eigenen Texteingaben (nur Zahlen am Schloss).
- Flackern ≤ 3 Hz (Fotosensibilität), Einstellungen aus §10.
- Nur Engine-Inhalte (Kat. 0); keine Sounds ohne Owner-Prüfung (D-030 gilt weiter). Alle Wesen sind über Licht erkennbar (S1), deshalb ist das Spiel ohne Sounds spielbar.

## 12. Telemetrie (Kurzfassung; Details in `docs/lantern-line/telemetry_plan.md`)
- Onboarding-Funnel (erster Lauf): Bahnsteig → eingestiegen → erste Tür → erstes Versteck → Wagen 10 → Wagen 25 → Postwagen → geschafft.
- Lauf-Funnel je Lauf: Meilensteine Wagen 1, 5, 10, 15 … 50, Ziel.
- Todesursache (Custom Event, 6 Werte), Abbruch-Wagen.

## 13. Feature-Liste (MoSCoW, MVP = Linie 1)
- **Must:** Bahnsteig mit Countdown; Wagen 0–50 prozedural; Türen, Schlüssel, Behälter; Verstecke + Kälte; Express, Pendel, Blinder Passagier, Kontrolleur, Schaffner-Finale mit Code; Tod + Zuschauen + Hinweise; HUD EN/DE; Einstellungen Flackern/Sanft; Fairness-Prüfer mit Tests; Remote-Schutz.
- **Should:** Vorbeiziehende Lichter vor den Fenstern, Schwanken, Ergebnis-Fahrkarte, Telemetrie.
- **Could:** Harmlose Schreckmomente (Motten aus dem Schrank), Bahnsteig-Vorbeifahrt am Fenster, Laterne als Fundstück.
- **Won’t (MVP):** Verfolgungsjagd (Gepäckberg), Wagen 51–100, Shop/Währung über Läufe hinweg, Speicherstand, Käufe, eigener Lobby-Place.

## 14. Hypothesen
- H1: ≥ 60 % der Erstspieler erreichen Wagen 10 [ANNAHME]; Messung über den Onboarding-Funnel.
- H2: Express-Tode im ersten Lauf ≤ 50 % der Begegnungen (Zeichen verständlich) [ANNAHME].
- H3: Mit „Licht verrät alles“ ist das Spiel ohne Ton genauso fair (Owner-Test einmal stumm).

## 15. Offene Fragen an den Owner
1. Arbeitstitel „CARRIAGES“ / „Der Nachtzug“ – passt der Stil (Nachtzug statt Hotel)? Das Setting ist eine austauschbare Schicht; die Mechanik bleibt gleich.
2. Sounds: wie D-030 – Engine-Sounds bzw. Roblox-eigene Sounds erst nach deiner Prüfung in Studio.
