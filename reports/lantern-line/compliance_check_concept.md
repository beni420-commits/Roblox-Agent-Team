# Compliance-Vorprüfung „CARRIAGES / Der Nachtzug“ (GDD v0.1)

| Feld | Wert |
|---|---|
| Datum / Rolle | 2026-10-13 · Compliance-Officer (Veto-Recht: Kinderschutz, Sicherheit, Roblox-Regeln, Recht) |
| Gegenstand | `docs/lantern-line/game_design_doc.md` v0.1, vollständig gelesen |
| Grundlage | Digest v1.1, `compliance_check_sprint0.md` v1.1, `compliance_check_sprint1.md`, `docs/decisions.md` (D-023, D-024, D-030). Original-Doku: creator-docs @af5f853 (lokal), Pfade relativ zu `content/en-us/`, abgerufen 2026-10-13 |
| Methode | Original gelesen (`OG`), 10 Websuchen (`WS-O` offiziell, `WS-S` sekundär), sonst `[ANNAHME]`/`[VORWISSEN]`. Es gibt noch keinen Code, also keine Studio-Prüfung. **Keine Rechtsberatung.** |

## 1. Ergebnis: **Freigabe mit Auflagen** (H-A1 … H-A15)

**Kernnah** (ohne sie keine Freigabe): H-A1, H-A2, H-A3, H-A6.
**Bedingtes Veto**, sobald einer dieser Punkte eintritt:
- **V1:** Namen, Assets, Texte, Sounds oder Metadaten-Bezüge von Doors im Spiel oder auf der Spielseite (H-A1, H-A2).
- **V2:** Bar oder Alkohol im Spiel (H-A6). Folge wäre das Label Restricted (nur altersgeprüft ab 18).
- **V3:** Kaufbare Wiederbelebung, Robux-Shop für Lauf-Gegenstände oder bezahlte Zufallsgegenstände, auch nach dem MVP (H-A13).

## 2. Begründung (Kurzfassung)

- **Mechanik ja, Ausdruck nein.** „Copyright does not protect facts or ideas, but it may protect the specific expression“; auch KI-veränderte Kopien sind meldefähig [QUELLE: OG `production/publishing/ip-guidelines.md`]. Raumfolge, Licht als Warnung, Verstecken, Schlüsselsuche und Rätsel-Finale sind Genre-Konventionen. Das GDD übernimmt keine Namen oder Figuren (§2). Das ist richtig.
- **Die Auswahl ist aber sehr nah.** Fast jedes Hotel-Element von Doors hat eine 1:1-Entsprechung [QUELLE: Doors-Guides, WS-S, §9]:

  | Doors | Bei uns |
  |---|---|
  | Lobby mit Fahrstuhl-Countdown | Bahnsteig mit Countdown |
  | Rush / Ambush (2–6 Durchgänge) | Express / Pendel (2–4 Durchgänge) |
  | Screech (im Dunkeln ansehen) | Blinder Passagier |
  | Hide (zu lange versteckt) | Kälte |
  | Guiding Light | Fahrkarten-Notiz |
  | Figure + Bibliothek in Raum 50 (Bücher „Form + Ziffer“, Code aus der Reihenfolge) | Schaffner in Wagen 50 (Anhänger ●▲■ + Ziffer) |

  Eigenständig sind vor allem **Kontrolleur** und **Ruck**. Risiken:
  - Roblox empfiehlt „non-unique games“ nicht mehr bevorzugt [OG `discovery.md`].
  - Bei Klon-Streit zählt die Darstellung auch bei getauschtem Thema: Die Klage von Spry Fox gegen „Yeti Town“ wurde trotz anderem Thema nicht abgewiesen, danach Vergleich [WS-S].
  - „DOORS“ ist von LSPLASH Inc. als Marke angemeldet; die Eintragung ist nicht verifiziert [WS-S].

  → H-A1 bis H-A5.
