# Playtest-Bericht Sprint 0 – „Schwungturm“ (Persona-Simulation)

**Datum:** 2026-10-12 · **Sprint:** 0 · **Rolle:** Playtest-Simulator · **Evidenz:** `[SIMULIERT]` (gilt für den ganzen Bericht) · **Status:** Prüfbericht zum Konzeptentwurf. Das ist kein Spieltest.

> Alle Aussagen zu Erleben, Frust, Zeiten und „Würde ich wiederkommen?“ sind `[SIMULIERT]`, also ein gedanklicher Walkthrough. Rechenergebnisse sind `[EIGENE RECHNUNG]` auf Basis der Dokumentwerte. Die Eingangsparameter des Zeitmodells sind `[ANNAHME]`. Roblox-Verhalten, das in den Projektquellen nicht belegt ist, ist `[VORWISSEN, nicht aktuell]` markiert und muss im Owner-Test geprüft werden.

---

## 1. Kopf

### 1.1 Geprüfte Artefakte
| Artefakt | Stand | Geprüfte Teile |
|---|---|---|
| `docs/game_design_doc.md` | Entwurf 2026-10-12, inkl. §11 (Auflagen C-A1–C-A18) aus Commit `825197d`, der während dieser Prüfung entstand | vollständig (§1–§12) |
| `docs/ux_spec.md` | Sprint 0 | Teil A (A1–A7), Teil B (B1–B6) |
| `docs/tech_notes.md` | Entwurf | §6 (6.1–6.7), dazu §3 (Remote-Sicherheit, Bewegungs-Plausibilität) und §5 (Streaming) |
| `docs/research_report.md` | Sprint 0 | §2.6, §4, §5 (Konzept A), §6 |
| zum Abgleich | – | `docs/telemetry_plan.md`, `reports/compliance_check_sprint0.md` (C-A1–C-A18) |

### 1.2 Methode
1. **Walkthrough je Persona:** Für alle fünf Pflicht-Personas gehe ich die ersten 20 Minuten Schritt für Schritt entlang GDD §7 und UX B4 durch: Spawn → Onboarding → Zone 1 → Lager E5 → Schrein → Doppelsprung (E10) → Zone 2 → Dash (E20) → Zone 3 → Gipfel. Beim Grinder kommen Lauf 2–4 dazu, beim Exploiter jeder Angriffsweg einzeln gegen Tech §3, §6.4–§6.6.
2. **Nachrechnung** mit kleinen Python-Skripten (nicht im Repo):
   - Flugbahnen und Zeitfenster für Sprung, Doppelsprung (DJ) und Dash nach Tech §6.3
   - Kauf-Simulation der Economy nach GDD §5/§6
   - Monte-Carlo-Zeitmodell für den ersten Lauf
3. **Aktive Fehlersuche:** Ich habe das Design geprüft, als hätte ich es nicht selbst erstellt. Je Persona und insgesamt nenne ich die drei größten Schwachstellen. Lob gibt es nur dort, wo es eine Designentscheidung absichert.

**Schweregrade:**
- **hoch:** führt wahrscheinlich zum Abbruch oder in eine Sackgasse, bricht eine Designsäule (S1–S5) oder eine zugesagte Garantie (z. B. „Lösbarkeit“, „fair“).
- **mittel:** spürbarer Frust oder Motivationsverlust, oder ein Exploit mit begrenzter Wirkung.
- **gering:** Feinschliff oder Spezifikationslücke ohne direkte Wirkung auf Spieler.

### 1.3 Grenzen
- Es gibt keinen Build, kein Studio und kein Gerät. Über Bewegungsgefühl, Kamera, Touch-Präzision, FPS und Latenz kann ich nichts Belegtes sagen. Ein Gate (§5) ist mit `[SIMULIERT]` grundsätzlich nicht bestehbar.
- Personas sind Modelle. Kinder von 7–10 Jahren handeln weniger vorhersehbar als jedes Modell.
- Das Zeitmodell (§4.3) zeigt Größenordnungen und Empfindlichkeit, aber keine Prognose.
- Der Masterprompt (§1.7, §5) liegt nicht als Datei im Repo. Ich verwende die Gate-Kriterien aus dem Auftrag.

### 1.4 Kurzfazit
- **Stark:** Ziel und Kernhandlung sind ohne Text klar („nach oben, Funken sammeln“). Kein Kaufdruck, keine Kollision und kein Handel. Die Remote-Schicht ist solide.
- **Schwach:** Vier Problemfelder tragen einen großen Teil des Frust-Risikos:
  1. **Rücksetzung auf das Lager alle 5 Etagen**, zusammen mit einer Hilfe, die Fehlversuche pro Etage zählt
  2. ein **Bewegungsmodell**, dessen Sicherheitsfaktoren je Achse gelten und deshalb kombiniert bis zu 111 % der echten Reichweite verlangen
  3. ein **Dash**, der rechnerisch keine eigenen Lücken öffnet
  4. ein **gestapelter Turm** mit 16 Studs Etagenhöhe, in dem Kopf und Kamera an die nächste Etage stoßen
- **Social und Langzeit:** Der Social-Teil ist im MVP nicht tragfähig. Der Langzeit-Loop des MVP ist nach rund 45 Minuten leer.
- **Exploits:** Die Bewegungs-Plausibilität lässt Speedhack, Teleport und Fly fast vollständig durch.
- **Gate „Spielspaß“:** nicht bestanden (§5).

---

## 2. Persona-Walkthroughs `[SIMULIERT]`

### 2.1 Neuling (7–10 Jahre, liest wenig, kleines Android-Handy)
*Annahmen:* 5,5–6"-Telefon im Querformat, 2–3 GB RAM, Ping 100–200 ms. Die Roblox-Standardsteuerung kennt das Kind aus anderen Spielen. Es liest nur Zahlen.

| Minute / Schritt | Erleben | Problem | Schwere |
|---|---|---|---|
| 0:00 Spawn | Das Startpad leuchtet, die Kamera schwenkt 2 s nach oben. Das Kind tippt sofort und überspringt den Schwenk (UX B4). | Der Gipfel ist womöglich gar nicht im Bild: StreamingEnabled ist an, `TowerBuilder` baut nur Etagen in Spielernähe (Tech §6.1), und von unten verdeckt sich der Turm selbst. Dann fehlt das Ziel-Signal von S1. | mittel |
| 0:05–0:20 erste Bewegung | Funken liegen auf dem Leuchtpfad, „+1“ fliegt in den Zähler. Funken sind der stärkste Magnet. | Der Beam blendet sich nach dem ersten Mal aus (UX A5). Ab dann muss allein „das hellste Objekt“ führen. | gering |
| 0:20–0:60 erste Sprünge, Etage 1 | Breite Stufen mit höchstens 3,96 Studs Anstieg. Den Sprungknopf kennt das Kind. Dann Torbogen und „1/30“. | Die Fanfare hängt an der offenen Audio-Freigabe (GDD §12.3); ohne Ton fehlt die Hälfte des Feedbacks. AutoJump auf Touch kann an der Säule ungewollt auslösen `[VORWISSEN, nicht aktuell]`. | gering |
| 1–3 Etage 2–4 | Förderbänder und Sprungpads machen Spaß. Ein Fall auf Etage 3 setzt das Kind per „Plopp“ auf **Etage 0** zurück (GDD §7). | Es muss 2–3 Etagen erneut laufen, und die Funken dort sind schon weg: Wiederholung ohne Belohnung. Warum es „ganz unten“ ist, versteht es nicht. | **hoch** |
| ~4–5 Lager E5, Schrein | Der Kristall pulsiert. Das Kind tippt den Prompt an, tippt die pulsierende Karte und sucht dann „Kaufen“. | Der Kauf hat zwei Schritte (Karte, dann Kaufen) und keinen Text. Sprungkraft I bringt +6 % = +0,43 Studs, also „hat nix gebracht“. Das Wort „Kaufen“ erinnert an Robux. | mittel |
| 5–10 Etage 6–9 | Lücken bis 4,8 Studs. Das Kind fällt mehrfach auf E8/E9 und landet jedes Mal wieder auf E5 (UX B1). | Die Hilfe zählt Fehlversuche **pro Etage**. 5 Fehlversuche auf E9 heißen 5× E6–E8 wiederholen, rund 6–8 min bis zum Geist-Pfad. Typischer Abbruchpunkt. | **hoch** |
| ~10–12 Bühne Doppelsprung E10 | Lichtsäule, das Symbol fliegt zum Spieler. Ein neuer Knopf erscheint nicht, denn DJ ist „Sprungknopf erneut“. | „Knopf erscheint mit Puls“ (UX B4) passt nur zum Dash; für DJ fehlt das Signal „in der Luft nochmal tippen“. Schnelles Doppeltippen (< 0,14 s) verschenkt Reichweite: 9,5–10,8 statt der nötigen 11,7 Studs (§4.2). Die Übungsstrecke ist Pflicht und hat keine Hilfe, also droht eine **Sackgasse**. | **hoch** |
| 12–18 Zone 2 „Wolken“ | Weiß/Hellblau mit Nebel, Wolkenplattformen verschwinden. Andere Spieler ziehen Leuchtspuren hinter sich her. | Das Ziel ist nicht mehr das hellste Objekt. Das Kind folgt einer fremden Leuchtspur, die wie der Onboarding-Pfad aussieht. Im DJ-Scheitel liegt der Kopf bei etwa +18 Studs und stößt an die Etage darüber (16 Studs); die Kamera springt an der Decke. | **hoch** |
| 18–20 Lager E15 | Zweites Upgrade, kurze Ruhe. | Im Zeitmodell erreicht das Kind E15 nach ~17 min statt nach ~10 min (GDD §6.2). | mittel |
| > 20 min: Dash, Zone 3, Gipfel | In 20 min nicht erreicht. Im Modell liegt der Median für E20 bei ~26 min und für den Gipfel bei ~52 min (§4.3). Zone 3 verlangt in der Praxis Sprung → DJ → Dash, also 3 Eingaben auf 2 Knöpfen. | Die Übungsstrecke lehrt Dash allein, die Zone verlangt aber die Kombination (§4.2). | hoch (vorausschauend) |

