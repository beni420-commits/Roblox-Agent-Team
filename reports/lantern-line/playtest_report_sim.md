# Playtest-Bericht „Lantern Line – Der Nachtzug“ (Persona-Simulation)

**Datum:** 2026-10-13 · **Stand:** Commit `dd5abc5` (enthält H-A16 bis H-A18) · **Rolle:** Playtest-Simulator · **Evidenz:** `[SIMULIERT]` (gilt für den ganzen Bericht) · **Status:** gedanklicher Walkthrough, **kein Spieltest**

> Erleben, Frust, Zeiten und „Würde ich wiederkommen?“ sind `[SIMULIERT]`. Rechnungen sind `[EIGENE RECHNUNG]` aus `GameConfig.luau`. Roblox-Verhalten, das im Repo nicht belegt ist, steht als `[VORWISSEN, nicht aktuell]` da und muss im Owner-Test geprüft werden. Dateinamen ohne Pfad liegen unter `games/lantern-line/src/` (client/Controllers, server, shared/Logic, shared/Config, shared/Visual, localization).

## 1. Grundlage, Methode, Kurzfazit
- **Geprüft:** GDD v0.2 (`docs/lantern-line/game_design_doc.md`), `shared/Config/GameConfig.luau`, `localization/GameStrings.csv`, alle `client/Controllers/*.luau`. Zur Belegung der UI-Befunde dazu `server/Services/RunController.luau`, `server/TrainBuilder.luau` und `shared/Logic/{Fairness,Inspector,Sweep,Lobby,MotionTracker}.luau`.
- **Methode:** Je Persona ein Durchlauf vom Bahnsteig bis zum Ausscheiden oder Ziel, entlang der Codepfade. Die Schweregrade folgen Sprint 0: **hoch** = wahrscheinlich Abbruch/Sackgasse oder Bruch einer Säule bzw. Garantie; **mittel** = spürbarer Frust; **gering** = Feinschliff.
- **Nicht doppelt gezählt:** H-A16 (Gegenzug-Flackern, bildfüllende Express-Kugel), H-A17 (Kupplung, Hörradius 16) und H-A18 (Verfolgerkamera, Kellen-Puls, Kontrolleur höchstens 40 s) sind in `dd5abc5` umgesetzt.
- **Grenzen:** Es gab weder Build noch Gerät. Latenz, Touch-Präzision und die Sichtbarkeit im Dunkeln lassen sich nicht belegen.
- **Kurzfazit:**
  - **Stark:** Die Zeichen-Idee („Licht verrät alles“) und die Doppelmerkmale bei Kelle, Augen und Gegenzug. Kein Blut, keine Käufe. Modale Knöpfe geben bei gesperrter Maus den Zeiger frei (`client/Controllers/UiKit.luau:90-101`).
  - **Schwach:** Der Kontrolleur ist auf das sichtbare Signal hin kaum fair (LP-01). Die Mehrspieler-Garantien gelten nur für Einzelspieler (LP-02, LP-04). Ein Ausscheiden kostet bis zu 25 min (LP-03). Allein sieht man den Hinweis nach dem Tod nicht (LP-05).

## 2. Persona-Walkthroughs `[SIMULIERT]`