- **Neuer Fund: Bar im Salonwagen (GDD §5).** Alkohol sowie „locations that provide or sell alcohol, such as characters drinking alcohol at a bar“ führen zu **18+**, ebenso „settings intended for adults (e.g. clubs, bars)“ [OG `production/promotion/content-maturity.md`, Alcohol und Romantic themes]. → H-A6.
- **Label Mild ist erreichbar** (§4), solange der Tod unrealistisch dargestellt wird und Gore fehlt. Mild ist zugelassen für Roblox Kids (5–8) und Select (9–15) [OG `content-maturity.md`].
- **Kinderschutz im GDD gut angelegt:** keine Käufe, keine Wiederbelebung, nur Ziffern, „Sanfter Modus“. Lücken: Signale nur über Farbe (Gelb/Rot, Weiß/Blau), Gelb-Rot-Flackern, Flacker-Grenze je Lampe statt je Bildschirm, Technik der Code-Eingabe. → H-A9 bis H-A12.
- **Öffentliches Repo.** `beni420-commits/Roblox-Agent-Team` ist öffentlich [GETESTET: GitHub-API `visibility: public`, 2026-10-13]. Die Zuordnungstabelle kann jeder lesen. → H-A5.

## 3. IP-Abgrenzung im Detail

### 3.1 Unbedenklich und problematisch

| Unbedenklich (Genre/Mechanik) | Problematisch (Ausdruck/Kennzeichen), nicht übernehmen |
|---|---|
| Räume nacheinander mit Zählung, prozedurale Räume | Name „Doors“/„DOORS“, Wortmarken-Stil, Tür oder Hand am Knauf in Logo/Icon |
| Licht flackert als Warnung, Verstecken in Schränken | Wesen-Namen: Rush, Ambush, Screech, Eyes, Halt, Seek, Figure, Hide, Dupe, Jack, Timothy, Guiding/Curious Light, Jeff |
| Schlüssel in Behältern, Hinweis nach dem Tod | Orte und Items: The Hotel, The Mines, Backdoor, The Rooms, **Knobs**, **Revives**, Pre-Run Shop, Elevator. Knobs, Revives, Pre-Run Shop und Fahrstuhl belegt in [OG `production/game-design/contextual-purchases.md`, `monetization-foundations.md`] |
| Rätsel-Finale, Koop bis 4, Lobby-Countdown | Figurendesigns (Gesicht/Grinsen, Rauchkörper, Augen-Cluster, fleischiger Riese), „psst“-Laut, Herzschlag-Minispiel, Hinweistexte, UI-Layout, Thumbnail-Komposition |
| Raumnummer als Fortschritt | **Raumnummer-Plaketten im Messing-/Gold-Stil** [nicht verifiziert, vorsorglich]; **blaue bzw. gelbe Leuchttexte nach dem Tod** (Guiding/Curious Light) [WS-S] |

### 3.2 Abstand unserer Wesen

| Wesen | Mechanik-Vorbild | Unsere Gestaltung | Bewertung |
|---|---|---|---|
| Express | Rush | Scheinwerferlicht, kein Körper | ausreichend mit H-A2 |
| Pendel | Ambush | bläuliches Licht | ausreichend mit H-A2 und H-A11 (zweites Merkmal) |
| Blinder Passagier | Screech | zwei grüne Augen | ausreichend mit H-A2 (kein Mund, kein „psst“) |
| Kontrolleur | (eigene Mechanik) | Laterne, Stillstehen bei Rot | eigenständig; generisches Kinderspiel. Kein Squid-Game-Look oder -Begriff [ANNAHME] |
| Schaffner + Wagen 50 | Figure + Bibliothek in Raum 50 | blind, hört Schritte, Formen-Ziffern-Code, Verstecke | **zu nah** → H-A3 |
| Kälte | Hide (~12 s, Bildschirm pulsiert rot, 40 Schaden) [WS-S] | Raureif, kein Schaden | ausreichend |
| Fahrkarten-Notiz | Guiding Light | Person statt Lichtwesen, Papier | ausreichend mit H-A2 (c) |

## 4. Content Maturity: erwartete Fragebogen-Antworten

[QUELLE: OG `production/promotion/content-maturity.md` @af5f853, abgerufen 2026-10-13]