**Fazit Neuling** `[SIMULIERT]`
- **Verständlichkeit ≤ 60 s:** wahrscheinlich ja. Funken, Pfad und breite Stufen tragen ohne Text. Risiko: Das Gipfel-Signal fehlt, wenn Streaming den Gipfel nicht lädt.
- **Frust-Stellen:** Rücksetzung auf E5 bei E6–E9 (hoch), DJ-Lernen mit Pflicht-Übung (hoch), Sicht und Kamera in Zone 2 (hoch).
- **Leerlauf:** Nach jedem Fall wiederholt das Kind bereits geleerte Etagen ohne einen einzigen Funken. Das ist der größte Leerlauf im Design.
- **Belohnungsrhythmus:** Zone 1 liegt noch nahe am Plan (E5 nach ~4 min, E10 nach ~9 min). Danach bricht er: Für diese Persona gilt GDD §6.2 nicht.
- **Würde ich wiederkommen?** **Vielleicht, eher nein.** Wer E10 schafft, kommt wieder. Wer an E8/E9 oder in der DJ-Übung hängen bleibt, kommt nicht wieder.
- **Drei größte Schwachstellen:**
  1. Rücksetzung auf das Lager zusammen mit der Hilfe-Zählung pro Etage (P-01)
  2. DJ ohne Text lernen, dazu eine Pflicht-Übung ohne Hilfe (P-05)
  3. Kamera und Kopffreiheit im gestapelten Turm sowie die Lesbarkeit von Zone 2 (P-04, P-09)

### 2.2 Casual-Spieler (5-Minuten-Sessions)
*Annahmen:* 10–13 Jahre, Telefon oder Tablet, normales Geschick. Vier Sessions à 5 min ergeben 20 min.

| Session / Minute | Erleben | Problem | Schwere |
|---|---|---|---|
| S1 0:00–1:00 | Das Onboarding läuft glatt, Etage 1 nach ~40 s. | – | – |
| S1 1–4 | E2–E5. Das Lager kommt nach ~3,5 min, der erste Kauf auch. | Gut: Die erste große Belohnung fällt noch in die erste Session (GDD-Ziel erfüllt). | – |
| S1 4–5 | E6–E7, dann endet die Session. | Der Fortschritt auf E6–E7 ist weg, weil der Rejoin am Lager E5 startet. Die Funken bleiben. | mittel |
| S2 0–1 | Rejoin am Lager E5, das HUD zeigt „5/30“. | Es fehlt ein Signal „hier geht es weiter“; der Beam gibt es nur im Onboarding. | gering |
| S2 1–5 | E6–E10, die DJ-Bühne kommt bei ~4:30. Die Übungsstrecke ist angefangen, als die Session endet. | Was nach einem Abbruch in der Übungsstrecke passiert, ist nicht spezifiziert: Muss die Übung beim Rejoin erneut gemacht werden? | gering |
| S3 0–5 | Zone 2: Nebel, DJ-Lücken, 2 Fälle zurück auf E10. Die Session endet bei E13. | Der Abschnitt E10–E15 dauert im Modell je nach Profil ~4,5–8 min (§4.3) und passt mit Fällen nicht in 5 min. Die zweite Session in Folge endet ohne erreichtes Lager. | **hoch** (für diese Persona) |
| S4 0–5 | Wieder ab E10, diesmal wird E15 erreicht. | Gefühl: „Ich spiele immer dieselben Etagen.“ Das GDD verspricht einen Pausenpunkt alle ~3 min (§3.2). | mittel |
| nach dem Gipfel (≈ Session 7–9) | Gipfel-Fest. | Im MVP gibt es danach kein 5-Minuten-Ziel, denn der Tagesturm ist Should. Lauf 2 dauert 8–10 min. | mittel |

**Fazit Casual** `[SIMULIERT]`
- **Verständlichkeit ≤ 60 s:** ja.
- **Frust-Stellen:** Ab Zone 2 endet die Session vor dem nächsten Lager, und der Fortschritt geht verloren.
- **Leerlauf:** Nach jedem Rejoin werden bereits geleerte Etagen erneut gelaufen.
- **Belohnungsrhythmus:** In Zone 1 passt er (ein Lager alle ~3 min). In Zone 2 und 3 nicht: Dort dauert ein Abschnitt 4–8 min.
- **Würde ich wiederkommen?** **Vielleicht**, solange pro Session ein Lager erreichbar ist. Nach dem Gipfel im MVP **nein**.
- **Drei größte Schwachstellen:**
  1. Ab Zone 2 ist ein Abschnitt länger als eine Session (P-01, P-14).
  2. Es fehlt ein Wiedereinstiegs-Signal (P-14).
  3. Nach dem Gipfel gibt es kein Kurz-Ziel (P-08).

### 2.3 Grinder / Completionist (Lauf 1–4)
*Annahmen:* 12–14 Jahre, geübt, PC oder Tablet. Sammelt alles und will maximieren.

| Lauf / Minute | Erleben | Problem | Schwere |
|---|---|---|---|
| L1 0–7 | Zone 1 zügig, alle Funken eingesammelt. Sucht nach Bonusrouten. | Funkenrouten, Gleiter und Wandsprung sind Should (GDD §9). Im MVP gibt es abseits des Hauptwegs nichts. | mittel |
| L1 E5/E10/E15 | Rechnet die Kosten durch und merkt, dass +6 % Sprunghöhe kaum spürbar ist. Kauft Tempo. | Die Upgrades sind zu klein für Säule S2 („spürbar“), siehe §4.1. | mittel |
| L1 E20 Dash | Dash-Spam auf geraden Strecken ist der eigentliche Tempo-Hebel. | Gut für diese Persona. Die „Dash-Lücken“ in Zone 3 sind in Wahrheit DJ+Dash-Lücken (§4.2). | – |
| L1 Gipfel (~22–25 min) | Fest, große Laufzeit-Zahl, Leuchtspur. | Laut §6.2 ist die Gipfel-Leuchtspur eine Belohnung, laut §9 ist Kosmetik aber Could. Im MVP gibt es sie womöglich nicht. | mittel |
| L2 (8–10 min) | Derselbe Turm, weil der Seed fest ist (GDD §4). Zone 1 ist mit DJ und Dash trivial, es gibt eine neue Bestzeit. | „Jeder Lauf macht dich besser“ funktioniert hier einmal sehr gut. | – |
| L3 | Dieselben 30 Etagen zum dritten Mal. Bei 100 % Sammelquote sind die Must-Upgrades in L3 bei E25 komplett (§4.1). | Danach sind Funken wertlos, und das „+1“-Feedback wird hohl. | **hoch** |
| L4 | Es bleibt nur die Bestzeit, ohne Vergleich, weil der Hauptturm keine Bestenliste hat. | Der ganze Lauf ist Leerlauf. Säule S4 „Vielfalt aus Regeln“ sieht der Spieler wegen des festen Seeds nie. | **hoch** |

**Fazit Grinder** `[SIMULIERT]`
- **Verständlichkeit ≤ 60 s:** ja.
- **Frust-Stellen:** wenige, weil das Können hoch ist. Das Problem ist Langeweile, nicht Frust.
- **Leerlauf:** Lauf 3–4 komplett.
- **Belohnungsrhythmus:**
  - Lauf 1 dauert mit Übungen und Schrein ~22–25 min statt 18–20 min.
  - „Alle Upgrades in ~4 Läufen“ stimmt nur mit den Should-Senken Gleiter und Wandsprung.
  - Im Must-only-MVP ist alles nach ~40–50 min gekauft.
- **Würde ich wiederkommen?** **Ja für 2–3 Läufe, dann nein** (MVP). Mit Tagesturm und neuen Seeds je Lauf: ja.
- **Drei größte Schwachstellen:**
  1. Identischer Turm und leere Senken (P-08)
  2. Kaum spürbare Upgrades (P-12)
  3. Keine optionalen Wege im MVP (P-08)

### 2.4 Social-Spieler (mit 1–2 Freunden im selben Server)
*Annahmen:* 9–12 Jahre, jedes Kind mit eigenem Gerät. Chat ist für die meisten nicht verfügbar, weil er seit 07.01.2026 eine Altersprüfung verlangt (`docs/log.md`, Compliance-Digest).

| Minute | Erleben | Problem | Schwere |
|---|---|---|---|
| 0–1 | Die Freunde joinen. Fall A: Beide sind neu und starten zusammen. Fall B: Ein Freund ist schon auf E17, also irgendwo weit oben. | Im MVP gibt es keinen Freundes-Marker (Could, GDD §8/§9) und keinen Weg, sich zu finden. | **hoch** |
| 1–4 | Wettrennen über E1–E5. Ohne Kollision kann niemand schubsen (gut). | Fällt einer, landet er auf E0 bzw. E5, und der andere läuft weiter. Nach wenigen Minuten sind sie getrennt. | **hoch** |
| 4–6 | Einer wartet am Lager. | Am Lager gibt es außer dem Schrein nichts zu tun. Ohne Chat und ohne vordefinierte Gesten kann niemand „ich warte“ signalisieren. | mittel |
| 6–10 | Der erfahrene Freund will hinunter, um den Sprung vorzumachen, und springt ab. | Die Auffangzone (UX B1) teleportiert ihn zu **seinem** letzten Lager, also nach oben. Nach unten helfen ist unmöglich. | **hoch** |
| ~10 | Jeder spielt die DJ-Übungsstrecke für sich. Einer schafft sie, der andere nicht. | Die Pflicht-Sperre trennt die Freunde. Helfen geht nicht: keine Kollision, kein Tragen (korrekt nach C-A13). | mittel |
| 10–20 | Beide in Zone 2, auf verschiedenen Etagen. | Von 12 Spieler-Leuchtspuren ist die des Freundes nicht zu unterscheiden. | mittel |
| Seilschaft (Could) | +2 Funken, wenn beide ein Lager innerhalb von 20 s erreichen. | Den Bonus gibt es nur für **Roblox-Freunde**. Das schafft einen Anreiz, Fremden Freundschaftsanfragen zu schicken (Research §2.6, C-A5). +2 Funken sind außerdem zu wenig, um Verhalten zu prägen. | mittel |