### 2.1 Mia, 9 – Tablet (Touch), Deutsch, ängstlich, spielt mit älterem Bruder
| Schritt | Erleben | Problem / Beleg | LP |
|---|---|---|---|
| Bahnsteig | Tafel „Der Nachtzug – Abfahrt in 15“. Der Bruder steht sofort im Feld. Mia schaut auf den pulsierenden Knopf „Einstellungen [M]“ | Nach 15 s fährt der Zug ohne sie ab, sie wartet ~25 min (`RunController.luau:617-639`). „[M]“ sagt ihr auf dem Tablet nichts (`Hud.luau:307`) | LP-04 |
| Wagen 0–4 | Durchsuchen per Tippen (0,35 s halten) klappt, „+2“ freut sie. In Wagen 3 geht eine Tür nicht auf; die Lampe daneben leuchtet wie alle anderen. Der Bruder findet den Schlüssel | Allein würde sie denken: „kaputt?“ (`TrainBuilder.luau:759-763`) | LP-14 |
| ~W7 Express | Lampen flackern, unten erscheint eine helle Leiste, der Bruder ruft „Schrank!“. „Verstecken“ wirkt sofort (`TrainBuilder.luau:381`). Durch die Schlitze zieht weißes Licht vorbei: kurz gruselig, aber ok. Raureif nach 14 s, nach 20 s ist sie draußen | Allein hätte sie die Leiste nicht gedeutet | LP-06 |
| ~W9 dunkel | Es gibt nur ihr eigenes Licht (Radius 9). Grüne Punkte springen plötzlich auf hell, sie erschrickt und weicht falsch aus: 35 Schaden | Hart umgeschaltet ohne Übergang (`EntityController.luau:353`). Der Sanfte Modus ändert hier nichts | LP-17, LP-07 |
| ~W13 Kontrolleur | Sie liest „Gehen“. Die Kelle wird kleiner, der Text bleibt „Gehen“. Bei „Stillstehen“ bleibt sie stehen und bekommt trotzdem 40 Schaden: „Ich hab doch angehalten!“ | `Hud.luau:138-149`, `Inspector.luau:93-96` | LP-01 |
| ~W16 Gegenzug | Blaues Licht links, am linken Rand „‹‹“. Sie geht in Pfeilrichtung: 50 Schaden, ausgeschieden | Der Pfeil zeigt zur Gefahr (`Hud.luau:171-181`) | LP-09 |
| danach | Die Notiz versteht sie (zwei Sätze). „OK“ startet das Zuschauen beim Bruder für ~15 min. Nach 5 min will sie neu anfangen; das geht nicht | Kein Wiedereinstieg | LP-03 |

**Fazit:** Mit dem Bruder als Erklärer verständlich, allein kaum. Die dunklen Wagen mit aufspringenden Augen sind für ein ängstliches Kind die Grenze. Der Express im Schrank ist eher spannend. **Wiederkommen:** nur zusammen mit dem Bruder.

### 2.2 Jonas, 12 – PC (Maus/Tastatur), Englisch, genre-erfahren, will Herausforderung
| Schritt | Erleben | Problem / Beleg | LP |
|---|---|---|---|
| Bahnsteig | Allein ins Feld, Abfahrt nach 3 s. M öffnet die Einstellungen, die Maus wird frei ✓. Der HUD-Knopf selbst ist bei gesperrter Maus nicht klickbar (`Hud.luau:222`, nicht modal); „[M]“ reicht ihm | – | – |
| W0–12 | 2–3 min passiert nichts, dann der Express. Er versteckt sich sofort. Ab dem Heck von k−1 bleiben ihm 4,5–5,5 s `[EIGENE RECHNUNG]` (`GameConfig.luau:40-43`). Ihm ist das zu leicht. „Ticket stubs – what for?“ | Abrisse ohne Zweck | LP-15 |
| Kontrolleur | Er hält beim Streifen sofort an und bekommt trotzdem 40 Schaden. Beim zweiten Mal reagiert er schon auf das Schrumpfen der Kelle. Sein Urteil: „laggy, unfair“ | `GameConfig.luau:79-81` | LP-01 |
| Strg-Gewohnheit | Er drückt aus Gewohnheit Strg zum „Ducken“. Damit ist Schleichen an, ohne dass er es merkt. In der Lawine (~W31) holt sie ihn bei Tempo 8 gegen 13 ein | `MovementController.luau:30-35` | LP-10 |
| Variante ohne Strg | Er läuft der Lawine davon und koppelt an der orangen Kupplung ab: starker Moment. W38–49 sind eintönig | – | LP-15 |
| Postwagen | Laufen (16) ist schneller als die Jagd des Schaffners (13); er entkommt, liest drei Schnipsel, stanzt das Muster und gewinnt nach ~26 min | – | – |

**Fazit:** Gut verständlich. Der Kontrolleur ist der einzige echte Frust. Bis W25 ist die Herausforderung gering, das Finale ist gut. **Wiederkommen:** eher nein. Der Ablauf ist gleich, es gibt keine Belohnung, und ein Fehler bei W50 kostet 25 min (LP-03).