| Kategorie | Antwort | Begründung (Original) |
|---|---|---|
| Violence | **Ja · Mild · Repeated** | Gewalt = „intentional use of physical or psychological force against players“. Die Wesen fügen Schaden zu (35/40) und töten. **Auch der Tod durch ein Lichtwesen ohne Blut ist Gewalt**, aber **Mild**: „Implied or unrealistic depictions of violence, such as bodies disappearing the moment their health reaches zero“. Schon angedeutete Gewalt gilt als Mild. Häufig (Begegnung alle paar Wagen, Passagier alle 8–18 s), also Repeated. |
| Blood | Nein | GDD S4 |
| Fear | **Ja · Mild · Repeated** | Mild: „creepy-looking NPCs, jump scares, ominous music, and/or gameplay that builds suspense“. Moderate erst bei „disfigured mouths with realistic blood“, sichtbaren Organen, offenen Wunden, blutenden Augen. „Even a small part … repeated“ zählt als Repeated. |
| Crude humor / Unplayable gambling / Strong language | Nein / Nein / Nein | „Allow strong language“ bleibt aus. |
| Romantic themes, private spaces, adult settings | **Nein**, nur mit H-A6 und H-A7 | Eine Bar macht daraus „Ja“ (18+). Das Spiel darf nicht „primarily“ in privaten Räumen stattfinden. |
| Alcohol | **Nein**, nur mit H-A6 | Mit Alkohol nur ab 18 |
| Social hangout / Free-form | Nein / Nein | Kern ist Überleben; am Schloss nur Ziffern-Tasten |
| Sensitive issues / Paid random items / Paid item trading | Nein / Nein / Nein | Keine Käufe im MVP |
| Media / AI interaction | Nein (alle drei) / Nein | Zuschauen ist Live-Ansicht, kein Teilen von Medien |

**Erwartetes Label: Mild**, mit den Deskriptoren Violence und Fear (Bezeichnung auf der Spielseite [ANNAHME]).
- **Minimal** ist wegen Fear ausgeschlossen. **Moderate** entsteht erst durch realistische Todesfolge oder Gore; dann fällt Roblox Kids weg.
- Das regionale Ergebnis aus der Fragebogen-Vorschau wird eingetragen.
- Die Beschreibung von Fear „Repeated“ enthält im Original „many violent events“, offenbar ein Kopierfehler aus Violence. Die Antwort bleibt Repeated.

**Grenzen, die uns bei Mild halten:** Der Avatar verblasst oder löst sich im Licht auf. Kein Ragdoll mit Verletzungen, keine Körperteile, kein Blut, keine Leichen. Keine entstellten Münder, Organe, Wunden oder blutenden Augen. Schon eine einzige realistische Todesfolge reicht für Moderate („even if the realistic violence only occurs once“).

## 5. Auflagen

Format: **Regel/Quelle** · **Umsetzung im Spiel** · **Prüfbar über**.

**H-A1 Keine Doors-Kennzeichen (kernnah, V1)**
- **Regel/Quelle:** Abwertung bei „Non-unique games“, „Mismatched metadata“ und „irrelevant keywords“ [OG `discovery.md`]; Spam-Beispiel mit fremden Spielnamen („…piggy baldi granny…“) [OG `production/publishing/publish-games-and-places.md`]; Marken [OG `ip-guidelines.md`; DOORS-Anmeldungen von LSPLASH, WS-S]; C-A10.
- **Umsetzung:** In Titel, Beschreibung, Icon, Thumbnails, Badges, Place-/Gruppennamen und Lokalisierung keine Eigennamen aus §3.1, auch nicht „Doors“, „… but on a train“, „like/inspired by Doors“, „hotel“ als Schlagwort, „Squid Game“ oder „Red Light Green Light“. Keine Vergleiche mit anderen Spielen. In Titel und Beschreibungs-Hook (erste 160 Zeichen) kein „door/Tür“; im Spiel ist das Gattungswort erlaubt. Punkte/Währung heißen nie „Knobs“/„Knöpfe“; nichts heißt „Revive“.
- **Prüfbar:** Unit-Test der Blockliste gegen `localization/*.csv` und `src/` (ganze Wörter, ohne Groß-/Kleinschreibung); Metadaten-Entwurf vor Veröffentlichung durch Test und Compliance.

