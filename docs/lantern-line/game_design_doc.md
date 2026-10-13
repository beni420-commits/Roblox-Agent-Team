# Game Design Document – „Lantern Line – Der Nachtzug“

Rolle: Game Designer · Stand: 2026-10-13 · **Version 0.2**
- v0.1 war der Konzeptentwurf.
- v0.2 setzt die Recherche (`docs/lantern-line/research_doors.md`) und die Compliance-Vorprüfung (`reports/lantern-line/compliance_check_concept.md`, Auflagen H-A1 bis H-A15) um und beschreibt den gebauten Stand.

**Arbeitstitel:** Der Titel ist bewusst kein einzelnes Pluralwort in Versalien (H-A15). Die Markenrecherche ist offen.
**Owner-Auftrag:** steht in `docs/decisions.md` (D-032).

**Evidenz:**
- Werte zu Spielspaß, Zeiten und Balancing sind `[ANNAHME]`, bis Playtests vorliegen.
- Als **Garantie** markierte Regeln prüft der Fairness-Prüfer über 150 Seeds; die Tests stehen in `games/lantern-line/tests`.

---

## 1. Pitch

**Bis zu vier Mitreisende kämpfen sich durch einen nächtlichen Zug, Wagen für Wagen. Alles, was ihnen gefährlich wird, kündigt sich durch Licht an. Wer die Zeichen liest, erreicht den Postwagen und entwertet dort seine Fahrkarte.**

## 2. Vertrautes Genre-Gefühl, eigene Gestaltung (H-A5)

Das Spiel nutzt bekannte Prinzipien des Raum-für-Raum-Horrors. Gestaltung, Namen, Figuren, Texte und UI sind eigen. Diese Tabelle ist der Abstandsnachweis.

| Genre-Prinzip | Unsere Umsetzung | Ausdrücklich nicht übernommen (H-A2, H-A3) |
|---|---|---|
| Räume nacheinander, Fortschritt als Zahl | Wagen 0–50 eines Nachtzugs. Die Wagennummer steht in weißer Schablonenschrift über der Übergangstür | Nummernschilder im Messing-/Gold-Stil, Türen als Logo |
| Lobby mit Countdown | Bahnsteig mit Abfahrtstafel (lokalisiert) und Einstiegsfeld vor der Zugtür | Aufzug, Pre-Run-Shop |
| Warnung durch Licht, verstecken | **Express**: weißes Scheinwerferlicht von hinten. Die Lampen schwingen und flackern höchstens 2-mal pro Sekunde, im HUD erscheint eine Warnleiste | Gesichter, Grinsen, Rauch- oder Partikelkörper, Durchgänge im Wechsel |
| Gefahr in dunklen Räumen | **Blinder Passagier**: grüne Augenpaare unter Sitzen und in Ablagen. Man muss **Abstand halten**; kommt man zu nah, kostet das 35 Lebenspunkte | „Ansehen“-Mechanik, Laut „psst“, Augen-Cluster |
| Wesen, das eine bestimmte Reaktion verlangt | **Gegenzug**: Licht flutet eine Fensterseite. Dann auf die andere Wagenhälfte wechseln; ein Pfeil im HUD und eine markierte Bodenhälfte zeigen die Seite | Wiederholte Hin-und-her-Durchgänge |
| (eigene Mechanik) | **Kontrolleur**: Bei runder Kelle darf man gehen, bei der Kelle mit Streifen muss man stillstehen. Wer bei ihm ankommt, ist kontrolliert. Er gibt die Tür erst frei, wenn alle kontrolliert sind | Begriffe oder Optik bekannter Serien |
| Verfolgungsjagd | **Kofferlawine**: Eine Wand aus Koffern rollt durch 5 Wagen, die Türen vorn öffnen sich von selbst | Augen an Wänden, greifende Arme (H-A4) |
| Rätsel-Finale mit Wächter | **Schaffner** im Postwagen sieht nur, was seine Kopflampe beleuchtet, und hört laute Schritte. **Entwerter-Rätsel**: Drei Fahrkartenschnipsel zeigen je eine Reihe eines 3×3-Lochmusters | Blindheit als Kernmechanik, Formen-Ziffern-Code, Bücher, Vorhängeschloss (H-A3) |
| Hinweis nach dem Tod | Fahrkarten-Notiz des Bahnhofsvorstehers mit eigenen Texten | Leuchtende blaue oder gelbe Texte, schwebende Lichtfigur |
| Zurückgebliebene einholen | **Der Ruck**: Hinter dem höchsten geöffneten Wagen bleiben 4 Wagen angekoppelt; wer weiter zurück ist, wird nach vorn versetzt | – |