### 2.3 Lea, 14 – Handy, allein, ohne Ton (Schule), Rot-Grün-Schwäche
| Schritt | Erleben | Problem / Beleg | LP |
|---|---|---|---|
| Start | Querformat. Die Wagennummer liegt unter den Roblox-Symbolen oben links, die Lebens-Fahrkarte unter dem linken Daumen | `UiKit.luau:18` (IgnoreGuiInset), `Hud.luau:92,210` `[VORWISSEN]` | LP-12 |
| Ohne Ton | Kein Nachteil: Bis zur Owner-Prüfung gibt es gar keine Sounds (GDD §11). Der Hinweis „Gepäck rumpelt“ setzt Ton voraus | `GameStrings.csv:59` | LP-18 |
| ~W8 Express | Die Warnleiste (26 px) liegt unter ihren Daumen, die Lampen flackern. Sie geht weiter und scheidet aus | `Hud.luau:268` | LP-06, LP-12 |
| Ergebnis | Notiz und Ergebnis-Fahrkarte erscheinen übereinander, den Hinweis sieht sie nicht. Nach 15 s steht sie wieder am Bahnsteig, Neustart bei W0 | `DeathController.luau:125-145` | LP-05 |
| Lauf 2 | Kelle (rund gegen Balken, dazu Text) ✓. Augen als helle Punkte ✓, Gegenzug blau ✓. Den Laternenwechsel von Bernstein zu Rot erkennt sie kaum (`Palette.luau:33-34`). Bei der Lawine sehen die orangen Lampen für sie aus wie normales Licht, die Leiste ist dieselbe wie beim Express. Sie sucht einen Schrank, findet keinen Prompt und verliert Zeit | `Hud.luau:182-190` | LP-01, LP-08 |
| Pausenende | Bei ~W20 klingelt es. Es gibt keinen Zwischenstand | – | LP-03 |

**Fazit:** Die Farbsehschwäche ist bei Kelle, Augen und Gegenzug gut abgefangen, bei Lawine und Kontrolleur-Warnung schwach. Ohne Ton voll spielbar. Die Hürden sind das Handy-Layout und die Lernschleife beim Solospiel. **Wiederkommen:** vielleicht, wenn ein Lauf in eine Pause passt.

### 2.4 Tim, 11 – Gamepad, spielt zu viert mit Freunden
| Schritt | Erleben | Problem / Beleg | LP |
|---|---|---|---|
| Bahnsteig | Drei Freunde stehen im Feld. Tim öffnet mit Select die Einstellungen, nach 15 s fährt der Zug ohne ihn. Annahme für den weiteren Ablauf: alle steigen ein | `Lobby.luau:15-26` | LP-04 |
| Steuerung | X für Prompts ✓ (`TrainBuilder.luau:107`). Mit B verlässt er den Schrank. Drückt er B in dem Moment, in dem ihn die Kälte hinausschiebt, schaltet er Schleichen ein | `HidingController.luau:52-57` | LP-10 |
| ~W9 Express | Alle vier stehen an der Tür. Im Wagen gibt es 2–3 Schränke, dahinter 2. Zwei finden einen Platz. Der Dritte rennt nach hinten, dem Express entgegen; der Vierte steht noch in k−2. Zwei scheiden aus | `Fairness.luau:139-155` | LP-02 |
| Ausgeschieden | Die Notiz erscheint, „OK“ ist nicht ausgewählt, Select öffnet die Einstellungen `[VORWISSEN]`. Im Zuschauen gibt es jetzt eine Verfolgerkamera ✓; „Mitreisender 2/2“ sagt ihm nicht, wen er sieht | `DeathController.luau:93,171` | LP-11, LP-18 |
| Kontrolleur | Die Tür bleibt zu, bis alle kontrolliert sind, und niemand sieht, wer fehlt. Nach 40 s geht er trotzdem ab ✓ | `Hud.luau:155-166` | LP-16 |
| Lawine, Finale | Die Kupplung ist eine starke Teamaufgabe, wenn man sie kennt. Den Notizzettel sehen alle ✓. „Das Tor öffnet sich!“ sieht nur, wer gestanzt hat | `RunController.luau:987` | LP-16 |

**Fazit:** Mit Freunden sind die ersten 10 min am lustigsten; danach schauen 1–3 Spieler lange zu. Die Gruppe ist der Zielmodus, aber Bahnsteig und Garantien sind auf Einzelspieler ausgelegt.

### 2.5 Elternteil, 38 – schaut zu und prüft die Kindgerechtheit
- **Positiv:**
  - Kein Blut, keine Gesichter. Figuren verblassen (`server/Services/PlayerService.luau:156-177`).
  - Keine Käufe, keine Texteingabe, Zuschauen ohne Namen.
  - Freundlicher Ton („Deine Reise endete in Wagen 14 – der Bahnhofsvorsteher“). Der Einstellungsknopf fällt am Bahnsteig auf.