**H-A2 Eigene Gestaltung, No-Go-Liste (kernnah, V1)**
- **Regel/Quelle:** Ausdruck ist geschützt, auch bei KI-Veränderung [OG `ip-guidelines.md`]; C-A10.
- **Umsetzung:**
  - (a) Lichtwesen ohne Gesicht, Mund, Zähne, Grinsen, Rauch- oder Partikelkörper. Der Blinde Passagier hat genau zwei Augen, keinen Mund. Keine Augen-Cluster, kein „psst“.
  - (b) Keine Messing-/Gold-Nummernschilder; nur weiße Schablonenschrift (wie GDD).
  - (c) Hinweise nach dem Tod nie als leuchtender blauer/gelber Text oder schwebendes Licht, sondern als Fahrkarten-Notiz mit eigenen Formulierungen.
  - (d) Kein Herzschlag-Timing-Minispiel im Versteck, kein rot pulsierender Bildschirm mit Klingeln.
  - (e) Logo/Icon im Fahrkarten- bzw. Laternen-Stil, ohne Tür.
  - (f) Keine Doors-Assets, -Sounds, -Screenshots, -Wiki-Texte oder Fan-Modelle, auch nicht als Referenz im Repo oder als KI-Vorlage.
- **Prüfbar:** Studio-Screenshot je Wesen und UI-Element an Compliance vor dem Merge; Asset-Register (H-A14).

**H-A3 Finale „Wagen 50“ abgrenzen (kernnah)**
- **Regel/Quelle:** wie H-A2; „Non-unique“ [OG `discovery.md`]. Befund: In Doors Raum 50 hört ein blindes Wesen Schritte; Bücher tragen Form und Ziffer; ein Zettel gibt die Reihenfolge vor; Vorhängeschloss; Verstecken [WS-S]. GDD §6.5 trifft jeden Punkt, sogar die geometrischen Formen.
- **Umsetzung:** **Pflicht ist (b) plus (a) oder (c).**
  - (a) Der Schaffner nimmt wahr, was der Lichtkegel seiner Kopflampe trifft (passt zu S1); Geräusche nur als Nebenfaktor.
  - (b) Eigenes Rätsel ohne „Symbol → Ziffer → Reihenfolge“ und ohne ●▲■, z. B. Anhänger mit Abfahrtszeit und Gleis; Code = Gleise in Abfahrtsreihenfolge laut Abfahrtstafel.
  - (c) Das Finale liegt nicht genau bei Wagen 50.
  - Die Figur ist eine Silhouette in Uniform, ohne fleischigen oder gerippten Körper, ohne Zähne.
- **Prüfbar:** GDD v0.2 §6.5 und Compliance-Nachprüfung vor der Umsetzung.

**H-A4 Keine weiteren 1:1-Entsprechungen**
- **Regel/Quelle:** wie H-A3.
- **Umsetzung:** Neue Wesen und Linien (Wagen 51–100, Verfolgungsjagd) brauchen eine eigene Kernmechanik. Ausgeschlossen: Augen an Wänden mit Verfolgung durch Arme/Hände (Seek), Korridor mit „Umdrehen“-Text (Halt), falsch nummerierte Türen (Dupe), Wesen in Schubladen (Timothy), Händler im Gang (Jeff). Werte von Express und Pendel nicht weiter ans Original angleichen.
- **Prüfbar:** Compliance-Check vor Linie 2 und vor jedem neuen Wesen.