**Fazit Social** `[SIMULIERT]`
- **Verständlichkeit ≤ 60 s:** Den Core Loop versteht der Spieler. Einen *gemeinsamen* Loop gibt es im MVP nicht.
- **Frust-Stellen:** Trennung, kein Wiederfinden, kein Helfen.
- **Leerlauf:** Warten am Lager.
- **Belohnungsrhythmus:** läuft für jeden einzeln. Gemeinsame Momente entstehen nur zufällig.
- **Würde ich wiederkommen?** **Nein** als Gruppe. Einzeln wie der Casual-Spieler.
- **Ist der Social-Teil ohne Chat tragfähig?** **Im MVP nicht.** Er wird tragfähig für 1–2 Freunde mit:
  - Freundes-Marker
  - Lager-Lift
  - drei vordefinierten Signalen (laut C-A4 erlaubt)
  - einer gemeinsamen Lager-Feier
- **Drei größte Schwachstellen** (alle P-07, dazu P-16):
  1. Die Freunde finden sich nicht wieder.
  2. Abwärts helfen ist unmöglich.
  3. Es gibt kein Signal ohne Chat.

### 2.5 Exploiter (Remotes, Rejoin-Farming, Speedhack, Teleport, Bestenliste, Doppelkauf, Spam)
*Annahmen:* Der Exploiter nutzt einen Executor und einen Remote-Spy. Ziele: schnell nach oben, Bestzeit bzw. Tagesturm-Platz 1, Funken, Kosmetik, Störung.

| # | Angriffsweg | Vorgehen | Abwehr laut Design | Lücke | Schwere |
|---|---|---|---|---|---|
| E1 | Remote-Fuzzing | NaN/±inf, falsche Typen, zusätzliche Argumente an alle 7 Remotes | NetService (Tech §3): Argumentzahl, `typeof`, `isfinite`, Enums | gedeckt ✓ | gering |
| E2 | Remote-Spam | 1 000 Aufrufe/s | Token Bucket je Remote, Kick erst ab > 10× Limit | gedeckt ✓ | gering |
| E3 | Funken aus der Ferne | `CollectSpark` mit fremden IDs | Distanz ≤ 8 Studs + Toleranz, Etage ≤ plausibel + 1 | Die Position meldet der Client. Teleport an den Funken gilt als gültig, ebenso Bonusfunken ohne die nötige Fähigkeit. | gering (betrifft nur eigene Währung) |
| E4 | Rejoin-Farming Funken | sammeln, rejoinen, erneut sammeln | `run.collected` überlebt den Rejoin | gedeckt ✓ | – |
| E5 | Bonus-Farming Lager/Gipfel | Respawn oder Rejoin am Lager E25, dann erneut zum Gipfel | „+5 beim ersten Erreichen pro Lauf“, „+50 pro Lauf“ (GDD §6.1) | Das Schema (Tech §6.4) hat **kein Feld** für eingelöste Boni und keinen Endzustand für den Lauf. +50 je Wiederholung (~1 min) ergeben etwa das doppelte normale Einkommen. Auch `summits` steigt mit, also sind Meilenstein-Kosmetiken (3/10 Gipfel) farmbar. | mittel |
| E6 | Neuer Lauf als Reset | `StartNewRun` direkt nach dem Gipfel, dann nur Zone 1 farmen | 1 Aufruf je 10 s, nur am Turmfuß | Das Einkommen entspricht etwa einem normalen Lauf, also kaum Gewinn. „Höchste plausible Etage“ steht im Schema aber nur als Allzeitwert (`progress.highestFloor`) und nicht pro Lauf. | gering |
| E7 | Speedhack | `WalkSpeed` lokal ×1,45 (vor Dash) bzw. bis ×4,5 (nach Dash) | Grenze max(WalkSpeed·Upgrades, Dash)·1,5 = 72 Studs/s je 0,5-s-Probe | Ist Dash freigeschaltet, sind **dauerhaft 72 Studs/s** erlaubt; der legitime Höchstwert liegt bei 33,9 Studs/s (§4.2). Vorher bleibt 1,5× unentdeckt. Die Mindestzeit „Weg ÷ Höchstgeschwindigkeit“ rechnet mit 48 Studs/s und ist damit wertlos. | **hoch** (Bestzeit/Tagesturm) |
| E8 | Teleport/Fly | horizontal in 36-Studs-Schritten, vertikal ≤ 13 Studs je Probe; schweben | Höhengewinn je Probe ≤ DJ-Höhe + Toleranz; Sprung über > 1 Etage = Verstoß | Wer Etage für Etage teleportiert, bleibt unter allen Grenzen (~1 s je Etage, der ganze Turm in < 1 min). **Schweben wird gar nicht geprüft.** | **hoch** |
| E9 | Infinite Jump vor DJ-Freischaltung | Sprung in der Luft wiederholen | Höhengrenze „mit Doppelsprung“, unabhängig von der Freischaltung | wird nicht erkannt | mittel |
| E10 | Freischaltung per Teleport | Teleport ins Lager E20 bzw. auf den Gipfel | Es wird nur `run.flagged` gesetzt (Tech §6.6) | Dash, Gipfel-Bonus und Gipfel-Leuchtspur gibt es trotzdem: „erspielt“, ohne gespielt zu haben. | mittel |
| E11 | Doppelkauf | 4× `RequestUpgrade` parallel | Transaktions-Lock, Knopfsperre (UX B3), 2/s | Gedeckt ✓. Aber `glide` und `wallJump` werden als IDs angenommen, obwohl sie im MVP Should sind. | gering |
| E12 | Effekt-Spam | `RequestRespawn` 1/s am Lager | Rate-Limit | Wer `FeedbackEvent` empfängt, ist nicht spezifiziert. Sehen alle Spieler die Lager-Feier bzw. die „Plopp“-Wolke, gerät das Partikelbudget (≤ 25 Emitter, Tech §5) bei 12 Spielern unter Druck, und andere werden gestört. | mittel |
| E13 | Bestenliste Tagesturm | E7 und E8 kombinieren | „nur Läufe ohne Plausibilitätsverstoß“ (GDD §8) | Die Flags greifen nicht (E7/E8), also ist der Exploiter im Server immer auf Platz 1. | **hoch** (Should-Feature) |
| E14 | Telemetrie-Vergiftung | `ReportAbilityUsed` (success), `ClientPerf` und Funnel-Schritt 4 fälschen | Rate-Limit, Bitmaske | H6 und die Performance-KPIs lassen sich vom Client aus verfälschen. | gering |
| E15 | Seilschaft-Farming (Could) | Zwei Konten respawnen abwechselnd am Lager. | „innerhalb von 20 s“ | Ohne die Regel „einmal pro Lager und Lauf“ ist der Bonus farmbar. | mittel (falls gebaut) |

**Fazit Exploiter** `[SIMULIERT]`
- **Verständlichkeit:** Mit einem Remote-Spy liegt die Remote-Liste nach ~2 min offen.
- **Stark:**
  - Es gibt keinen Handel, keine Robux und kein globales Ranking, also wenig Beute.
  - Die Remote-Validierung ist vollständig.
  - `run.collected` verhindert das klassische Rejoin-Farming.
- **Schwach:**
  - Die Bewegungsprüfung lässt Speed, Teleport, Fly und Infinite Jump durch.
  - Der Lauf-Zustand fehlt im Schema.
  - Belohnungen werden trotz Flag vergeben.
- **Würde ich wiederkommen?** **Vielleicht.** Solange die Tagesturm-Bestenliste und die Gipfel-Kosmetik ohne echte Prüfung zu holen sind, ja. Sonst gibt es kaum Beute.
- **Drei größte Schwachstellen:**
  1. Die Bewegungs-Plausibilität (P-06)
  2. Der Lauf-Zustand bzw. Bonus-Farming (P-11)
  3. Effekt-Spam für andere Spieler (P-15)

---

## 3. Gesamtliste der Probleme (nach Schweregrad)

Jeder Eintrag nennt einen konkreten Vorschlag und das betroffene Dokument. Wer was macht: GD = Game Designer, UX = Level- & UX-Designer, SE = Systems Engineer, CO = Compliance, DA = Data Analyst.

### 3.1 Hoch