## 3. Designsäulen (Stil „Laternen-Noir“)

| # | Säule | Konkret | Prüfbar über |
|---|---|---|---|
| S1 | **Licht verrät alles** | Jedes Wesen hat eine Lichtfarbe **und** ein zweites Merkmal: Form, Bewegung oder HUD-Symbol (H-A11). Ohne Ton voll spielbar | Todesursachen (Telemetrie), Graustufen-Screenshots |
| S2 | **Der Zug fährt** | Lichter ziehen draußen vorbei, die Kamera schwankt leicht (abschaltbar), Wagentypen eines echten Nachtzugs | Owner-Test |
| S3 | **Fahrkarten-Ästhetik** | HUD aus Fahrkarten: Leben als 10 Lochfelder, Schlüssel, Notizzettel. Schrift SpecialElite (Schreibmaschine) und Michroma (Schablone) | UX |
| S4 | **Gruselig, nicht grausam** | Kein Blut, kein Ragdoll. Figuren verblassen beim Ausscheiden. Schreckmoment ≤ 1 s, Sanfter Modus | Compliance H-A8, H-A9 |
| S5 | **Fair gemein** | Jede Gefahr ist überlebbar, wenn man das Zeichen liest (§9) | Fairness-Prüfer |

## 4. Core Loop
1. **Pro Wagen, ca. 30 s:**
   - Die Tür öffnet sich beim Herantreten.
   - Koffer, Ablagen, Schubladen und Kisten durchsuchen (Abrisse oder Schlüssel).
   - Zeichen lesen und reagieren, dann zur nächsten Tür.
2. **Strecke, ca. 5 Minuten:** 8–12 Wagen mit mindestens einem Wesen, einem verschlossenen und ab Wagen 8 einem dunklen Wagen.
3. **Lauf „Linie 1“, 20–30 Minuten [ANNAHME]:**
   - Bahnsteig → Wagen 0 (ruhig) → Wagen 1–49 mit Kofferlawine zwischen Wagen 25 und 42.
   - Wagen 50 ist der Postwagen; mit dem Entwerter-Muster öffnet sich das Tor zum Ankunftsbahnsteig, die Linie ist geschafft.

## 5. Wagentypen (Innenbreite 12, Höhe 11, Übergang 4)

| Typ | Länge | Verstecke (1 Person) | Behälter | Besonderheit | Ab Wagen |
|---|---|---|---|---|---|
| Einstiegswagen | 40 | 2 Schränke | 2 Ablagen | ruhig | 0 |
| Großraumwagen | 56 | 2–3 Gepäckschränke | 3–4 Ablagen | Sitzreihen, Mittelgang | 1 |
| Schlafwagen | 64 | 4–5 Kleiderschränke | je Abteil ein Koffer | Seitengang, offene Abteile ohne Türen; Kontrolleur möglich; **höchstens 25 % je Lauf** (H-A7) | 2 |
| Speisewagen | 56 | 1 Schrank + 2 Vorratsschränke | 3 Schubladen | Sitznischen, Küche (ohne Alkohol, H-A6) | 3 |
| Gepäckwagen | 60 | 2–3 Überseekoffer (je einer hinten und vorn) | 4 Kisten | Kisten-Slalom, öfter dunkel | 4 |
| Teesalon | 48 | 2–3 Garderobenschränke | 3 Schubladen | Sofas, Teetresen mit Samowar (statt Bar, H-A6) | 6 |
| Postwagen | 96 | 6 Schließfächer | – | zwei Regalgänge, Schaffner, Entwerter, Tor | 50 |