- **Kritisch:**
  - Der „Sanfte Modus“ klingt nach „weniger gruselig“, ändert aber weder dunkle Wagen noch Augen noch Schaffner-Jagd. Er ist standardmäßig aus, wird nicht gespeichert, und das Kind kann ihn abschalten (LP-07).
  - Ein Lauf dauert ~25 min ohne Speichern; „noch fünf Minuten“ geht nicht (LP-03).
  - Der intensivste Moment ist die Schaffner-Jagd: eine Silhouette von 7,6 Studs, Jagdtempo 13.
  - Mitreisende können Fremde sein (offene Server, Chat nach den Roblox-Kontoeinstellungen) `[VORWISSEN]`.
- **Urteil:** Das Label „Mild“ ist plausibel. Ab 9 Jahren mit Sanftem Modus vertretbar, für 5–8 Jahre nicht (deckt sich mit T-5).

## 3. Befunde
| ID | Schwere | Befund | Beleg | Vorschlag |
|---|---|---|---|---|
| LP-01 | **hoch** | **Kontrolleur: Auf die Streifen-Kelle hin kann man kaum rechtzeitig reagieren.** Die erste Messung bei Halt + 0,35 s vergleicht mit der Position bei ≈ Halt + 0,05 s. Bei 16 Studs/s muss man also (so wie der Server es sieht) bis Halt + 0,14 s stehen `[EIGENE RECHNUNG]`, dazu kommt die Latenz `[VORWISSEN]`. Die echte Warnung ist die Achtungsphase (1,2 s), doch das HUD zeigt dort weiter „Gehen“. Mit „Bewegung reduzieren“ oder Sanftem Modus bleibt nur eine etwas kleinere Kelle und der Farbwechsel Bernstein→Rot, den Rot-Grün-Schwache kaum sehen. Der Hinweistext nennt das falsche Signal | `GameConfig.luau:79-81`, `Inspector.luau:93-96`, `MotionTracker.luau:31-47`, `Hud.luau:138-149`, `Palette.luau:33-34`, `GameStrings.csv:57` | Eigener HUD-Zustand „Achtung – gleich stehen!“ mit eigener Form (halbe Kelle) und 1,2-s-Balken, ohne Puls. Bewegung erst ab Halt + Gnadenzeit messen, Gnade 0,6 s. Hinweistext anpassen |
| LP-02 | **hoch** | **Die Versteck-Garantie beim Express gilt nur für einen Spieler.** Der Prüfer nimmt je Punkt das nächste Versteck, aber jedes Versteck fasst nur eine Person. Zu viert konkurrieren alle um dieselben ≥ 4 Plätze. Nachzügler in k−2/k−3 liegen in der Express-Bahn (Start 140 Studs hinter k−1), werden aber nicht geprüft | `Fairness.luau:139-155`, `GameConfig.luau:29,48`, `HideState.luau:35-36`, `Sweep.luau:32` | Prüfer mit Zuordnung für 4 Spieler (4 Startpunkte an der Tür, je ein eigenes Versteck); k−2 bis k−4 mitprüfen oder die Bahn verkürzen |
| LP-03 | **hoch** | **Ein Ausscheiden kostet bis zu 25 min.** 51 Wagen à ~30 s, keine Wiederbelebung, kein Zwischenstand, keine Regeneration. Wer ausscheidet, schaut bis zum Ende zu und beginnt dann wieder bei W0 | `GameConfig.luau:7`, GDD §4, §6, §7, §13; `RunState.luau:203-207` | „Haltestellen“ alle 10 Wagen: Ausgeschiedene steigen kostenlos wieder zu (mit H-A13 abgleichen), dazu 1–2 Lochfelder nachstempeln. Optional „ab Wagen 25“ innerhalb der Sitzung |
| LP-04 | **hoch** | **Am Bahnsteig zurückgelassen.** Mit fährt nur, wer bei Abfahrt im Feld steht (15 s nach dem Ersten). Wer gerade in den Einstellungen ist oder zögert, wartet den ganzen Lauf; die Tafel zeigt nicht, wer fehlt | `RunController.luau:617-639`, `Lobby.luau:15-26`, `GameConfig.luau:119-120`, `LobbyController.luau:57-71` | Ein Server ist eine Gruppe: bei Abfahrt alle am Bahnsteig mitnehmen oder „2/3 bereit“ anzeigen. Zustieg bis W4 erlauben |
| LP-05 | **hoch** | **Allein ausgeschieden: Die Ergebnis-Fahrkarte verdeckt den Hinweis.** Das Laufende folgt ≤ 0,1 s nach dem Tod. Die Notiz erscheint erst nach 1 s und wird danach nicht mehr ausgeblendet; beide liegen übereinander. Das später erzeugte Ergebnis liegt vermutlich oben `[VORWISSEN]`. Damit bricht die einzige Lernschleife | `DeathController.luau:125-145,165,185`; `RunController.luau:842` | Hinweis als Zeile auf die Ergebnis-Fahrkarte; die Notiz nach dem Ergebnis nicht mehr zeigen; Ergebnis erst nach „OK“ |
| LP-06 | mittel | Wer einem Wesen zum ersten Mal begegnet, bekommt das Zeichen erst nach dem Ausscheiden erklärt. W0 ist ruhig, erklärt aber nichts | GDD §4, §7 | Aushang in W0 mit 6 Piktogrammen „Zeichen → Reaktion“; bei der Erstbegegnung ein Symbol in der Warnleiste |
| LP-07 | mittel | Der Sanfte Modus schwächt die Warnungen: kein Schwingen, kein Puls, eine statische Leiste. Dunkle Wagen, Augen und Schaffner bleiben unverändert. Standardmäßig aus und nicht gespeichert | `Settings.luau:2,12-16,49-61`, `AmbienceController.luau:91`, `Hud.luau:185-187` | Statt Bewegung ein großes statisches Warnsymbol; Notlicht in dunklen Wagen, Augen weich einblenden; Einstellung merken oder am Bahnsteig fragen |
| LP-08 | mittel | Express und Lawine nutzen dieselbe Leiste, nur die Farbe unterscheidet sie. Die orange Lampentönung liegt nahe am normalen Lampenlicht (H-A11) | `Hud.luau:182-190`, `EntityController.luau:119,169`, `Palette.luau:20,35` | Symbol in der Leiste (Schrank bzw. Doppelpfeil nach vorn); Lawinen-Leiste gestreift |
| LP-09 | mittel | Der Gegenzug-Pfeil zeigt zur Gefahr. Das Bodenband markiert die Gefahrenhälfte, ist aber zu 92 % transparent. Schaut man zur Seite, fehlt der Pfeil ganz | `Hud.luau:171-181`, `EntityController.luau:179-190`, `GameStrings.csv:54` | Pfeil zur sicheren Seite mit Schutzsymbol; die sichere Hälfte deutlich markieren |
| LP-10 | mittel | Schleichen bleibt eingeschaltet, Gamepad-B schaltet es um und verlässt zugleich das Versteck. Mit Tempo 8 holt die Lawine (13) jeden ein; der Prüfer rechnet mit 16 | `MovementController.luau:30-35`, `HidingController.luau:52-57`, `GameConfig.luau:15,93`, `Fairness.luau:127` | Schleichen bei Warnungen automatisch aus; am Gamepad auf L3 legen; deutliche Anzeige |
| LP-11 | mittel | Gamepad: „OK“ auf der Todes-Notiz ist nicht vorausgewählt, und Select ist mit den Einstellungen belegt. Zuschauen ist womöglich nicht erreichbar `[VORWISSEN]` | `DeathController.luau:125-132,171`; vgl. `ValidatorController.luau:48`; `SettingsPanel.luau:75-80` | `GuiService.SelectedObject` auf „OK“ setzen; nach 8 s automatisch zuschauen |
| LP-12 | mittel | Handy: Die Wagennummer liegt unter der Roblox-Leiste, Lebens- und Schleichen-Fahrkarte im Daumenbereich, die Warnleiste unten. Der Entwerter ist 400 px hoch, „ד hat 32 px | `UiKit.luau:18`, `Hud.luau:92,210,218,268`, `ValidatorController.luau:53,79` | Safe Area beachten, UIScale nach Bildhöhe, Entwerter höchstens 80 % der Höhe, Warnung oben |
| LP-13 | mittel | Im Postwagen schützt das Schließfach nur 20 s, solange der Schaffner patrouilliert. Danach wird man hinausgeschoben, eventuell in den Lichtkegel | `RunController.luau:819-824`, `GameConfig.luau:34-35` | Im Postwagen 45 s, oder die Kälte pausiert, solange der Schaffner näher als 16 Studs ist |
| LP-14 | mittel | Eine verschlossene Tür zeigt nur eine 0,5-Stud-Lampe in normaler Lampenfarbe (leuchtet = zu). Das HUD zeigt nichts, bis der Schlüssel gefunden ist | `TrainBuilder.luau:525-531,759-763`, `Hud.luau:54-58` | Schlossform an der Tür und ein leeres Schlüsselfeld im HUD |
| LP-15 | mittel | Abrisse haben keinen Zweck, und es gibt keinen Anreiz für einen zweiten Lauf | `LobbyController.luau:82-83`, `DeathController.luau:141`, GDD §13 | An Haltestellen gegen Lochfelder eintauschen (LP-03); eine Stempelsammlung ohne Kauf |
| LP-16 | gering | Bei „Der Ruck“ und „Tor offen“ fehlt im Client jede Rückmeldung. Wer kontrolliert ist, sieht das nicht | `RunController.luau:250,987` (kein Client-Empfänger), `Hud.luau:155-166` | Kurze Einblendung; Stempel „Kontrolliert“ |
| LP-17 | gering | Augen sind winzig (0,22 Studs) und schalten ohne Übergang auf hell, was als kleiner Schreckmoment wirkt | `TrainBuilder.luau:479`, `EntityController.luau:350-355` | In 0,5 s einblenden, im Sanften Modus schwächer |
| LP-18 | gering | Der Entwerter bleibt nach dem Ausscheiden offen (`ValidatorController.luau:88-102`). „[M]“ steht auch bei Touch und Gamepad da (`Hud.luau:307`). „Rumpelt“ setzt Ton voraus; mit „Bewegung reduzieren“ fehlt auch das Rütteln (`EntityController.luau:251`). Die Kupplung wird erst nach dem Tod erklärt. Beim Zuschauen fehlt jeder Hinweis, wen man sieht | siehe links | Beim Tod schließen; Tastenhinweis je Eingabegerät; Text „rollt“; Symbol an der Kupplung |