| ID | Problem | Konkreter Verbesserungsvorschlag | Dokument / Abschnitt | Personas |
|---|---|---|---|---|
| **P-01** | **Rücksetzung nur auf das Lager (alle 5 Etagen), und die Hilfe zählt pro Etage.** Ein Fall kostet bis zu 4 Etagen (~2–3 min). Die Wiederholung bringt keine Funken. Die Leuchtspur kommt erst nach 5 Wiederholschleifen (~6–8 min), die Hilfsstufen nach 10 (~15 min). Im Zeitmodell braucht der Neuling bis zum Gipfel ~52 min statt 18–20 min (§4.3). Casual-Sessions enden ab Zone 2 regelmäßig vor dem nächsten Lager. | Einen **Etagen-Rücksetzpunkt** einführen: Wer unter die Basis der aktuellen Etage fällt (y < Etagenbasis − 4), landet nach ≤ 1,5 s am **Anfang dieser Etage**. Das zählt als 1 Fehlversuch. Die Lager bleiben Speicherpunkt, Schrein und Rejoin-Ort. Hilfe nach **3/6** statt 5/10 Fehlversuchen; die H2-Varianten entsprechend auf 3 gegen 6 setzen. Schema: `run.checkpointFloor` (Etage) und `run.campFloor` (Lager) trennen. Optional für Könner: Schalter „Lager-Modus“ (klassisch). Gewinn im Modell: Gipfel nach ~29 min statt ~52 min (Neuling) bzw. ~24 min statt ~33 min (9–14). | GDD §3.1, §3.2, §6.3, §7, §10 (H2); UX B1 (Fallschutz), B4 (Fehlsprung); Tech §6.4 | Neuling, Casual, Social |
| **P-02** | **Die Sicherheitsfaktoren gelten je Achse und nicht für die Flugbahn.** Eine Lücke mit maximaler Weite *und* maximalem Anstieg verlangt kombiniert 66 % (Z1), **90 % (Z2), 100 % (Z3) und 111 % (Tagesturm)** der echten Reichweite (§4.2). Damit sind Z3-Sprünge nur pixelgenau schaffbar und Tagesturm-Sprünge unmöglich, obwohl der Erreichbarkeitsprüfer Lösbarkeit garantieren soll. | Den Faktor auf einen **Referenzcharakter** anwenden: WalkSpeed·f, JumpHeight·f, DJ·f, Dash·f. Mit diesem Charakter die **Flugbahn simulieren**, inklusive Hitbox (≈ 2 × 5 × 1 Studs `[VORWISSEN, nicht aktuell]`), Kopffreiheit, Eingabelatenz von 0,1 s und realistischem DJ-Zeitpunkt (Scheitel ± 0,1 s statt Optimum). Grenzfälle als Unit-Tests aufnehmen: „max. Weite + max. Anstieg“ je Zone. | Tech §6.3; GDD §2 (S4), §5 (Regeln) | alle Spielenden |
| **P-03** | **Das Dash-Modell ist widersprüchlich und öffnet keine eigenen Lücken.** GDD §5 nennt ≈ 2× WalkSpeed (32 Studs/s, 8 Studs), Tech §6.3 nennt 48 Studs/s (12 Studs). Mit Schwerkraft reicht Sprung + Dash höchstens 18,0 Studs (48) bzw. 14,0 Studs (32); der DJ allein schafft schon 16,7. „Dash Pflicht ab Zone 3“ geht also nur als **Dreifach-Kombo** Sprung → DJ → Dash (16,7–19,8 Studs). Die Übungsstrecke lehrt aber Dash allein. Auf Touch heißt das 3 Eingaben auf 2 Knöpfen. | (1) **Einen Wert festlegen**, Empfehlung 48 Studs/s, und Schwerkraft während der 0,25 s **ausschalten** („Schwebe-Dash“, §4.2: 20,7 Studs am Scheitel). (2) Dash-Pflicht vor allem über die **Form** statt über die Weite erzwingen: niedrige Decke bzw. Tunnel, in dem Springen nicht hilft, oder eine Windwand, die nur Dash durchbricht. (3) Die Übungsstrecke lehrt genau die Kombination, die Zone 3 verlangt, in zwei Stufen (erst Dash, dann Sprung + Dash). (4) „Pflicht-Fähigkeit“ im Prüfer definieren: Die Lücke ist *ohne* die Fähigkeit mit dem großzügigen Modell unlösbar und *mit* ihr mit dem konservativen Modell lösbar. (5) Touch-Hilfe: Dash am Boden löst einen kleinen Hüpfer plus Dash aus (eine Taste statt zwei). | GDD §4 (Zone 3), §5; Tech §6.3; UX B2, B4 | Neuling, Casual, Grinder |
| **P-04** | **Kopffreiheit und Kamera im gestapelten Turm.** Die Etagenhöhe ist 16 Studs. Im DJ-Scheitel stehen die Füße bei +13,3 Studs, der Kopf bei ≈ +18 Studs: Kopfstoß an der nächsten Etage, der Sprung misslingt. Die Standard-Kamera hinter und über dem Spieler stößt an Decke und Säule und springt (Popper-Verhalten `[VORWISSEN, nicht aktuell]`). Auf kleinen Handys wirkt das desorientierend. | (1) **Helix-Layout mit freiem Luftraum:** Jede Etage liegt im nächsten 90°-Sektor, sodass der Pfad erst nach 4 Etagen (64 Studs) überdeckt wird. Alternativ in Zone 2/3 eine Etagenhöhe von 24 Studs. (2) Der Erreichbarkeitsprüfer testet Kopffreiheit ≥ 20 Studs über jeder DJ-Bahn. (3) Eigene Verfolgerkamera mit fester Neigung (~35°), Zoom-Untergrenze und Ausblenden verdeckender Teile per `LocalTransparencyModifier` statt Heranzoomen. Gehört in den Owner-Test von Sprint 1 (GDD §12.2). | UX B1 (Turmform), B6.1; GDD §12.2; Tech §6.2, §6.3 | Neuling, Casual, Social |
| **P-05** | **Doppelsprung ohne Text lernen, dazu eine Pflicht-Übung ohne Hilfe.** DJ hat keinen eigenen Knopf, und UX B4 („Knopf erscheint mit Puls“) gilt nur für Dash. Schnelles Doppeltippen (< 0,14 s nach dem Absprung) verfehlt die Z2-Lücken (9,5–10,8 statt 11,7 Studs). `JumpRequest` kann bei gehaltenem Knopf mehrfach feuern `[VORWISSEN, nicht aktuell]`, sodass der DJ ungewollt verpufft. Coyote-Time und Sprungpuffer fehlen. „Keine Weiterreise ohne geschaffte Übung“ ohne Hilfe ist eine Sackgasse. | (1) Der Sprungknopf zeigt in der Luft ein pulsierendes „2×“, sobald DJ möglich ist. Ein Geist zeigt den Ablauf einmal vor. (2) DJ nur auf eine **neue Drück-Flanke** (IAS „Pressed“) auslösen. Eine zu frühe Eingabe wird gepuffert und frühestens 0,15 s nach dem Absprung ausgeführt. (3) **Coyote-Time 0,12 s** und **Sprungpuffer 0,1 s** für alle Sprünge. (4) Die Übungsstrecke bekommt eigene Hilfestufen: nach 3 Fehlversuchen Vorführung, nach 6 eine Hilfsplattform. **Nie eine Sackgasse.** | GDD §5, §7; UX B4; Tech §6.1 (MovementController) | Neuling, Casual |
| **P-06** | **Die Bewegungs-Plausibilität ist praktisch wirkungslos.** Nach der Dash-Freischaltung erlaubt sie dauerhaft 72 Studs/s (4,5× Gehen), legitim sind höchstens 33,9 Studs/s je 0,5-s-Fenster. Vorher bleibt ein 1,5-facher Speedhack unentdeckt. Die Höhengrenze gilt „mit DJ“ auch vor der Freischaltung (Infinite Jump). Schweben wird nicht geprüft. Die Mindestzeit rechnet mit der Dash-Geschwindigkeit. Freischaltungen, Gipfel und Kosmetik werden trotz Flag vergeben. Folge: Tagesturm-Bestenliste und Bestzeit sind wertlos. | (1) **Fensterbudget:** Weg in 0,5 s ≤ WalkSpeed·Upgrades·0,5·1,15, plus 8 Studs Dash-Zusatz nur dann, wenn Dash laut Server-Abklingzeit verfügbar war. Förderband- und Plattformgeschwindigkeit aus den Generatordaten addieren. (2) Höhengrenze nach den **freigeschalteten** Fähigkeiten. (3) Luftzeitgrenze: > 1,5 s ohne Bodenkontakt (ohne Gleiter) gilt als Verstoß. (4) Mindestzeit je Abschnitt aus einer **Pfad-Simulation** des Generators mit Basiswerten × 0,8. (5) Freischaltung, Lager-Bonus, Gipfel und Kosmetik nur bei **lückenloser Etagenfolge**. Teleport-Sprünge zählen nicht als Erreichen. (6) Vor dem Bau der Bestenliste einen Spike zu Roblox „Server Authority“ machen (Tech §6.6). Bis dahin nur die persönliche Bestmarke zeigen und keine fremden Einträge, auch nicht über die PlayerList (GDD §8, C-A16). | Tech §3 (Bewegungs-Plausibilität), §6.5, §6.6; GDD §8 | Exploiter, indirekt alle |
| **P-07** | **Der Social-Teil ist ohne Chat im MVP nicht tragfähig.** Freundes-Marker und Seilschaft sind Could. Nach dem ersten Fall trennen sich die Freunde. Die Auffangzone verhindert, dass ein Freund nach unten geht, um zu helfen. Für die meisten Kinder gibt es keinen Chat, und es gibt kein vordefiniertes Signal. | Ins **Must** (geringer Aufwand): (1) **Freundes-Marker** (farbiger Ring + Icon über dem Kopf, auch durch Wände sichtbar). (2) **Lager-Lift:** An jedem Lager kann man per Teleport zu jedem *selbst erreichten* Lager wechseln; „Zum Freund“ führt nur zu Lagern, die man selbst schon erreicht hat (kein Überspringen). (3) **Drei vordefinierte Signale** (Winken, Daumen hoch, „Hier!“-Ping) nach C-A4, ohne Text. (4) Erreichen beide in kurzer Zeit dasselbe Lager, gibt es eine **gemeinsame Lager-Feier** (rein visuell). Vorab von CO prüfen lassen. | GDD §2 (S5), §8, §9; UX B2; Compliance C-A4, C-A13, C-A17 | Social, Neuling |
| **P-08** | **Der Langzeit-Loop des MVP ist leer.** Der Seed ist fest, also sind Lauf 2–4 identisch. Die Must-Senken (685 Funken) sind nach Lauf 3–4 (~40–50 min) aufgebraucht. Tagesturm, Gleiter, Wandsprung, Funkenrouten und Kosmetik sind Should oder Could. Danach sind Funken wertlos, und S4 „Vielfalt aus Regeln“ ist für den Spieler unsichtbar. | (1) **Fester Seed nur für Lauf 1 und den Tagesturm**, ab Lauf 2 `seed + runIndex` (jeder Seed ist vom Prüfer abgesichert). Das hält die Vergleichbarkeit im Onboarding und bringt Vielfalt danach. (2) **Lebenszeit-Funken-Meilensteine** (`lifetimeSparks` existiert schon) mit 3–5 erspielten Leuchtspur-Farben als „Must-light“. (3) Den Gleiter als Ziel für Lauf 2 ins Must holen, oder den Tagesturm ohne Bestenliste ins MVP. (4) H4 erst messen, wenn mindestens eins davon live ist. | GDD §3.3, §4, §6.1, §6.2, §9, §12.1; Tech §6.4 | Grinder, Casual |