## 6. Wesen (Werte aus `GameConfig.luau`)
100 Lebenspunkte, keine Regeneration. Wagen 0–4 sind ohne Wesen, die Wagen 49 und 50 ohne Zufallsereignisse.

| Wesen | Zeichen (Licht + zweites Merkmal) | Richtige Reaktion | Folge | Ab Wagen | Häufigkeit (gemessen über 150 Pläne) |
|---|---|---|---|---|---|
| Express | weißes Licht von hinten; Lampen schwingen und flackern (≤ 2 Hz); Warnleiste unten | verstecken | ausgeschieden | 5 | Ø ca. 3 pro Lauf, Abstand ≥ 4 Wagen |
| Gegenzug | blaues Licht an einer Fensterseite; Pfeil im HUD; markierte Bodenhälfte | auf die andere Hälfte oder verstecken | 50 Schaden | 10 | Ø ca. 1,5 pro Lauf |
| Blinder Passagier | grüne Augenpaare, ab 8 Studs heller | Abstand > 2,5 Studs | 35 Schaden, Augenpaar verschwindet | 8 (dunkel) | 2–4 Paare je dunklem Wagen |
| Kontrolleur | Laterne und Kelle: rund = gehen, Streifen = stillstehen. Die Warnung pulsiert langsam (≤ 1 Hz) | bei Streifen still; zu ihm hingehen | 40 Schaden je Haltphase | 7 (Schlafwagen) | 30 % der Schlafwagen, Abstand ≥ 6 |
| Kofferlawine | Lampen hinten färben sich orange, Kofferwand rumpelt | nach vorn laufen | ausgeschieden | Start 25–38 | genau 1 pro Lauf |
| Schaffner | Kopflampe mit sichtbarem Lichtkegel (16 Studs, ±30°) | schleichen, aus dem Kegel bleiben, Schließfach | ausgeschieden | 50 | immer |

### 6.1 Express
- **Auslöser:** Betreten von Wagen *k*.
- **Warnung:** 2,5–3,5 s.
- **Fahrt:** Start 140 Studs hinter Wagen *k−1*, 70 Studs/s, bis zur Vordertür von *k*.
- **Garantie:** Von jedem erreichbaren Punkt in *k−1* und *k* ist ein Versteck rechtzeitig erreichbar (Weg/16 + 1,0 s Reaktion + 0,5 s Einsteigen ≤ Ankunft). Zusammen gibt es ≥ 4 Verstecke.

### 6.2 Gegenzug
- **Ablauf:** 3–4 s Warnung, 1,6 s Licht auf der Seite `side`.
- **Sicher ist:** wer bei z·Seite ≤ −1 steht oder versteckt ist.
- **Garantie:** Die sichere Hälfte ist von überall in *k−1* und *k* vor Ablauf der Warnzeit erreichbar.

### 6.3 Blinder Passagier
- **Position:** Augenpaare stehen fest unter Sitzen oder in Ablagen.
- **Garantie:** Wege zur Vordertür, zu allen Verstecken und Behältern (auch zum Schlüssel) führen mit Abstand an den Augen vorbei.
- **Auslöser:** Die Augen werden über die Nähe ausgelöst, nicht über Blicke.

### 6.4 Kontrolleur
- **Phasen:** Einleitung 2 s → Gehen 3,5–5,5 s → Achtung 1,2 s (Laterne wechselt weich die Farbe, Kelle pulsiert) → Halt 2–3 s.
- **Messung bei Halt:** Erst nach 0,35 s Gnadenzeit misst der Server die Bewegung; mehr als 1,5 Studs in 0,3 s gilt als bewegt.
- **Kontrolliert:** ab 8 Studs Abstand zu ihm.
- **Tür:** Sie bleibt zu, bis alle lebenden Spieler im Wagen kontrolliert sind.