**H-A5 Zuordnungstabelle umformulieren (öffentliches Repo)**
- **Regel/Quelle:** C-A10; Repo öffentlich [GETESTET]. Die Tabelle ist inhaltlich sauber (keine Doors-Namen) und soll als **Nachweis des Abstands bleiben**, aber nicht wie eine Reskin-Liste klingen.
- **Umsetzung:** Spalten „Genre-Prinzip“ | „Unsere Umsetzung“ | „Ausdrücklich nicht übernommen“ (No-Gos aus H-A2/H-A3). Kopfzeile ohne „Doors-Konvention“. „Nah am Original“ ersetzen durch „vertrautes Genre-Gefühl, eigene Gestaltung“. Den Wortlaut des Owner-Auftrags nach `docs/decisions.md` verschieben. Doors nur in Recherche- und Compliance-Dokumenten nennen; keine Doors-Bilder oder Wiki-Auszüge im Repo.
- **Prüfbar:** `grep -ri doors docs/lantern-line src` findet nur Recherche- und Compliance-Dokumente.

**H-A6 Keine Bar, kein Alkohol (kernnah, V2)**
- **Regel/Quelle:** Alkohol und Bars → 18+ [OG `content-maturity.md`, Alcohol und Romantic themes; OG `safety.md` zu Bars].
- **Umsetzung:** Salonwagen ohne Bar, z. B. als Teesalon mit Samowar oder Kaffeetresen. Nirgends Flaschen, Wein-/Biergläser, Zapfhähne oder Schilder und Texte „Bar“, „Wein“, „Bier“; das gilt auch für den Speisewagen. Teekannen und Tassen sind in Ordnung.
- **Prüfbar:** Modell-Review per Screenshot; Wortlisten-Test auf die Lokalisierung (ganze Wörter).

**H-A7 Private Räume, Betten und Verstecke**
- **Regel/Quelle:** Spiele für unter 18 nicht überwiegend in privaten Räumen („bedrooms, bathrooms, or closets“); Bounding-Box für Betten [OG `safety.md`]; private Räume → 18+ [OG `content-maturity.md`]; KS-07.
- **Umsetzung:**
  - Höchstens 25 % der Wagen eines Laufs sind Schlafwagen [ANNAHME].
  - Keine WC-, Wasch- oder Duschräume; Abteile ohne schließbare Türen.
  - Betten, Pritschen und Sofas ohne `Seat`, per Bounding-Box nicht betretbar, keine Liege-Animation.
  - Versteck serverseitig für genau eine Person, jederzeit verlassbar.
  - Spieler-Kollision aus (C-A13), damit niemand Verstecke oder Türen blockiert.
  - Bahnsteig ohne Sitzplätze und Emote-Bühne (wie C-A20).
- **Prüfbar:** Fairness-Prüfer misst über 500 Seeds den Schlafwagen-Anteil; `grep Seat src` = 0 Treffer; Test der Versteck-Belegung.

**H-A8 Fragebogen und Mild-Grenzen**
- **Regel/Quelle:** CM-01, CM-03, CM-04, CM-09, C-A1, T-1, T-2.
- **Umsetzung:** Entwurf `docs/lantern-line/questionnaire.md` nach §4 anlegen; der Owner reicht ihn vor jedem Zugang Dritter ein. Tod nur innerhalb der Mild-Grenzen aus §4. Jede Inhaltsänderung löst einen Fragebogen-Check aus.
- **Prüfbar:** Release-Check R01 und R15; Sichtprüfung der Todesdarstellung in Studio.

**H-A9 Kindgerechte Schreckmomente (Hausregel, strenger als Roblox)**
- **Regel/Quelle:** Jumpscares sind Mild [OG]; Mild erreicht auch Kids 5–8 [OG `content-maturity.md`]; Zielgruppe 9–14 (D-002).
- **Umsetzung:**
  - Jedem gefährlichen Schreckmoment geht ein sichtbares Zeichen voraus (S1, S5).
  - Todesbild höchstens 1,0 s, kein bildfüllendes Gesicht, keine realistischen Gesichter, keine Schmerzensschreie.
  - Spätere Sounds ohne plötzliche Pegelspitzen [Grenzwert ANNAHME, im Owner-Test].
  - **Sanfter Modus:** kein Kamerawackeln, kein Vollbild-Blitz, Tod als Abblende, harmlose Schreckmomente (z. B. „Motten“) aus, Express gedimmt.
  - Einstellungen am Bahnsteig vor dem ersten Lauf sichtbar.