### 3.2 Mittel

| ID | Problem | Konkreter Verbesserungsvorschlag | Dokument / Abschnitt | Personas |
|---|---|---|---|---|
| P-09 | **Die visuelle Führung kollidiert mit sich selbst.** Zone 2 ist weiß auf weiß mit Nebel. Es gibt **vier Arten „Leuchtspur“** mit unterschiedlicher Bedeutung: Onboarding-Beam, Hilfe-Geistpfad, Spielerspuren, Gipfel-Kosmetik. Dazu ist überall Neon. Damit bricht die Regel „Ziel = hellstes Objekt“. | Eine **reservierte Führungssprache**: goldene Chevron-Pfeile am Boden, nur für Führung und Hilfe. Spielerspuren dünn, kurz (≤ 1 s) und nie in der Führungsfarbe, mit Option „Spuren anderer ausblenden“. Zone-2-Plattformen bekommen eine dunkle Unterseite bzw. Kontur, Nebel erst ab ~120 Studs. Neon nur für Ziele, Deko in SmoothPlastic. | UX A5, B1, B2, B5, B6.3; GDD §4 (Art-Stil), §6.3, §8 | Neuling, Social |
| P-10 | **Dynamische Module fehlen im Erreichbarkeitsmodell:** bewegliche Plattformen, Wolken, Kippblöcke, Taktplatten, Wind, Förderbänder, Sprungpads. Auch die Dash-Abklingzeit (2,5 s) zwischen aufeinanderfolgenden Dash-Lücken fehlt. Die Lösbarkeitsgarantie gilt nur für statische Lücken. | Regeln je Modul: Wartefenster ≥ 1,5 s; keine Pflichtsprünge in Gegenwind; Abstand zwischen Dash-Lücken ≥ Basis-Abklingzeit + 1 s; Förderband-Sprünge nur in Bandrichtung. Takt- und Wolkenanimation clientseitig synchron über `workspace:GetServerTimeNow()`, damit hoher Ping nicht bestraft wird. | Tech §6.2, §6.3 | Neuling, Casual |
| P-11 | **Der Lauf-Zustand im Schema ist unvollständig.** Es fehlen eingelöste Lager-Boni, der Gipfel-Abschluss, die höchste Etage *des Laufs* und der Zustand der Übungsstrecke. Folgen: Bonus- und Gipfel-Farming (E5), Meilenstein-Kosmetik farmbar, Funken-Plausibilität unklar (E6). | `run` ergänzen um `highestFloor`, `campsClaimed` (Bitmaske), `state` („climbing“/„summited“) und `practiceDone` (Bitmaske). Der Gipfel schließt den Lauf atomar ab: `summits++`, Bonus, `state = summited`; ein neuer Lauf startet nur über das Tor. Funken nur mit Etage ≤ `run.highestFloor` + 1. Tests für Rejoin/Respawn-am-Lager/Gipfel-Wiederholung. | Tech §6.4, §6.5; GDD §6.1 | Exploiter, Casual |
| P-12 | **Upgrades sind kaum spürbar.** +6 % Sprunghöhe sind +0,43 Studs bzw. +3 % Weite, +8 % Tempo sind 1,3 Studs/s. Der Schrein pulsiert bei *jedem* leistbaren Upgrade. In der Simulation kauft ein „gieriges“ Kind deshalb den Gleiter erst in **Lauf 4 statt Lauf 2** (§4.1). | Weniger, größere Stufen, z. B. Tempo +10/+20/+30 %, Sprung +8/+16/+24 %. Die Lösbarkeit mit Basiswerten bleibt; die Toleranzen in P-06 wachsen mit. Wirkung **zeigen**: eine Messlatte am Schrein mit Geist-Sprung „vorher/nachher“ und ein Stufen-Ring an den Füßen. Puls nur für ein „empfohlenes nächstes Ziel“ und eine Spar-Anzeige für den Gleiter („✦ 96/150“). | GDD §5, §6.2; UX B3 | Neuling, Grinder |
| P-13 | **Der Gipfel ist vom Spawn aus nicht sicher sichtbar.** Gründe: Streaming, Bau nur naher Etagen, Selbstverdeckung von unten. Das trifft S1 direkt. | Ein **persistentes Gipfel-Leuchtfeuer** aus 1–3 Neon-Parts plus Lichtsäule über dem Turm, `ModelStreamingMode = Persistent`, unabhängig vom `TowerBuilder`. Der Spawn liegt mit freier Blickachse ~40 Studs neben dem Turm. Im Owner-Test auf dem kleinsten Android-Gerät prüfen. | UX B1, B4; Tech §5 (Streaming), §6.1 | Neuling, alle |
| P-14 | **Wiedereinstieg für Casual-Spieler.** Ab Zone 2 ist eine Session kürzer als ein Abschnitt. Es gibt kein Signal „hier weiter“. Was nach einem Abbruch in der Übungsstrecke passiert, ist offen. | P-01 löst den Kern. Zusätzlich: Beim Rejoin leuchtet der Pfad zur nächsten Plattform 3 s lang auf (der Onboarding-Beam wird wiederverwendet). Eine absolvierte Übung wird gespeichert (`practiceDone`). Die Kamerafahrt beim Spawn gibt es nur beim ersten Join. | UX B4 (Rejoin); GDD §3.2; Tech §6.4 | Casual |
| P-15 | **Fremd-Effekte und Respawn-Spam.** Wer `FeedbackEvent` empfängt, ist offen. Lager-Feier und „Plopp“ bei jedem Respawn sind für alle sichtbar, was bei 12 Spielern Störung und Partikellast (≤ 25 Emitter) bedeutet. | Feier nur beim **ersten** Erreichen eines Lagers pro Lauf; ein Respawn löst keine Feier aus. Fremd-Effekte gedrosselt (≤ 1/s je Spieler) und auf Low-End reduziert. Eigene Effekte haben Vorrang. | Tech §6.5; UX B5 | Exploiter, Neuling (Low-End) |
| P-16 | **Die Seilschaft hängt an der Roblox-Freundschaft.** Das schafft einen Anreiz, Fremden Freundschaftsanfragen zu schicken (Research §2.6 Grow-a-Garden-Muster, C-A5). +2 Funken sind zu wenig als Motiv. | Den Bonus für **alle** Spieler vergeben, die ein Lager innerhalb von 20 s gemeinsam erreichen (keine Freundschaft nötig), höchstens einmal pro Lager und Lauf. Alternativ nur eine gemeinsame visuelle Feier ohne Funken. **CO erneut prüfen lassen** (C-A17). | GDD §8; Compliance C-A5, C-A17 | Social |
| P-17 | **Dokument-Inkonsistenzen** (Stand nach Commit `825197d`; §11, C-A16 in §8 und das Gewitter-Verhalten sind dort bereits bereinigt): (a) Die Gipfel-Leuchtspur ist Belohnung in §6.2, Kosmetik ist aber Could in §9. (b) „2–4 Bonusfunken“ pro Etage oder pro Route? (c) Dash 2× oder 48 Studs/s (P-03). (d) §3.3 und §9 sprechen noch von „Server-Bestenliste“, §8 von persönlicher Bestmarke plus Roblox-PlayerList. (e) Die Seilschaft heißt in §8 weiter „Freunde im selben Server“; C-A17 untersagt nur die Kopplung an Einladen (P-16). | GD gleicht ab: Gipfel-Leuchtspur ins Must (eine Spur) oder aus §6.2 streichen; die Einheit für Bonusfunken festlegen; den Dash-Wert vereinheitlichen; den Begriff „Bestenliste“ in §3.3 und §9 an §8 angleichen. | GDD §3.3, §5, §6, §8, §9; Tech §6.3 | – |
| P-18 | **Die Zeittabelle im GDD §6.2 ist zu optimistisch.** Übungsstrecken (E10, E20), Schreinbesuche und Rücksetzverluste sind nicht eingerechnet. Das Modell ergibt für die Zielgruppe 9–14 bis zum Gipfel ~33 min (P90 ~42 min) statt 18–20 min (§4.3). Folge: falsche Erwartung bei KPIs wie der Sessiondauer. | Die Tabelle nach P-01 neu kalibrieren (Modell: ~24 min) und für Zone 3 eine **längere** Etagenzeit ansetzen als für Zone 2, nicht eine kürzere. Owner-Playtest-Zeiten als Quelle eintragen (`[GETESTET]`). | GDD §6.2; Telemetrie §2 | alle |

### 3.3 Gering