### 6.5 Schaffner und Entwerter (Finale)
- **Start:** Er erwacht 6 s nach dem Betreten am vorderen Ende.
- **Wahrnehmung:** Lichtkegel mit Sichtprüfung an den Regalen vorbei. Er hört Laufen (> 10 Studs/s) im Radius 22, Schleichen im Radius 6, Stillstand gar nicht. Ein falsches Muster am Entwerter hört er im Radius 60.
- **Tempo:** Streife 7, Jagd 13; das liegt zwischen Schleichen (8) und Laufen (16). Er fängt im Radius 3,5; Schließfächer schützen.
- **Rätsel:** Jedes Fragment zeigt eine Reihe (1–2 Löcher). Gelesene Reihen erscheinen für alle im Notizzettel. Am Entwerter stanzt man das 3×3-Muster ohne Texteingabe.

### 6.6 Kofferlawine
- **Start:** Einmal pro Lauf, Start in Wagen *c* (25–38). Nach 3 s Warnung startet sie am Heck von *c−1*, rollt mit 13 Studs/s und endet an der Vordertür von *c+4*.
- **Verstecke:** In diesen Wagen sind die Verstecke deaktiviert.
- **Garantie:** Nur gerade Wagentypen. Laufweg/16 ≤ 0,9 × Lawinenzeit.
- **Ruhe:** Wagen *c−1* und *c+5* bleiben ruhig.

## 7. Interaktionen
- **Türen:** Sie öffnen sich, wenn ein Spieler auf 6 Studs herankommt. Gebaut ist immer der nächste Wagen; behalten werden 4 Wagen dahinter.
- **Verschlossene Türen** ab Wagen 3 (20 %): Der Schlüssel liegt im selben Wagen (Garantie) und gehört der Gruppe, deshalb gibt es keine Sackgasse, wenn jemand ausscheidet.
- **Verstecke:** genau 1 Person; Sicht durch die Schlitze; „Aussteigen“ per E, Gamepad B oder Knopf. Kälte: Warnung nach 14 s, nach 20 s wird man hinausgeschoben. Solange ein Wesen aktiv ist, beginnt die Zeit neu.
- **Schleichen:** Umschalten mit C, Strg, Gamepad B oder Touch-Knopf.
- **Ausscheiden:** Die Figur verblasst. Danach kommt die Hinweis-Notiz, dann Zuschauen bei Mitreisenden (ohne Namen, H-A12). Es gibt keine Wiederbelebung, auch nicht kaufbar (H-A13).
- **Ende:** Gewonnen ist, wenn ein Spieler nach dem Lösen durchs Tor geht; verloren, wenn niemand mehr lebt. Die Ergebnis-Fahrkarte zeigt Wagen, Abrisse und Zeit. Nach 15 s geht es zurück zum Bahnsteig.

## 8. Bahnsteig und Mehrspieler
- Ein Server ist eine Gruppe mit höchstens 4 Spielern; die Servergröße beim Veröffentlichen auf 4 setzen.
- Countdown: 15 s ab dem ersten Bereiten, 3 s wenn alle bereit sind.
- Wer später beitritt, wartet am Bahnsteig; die Tafel zeigt „Zug unterwegs – Wagen n“.
- Am Bahnsteig gibt es keine Sitzplätze und keine Bühne. Die Einstellungen sind dort deutlich hervorgehoben (H-A9).

## 9. Fairness-Garantien
Alle sind durch Tests über 150 Seeds geprüft.
1. 51 Wagen: Wagen 0 ist der Einstieg, Wagen 50 der Postwagen. Alle Wagen sind begehbar: Weg hinten→vorn; Verstecke, Behälter, Fragmente, Entwerter und Wegenetz erreichbar.
2. Keine Ereignisse in den Wagen 0–4, 49 und 50 (außer dem Schaffner).
3. Express und Gegenzug unabhängig nachgeprüft (§6.1, §6.2), Abstand ≥ 4 Wagen.
4. Verschlossen ⇒ genau ein Schlüssel im selben Wagen; nie zweimal hintereinander verschlossen oder dunkel.
5. Kontrolleur nur im hellen, unverschlossenen Schlafwagen, Abstand ≥ 6.
6. Kofferlawine: genau eine, mit fünf geraden Wagen und ruhigen Nachbarn.
7. Schlafwagen ≤ 25 %; kein Wagentyp dreimal hintereinander.
8. Postwagen: Netz zusammenhängend, Schaffner startet ≥ 60 Studs vom Eingang, der Code passt zu den Fragmenten.
9. Flackern ≤ 2 Pulse pro Sekunde über den ganzen Bildschirm (synchroner Plan; geprüft über 500 Pläne).