- **Prüfbar:** Logik-Test der Einstellungen; Owner-Test im Sanften Modus.

**H-A10 Fotosensibilität (konkretisiert C-A14)**
- **Regel/Quelle:** WCAG 2.3.1: höchstens drei Blitze pro Sekunde; für gesättigtes Rot eine strengere Schwelle („red flash threshold“) [WS-O: w3.org]. **≤ 3 Hz ist als Obergrenze sinnvoll, reicht aber nicht.**
- **Umsetzung:**
  - (a) Gezählt wird pro 1-s-Fenster **über den ganzen Bildschirm**, also alle Lampen eines Wagens zusammen; unsynchrone Lampen ergeben sonst mehr als 3 Blitze. Designziel: höchstens 2 Hz.
  - (b) **Kein Gelb/Rot-Flackern.** Kontrolleur-Warnung als langsamer Puls (höchstens 1 Hz) oder Formwechsel (H-A11); Rotphase konstant.
  - (c) Rot nur an der Laterne und als schwache Tönung, nie großflächig.
  - (d) Express ohne bildfüllendes Weiß (Bloom und Helligkeit begrenzt); Todesblitz höchstens einmal, im Sanften Modus aus.
  - (e) „Flackern reduzieren“: keine Helligkeitssprünge, Übergänge mindestens 0,3 s [ANNAHME].
- **Prüfbar:** Unit-Test des Flacker-Planers: im gleitenden 1-s-Fenster über alle Lampen höchstens 3 Blitze (Ziel 2). Owner-Aufnahme in Studio [Werkzeug zur Bildanalyse offen].

**H-A11 Signale nicht nur über Farbe, Bewegung abschaltbar**
- **Regel/Quelle:** „Color non-reliance“, „Sound non-reliance“, „Reduce Motion“ = `GuiService.ReducedMotionEnabled` [OG `production/publishing/accessibility.md`, `reference/engine/classes/GuiService.yaml`]; wie C-A21.
- **Umsetzung:** Express und Pendel mit zweitem Merkmal, z. B. quer schwingende Lampen und HUD-Symbol. Kontrolleur Gelb/Rot zusätzlich über die Form, z. B. Signalkelle mit Kreis = gehen und Balken = stehen; bei Rot-Grün-Schwäche sind Gelb und Rot schwer unterscheidbar [VORWISSEN]. Schritte und Flüstern haben ein sichtbares Gegenstück (Kopflampe, Augen). Kamerawackeln und Schwanken (S2) abschaltbar, standardmäßig aus, wenn `ReducedMotionEnabled` true ist.
- **Prüfbar:** Graustufen-Screenshot je Signal (Owner in Studio); Code-Review.

**H-A12 Texte, Code-Eingabe, Namen und Chat**
- **Regel/Quelle:** TXT-01, TXT-02, C-A2, C-A4, KS-02; C-A16 sinngemäß.
- **Umsetzung:** Schloss über Ziffern-Tasten bzw. Drehräder 0–9, **ohne `TextBox`**. Der Server prüft Länge und Ziffern, mit Rate-Limit; andere sehen nur „richtig“ oder „falsch“. Die eigene UI (Zuschauen, Ergebnis-Fahrkarte) zeigt keine Spielernamen; Namen nur über Nameplate/PlayerList oder serverseitig gefiltert. Nur Standard-Chat; ohne Chat spielbar über den gemeinsamen Notizzettel.
- **Prüfbar:** `grep TextBox src` = 0 Treffer; Remote-Tests mit ungültigen Eingaben.