| ID | Problem | Konkreter Verbesserungsvorschlag | Dokument / Abschnitt |
|---|---|---|---|
| P-19 | Das Wort „Kaufen“ im Schrein weckt bei Kindern und Eltern Echtgeld-Assoziationen. | Knopf „Tauschen“ mit ✦-Icon, Lokalisierungsschlüssel `shrine.trade`. | UX B3 |
| P-20 | Bei einer Sammelquote < 70 % ist Sprungkraft I (25) am Lager E5 nicht leistbar (60 %: 18 + 5 = 23). Dann pulsiert der Schrein nicht, und der Funnel-Schritt `FirstUpgrade` verschiebt sich auf E10. | Sprungkraft I auf 20 senken oder den ersten Lager-Bonus auf +10 erhöhen. | GDD §5, §6.2 |
| P-21 | Client-gemeldete Telemetrie (`AbilityResult`, `ClientPerf`, Schritt 4) ist fälschbar und verzerrt H6. | Erfolg serverseitig bestimmen (Landung auf der Zielplattform aus der Positionsprobe). Clientwerte auf Plausibilität kappen und separat markieren. | Telemetrie §3.4; Tech §6.5 |
| P-22 | `elapsedSeconds` „pausiert bei Abwesenheit“: Was als Abwesenheit gilt (Verlassen? AFK?), ist undefiniert. | Definieren: Die Zeit läuft nur, solange der Spieler im Server ist und sich in den letzten 30 s bewegt hat. Das per Test absichern. | Tech §6.4 |
| P-23 | `RequestUpgrade` nimmt `glide` und `wallJump` an, obwohl sie im MVP Should sind. | Per Feature-Flag serverseitig ablehnen. Den Validator aus der Feature-Liste ableiten. | Tech §6.5 |
| P-24 | Gleiter „Sprung halten“ kollidiert mit dem DJ („erneut drücken“) und mit dem Auto-Wiedersprung bei gehaltenem Knopf `[VORWISSEN, nicht aktuell]`. | Den Gleiter erst *nach* verbrauchtem DJ und nur in der Fallphase aktivieren (vy < 0, gehalten ≥ 0,2 s). | GDD §5 |
| P-25 | AutoJump auf Touch (Roblox-Standard `[VORWISSEN, nicht aktuell]`) kann an Säule und Wänden ungewollte Sprünge auslösen. | Bewusst entscheiden (Empfehlung: in Zone 1 an, ab Zone 2 aus) und im Gerätetest prüfen. | UX A4, B2 |
| P-26 | Hilfsstufen: Sind sie lokal oder für alle sichtbar? Gelten sie auch in Übungsstrecke und Tagesturm? | Nur lokal erzeugen, für den betroffenen Spieler. Auch in der Übungsstrecke. Im Tagesturm erlaubt, aber mit „Hilfe genutzt“-Symbol in der Bestmarke. | Tech §6.2; GDD §6.3 |
| P-27 | Fremde Avatare ohne Kollision stehen auf der Zielplattform und verdecken die Kante. | Fremd-Avatare im Umkreis von 6 Studs halbtransparent darstellen (`LocalTransparencyModifier`). | UX A5, B2 |
| P-28 | Die Audio-Entscheidung ist offen. Ohne Ton halbiert sich die Feedback-Dichte, der wichtigste Spaßhebel (UX A5). | Bis Sprint 1 vom Owner entscheiden lassen (Roblox-eigene Standardklänge?), sonst ein Fallback mit stärkerem visuellem und haptischem Feedback. | GDD §12.3; UX B5 |
| P-29 | Für den KPI „Median-Guthaben bei Etage 30 zwischen 100 und 300“ ist der Messzeitpunkt unklar. Ein gieriger Käufer liegt nach dem Gipfelkauf bei ~34. | Messpunkt „vor Gipfel-Bonus und vor Käufen“ festlegen. | Telemetrie §2 |

---

## 4. Economy- und Bewegungsmodell-Check (mit Rechnung)

### 4.1 Economy `[EIGENE RECHNUNG]`
**Grundwerte (GDD §6.1):**
- 6 Funken pro Etage auf dem Hauptweg, Sammelquote 80 %, also 4,8 pro Etage
- Lager E5, E10, E15, E20, E25 mit je +5
- Gipfel +50
- Bonusrouten erst mit Gleiter/Wandsprung (Should), daher im ersten Lauf 0

| Meilenstein | GDD §6.2 (kumuliert) | Rechnung (80 %) | Bewertung |
|---|---|---|---|
| E1 | ~5 | 4,8 | ✓ |
| E5 | ~25 (+5) | 24 + 5 = 29 | ✓. Bei 60 % Sammelquote: 18 + 5 = 23 < 25, also P-20 |
| E10 | ~55 | 48 + 10 = 58 | ✓ |
| E15 | ~85 | 72 + 15 = 87 | ✓ |
| E20 | ~120 | 96 + 20 = 116 | ✓ |
| E30 Gipfel | ~190 (+50) | 144 + 25 = **169** (+50) = 219 | ✗ −21. Die 190 setzen Bonusrouten voraus, die es im ersten Lauf (und im MVP) nicht gibt. |

**Einkommen pro Lauf.** Das GDD nennt ≈ 230. Die Rechnung ergibt:

| Annahme | Funken pro Lauf |
|---|---|
| 80 % Sammelquote | 219 |
| 100 % Sammelquote | 255 |
| 100 % + 3 Routen à 3 | 264 |
| 100 % + „2–4 pro Etage“ | 345 |

Ob „2–4 Bonusfunken“ pro Etage oder pro Route gilt, ändert das Einkommen späterer Läufe um ~30 % (P-17e).

**Senken:**
- Sprung 25 + 60 + 120 = 205
- Tempo 30 + 70 + 140 = 240
- Dash-Abklingzeit 80 + 160 = 240
- **Summe Must: 685**, mit Gleiter 835, mit Wandsprung **1 035** ✓ (stimmt mit GDD)

**Laufanzahl:**
- 1 035 ÷ 230 ≈ 4,5 Läufe ✓
- Zeit: 20 + 4 × 9 ≈ 56 min, also am unteren Rand von „~1–1,5 h“ ✓

**Kauf-Simulation** (Spieler kauft an jedem Lager und am Gipfel sofort das billigste leistbare Upgrade, entsprechend dem Schrein-Puls):

| Szenario | Alles gekauft in | Gleiter gekauft in |
|---|---|---|
| 80 %, nur Must-Senken (MVP) | Lauf 4, E5 (≈ 40–50 min) | – |
| 100 %, nur Must-Senken (MVP) | Lauf 3, E25 | – |
| 80 %, mit Should-Senken | Lauf 5, Gipfel | **Lauf 4, E5** (GDD: Lauf 2) |
| Sparer (kauft im ersten Lauf nur 2 Upgrades) | – | Ende Lauf 1 ✓ |

Verlauf beim „gierigen“ Käufer (80 %):

| Lauf / Etage | Kauf | Restguthaben |
|---|---|---|
| L1 E5 | Sprung I (25) | 4 |
| L1 E10 | Tempo I (30) | 3 |
| L1 E20 | Sprung II (60) | 1 |
| L1 Gipfel | Tempo II (70) | 34 |
| L2 E10 | Dash I (80) | – |
| L2 Gipfel | Sprung III (120) | – |
| L3 E15 | Tempo III (140) | – |
| L4 E5 | Gleiter (150) | – |

**Ergebnis:**
- Economy und Balancing-Tabelle passen **rechnerisch im Großen**: Die Kosten von 1 035 Funken entsprechen 4–5 Läufen.
- Drei Brüche gibt es:
  1. Der Gipfel-Wert ist um ~21 Funken zu hoch.
  2. „Gleiter in Lauf 2“ gilt nur für Sparer; der pulsierende Schrein erzieht aber zum Sofortkauf (P-12).
  3. **Im Must-only-MVP sind die Senken nach ~40–50 min leer** (P-08).
- Die Tabelle beschreibt also den MVP mit Should-Features, nicht den MVP, wie er in §9 definiert ist.

### 4.2 Bewegungsmodell und Zonen-Designs `[EIGENE RECHNUNG]`
**Basis (Tech §6.3):**

| Größe | Rechnung | Wert |
|---|---|---|
| Schwerkraft | g | 196,2 Studs/s² |
| Absprunggeschwindigkeit | v₀ = √(2·196,2·7,2) | 53,15 Studs/s |
| Flugzeit (gleiche Höhe) | T = 2·v₀/g | 0,542 s |
| Reichweite Einzelsprung | R = 16·T | **8,67 Studs** |
| DJ-Impuls | v₁ = √(2·196,2·6,12) | 49,0 Studs/s |
| DJ-Gipfelhöhe | 7,2 + 6,12 | 13,32 Studs |

Für den DJ setze ich vy = v₁, nicht vy + v₁. Das Dokument sagt nicht, ob gesetzt oder addiert wird; das muss festgelegt werden.

**(a) Sicherheitsfaktoren je Achse gegen die echte Flugbahn**

| Zone | Faktor | max. Lücke | max. Anstieg | echte Reichweite bei max. Anstieg | kombiniert verlangt |
|---|---|---|---|---|---|
| Z1 | 0,55 | 4,77 | 3,96 | 7,24 | 66 % ✓ |
| Z2 | 0,70 | 6,07 | 5,04 | 6,71 | **90 %** ✗ |
| Z3 | 0,75 | 6,50 | 5,40 | 6,50 | **100 %** ✗ |
| Tagesturm | 0,80 | 6,94 | 5,76 | 6,27 | **111 % (unlösbar)** ✗ |
| Z2 mit DJ | 0,70 | 11,67 | 9,32 | 12,90 | 90 % ✗ |
| Z3 mit DJ | 0,75 | 12,50 | 9,99 | 12,50 | 100 % ✗ |

Wendet der Prüfer die Faktoren getrennt auf Weite und Höhe an (so liest sich Tech §6.3: „Anteil der theoretischen Reichweite/Höhe“), erzeugt er unfaire bzw. unlösbare Etagen. Abhilfe: P-02.

**(b) Doppelsprung-Lücken in Zone 2**

Die Reichweite hängt stark vom Zeitpunkt des zweiten Drückens ab (Sekunden nach dem Absprung):