## 4. Gate „Spielspaß“
- **Status: offen.** Mit `[SIMULIERT]` ist das Gate grundsätzlich nicht bestehbar; es bleibt offen bis zum echten Owner-Test.
- **Simulierte Tendenz:**
  - Die Kernidee trägt, und die Barrierefreiheit über Formen ist überdurchschnittlich.
  - Die Spannungskurve leidet an LP-01, LP-03 und LP-05, der Mehrspieler-Teil an LP-02 und LP-04.
  - Am besten wirkt das Spiel zu zweit mit einem erfahrenen Mitspieler (Mia, Tim). Am schwächsten wirkt es allein auf dem Handy (Lea).
- **Vor dem Owner-Test empfohlen** (kleiner Aufwand): LP-05, LP-01 (Text und Messung), LP-11, LP-04 (Variante „alle mitnehmen“). LP-02 und LP-03 brauchen eine Designentscheidung des Owners.
- **Bestanden, wenn im Owner-Test:**
  - (a) W10 im ersten Lauf erreicht wird (H1).
  - (b) jedes Ausscheiden im Nachhinein „fair“ wirkt, ausdrücklich auch beim Kontrolleur.
  - (c) mit 2 Clients niemand länger als 5 min untätig ist.
  - (d) Spaß und Fairness mit mindestens 4/5 bewertet werden.

## 5. Die 5 wichtigsten Fragen für den Owner-Test
1. **Kontrolleur:** Wenn du erst bei „Stillstehen“ anhältst, bekommst du trotzdem Schaden? Wie oft in drei Haltphasen? (LP-01)
2. **Allein ausscheiden:** Kannst du den Hinweis des Bahnhofsvorstehers lesen, oder liegt die Ergebnis-Fahrkarte darüber? (LP-05)
3. **Mit 2 Clients:** Beide stehen an der Tür, der Express kommt. Findet jeder rechtzeitig ein freies Versteck? Und: Wer am Bahnsteig nicht im Feld steht, bleibt der zurück? (LP-02, LP-04)
4. **Lauflänge:** Wie lange dauerte dein Lauf bis zum Ausscheiden oder Ziel? Würdest du nach einem Ausscheiden bei W30 sofort neu starten? (LP-03, LP-15)
5. **Erstbegegnung ohne Erklärung:** Was hast du beim ersten Express, beim ersten Gegenzug (bist du dem Pfeil gefolgt?) und bei der Lawine getan? Hast du die Express-Warnung im Sanften Modus noch bemerkt? (LP-06 bis LP-09)