**H-A13 Keine Käufe rund um Tod und Lauf (V3)**
- **Regel/Quelle:** HR-MON und C-A8 (D-023), MON-03, PRI-01 bis PRI-04. Die Roblox-Doku nennt das Doors-Modell (Knobs, Pre-Run Shop, kaufbare Revives) als positives Beispiel [OG `contextual-purchases.md`, `monetization-foundations.md`]. Für unsere Zielgruppe bleibt es ausgeschlossen, denn HR-MON verbietet Kauf-Popups nach Niederlagen.
- **Umsetzung:** MVP ohne `MarketplaceService`. Auch später keine Wiederbelebung gegen Robux, kein Robux-Shop vor dem Lauf, keine Robux-Währung, keine Zufallsgegenstände gegen Robux. Höchstens Kosmetik, nur nach neuer Prüfung und Preisfreigabe durch den Owner. Kein Streak (C-A7).
- **Prüfbar:** `grep -E "MarketplaceService|ProcessReceipt" src` = 0 Treffer.

**H-A14 Nur Assets aus Kat. 0, keine echten Marken oder Ereignisse**
- **Regel/Quelle:** D-024, D-030, C-A9, IP-02, IP-04, CS-04.
- **Umsetzung:** Lichtwesen aus Parts, Neon, Light-Objekten, Standard-Partikeln, Lighting und Atmosphere entsprechen D-024. Nur Roblox-Systemschriften. Papier- oder Stempel-Texturen als Bild-Upload sind Kat. 3 (Einzelfreigabe), sonst aus Frames und UIStroke bauen. Keine Sounds bis zur Owner-Prüfung, keine lizenzierte Musik, keine Fan-Modelle aus dem Store. Keine echten Bahnmarken, Logos, Lackierungen oder Zugnamen (DB, ÖBB Nightjet, SBB, SNCF, Orient-Express), keine Anspielung auf reale Zugunglücke.
- **Prüfbar:** Asset-Register; jede `rbxassetid` in `src` hat einen Registereintrag.

**H-A15 Titel, Marke und Store-Medien**
- **Regel/Quelle:** C-A11, C-A12, C-A29, EXP-01 bis EXP-03; ein Horror-Spiel muss Horror zeigen, nur echte Inhalte [OG `production/publishing/thumbnails.md`].
- **Umsetzung:** Vor der Veröffentlichung Markenrecherche zu „CARRIAGES“ und „Der Nachtzug“ (DPMA, EUIPO, USPTO, WIPO, Roblox-Suche). Titel nicht im DOORS-Muster (kein einzelnes englisches Pluralwort in Versalien als Wortmarke); Empfehlung: Der Nachtzug kommt im Titel vor. Thumbnails nur aus echten Aufnahmen im Laternen-Noir-Stil, keine dunkle Tür mit Nummer und Fratze. Grusel ehrlich zeigen, ohne Schock-Nahaufnahmen.
- **Prüfbar:** Owner-Freigabe von Metadaten und Medien; Blocklisten-Test aus H-A1.

## 6. Projektweit weiter gültig

- **Weiter gültig:** C-A1, C-A2, C-A4, C-A5, C-A7 bis C-A15, C-A29. Sinngemäß C-A16 (Namen), C-A20 (Lobby), C-A21 (zweites Merkmal). C-A6, sobald Daten gespeichert werden (z. B. Einstellungen).
- **Für jeden Test-Place mit Dritten:** T-1 bis T-4.
- **Nicht anwendbar:** C-A3, C-A17, C-A18, C-A22 bis C-A28, C-A30 bis C-A32. **C-A19** (Konzept B, keine Jumpscares) wird für dieses Spiel durch H-A9 ersetzt; dafür braucht es die Owner-Freigabe (§7).

## 7. Owner-Freigabe nötig (Masterprompt §8)

1. **Diese „Freigabe mit Auflagen“** verbindlich machen, wie D-023, einschließlich des Ersatzes von C-A19 durch H-A9.
2. **Content Maturity:** Ziel **Mild** (Violence Mild/Repeated, Fear Mild/Repeated) statt bisher Minimal. Im Universe des Schwungturms muss der Fragebogen neu abgegeben werden; ein neues Universe braucht einen eigenen. Mild öffnet das Spiel auch für Roblox Kids (5–8); der Owner bestätigt, dass das gewollt ist.
3. **Veröffentlichung und Zugang Dritter:** T-1 bis T-4, Publishing Requirements und Gebühr (D-025).
4. **Titelwahl und Markenrecherche** (H-A15).
5. **Sounds und Bild-Uploads** über Kat. 0 hinaus (D-030, H-A14).
6. **Jede Monetarisierung und jeder Preis** (H-A13).
7. **Abweichung von H-A3:** Ein Finale näher am Original nur nach erneuter Compliance-Prüfung.
8. *Optional:* Sollen die Konzeptdokumente im **öffentlichen Repo** bleiben?