| DJ gedrückt nach | Reichweite |
|---|---|
| 0,05 s | 9,52 Studs |
| 0,10 s | 10,82 Studs |
| 0,15 s | 11,97 Studs |
| Scheitel (0,271 s) | 14,23 Studs |
| kurz vor der Landung (0,531 s, Optimum) | **16,67 Studs** |

„Theoretische DJ-Reichweite“ ist im Dokument nicht definiert. Je nach Lesart ergibt sich:

- **Optimum als Referenz (16,67):** Die Z2-Höchstlücke ist 11,67. Der DJ muss im Fenster 0,137–0,540 s gedrückt werden, das ist **großzügig**. Wer aber schnell doppelt tippt (< 0,14 s), fällt. Bei Kindern ist das das Standardverhalten (P-05).
- **Scheitel als Referenz (14,23):** Die Z2-Höchstlücke ist 9,96, also nur das 1,15-Fache des Einzelsprungs. Mit Kantensprung und Hitbox (~1–2 Studs `[VORWISSEN, nicht aktuell]`) ist sie teils **ohne DJ** schaffbar. Die Lücke „verlangt“ den DJ dann nicht verlässlich, und die Lehrwirkung geht verloren.
- **Empfehlung:** DJ-Pflicht-Lücken mit 10,5–11,5 Studs Weite und höchstens 3 Studs Anstieg. Den DJ-Zeitpunkt im Referenzcharakter auf „Scheitel ± 0,1 s“ setzen und eine frühe Eingabe puffern (P-05).
- **Fazit:** Zone 2 passt zum Modell, sobald P-02 und P-05 umgesetzt sind.

**(c) Dash-Lücken in Zone 3**

| Variante | Schwerkraft im Dash an | Schwerkraft im Dash aus |
|---|---|---|
| Sprung + Dash, 32 Studs/s (GDD „≈ 2×“) | 14,02 | 18,47 |
| Sprung + Dash, 48 Studs/s (Tech) | 17,97 (Dash am Scheitel 16,68) | 22,48 (am Scheitel 20,69) |
| DJ allein (Vergleich) | 16,67 | 16,67 |
| Sprung + DJ + Dash, 48 Studs/s | max. 26,45; ×0,75 = 19,8; natürliches Timing (DJ am Scheitel, Dash am 2. Scheitel) 22,2 | max. 30,56 |

- **Mit dem GDD-Wert** bringt der Dash *weniger* Reichweite als der DJ. „Dash Pflicht ab Zone 3“ lässt sich dann über die Lückenweite nicht erzwingen.
- **Mit dem Tech-Wert und Schwerkraft** bringt der Dash nur +1,3 Studs mehr als der DJ.
- Echte Dash-Pflicht-Lücken liegen damit bei **16,7–19,8 Studs** und gehen nur als Kombination Sprung → DJ → Dash. Je nach Lücke gelingen 28–38 % aller Zeitpunkt-Kombinationen; das ist machbar, aber es sind 3 Eingaben auf 2 Touch-Knöpfen.
- **Fazit:** Das Dash-Design der Zone 3 passt **nicht** zum Modell (P-03).

**(d) Kopffreiheit:** Der DJ-Scheitel liegt bei Füßen +13,32 Studs, der Kopf (R15 ≈ 5 Studs hoch `[VORWISSEN, nicht aktuell]`) also bei ≈ +18,3 Studs. Das ist mehr als die Etagenhöhe von 16 Studs, also gibt es einen Kopfstoß, sobald über der Bahn Teile der nächsten Etage liegen (P-04). Das Modell enthält keine Kollision mit Decken.

**(e) Was im Modell sonst fehlt:**
- Bewegte, verschwindende und kippende Teile, Taktplatten, Wind, Förderbänder und Sprungpads (P-10)
- Dash-Abklingzeit zwischen Lücken (2,5 s Basis)
- Upgrades bleiben korrekt außen vor
- „Hilfsstufen halbieren die größte Lücke“ ist für die Weite in Ordnung: 19,8 → 9,9 Studs, mit DJ lösbar. Für Anstiege ist es nicht definiert.

**(f) Plausibilitätsprüfung (Tech §6.6)**

| Fall | Grenze | Legitimer Höchstwert | Spielraum für Cheater |
|---|---|---|---|
| vor Dash | 16 × 1,5 = 24 Studs/s (mit Tempo-Upgrades 29,8) | 16 (19,84) | 1,5× |
| nach Dash | max(19,84; 48) × 1,5 = **72 Studs/s** | 12 + 0,25 × 19,84 = 16,96 Studs je 0,5 s = **33,9 Studs/s** | 2,1× gegen den legitimen Höchstwert, **3,6–4,5×** gegen Gehen |
| vertikal | 13,32 + Toleranz je Probe | – | Teleport Etage für Etage (16 Studs) bleibt bei 2 Hz knapp darunter oder darüber, je nach Toleranz |

Schweben wird nicht geprüft. Die Mindestzeit „Weg ÷ 48“ ist kürzer als jede echte Zeit. Abhilfe: P-06.

### 4.3 Zeitmodell erster Lauf `[SIMULIERT]` mit Parametern `[ANNAHME]`
**Aufbau:** Monte-Carlo mit 3 000–4 000 Läufen je Profil.
- Je Etage gibt es eine Erstzeit und eine Fehlerwahrscheinlichkeit pro Versuch.
- Ein Fall kostet 30–90 % der Etagenzeit plus 1,5 s Respawn.
- Wiederholte Etagen laufen mit 60 % der Zeit.
- Die Hilfe halbiert die Fehlerquote nach 5 Fehlversuchen und viertelt sie nach 10.
- Zusatzzeiten: Kamerafahrt/Start 20 s, Schrein je 30 s, DJ-Bühne + Übung 75 s, Dash-Bühne + Übung 90 s.

| Profil (Etagenzeit Z1/Z2/Z3; Fehlerquote) | Rücksetzung | E10 | E20 | Gipfel (Median) | Gipfel P90 |
|---|---|---|---|---|---|
| Neuling 7–10 (35/45/50 s; 0,15/0,30/0,40) | nur Lager (GDD) | 9,3 min | 26,2 min | **52,2 min** | 73 min |
| | Etagen-Checkpoint (P-01) | 8,1 | 18,5 | **28,9** | 31 |
| Zielgruppe 9–14 (30/38/42 s; 0,10/0,20/0,28) | nur Lager (GDD) | 7,6 | 18,9 | **32,6** | 42 |
| | Etagen-Checkpoint | 7,2 | 15,9 | 24,2 | 25 |
| geübt 11+ (28/34/38 s; 0,05/0,12/0,18) | nur Lager (GDD) | 6,8 | 15,8 | 25,0 | 30 |
| | Etagen-Checkpoint | 6,8 | 14,6 | 21,8 | 23 |

**Lesart:**
- Die Rücksetzung auf das Lager wirkt wie ein Multiplikator auf die Fehlerquote. Ab Zone 2 dominiert sie die Spielzeit.
- Selbst das geübte Profil liegt über den 18–20 min aus GDD §6.2, weil Übungen und Schrein fehlen (P-18).
- Die Absolutwerte sind unsicher. **Robust** sind die Richtung und die Größe des Effekts, nämlich Faktor ~1,8 für den Neuling.

---

## 5. Gate-Einschätzung „Spielspaß“ (§5 Masterprompt) `[SIMULIERT]`

| Kriterium | Einschätzung | Begründung |
|---|---|---|
| Alle Personas verstehen den Core Loop in ≤ 60 s | **wahrscheinlich ja (4 von 5 sicher, Neuling bedingt)** | „Nach oben, Funken sammeln“ trägt ohne Text. Beim Neuling hängt es daran, ob der Gipfel sichtbar ist (P-13) und der Leuchtpfad funktioniert. Der *Upgrade*-Teil des Loops (Schrein) wird später und teils ohne Wirkung verstanden (P-12). Für den Social-Spieler gibt es keinen gemeinsamen Loop (P-07). |
| Keine Frust-Stelle „hoch“ offen | **nicht erfüllt** | 8 offene Probleme „hoch“ (P-01 bis P-08). Davon sind 4 direkte Abbruch- bzw. Sackgassen-Risiken für Neuling und Casual-Spieler: P-01, P-04, P-05 und P-03 (vorausschauend). |
| Evidenzgrad | **nicht ausreichend** | `[SIMULIERT]` kann ein Gate grundsätzlich nicht bestehen. Nötig ist `[GETESTET]` (§6). |

**Urteil: Gate „Spielspaß“ nicht bestanden.**

Das ist kein Votum gegen Konzept A. Die Kernidee trägt. Die „hoch“-Probleme sind fast alle Spezifikationsfehler, die sich vor Sprint 1 beheben lassen und keine Grundsatzfrage berühren.

**Empfehlung:**
- **Vor dem Bau von Sprint 1** einarbeiten: P-01, P-02, P-03, P-04 (Layout-Entscheidung), P-05 und P-11.
- **Sprint 2:** P-06, P-07 und P-08 einplanen.
- Danach eine erneute Simulation und den ersten echten Test (§6, Phase 1).

---

## 6. Plan für echte Tests vor dem öffentlichen Release (§1.7)

Ziel: Für einen Owner ohne Team machbar, mit Freunden und Familie, ohne Budget. Ergebnisse werden als `[GETESTET]` geführt, bei kleiner Stichprobe qualitativ und nicht statistisch.

### 6.1 Grundsätze
- **Vorbedingung C-A1:** Vor dem **ersten Zugang Dritter, auch für Playtests**, füllt der Owner den Maturity & Compliance Questionnaire aus und legt die Antworten versioniert ab (`docs/compliance/questionnaire.md`, GDD §11). Ohne das finden S1–S3 nicht statt.
- **Einwilligung:**
  - Bei Kindern immer mit schriftlichem Ja der Eltern (2 Sätze reichen); ein Elternteil ist anwesend.
  - Keine Gesichtsaufnahmen. Eine Bildschirmaufnahme nur mit Zustimmung; sie wird nach der Auswertung gelöscht.
  - Notizen nur mit Codes (T1, T2, …), ohne Namen. Personenbezogenes kommt nicht ins Repo.