## 10. UI/UX und Einstellungen
- **HUD:**
  - Wagennummer
  - Lebens-Fahrkarte mit 10 Lochfeldern
  - Schlüssel
  - Schleichen
  - Kontrolleur-Kelle mit Form und Text
  - Gegenzug-Pfeil
  - Warnleiste
  - Notizzettel im Postwagen
  - Raureif bei Kälte
- **Einstellungen** über Knopf oder Taste M:
  - Flackern reduzieren: keine Pulse, sanftes Abdunkeln ≥ 0,3 s.
  - Sanfter Modus: kein Wackeln, kein Blitz, gedämpfte Lichtwesen.
  - Bewegung reduzieren: Startwert aus der Roblox-Einstellung `ReducedMotionEnabled`.
- **Sprache:** EN und DE (59 Textschlüssel). ProximityPrompts werden automatisch über die Source-Texte übersetzt.

## 11. Kinderschutz und Compliance
Verbindlich ist der Compliance-Bericht.
- **Label:** erwartet „Mild“ (Violence Mild/Repeated, Fear Mild/Repeated).
- **Keine Käufe**, keine Texteingabe, kein Chat-Zwang.
- **Assets:** nur Engine-Inhalte (Kat. 0) und keine Sounds bis zur Prüfung durch den Owner (D-030). Ohne Ton bleibt das Spiel spielbar (S1).
- **Statische Prüfungen** in `scripts/lantern_line_checks.py`: Blockliste, keine Sitze, keine TextBox, keine Käufe, keine Asset-IDs, Bezüge auf das Vorbild-Spiel nur in Recherche und Compliance.

## 12. Telemetrie
Details in `docs/lantern-line/telemetry_plan.md`.
- **Onboarding (8 Schritte):** Bahnsteig, eingestiegen, erste Tür, erstes Versteck, Wagen 10, Wagen 25, Postwagen, geschafft.
- **Lauf-Funnel „Run“:** Meilensteine 1, 5, 10, … 50, Ziel.
- **Custom:** Death und Damage mit Ursache, Hide, Muster richtig oder falsch, RunEnded, RemoteRejected.

## 13. Umfang

| | Stand |
|---|---|
| **Gebaut (Must)** | Bahnsteig, Wagen 0–50 prozedural, Türen, Schlüssel, Behälter, Verstecke mit Kälte, alle 6 Wesen, Finale, Ausscheiden mit Hinweis und Zuschauen, Ergebnis, HUD EN/DE, Einstellungen, Fairness-Prüfer, Remote-Schutz, Telemetrie |
| **Gebaut (Should)** | vorbeiziehende Lichter, Schwanken, Kofferlawine |
| **Offen (Could)** | harmlose Schreckmomente, Bahnsteig-Vorbeifahrt am Fenster, Laterne als Fundstück, Sounds (nach Owner-Prüfung) |
| **Nicht im MVP** | Wagen 51–100, Fortschritt oder Währung über Läufe hinweg, Speicherstand, Käufe, eigener Lobby-Place mit Matchmaking |

## 14. Hypothesen (Messung über Telemetrie)
- **H1:** ≥ 60 % der Erstspieler erreichen Wagen 10 [ANNAHME].
- **H2:** Ausscheiden durch den Express im ersten Lauf ≤ 50 % der Begegnungen [ANNAHME].
- **H3:** Ohne Ton ist das Spiel genauso fair (Owner-Test einmal stumm).

## 15. Offene Fragen an den Owner
1. Passen Titel und Setting (Nachtzug statt Hotel)? Das Setting ist eine austauschbare Schicht.
2. Soll das Spiel mit dem Label „Mild“ auch für Roblox Kids (5–8) offen sein (Compliance §7.2)?
3. Sounds: Erst nach deiner Prüfung in Studio (wie D-030).