**API-Keys:** keine nötig.

## 8. Nicht verifiziert

- Doors: Design der Türschilder (Messing/Gold), Logo-Schrift, Thumbnail-Stil, Farben der Hinweistexte; Details zu Raum 50, Hide und Ambush. Nur Fan- und Guide-Quellen, teils widersprüchlich [WS-S].
- Status der DOORS-Anmeldungen von LSPLASH Inc. (USPTO-Serials 98404441 und 98405164, u. a. Plüschtiere); Eintragung offen [WS-S, Justia].
- Community Standards und ToS zu „misleading“, Imitation und IP; nur Sekundärquellen, die Liste im Digest §13 gilt weiter.
- Spry Fox v. 6waves nur aus Presse-Zusammenfassungen; Übertragbarkeit auf EU-/DE-Recht prüft eine Fachperson.
- Flächen- und Leuchtdichte-Schwellen der WCAG und ihre Anwendung auf 3D-Spiele; kein Harding-Test verfügbar.
- Ob eine Roblox-Systemschrift im Schreibmaschinen-Stil existiert (Enum-Doku nicht im Checkout).
- Ob es auf Roblox schon ein Spiel „Carriages“ oder „Night Train“ gibt; die Websuche ergab keinen verlässlichen Treffer.
- Bezeichnungen der Deskriptoren auf der Spielseite; das Label vergibt Roblox selbst.

## 9. Quellen (abgerufen 2026-10-13)

- **Original-Doku**, creator-docs @af5f853, `content/en-us/`: `production/promotion/content-maturity.md`; `production/publishing/` (`ip-guidelines.md`, `rights-manager.md`, `publish-games-and-places.md`, `thumbnails.md`, `accessibility.md`); `discovery.md`, `discovery-faq.md`, `safety.md`; `production/game-design/` (`contextual-purchases.md`, `monetization-foundations.md`, `design-for-roblox.md`); `reference/engine/classes/GuiService.yaml`.
- **Doors (Wesen, Hide, Raum 50, Guiding Light):** [attackofthefanboy](https://attackofthefanboy.com/guides/roblox-doors-all-entities-and-how-to-survive-them/), [gamerjournalist](https://gamerjournalist.com/every-enemy-and-how-to-avoid-in-roblox-doors/), [Doors Wiki „Hide“](https://doors-game.fandom.com/wiki/Hide), [progameguides](https://progameguides.com/roblox/roblox-doors-walkthrough-how-to-solve-and-escape-level-50/), [ginx.tv](https://www.ginx.tv/en/doors-room-50-code), [Wikipedia „Doors (game)“](https://en.wikipedia.org/wiki/Doors_(game)).
- **Marken und Klon-Fälle:** [Justia LSPLASH Inc. Trademarks](https://trademarks.justia.com/owners/lsplash-inc-5429789); Spry Fox: [MCV](https://mcvuk.com/?p=91469), [PocketGamer](https://www.pocketgamer.com/news/6waves-settles-with-spry-fox-in-yeti-town-triple-town-clone-debate/).
- **Regeln Dritter:** [W3C Understanding SC 2.3.1](https://www.w3.org/WAI/WCAG22/Understanding/three-flashes-or-below-threshold.html); [Rules of Conduct (Help Center)](https://en.help.roblox.com/hc/en-us/articles/203313410-Roblox-Rules-of-Conduct), nur Zusammenfassung.
- **Repo-Sichtbarkeit:** GitHub REST `repos/beni420-commits/Roblox-Agent-Team` → `"visibility": "public"`.