- **Konten:**
  - Keine Konten für fremde Kinder anlegen.
  - Entweder spielen die Kinder auf Geräten des Owners mit dessen eigenem Test-Konto, oder die Eltern loggen das Kinderkonto selbst ein. Kontoregeln und Altersgrenzen vorab im Original prüfen `[VORWISSEN, nicht aktuell]`.
- **Testumgebung:**
  - Ein **eigenes Test-Universe bzw. ein eigener Test-Place** (Tech §1), damit DataStore und Analytics der späteren Live-Version sauber bleiben.
  - Den Place privat halten und Tester gezielt freischalten. Den genauen Mechanismus im Creator Hub prüfen `[VORWISSEN, nicht aktuell]`.
  - Kostenpflichtige private Server meiden (Budget 0).
- **Keine Exploit-Software:** Der Owner nutzt keine Executor oder Cheat-Tools (Nutzungsbedingungen). Angriffe werden mit eigenen **Debug-Skripten in Studio** nachgestellt (§6.3, S5).
- **Warum diese Tests nötig sind:** Die Startphase ist laut Compliance nur für 16+ sichtbar (Telemetrie §6). Vor der Freigabe für alle Altersgruppen sind diese privaten Tests die **einzige** Quelle für Daten aus der Zielgruppe.

### 6.2 Geräte (Mindestset)

| Gerät | Zweck |
|---|---|
| **1 kleines, älteres Android** (≤ 6", ≤ 3 GB RAM, 3–4 Jahre alt) | Pflicht: Persona Neuling, FPS, Touch-Reichweite, Streaming |
| 1 größeres Telefon (Android oder iPhone) | Normalfall Mobile |
| 1 Tablet | Knopfabstände, Lesbarkeit |
| 1 PC mit Maus/Tastatur, optional Gamepad | H6-Vergleich, Gamepad-Navigation im Schrein |

Je Gerät notieren: Modell, RAM, OS-Version, WLAN oder Mobilfunk.

### 6.3 Sessions und Zeitplan

| Phase / Session | Wann | Wer | Ablauf | Dauer |
|---|---|---|---|---|
| **P0 Owner-Selbsttest** | nach Sprint 1 (Zone 1) | Owner | Studio Play Solo + Device Emulator (Knopflagen, Topbar), dann echtes kleines Android. Kamera im Turm, Kopffreiheit, DJ-/Dash-Zeitfenster (vorbereitete Teststrecke mit 9/10,5/11,5-Studs-Lücken), AutoJump, FPS. | 60 min |
| **S1 Erstkontakt** | nach Sprint 1, wiederholt nach Sprint 2 | 5–8 Kinder einzeln, je 2–3 aus 7–8, 9–11 und 12–14 Jahren | Kaltstart. Einzige Ansage: „Spiel einfach, ich schaue zu.“ Der Owner greift erst nach 2 min Feststecken oder auf die zweite Frage hin ein, mit einem minimalen Hinweis, und notiert das als **Eingriff**. Kein lautes Denken verlangen. | 20 min + 3 min Gespräch |
| **S2 Wiederkehr** | 1–3 Tage nach S1 | dieselben Kinder | Nicht einladen, sondern beobachten, ob das Kind **von sich aus** fragt. Dann 5 min spielen lassen (Casual-Rejoin, Orientierung am Lager). | 5–10 min |
| **S3 Social** | nach Sprint 2 | 2–3 Kinder gemeinsam, gleicher Raum, eigene Geräte, gleicher Server | Kein Hinweis auf Signale oder Lift. Beobachten: Finden sie sich wieder? Warten sie? Wie verständigen sie sich (im Raum sprechen ist erlaubt, wird aber notiert, weil es online fehlt)? | 15 min |
| **S4 Grinder** | nach Sprint 2 | 1 geübter Teen oder Erwachsener | 3 Läufe am Stück. Zeit je Lauf und Zeitpunkt der ersten Langeweile („Ab wann wolltest du aufhören?“). | 45–60 min |
| **S5 Robustheit/Exploit** | nach Sprint 2 | Owner allein in Studio | Debug-Skript (nur in Studio aktiv, `RunService:IsStudio()`) teleportiert, setzt WalkSpeed ×1,4/×3, lässt schweben, feuert Remotes mit NaN/inf/falschen Typen, spammt Respawn und Kauf, macht Rejoin am Lager E25. Studio-Netzwerkverzögerung 150–250 ms `[VORWISSEN, nicht aktuell]`, dazu 3 **legitime** Läufe auf Fehlalarme prüfen. | 60 min |
| **Release-Probe** | vor dem öffentlichen Release | 3 **neue** Kinder, die das Spiel nie gesehen haben | S1 mit dem Release-Kandidaten wiederholen. | je 20 min |

### 6.4 Beobachtungsbogen (eine Seite je Kind und Session)

| Feld | Erfassen |
|---|---|
| Kopf | Code (T1…), Altersgruppe, Gerät, Eingabe (Touch/KBM/Gamepad), Build-Version, Datum |
| Zeitstempel (mm:ss) | Spawn · erste Bewegung · erster Sprung · **Etage 1** · erster Fall · Lager E5 · Schrein geöffnet (allein? j/n) · erster Kauf · DJ-Bühne · DJ-Übung geschafft (Versuche) · E15 · E20 · Dash-Übung geschafft (Versuche) · E25 · Gipfel · Abbruch |
| Strichliste je Etage | Fälle; „Hilfe gezeigt“ (Leuchtspur/Hilfsstufen) |
| Eingriffe | Zeit, Anlass, Hinweis (wörtlich) |
| Frust-Signale | Seufzen, „boah“, Gerät weglegen, Frage „Was soll ich machen?“, Wiederholungs-Schimpfen. Jeweils Zeit und Etage. |
| Freude-Signale | Lachen, „Guck mal!“, Jubel bei Lager oder Freischaltung. Jeweils Zeit. |
| Kamera/Steuerung | Fehlgriffe Dash/Sprung, Kamera-Verwirrung (Decke, Säule), ungewollte Sprünge |
| Social (S3) | Zeit bis zum Wiederfinden nach einer Trennung, Warte-Episoden, genutzte Signale |
| Technik | FPS (Debug-Overlay im Testbuild), Ruckler, Abstürze, Wärme/Akku auf dem kleinen Android |
| Nachgespräch (Smiley-Skala 1–5) | 1. „Was musst du in dem Spiel machen?“ (Core Loop wörtlich notieren) 2. „Was hat der Kristall gemacht?“ 3. „Was war am schwersten?“ 4. „Willst du morgen weiterspielen?“ (Smiley) 5. „Was würdest du ändern?“ |

**Hilfsmittel:**
- Stoppuhr am Zweitgerät.
- Ein Debug-Overlay im Testbuild zeigt FPS, Ping, Etage und Fehlversuch-Zähler.
- Im veröffentlichten Test-Place werden zusätzlich die Telemetrie-Events gegengelesen („View Events“, Telemetrie §5). In Studio schreibt der Log-Stub dieselben Events mit Zeitstempel.

### 6.5 Was gemessen wird und Go/No-Go vor dem öffentlichen Release

| Messgröße | Quelle | Go-Schwelle `[ANNAHME, nach P0 justieren]` |
|---|---|---|
| Etage 1 ≤ 60 s ohne Eingriff | Bogen, Funnel-Schritt 5 | ≥ 4 von 5 Kindern je Altersgruppe |
| Core Loop richtig beschrieben (Nachgespräch Frage 1 und 2) | Bogen | ≥ 4 von 5 |
| Eingriffe pro Kind in 20 min | Bogen | Median ≤ 1, kein Kind > 3 |
| Fälle pro Etage | Strichliste, `FloorSummary` | Keine Etage mit > 8 Fällen bei ≥ 2 Kindern; kein Abbruch an derselben Stelle bei ≥ 2 Kindern |
| DJ-/Dash-Übung | Bogen, `AbilityResult` | Median ≤ 5 Versuche (DJ) bzw. ≤ 6 (Dash); niemand bleibt stecken |
| Touch- gegen PC-Erfolgsquote Dash (H6-Vorindikator) | `AbilityResult` je Eingabe | Abstand ≤ 15 Prozentpunkte (live: ≤ 10) |
| Zeit bis E10 / Gipfel (9–14) | Bogen, `SummitReached` | E10 ≤ 10 min, Gipfel ≤ 30 min. Sonst die Tabelle in GDD §6.2 anpassen. |
| Freiwillige Wiederkehr (S2) | Beobachtung | ≥ 3 von 5 Kindern fragen von sich aus |
| Social: Wiederfinden nach Trennung (S3) | Bogen | ≤ 60 s mit Marker/Lift |
| Grinder: Langeweile-Punkt (S4) | Bogen | nicht vor Lauf 3 |
| Performance kleines Android | Overlay, `ClientPerf` | Median ≥ 30 FPS, P5 ≥ 25, kein Absturz, Speicherwachstum ≤ 5 % in 30 min (Tech §5) |
| Exploit-Fälle (S5) | Server-Log, `MovementFlagged`, `RemoteRejected` | Alle nachgestellten Angriffe werden abgelehnt oder geflaggt; **0 Fehlalarme** in 3 legitimen Läufen mit 250 ms Ping; Bonus/Gipfel nicht farmbar |

**Auswertung:**
- Ergebnisse kommen nach `reports/playtest_report_sprint<N>.md` und werden `[GETESTET]` gekennzeichnet, mit n und Geräteliste.
- Jede verfehlte Go-Schwelle wird ein Backlog-Eintrag mit Bezug auf P-xx.
- Bestanden ist das Gate „Spielspaß“ erst, wenn alle Schwellen in der Zeile „Release-Probe“ erfüllt sind.
