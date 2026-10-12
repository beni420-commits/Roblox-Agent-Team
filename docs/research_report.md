# Research-Report: Markt, Genres und Konzeptwahl für das MVP

| Feld | Wert |
|---|---|
| Datum | 2026-10-12 |
| Autor-Rolle | Market Researcher (KI-Agent), Sprint 0 |
| Empfänger | Orchestrator, Compliance-Officer, Owner |
| Status | Entwurf 1.0, zur Prüfung |
| Grundlage | 34 Websuchen am 2026-10-12 (nur Suchergebnis-Zusammenfassungen) |

## 0. Kurzfassung

- **Empfehlung: Konzept A „Schwungturm“ (EN: „Momentum Tower“).** Das ist ein prozedural erzeugter Kletterturm aus Bausteinen. Jeder Lauf macht dich schneller und schaltet Bewegungs-Fähigkeiten frei. Dazu kommt ein Tagesturm, der für alle Spieler gleich ist. Kein anderes Konzept lässt sich mit unserem Werkzeugkasten (nur Code und Roblox-Primitive, kein Studio) so gut umsetzen. Es setzt auf einen nachweislich laufenden Trend (Obbies und „+1“-Escape-Obbies 2026) und hat kaum Compliance-Risiko.
- **Plan B: Konzept B „Formwächter“.** Das ist ein kindgerechtes Koop-Spiel im Stil „Finde die Anomalie“. Das Genre ist 2026 stark im Kommen, die Konkurrenz ist geringer, aber die Umsetzung mit Primitiven ist riskanter.
- **Markt:** Roblox ist riesig, die DAU sinken aber seit dem Viral-Hoch im 3. Quartal 2025. Der Empfehlungsalgorithmus belohnt seit 2025/26 ausdrücklich **langfristige Retention, gemeinsames Spielen (Co-Play) und Wiederkehr**, nicht kurzfristige Spitzen. Für ein kleines Team ohne Art-Pipeline ist das eine Chance, denn ein Spiel muss nicht viral starten, um sichtbar zu werden.
- **Größte Unsicherheit:** Alle Zahlen stammen aus Suchergebnis-Zusammenfassungen. Spielerzahlen kommen meist von Drittanbieter-Trackern, die sich widersprechen. Siehe Abschnitt 1.

## 1. Methodik und Grenzen

- **Werkzeug:** nur WebSearch, 34 Anfragen am 2026-10-12 im Modus „standard“, bei dünnen Ergebnissen „extended“. Es gab **keinen Seitenabruf**: WebFetch scheitert in dieser Umgebung per DNS, `*.roblox.com` ist per Netzwerk-Policy gesperrt (siehe `docs/decisions.md`, D-010). Ich habe also keine Seite selbst gelesen, sondern nur die automatisch erzeugten Zusammenfassungen der Suchmaschine.
- **Bekannte Fehler der Zusammenfassungen** (in dieser Recherche beobachtet): Eine Zusammenfassung hielt einen Juni-2026-Bericht für „in der Zukunft liegend“. Eine Drittseite (gameindustrylibrary) nannte für Q2 2026 Zahlen, die zu Q3 2025 gehören. Zahlen können also falsch zugeordnet sein.
- **Nicht direkt abrufbar:** Roblox-Charts, Creator Analytics, RoMonitor Stats und Rolimons. CCU-Werte (gleichzeitige Spieler) stammen meist von Drittanbieter-Trackern (RoWatcher, Rotrends, profitable.app, Bloxodes, GGAID). Sie sind Momentaufnahmen und weichen teils um ein Vielfaches voneinander ab.
- **Quellengüte**, im Text in Klammern:
  - **(A)** Roblox selbst: SEC-/IR-Dokumente, Newsroom, Creator Hub, DevForum
  - **(B)** Fachpresse und Analysefirmen: Bloomberg, PocketGamer.biz, Tubefilter, GamesBeat, TechCrunch, Fortune, GameAnalytics, Dubit, Universität Sydney
  - **(C)** Tracker, Guides und SEO-Blogs: nur als Indiz, nie alleiniger Beleg für eine Kernaussage
- **Nicht verifizierbar waren:**
  - der Unter-13-Anteil an *allen* DAU (es gibt nur Werte für altersgeprüfte Nutzer)
  - Roblox-Zahlen speziell für Deutschland
  - die genauen Signale des Empfehlungsalgorithmus
  - Retention-Benchmarks pro Genre
  - verlässliche aktuelle CCU der „+1“-Obby-Familie
  - die genauen Namen und Regeln der Zielgruppen „Roblox Kids“ und „Roblox Select“
  - das Datum, an dem „Server Authority“ voll freigegeben wurde
- **Q3-2026-Zahlen** sind noch nicht veröffentlicht. [ANNAHME: Veröffentlichung Ende Oktober 2026]
- **Kennzeichnung:** `[QUELLE: …]` für belegte Aussagen. `[ANNAHME]` für eigene Einschätzungen ohne Beleg. `[VORWISSEN, nicht aktuell]` für Wissen aus dem Training. `[EIGENE RECHNUNG]` für abgeleitete Werte.

## 2. Marktüberblick 2025/2026

### 2.1 Plattformgröße

| Zeitraum | DAU | Engagement-Stunden | Bookings | Quelle |
|---|---|---|---|---|
| Q3 2025 (Hoch) | 151,5 Mio. (+70 % zum Vorjahr) | 39,6 Mrd. (+91 %) | – | (A) [QUELLE: Roblox Q3 2025 Shareholder Letter, SEC 8-K https://www.sec.gov/Archives/edgar/data/1315098/000131509825000326/ex991-q32025shareholderl.htm, abgerufen 2026-10-12 via Websuche-Zusammenfassung] |
| Q1 2026 | 132 Mio. (+35 %) | 31 Mrd. (+43 %) | – | (A) [QUELLE: Roblox Q1 2026, SEC 8-K https://www.sec.gov/Archives/edgar/data/0001315098/000162828026028882/ex991-q12026earningsshar.htm, abgerufen 2026-10-12 via Websuche-Zusammenfassung] |
| Q2 2026 | 123 Mio. (+10 %) | 29 Mrd. (+5 %) | 1,6 Mrd. USD (+8 %) | (A/B) [QUELLE: Roblox Q2 2026, SEC 8-K https://www.sec.gov/Archives/edgar/data/0001315098/000162828026051059/ex991-robloxq22026earnin.htm, abgerufen 2026-10-12 via Websuche-Zusammenfassung]; [QUELLE: Shacknews „Roblox Q2 2026 DAUs grew 10%“ https://www.shacknews.com/article/150208/roblox-daus-grew-10-percent-yoy, abgerufen 2026-10-12 via Websuche-Zusammenfassung] |
| Q3 2026 (Prognose) | – | – | 1,58–1,65 Mrd. USD (−14 % bis −18 %) | (B) [QUELLE: Outlook Respawn „Roblox Q2 2026 revenue soars…“ https://respawn.outlookindia.com/gaming/gaming-news/roblox-q2-2026-revenue-soars-36-to-15b-despite-bookings-miss, abgerufen 2026-10-12 via Websuche-Zusammenfassung] |

- **Rekord:** Am 23.08.2025 waren rund 47,3 Mio. Nutzer gleichzeitig online. Laut Vive-Blog entfielen fast 80 % davon auf Grow a Garden und Steal a Brainrot. (B/C) [QUELLE: Vive Blog https://blog.vive.com/us/roblox-beats-steam-but-which-games-attracted-4729-million-players-at-once, abgerufen 2026-10-12 via Websuche-Zusammenfassung]; [QUELLE: Tubefilter https://www.tubefilter.com/?p=188004, abgerufen 2026-10-12 via Websuche-Zusammenfassung]
- **Trend:** Die DAU sind seit dem Hoch in Q3 2025 drei Quartale in Folge gesunken. (B) [QUELLE: Shacknews https://www.shacknews.com/article/150208/roblox-daus-grew-10-percent-yoy, abgerufen 2026-10-12 via Websuche-Zusammenfassung]
- **Gründe laut Roblox:** Seit Januar 2026 gilt die Altersprüfung für den Chat. Außerdem wanderte Engagement von stark monetarisierenden Viral-Hits aus 2025 zu neuen und Evergreen-Spielen. (A) [QUELLE: Roblox Q1 2026 Earnings Call Transcript https://s27.q4cdn.com/984876518/files/doc_financials/2026/q1/32789865_1994106683_3707346_Transcript_EditedCopy_20260430235219.pdf, abgerufen 2026-10-12 via Websuche-Zusammenfassung]; [QUELLE: Roblox Q2 2026 Earnings Call Transcript https://s27.q4cdn.com/984876518/files/doc_financials/2026/q2/32789865_2009724400_3775763_Transcript_EditedCopy_20260730233208.pdf, abgerufen 2026-10-12 via Websuche-Zusammenfassung]
- **Nutzungsintensität:** 29 Mrd. h ÷ (123 Mio. DAU × 91 Tage) ≈ **2,6 Stunden pro DAU und Tag** in Q2 2026. [EIGENE RECHNUNG aus den Q2-2026-Werten oben]
- **Zahlende Nutzer:** In Q1 2026 haben nur 1,4 % der 132 Mio. DAU bezahlt. Das sagte Roblox in einer Stellungnahme. (B) [QUELLE: Fortune, 20.05.2026 https://fortune.com/2026/05/20/exclusive-advocacy-groups-file-complaint-roblox-manipulative-design/, abgerufen 2026-10-12 via Websuche-Zusammenfassung] → Für unser MVP ohne Monetarisierung ist das unkritisch.

### 2.2 Altersstruktur

- **Bis 31.01.2026** waren 45 % der DAU altersgeprüft. Davon sind 35 % unter 13, 38 % 13–17 und 27 % über 18. (A) [QUELLE: Roblox Q4 2025 Shareholder Letter https://s27.q4cdn.com/984876518/files/doc_financials/2025/q4/Q4-2025-Shareholder-Letter.pdf, abgerufen 2026-10-12 via Websuche-Zusammenfassung]
- **Q1 2026:** 51 % der DAU sind altersgeprüft. Über-18-Jährige stellen 26 % der Geprüften. (A) [QUELLE: Roblox Q1 2026 Earnings Call Transcript https://s27.q4cdn.com/984876518/files/doc_financials/2026/q1/32789865_1994106683_3707346_Transcript_EditedCopy_20260430235219.pdf, abgerufen 2026-10-12 via Websuche-Zusammenfassung]
- **7 Tage bis 30.06.2026:** 35 % der Geprüften sind unter 13. (A, über einen Drittspiegel) [QUELLE: last10k.com, Roblox-Filing https://last10k.com/sec-filings/rblx/0001628280-26-051082.htm, abgerufen 2026-10-12 via Websuche-Zusammenfassung]
- **Monetarisierung:** In den USA monetarisieren Über-18-Jährige mehr als 50 % besser als Unter-18-Jährige. (A) [QUELLE: Roblox Q1 2026 Earnings Call Transcript, URL wie oben, abgerufen 2026-10-12 via Websuche-Zusammenfassung]
- **Bedeutung für uns:** Unsere Zielgruppe 9–14 fällt in die beiden größten geprüften Altersgruppen. Unter-13-Jährige sind aber die am stärksten regulierte Gruppe (siehe 2.8).
- **Deutschland:** Ich habe keine Roblox-spezifischen Zahlen gefunden. Laut JIM-Studie 2025 nutzen 78 % der 12- bis 13-Jährigen in Deutschland digitale Spiele. (B) [QUELLE: gamesmarket.global zur JIM-Studie https://www.gamesmarket.global/new-jim-study-reveals-media-ownership-and-usage-among-german-youth/, abgerufen 2026-10-12 via Websuche-Zusammenfassung]

### 2.3 Geräte: Mobile zuerst ist Pflicht, Mobile allein reicht nicht

- **2024** spielten 80 % der DAU auf Mobilgeräten, 17 % auf PC und 3 % auf Konsole. Mobile brachte aber nur 46 % der Robux-Umsätze über die App-Stores. (B) [QUELLE: PocketGamer.biz https://www.pocketgamer.biz/80-of-roblox-users-are-on-mobile-contributing-46-of-robux-revenue, abgerufen 2026-10-12 via Websuche-Zusammenfassung]
- **2025 (Newzoo/Gamefam):** 80 % greifen über Mobile zu, aber nur 24 % der 10- bis 65-Jährigen spielen *ausschließlich* mobil. (B) [QUELLE: Newzoo via GameDevReports https://gamedevreports.substack.com/p/newzoo-roblox-as-a-platform-in-2025?open=false, abgerufen 2026-10-12 via Websuche-Zusammenfassung]
- **GameAnalytics 2025:** Die größte Gruppe wechselt zwischen PC und Mobile (knapp die Hälfte). (B) [QUELLE: GameAnalytics 2025 Roblox Benchmark Report https://investgame.net/wp-content/uploads/2025/09/2025-Roblox-Benchmark-Report.pdf, abgerufen 2026-10-12 via Websuche-Zusammenfassung]
- **Folge:** Wir entwickeln für Touch zuerst. Tastatur und Gamepad müssen trotzdem funktionieren, so wie Roblox es in seiner Anleitung zum „Adaptive Design“ vorgibt. (A) [QUELLE: Creator Hub „Adaptive design guidelines“ https://create.roblox.com/docs/production/publishing/adaptive-design, abgerufen 2026-10-12 via Websuche-Zusammenfassung]

### 2.4 Discovery: Was der Algorithmus belohnt

| Zeitpunkt | Änderung | Quelle |
|---|---|---|
| März 2025 | „Recommended For You“ (RFY) wird neu gebaut. Ziel ist langfristige Retention statt kurzer Spitzen. Irreführende Titel und Thumbnails werden abgewertet. | (B) [QUELLE: Tubefilter „Roblox discovery roadmap 2025“ https://www.tubefilter.com/2025/03/20/roblox-discovery-roadmap-2025/, abgerufen 2026-10-12 via Websuche-Zusammenfassung] |
| laufend | RFY arbeitet zweistufig und soll Spiele mit tiefem Engagement, sozialer Interaktion und Wiederspielen zeigen. | (A) [QUELLE: Creator Hub „Discovery“ https://create.roblox.com/docs/discovery, abgerufen 2026-10-12 via Websuche-Zusammenfassung] |
| Sept. 2025 | „Moments“ startet als Beta: Spiele werden über kurze Gameplay-Clips entdeckt. | (A) [QUELLE: Roblox Newsroom „RDC 2025“ https://about.roblox.com/newsroom/2025/09/roblox-rdc-2025, abgerufen 2026-10-12 via Websuche-Zusammenfassung] |
| Juni 2026 | Roblox schreibt: Wer langfristigen Wert über Retention, Co-Play und Ausgaben schafft, bekommt mehr Chancen. | (A) [QUELLE: Roblox Newsroom „Optimizing discovery…“ https://about.roblox.com/newsroom/2026/06/optimizing-discovery-great-games-reach-millions-players-roblox, abgerufen 2026-10-12 via Websuche-Zusammenfassung] |
| Juli 2026 (Q2-Call) | Retentionsstarke Spiele bekommen mehr Impressionen, auch zulasten kurzfristiger Monetarisierung. Laut Sekundärquelle wurde das Bewertungsfenster von 7 auf 28 Tage verlängert (nicht unabhängig bestätigt). | (A) [QUELLE: Roblox Q2 2026 Transcript https://s27.q4cdn.com/984876518/files/doc_financials/2026/q2/32789865_2009724400_3775763_Transcript_EditedCopy_20260730233208.pdf, abgerufen 2026-10-12 via Websuche-Zusammenfassung]; (C) [QUELLE: godisageek https://godisageek.com/2026/08/roblox-9-billion-algorithm-change/, abgerufen 2026-10-12 via Websuche-Zusammenfassung] |
| Sept. 2026 (RDC) | Rankings berücksichtigen Daten *über* die ersten 28 Tage hinaus. Roblox testet, wie viele neue Nutzer ein Spiel gewinnt. „Moments“ ist in den USA voll verfügbar. | (B) [QUELLE: GamesBeat RDC 2026 https://gamesbeat.com/roblox-hits-20-and-opens-rdc-2026-to-invite-the-world-to-play-and-make-games-dave-baszucki-keynote/, abgerufen 2026-10-12 via Websuche-Zusammenfassung]; (C) [QUELLE: Pro Game Guides RDC 2026 https://progameguides.com/roblox/rdc-2026-roblox-announces-standalone-apps-offline-play-ai-tools-and-more/, abgerufen 2026-10-12 via Websuche-Zusammenfassung] |

- **Unabhängige Analyse (Dubit):** Nach dem RFY-Start im März 2025 wurden 13 der Top-20-Spiele innerhalb von 9 Monaten ausgetauscht. Der Anteil „reifer“ (älterer) Spiele an den Top-20-Besuchen fiel in 6 Monaten von 84 % auf 18 %. Die Methodik ist nicht einsehbar. (B) [QUELLE: Dubit Blog https://dubit.io/blog/roblox-top-20-rfy, abgerufen 2026-10-12 via Websuche-Zusammenfassung]
- **Signale laut Dritten:** „qualified play-through rate“, wöchentliche Spielzeit und „intentional co-play“. Das ist nicht offiziell bestätigt. (C) [QUELLE: creation.dev https://www.creation.dev/learn/roblox-recommended-for-you-algorithm-signals-2026, abgerufen 2026-10-12 via Websuche-Zusammenfassung]
- **Session-Längen:** GameAnalytics teilt in Gelegenheits- und Kernspieler. Mitte 2025 dauerte eine Session bei ihnen etwa 2 Minuten bzw. über 37 Minuten. Laut Sekundärzusammenfassung haben Spiele mit Median-Session unter 6 Minuten nur etwa 6 % D1-Retention; im Bericht selbst nicht bestätigt. (B/C) [QUELLE: GameAnalytics 2025 Roblox Benchmark Report https://www.gameanalytics.com/cn/reports/2025-roblox-report, abgerufen 2026-10-12 via Websuche-Zusammenfassung]
- **Folgerung für die Konzeptwahl** [ANNAHME, abgeleitet aus den Quellen]: Wir sollten optimieren auf:
  1. eine erste Session, die zu einem klaren Abschluss führt (Play-through)
  2. Gründe, morgen wiederzukommen (D1/D7)
  3. Spaß, wenn Freunde im selben Server sind (Co-Play)

  Durch den hohen Austausch in den Top-Listen haben neue Spiele grundsätzlich eine Chance.

### 2.5 Trend-Spiele und Aufsteiger 2025–2026

| Spiel | Genre | Start | Kennzahl | Güte und Quelle |
|---|---|---|---|---|
| Grow a Garden | Garten/Idle-Sammeln | 2025 | fast 22 Mio. CCU (Juli 2025) | (A) [QUELLE: Roblox Q3 2025 Shareholder Letter https://www.sec.gov/Archives/edgar/data/1315098/000131509825000326/ex991-q32025shareholderl.htm, abgerufen 2026-10-12 via Websuche-Zusammenfassung] |
| Steal a Brainrot | „Steal“-Sammel-Tycoon | 2025 | 25,4 Mio. CCU (07.10.2025) | (B) [QUELLE: PocketGamer.biz https://www.pocketgamer.biz/robloxs-steal-a-brainrot-becomes-first-game-to-surpass-25m-concurrent-players, abgerufen 2026-10-12 via Websuche-Zusammenfassung] |
| 99 Nights in the Forest | Koop-Survival-Horror | 2025 | Höchstwert 14,2 Mio. CCU, ~26 Mrd. Besuche | (B) [QUELLE: The A.V. Club https://www.avclub.com/roblox-99-nights-in-the-forest-movie, abgerufen 2026-10-12 via Websuche-Zusammenfassung] |
| Dead Rails | Koop-Survival (Zug verteidigen) | 01.01.2025 | über 600.000 CCU an einem Wochenende (Stand Frühjahr 2025) | (B) [QUELLE: GameAnalytics „Dead Rails and the Hit Makers formula“ https://www.gameanalytics.com/blog/dead-rails-and-the-hit-makers-formula, abgerufen 2026-10-12 via Websuche-Zusammenfassung] |
| Scary Shawarma Kiosk: the ANOMALY | Anomalie-Horror | 25.08.2025 | Höchstwert 192.000 CCU, ~1,3 Mrd. Besuche | (C) [QUELLE: Rotrends https://rotrends.com/game/8539298853/Scary-Shawarma-Kiosk-the-ANOMALY-horror, abgerufen 2026-10-12 via Websuche-Zusammenfassung] |
| Animal Hospital (Anomaly) | Koop-Anomalie-Horror | 10.05.2026 | ~1,2 Mio. CCU (12.07.2026, laut Rolimons) | (C) [QUELLE: Know Your Meme https://knowyourmeme.com/memes/subcultures/animal-hospital-roblox, abgerufen 2026-10-12 via Websuche-Zusammenfassung] |
| Grow a Garden 2 | Garten mit Stehl-Mechanik | 12.06.2026 | Höchstwert unklar (Tracker widersprechen sich) | (C) [QUELLE: Pro Game Guides https://progameguides.com/roblox/grow-a-garden-2-release-date/, abgerufen 2026-10-12 via Websuche-Zusammenfassung] |
| „+1 Speed … Keyboard Escape“ und Varianten | „+1“-Escape-Obby | 2026 | Original am 20.08.2026 in den Top 10 (GGAID). Eine Klon-Variante erreichte 129.000 CCU (Juli 2026) und 100,8 Mio. Besuche. | (C) [QUELLE: StudioKrew „Top Roblox Games August 2026“ https://studiokrew.com/blog/top-roblox-games-august-2026/, abgerufen 2026-10-12 via Websuche-Zusammenfassung]; (C) [QUELLE: RoWatcher https://rowatcher.com/games/10127090395/w3-1-speed-slime-keyboard-escape, abgerufen 2026-10-12 via Websuche-Zusammenfassung] |
| Steal An Egg | „Steal“-Sammeln | ~25.07.2026 | 2,2–2,4 Mio. CCU (Aug./Sept. 2026). Am 08.10.2026 ~1,19 Mio., etwa 7-mal so viel wie Platz 2 (Brookhaven). | (C) [QUELLE: RoWatcher https://rowatcher.com/games/10563114921/steal-an-egg, abgerufen 2026-10-12 via Websuche-Zusammenfassung]; (C) [QUELLE: profitable.app https://profitable.app/roblox/games/steal-an-egg, abgerufen 2026-10-12 via Websuche-Zusammenfassung]; (C) [QUELLE: endgametools https://endgametools.com/en/roblox/news/roblox-most-popular-games, abgerufen 2026-10-12 via Websuche-Zusammenfassung] |

- **Evergreens:** Anfang Oktober 2026 standen Brookhaven RP, 99 Nights in the Forest, Adopt Me!, Murder Mystery 2, Blox Fruits, Dandy's World, RIVALS und DOORS weit oben. (C) [QUELLE: endgametools Charts 04.10.2026 https://endgametools.com/en/roblox/charts, abgerufen 2026-10-12 via Websuche-Zusammenfassung]
- **Beobachtung** [ANNAHME, Interpretation der Tabelle]:
  - Die Viral-Spitzen 2026 sind eine Größenordnung kleiner als 2025 (2 Mio. statt 20+ Mio. CCU).
  - Zwei Muster dominieren 2026: **„Stehlen und Sammeln“** (Steal An Egg) und **„Anomalie- und Koop-Horror“**.
  - **„+1“-Obbies** bilden eine breite, billig produzierte Welle mit vielen Klonen.

### 2.6 Häufige Kritik von Spielern und Eltern

| Problem | Beleg | Bedeutung für uns |
|---|---|---|
| Irreführende Monetarisierung (falsche Rabatte, Countdowns, die künstlich Dringlichkeit erzeugen, Zufallsbelohnungen, verschleierte Preise) | 14 von 15 umsatzstärksten Spielen zeigten solche Muster (Okt. 2025 – Feb. 2026). (B) [QUELLE: Universität Sydney, Report „Misleading and Deceptive Monetisation in Roblox“ https://ses.library.usyd.edu.au/handle/2123/35033, abgerufen 2026-10-12 via Websuche-Zusammenfassung] | Keine Countdown-Kaufanreize und keine „Tagesangebote“, auch nicht später. |
| Manipulatives, süchtig machendes Design | FTC-Beschwerde von Fairplay, NCOSE und EPIC (Mai 2026). (B) [QUELLE: Fortune https://fortune.com/2026/05/20/exclusive-advocacy-groups-file-complaint-roblox-manipulative-design/, abgerufen 2026-10-12 via Websuche-Zusammenfassung]. Sammelklage in British Columbia (Sept. 2025). (B) [QUELLE: CBC https://www.cbc.ca/lite/story/1.7642727, abgerufen 2026-10-12 via Websuche-Zusammenfassung] | Kein Streak-Druck, keine Strafe für Pausen. |
| Handels-Scams und Item-Duping | Grow a Garden: Beim Verschenken gibt eine Seite zuerst, Betrüger geben sich als Admins aus, Pets wurden dupliziert, das Verschenken wurde zeitweise abgeschaltet. (C) [QUELLE: Gamezebo https://www.gamezebo.com/walkthroughs/what-happens-if-you-get-scammed-in-grow-a-garden/, abgerufen 2026-10-12 via Websuche-Zusammenfassung]; (C) [QUELLE: Sportskeeda https://www.sportskeeda.com/roblox-news/why-pet-gifting-disabled-grow-garden, abgerufen 2026-10-12 via Websuche-Zusammenfassung] | Kein Handel zwischen Spielern im MVP. |
| Kontakt zu Fremden über Spielfunktionen | In Grow a Garden folgt auf das Teilen von Samen eine Freundschaftsanfrage an Fremde (Meinungsbeitrag). (B/C) [QUELLE: The West Australian via broomead.com.au https://www.broomead.com.au/opinion/ben-oshea-theres-a-sinister-side-to-kids-sedate-online-gardening-game-c-19274605, abgerufen 2026-10-12 via Websuche-Zusammenfassung]. Klagewelle zum Kinderschutz. (B) [QUELLE: ABC News https://abcnews.go.com/family/story/roblox-announces-new-safety-measure-amid-spate-lawsuits-127626071, abgerufen 2026-10-12 via Websuche-Zusammenfassung] | Keine eigenen Freundschafts- oder Chat-Aufforderungen im Spiel. |
| Exploiter und Cheats | Roblox liefert inzwischen „Server Authority“ gegen Physik-Exploits wie Speedhacks. Dafür ist die Beta „Next Generation Replication“ nötig. (A) [QUELLE: DevForum „[Full Release] Ship Fair And Competitive Games with Server Authority“ https://devforum.roblox.com/t/full-release-ship-fair-and-competitive-games-with-server-authority/4727993, abgerufen 2026-10-12 via Websuche-Zusammenfassung] | Bestenlisten serverseitig auf Plausibilität prüfen. |
| Schlechte Mobile-UX | UI skaliert schlecht auf kleinen Bildschirmen, Touch ist im Kampf ungenau, ältere Geräte laggen. (C) [QUELLE: RoWatcher „Best Roblox Games for Mobile in 2026“ https://rowatcher.com/news/best-roblox-games-for-mobile-in-2026-10-games-that-actually-play-well-on-phone, abgerufen 2026-10-12 via Websuche-Zusammenfassung] | Große Buttons, wenig Text, keine Präzisions-Kämpfe. |
| Toxische Bewertungen | In Dress to Impress geben Spieler Konkurrenten aus Prinzip die schlechteste Wertung („Spite-Voting“). (C) [QUELLE: RoWatcher DTI https://rowatcher.com/news/dress-to-impress-how-a-teen-developer-s-fashion-game-hit-9-7-billion-visits, abgerufen 2026-10-12 via Websuche-Zusammenfassung] | Keine Wertungen von Spielern über Spieler. |
| Grind und Pay-to-Win | Ich habe keine belastbare Quelle gefunden. [VORWISSEN, nicht aktuell]: Das ist ein häufiger Kritikpunkt bei Simulatoren mit Robux-Multiplikatoren. | Später nur Kosmetik verkaufen, keine Tempo- oder Fortschritts-Boosts. |

### 2.7 Fast Follow, Klonwellen und kurze Zyklen

- **Steal a Brainrot:** Die Entwickler haben seit November 2025 mindestens vier Klagen gegen Nachahmer eingereicht. (B) [QUELLE: Bloomberg, 24.03.2026 https://www.bloomberg.com/news/articles/2026-03-24/roblox-s-hit-game-steal-a-brainrot-battles-its-many-imitators, abgerufen 2026-10-12 via Websuche-Zusammenfassung]
- **Boom und Absturz bei Steal a Brainrot:** Laut Zusammenfassung fiel das Spiel von 25,8 Mio. CCU (Okt. 2025) auf ~215.000 CCU (−99,2 %). Ob die Zahl von Bloomberg oder RoWatcher stammt, ist unklar. (B/C) [QUELLE: RoWatcher „Is the Brainrot Trend Dying?“ https://rowatcher.com/news/is-the-brainrot-trend-dying-what-ccu-data-from-three-top-games-reveals, abgerufen 2026-10-12 via Websuche-Zusammenfassung]
- **Wechsel der Spieler:** Als Steal a Brainrot aufkam, verlor Grow a Garden laut einem italienischen Bericht innerhalb weniger Tage mehr als die Hälfte seiner Spieler. (C) [QUELLE: Multiplayer.it https://multiplayer.it/notizie/il-fenomeno-grow-a-garden-di-roblox-ha-gia-un-contendente-che-gli-sta-succhiando-utenti.html, abgerufen 2026-10-12 via Websuche-Zusammenfassung]
- **„Admin Abuse“-Events am Wochenende** treiben gezielt gleichzeitige Logins und damit CCU-Spitzen. (B) [QUELLE: Tubefilter https://www.tubefilter.com/?p=188004, abgerufen 2026-10-12 via Websuche-Zusammenfassung]
- **Portfolio-Strategie:** Das Studio hinter Dead Rails hat 70 Titel veröffentlicht, Dead Rails übertrifft die anderen 69 deutlich. Als Hit-Rezept nennt GameAnalytics „MAYA“ (Most Advanced Yet Acceptable): Vertrautes mit einer neuen Wendung kombinieren. (B/C) [QUELLE: GameAnalytics https://www.gameanalytics.com/blog/dead-rails-and-the-hit-makers-formula, abgerufen 2026-10-12 via Websuche-Zusammenfassung]
- **Folgerung** [ANNAHME]: Ein KI-Team ohne Art-Pipeline gewinnt kein Wettrennen um Trend-Klone, denn Klone leben von Meme-Figuren und Assets. Unser Vorteil muss **systemische Tiefe und prozedurale Vielfalt** sein, nicht Geschwindigkeit beim Kopieren.

### 2.8 Regulatorischer Rahmen (Übergabe an Compliance)

- **Content-Maturity-Labels:** Es gibt vier Stufen: Minimal, Mild, Moderate und Restricted.
  - **Minimal:** gelegentliche milde Gewalt
  - **Mild:** wiederholte milde Gewalt, milde Angstinhalte

  Minimal und Mild sind laut Zusammenfassung für „Roblox Kids (5–8)“ und „Roblox Select (9–15)“ zugelassen, mit zusätzlichen Veröffentlichungsanforderungen. Diese Bezeichnungen konnte ich nicht verifizieren, Compliance sollte das prüfen. (A) [QUELLE: Creator Hub „Content maturity“ https://create.roblox.com/docs/en-us/production/promotion/content-maturity, abgerufen 2026-10-12 via Websuche-Zusammenfassung]
- **Unter-13-Jährige** können unbewertete Spiele standardmäßig nicht spielen. Social Hangouts und freie 2D-Zeichen-Spiele sind für sie gesperrt. Der Maturity-Fragebogen ist Pflicht. (B) [QUELLE: TechCrunch, 07.11.2024 https://techcrunch.com/2024/11/07/roblox-adds-new-safety-measures-to-ban-kids-under-13-from-social-spaces, abgerufen 2026-10-12 via Websuche-Zusammenfassung]
- **Bezahlte Zufallsitems:** Alle möglichen Ergebnisse müssen mit Quoten in Prozent angegeben werden, die zusammen 100 % ergeben. Das gilt auch indirekt, etwa wenn ein mit Robux gekaufter Samen später ein Zufallsergebnis bringt. (A) [QUELLE: Creator Hub „Paid random items“ https://create.roblox.com/docs/production/monetization/paid-random-items, abgerufen 2026-10-12 via Websuche-Zusammenfassung]
- **Chat:** Seit Januar 2026 ist für den Chat weltweit eine Altersprüfung per Gesichtsscan Pflicht. Für Unter-9-Jährige ist der Chat standardmäßig aus. (B) [QUELLE: ClickOrlando https://www.clickorlando.com/news/local/2026/01/08/roblox-launches-mandatory-face-scans-for-chat-safety-amid-lawsuits, abgerufen 2026-10-12 via Websuche-Zusammenfassung]; [QUELLE: ABC News https://abcnews.go.com/family/story/roblox-announces-new-safety-measure-amid-spate-lawsuits-127626071, abgerufen 2026-10-12 via Websuche-Zusammenfassung]
- **EN+DE:** Die automatische Übersetzung unterstützt Deutsch. Es gibt ein Anfangskontingent und danach ein Monatskontingent. (A) [QUELLE: Creator Hub „Automatic translations“ https://create.roblox.com/docs/production/localization/automatic-translations, abgerufen 2026-10-12 via Websuche-Zusammenfassung]. Empfehlung: eigene Lokalisierungstabelle per Code (D-008), die automatische Übersetzung nur als Fallback.

## 3. Genre-Analyse

Bewertung von Nachfrage und Konkurrenz: [ANNAHME, abgeleitet aus Abschnitt 2]. Die Spalte „Eignung für uns“ misst, wie gut sich das Genre nur mit Code und Primitiven, ohne Studio, umsetzen lässt.

| Genre | Nachfrage | Konkurrenz | Typische Retention-Hooks | Typische Probleme | Eignung für uns |
|---|---|---|---|---|---|
| 1. „Steal“-Sammel-Tycoon | sehr hoch (Steal a Brainrot, Steal An Egg) | extrem, Klone und Klagen | seltene Figuren sammeln, Basis verteidigen, Admin-Events, Offline-Einkommen | Stehlen als Kernmechanik bei Kindern, Boom-Bust, Seltenheit nahe am Glücksspiel | **niedrig**: Meme-Figuren nötig, hohes Compliance-Risiko |
| 2. Garten/Idle-Wachstum | hoch (Grow a Garden, Grow a Garden 2) | extrem, Platzhirsch mit Nachfolger | Echtzeit-Timer, Mutationen, Wetter-Events, Handel | Scams, Duping, FOMO, Stehlen in Grow a Garden 2 | **mittel-hoch**: Pflanzen lassen sich prozedural bauen, Abgrenzung ist schwer |
| 3. Obby / Turm / „+1“-Escape | hoch und dauerhaft (Tower of Hell, „+1“-Welle 2026) | sehr hoch, aber geringe Einstiegshürde | sichtbare Höhe als Fortschritt, wachsende Zahlen („+1“), Können meistern, Zufallsstrecken, Bestenlisten | Frust, kurze Sessions, „Pay-to-Skip“, schwache Bindung [ANNAHME] | **sehr hoch**: Parts sind das Grundmaterial des Genres |
| 4. Koop-Survival und Anomalie-Horror | hoch (99 Nights, Animal Hospital, Shawarma Kiosk) | mittel, wachsend | Freunde, Nacht-Zähler, Events, Spannung | Angstinhalte (Label Mild oder Moderate), Jumpscares, Anomalien sind nach einmal Spielen bekannt | **mittel**: Atmosphäre per Licht möglich, Kreaturen und Animationen nicht |
| 5. Tower Defense | mittel-hoch, dauerhaft | hoch | Einheiten sammeln (oft Gacha), Wellen, Koop | bezahlter Zufall, Balancing | **mittel**: Einheiten aus Primitiven möglich, der Sammelreiz hängt aber an der Figuren-Grafik |
| 6. Kampf / Anime / PvP-Shooter | hoch (RIVALS, Jujutsu Shenanigans) | hoch, hohe Qualitätslatte | Können, Ranglisten | Gewalt-Label, Exploiter, Netcode, Touch-Präzision | **niedrig**: Animationen und VFX nötig, Netcode schwer testbar |
| 7. Rollenspiel / Social Hangout | sehr hoch (Brookhaven, Adopt Me!) | extrem, Netzwerkeffekte | Freunde, Häuser, Identität | Chat und Kontakt zu Fremden, für Unter-13-Jährige gesperrt | **ausgeschlossen** (Kinderschutz) |
| 8. Fashion / Dress-up | hoch, älteres Publikum | mittel | Kreativität, Abstimmungen, Kollaborationen | Spite-Voting, viele Kleidungs-Assets nötig | **sehr niedrig**: kein Art-Content möglich |

**Belege zur Tabelle:**
- **Tower of Hell:** ~22 Mrd. Besuche, jede Runde ein zufällig erzeugter Turm ohne Checkpoints. (B) [QUELLE: Pocket Tactics https://www.pockettactics.com/tower-of-hell/visits, abgerufen 2026-10-12 via Websuche-Zusammenfassung]
- **„Roblox but every second you get +1 Speed“:** 75,2 Mio. Besuche. (C) [QUELLE: Bloxodes https://bloxodes.com/stats/games/roblox-but-every-second-you-get-1-speed-4122139330, abgerufen 2026-10-12 via Websuche-Zusammenfassung]
- **Garten/Idle:** Laut einem Trendbericht stieg der durchschnittliche CCU des Genres im Jan./Feb. 2026 auf 4,8 Mio., +185 % gegenüber Q4 2025. Die Quelle ist SEO-nah. (C) [QUELLE: rolearn.dev Q1 2026 https://rolearn.dev/trend-reports/q1-2026-market-trends/, abgerufen 2026-10-12 via Websuche-Zusammenfassung]
- **Tower Defense:** Anime Defenders liegt bei 40.000–60.000 CCU, nach über 200.000 im Jahr 2025. (C) [QUELLE: earnaldo.com https://earnaldo.com/blog/tower-defense-simulator-vs-anime-defenders, abgerufen 2026-10-12 via Websuche-Zusammenfassung]
- **Dress to Impress:** 63 % der Spieler sind über 13 (laut Zusammenfassung). (C) [QUELLE: RoWatcher DTI https://rowatcher.com/news/dress-to-impress-how-a-teen-developer-s-fashion-game-hit-9-7-billion-visits, abgerufen 2026-10-12 via Websuche-Zusammenfassung]

**Fazit:** Für unser Team passen Genre 3 (Obby/Turm), Genre 4 (Anomalie, entschärft) und Genre 2 (Garten, ohne Stehlen und Handel) am besten. Daraus entstehen die drei Konzepte in Abschnitt 5.

## 4. Referenzspiele: was funktioniert und was fehlt

Aus diesen Spielen leite ich nur **Prinzipien** ab. Namen, Figuren, Assets und konkrete Designs übernehmen wir nicht.

1. **Grow a Garden** (fast 22 Mio. CCU im Juli 2025, (A), Quelle in 2.5)
   - *Was funktioniert:* Echtzeit-Wachstum gibt einen Grund, wiederzukommen. Der Einstieg ist ruhig und gewaltfrei. Die Fortschrittsschleife (pflanzen, ernten, verkaufen, ausbauen) versteht jeder sofort.
   - *Kritik:* „Exzessive Monetarisierung“ (C) [QUELLE: Wikipedia „Grow a Garden“ https://en.wikipedia.org/wiki/Grow_a_Garden, abgerufen 2026-10-12 via Websuche-Zusammenfassung], Handels-Scams und Duping (2.6).
   - *Prinzip:* Sichtbares Wachstum plus kurze, einfache Schleife. Ohne Handel und ohne Druck durch künstliche Knappheit.
2. **Steal a Brainrot** (25,4 Mio. CCU, (B), 2.5)
   - *Was funktioniert:* Meme-Figuren und Sammeln, sozialer Konflikt (stehlen und verteidigen), Wochenend-Events.
   - *Kritik:* Absturz um ~99 % (2.7), Klonflut, Stehlen als Kernmechanik ist für Kinder problematisch.
   - *Prinzip:* Termine, zu denen alle gleichzeitig spielen, erzeugen Gemeinschaft. Wir übernehmen das nur als harmloses gemeinsames Ziel, ohne Stehlen.
3. **99 Nights in the Forest** (Höchstwert 14,2 Mio. CCU, (B), 2.5)
   - *Was funktioniert:* Koop mit wenigen Freunden, ein klares Ziel mit Zähler (Nächte überleben), regelmäßige Events. Ein Event zog über 1,4 Mio. Spieler. (C) [QUELLE: AllThingsHow https://allthings.how/99-nights-in-the-forest-events-schedule/, abgerufen 2026-10-12 via Websuche-Zusammenfassung]
   - *Kritik:* Horror-Kreaturen und Kampf brauchen Art-Content.
   - *Prinzip:* Ein klarer Zähler als Ziel („Etage 30“, „Nacht 5“) und Koop als Antrieb.
4. **Tower of Hell** (~22 Mrd. Besuche, (B), Abschnitt 3)
   - *Was funktioniert:* Jede Runde wird zufällig aus Modulen zusammengesetzt, das gibt unbegrenzte Variation ohne neuen Content. Die Aufgabe ist sofort klar: nach oben.
   - *Kritik:* Ohne Checkpoints ist es hart, für 9-Jährige frustrierend [ANNAHME].
   - *Prinzip:* **Prozedurale Modul-Zusammensetzung**, aber mit kindgerechten Checkpoints.
5. **„+1 Speed … Keyboard Escape“-Familie** (Top 10 im Aug. 2026, (C), 2.5)
   - *Was funktioniert:* Jede Aktion macht dich messbar stärker. Die wachsende Zahl fühlt sich gut an, und die Spiele lassen sich billig produzieren. (C) [QUELLE: Beebom https://beebom.com/plus-1-speed-keyboard-escape-codes/, abgerufen 2026-10-12 via Websuche-Zusammenfassung]
   - *Kritik:* Dutzende fast gleiche Klone, wenig Tiefe [ANNAHME].
   - *Prinzip:* Das „+1“-Gefühl übernehmen, aber in **echte Fähigkeiten** übersetzen, die neue Wege öffnen.
6. **Animal Hospital (Anomaly)** (~1,2 Mio. CCU im Juli 2026, (C), 2.5)
   - *Was funktioniert:* Ein Ort, eine Schicht, die Aufgabe „finde, was nicht stimmt“, im Koop gespielt. Ein einfaches Regelwerk mit hohem Gesprächswert.
   - *Kritik:* Horror-Rahmen. Wenn alle Anomalien bekannt sind, ist der Content verbraucht [ANNAHME].
   - *Prinzip:* **Eine Map mit Beobachtungs-Schleife.** Die Anomalien prozedural erzeugen.
7. **Dead Rails** (über 600.000 CCU, (B), 2.5)
   - *Was funktioniert:* Vertraute Formate (bewegliche Basis, Reise mit Gefahren) bekommen eine neue Wendung („MAYA“).
   - *Kritik:* Die Spielerzahlen sind stark abgekühlt (C).
   - *Prinzip:* Ein bekanntes Genre plus *eine* klare neue Idee.
8. **Fisch** (Höchstwert 1,3 Mio. CCU, durchschnittliche Session 29,1 Min. (C) [QUELLE: Rotrends https://rotrends.com/game/5750914919, abgerufen 2026-10-12 via Websuche-Zusammenfassung])
   - *Was funktioniert:* Eine ruhige Kernhandlung mit einem kleinen Geschicklichkeits-Minispiel und eine Sammel-Enzyklopädie. Das trägt lange Sessions.
   - *Prinzip:* Eine kleine Geschicklichkeits-Aktion im Kern plus ein Sammelalbum als Langzeitziel.
9. **Dress to Impress** (~9,7 Mrd. Besuche (C), 2.6)
   - *Was funktioniert:* Kreativer Ausdruck, Abstimmungsrunden, Kollaborationen.
   - *Kritik:* Spite-Voting, viele Assets nötig.
   - *Prinzip:* **Keine Wertungen von Spielern über Spieler**. Selbstausdruck nur über erspielte Kosmetik.

## 5. Drei Spielkonzepte

Bewertungsskala jeweils 1–5. **Nachfrage:** 5 = sehr hoch. **Konkurrenzdichte:** 5 = wenig Konkurrenz. **Umsetzbarkeit:** 5 = mit Code und Primitiven ohne Studio gut machbar. Die Arbeitstitel sind eigene Namen; eine Markenprüfung steht noch aus.

### Konzept A: „Schwungturm“ (EN: „Momentum Tower“), optimiert auf Umsetzbarkeit mit Primitiven

- **Pitch:** Ein prozedural erzeugter Leuchtturm aus Bausteinen. Jeder Sprung bringt Schwung, jeder Lauf schaltet neue Bewegungs-Fähigkeiten frei, und jeden Tag wartet ein neuer Tagesturm, der für alle Spieler gleich ist.
- **Core Loop:**
  1. Lauf starten.
  2. Etagen klettern. Jede Etage wird aus Modulen gebaut: Plattformen, Sprungpads, Förderbänder, bewegliche und kippende Blöcke.
  3. „Schwung-Funken“ sammeln. Sie geben im Lauf gedeckelt mehr Tempo und Sprungkraft, das „+1“-Gefühl.
  4. Wer fällt, startet am letzten Checkpoint (alle 5 Etagen) neu.
  5. Am Checkpoint werden Funken gegen dauerhafte Fähigkeiten getauscht: Doppelsprung, Wandsprung, Dash, Gleiter. Sie öffnen neue Routen und Abkürzungen.
  6. Danach geht es höher. Ist der Gipfel erreicht, wird der Tagesturm freigeschaltet (gleicher Seed weltweit, persönliche Bestmarke, Bestenliste nach Höhe und Zeit).
- **Erstinhalt (15–20 Min., Projektvorgabe):** 1 Turm mit 3 Zonen zu je 10 Etagen:
  - „Wiese“: Tutorial
  - „Wolken“: Doppelsprung
  - „Gewitter“: Dash und Wandsprung

  Rechnerisch etwa 30–40 s pro Etage für Erstspieler. [ANNAHME, im Playtest zu prüfen]
- **Passung 9–14 und Mobile:** Die Regeln sind sofort klar („nach oben“) und brauchen keinen Text. Roblox-Standardsteuerung mit Stick und Sprungknopf [VORWISSEN, nicht aktuell], dazu ein großer Fähigkeiten-Knopf. Runden lassen sich am Checkpoint unterbrechen. Keine Gewalt. Erwartetes Label: Minimal. [ANNAHME, Compliance prüft]
- **Differenzierung:** Gegenüber „+1“-Klonen bietet es echte Fähigkeiten statt nur wachsender Zahlen. Gegenüber Tower of Hell hat es Checkpoints für Kinder und einen täglich neuen, für alle gleichen Turm. Tempo lässt sich nicht kaufen. **Stretch-Ziel:** „Seilschaft“. Freunde im selben Server sehen sich als farbige Leuchtspur-Marker und bekommen einen Bonus, wenn sie einen Checkpoint gemeinsam erreichen. Das liefert ein Co-Play-Signal ohne Chat.
- **Art-Ansatz mit Primitiven:**
  - Materialien Neon, Glass, SmoothPlastic und ForceField
  - eine Farbpalette pro Zone
  - Lighting mit Atmosphere, Bloom und ColorCorrection
  - Beams als Leuchtpfade zwischen Checkpoints
  - Partikel für Funken
  - Wolken aus halbtransparenten Kugeln

  Alles wird per Code generiert. Ob Standard-Partikeltexturen ohne externe Asset-ID nutzbar sind, ist offen. [ANNAHME, Systems Engineer prüft]
- **Technische Stärke:** Der Generator ist eine reine Funktion: Er nimmt einen Seed und liefert eine Liste von Bauteil-Beschreibungen. Ein Erreichbarkeitsprüfer berechnet maximale Sprungweite und -höhe aus WalkSpeed, JumpPower und Gravity und garantiert, dass jede Etage lösbar ist. Beides lässt sich vollständig im Luau-CLI testen. Das Bauen der Instanzen ist eine dünne Schicht darüber.
- **Risiken:**
  1. **Konkurrenz und Discovery:** Es gibt sehr viele Obbies und Klone.
  2. **Bewegungsgefühl und Schwierigkeit** lassen sich nur im Studio und auf einem echten Handy prüfen. Der Owner muss früh testen.
  3. **Schwache Bindung im Obby-Genre** [ANNAHME]. Gegenmittel: Tagesturm, Fähigkeiten-Meta, Bestmarke.
  4. **Frust** bei Jüngeren. Gegenmittel: Checkpoints und eine kostenlose Hilfe (z. B. eine Leuchtspur nach X Fehlversuchen).
  5. **Cheats in der Bestenliste**, weil Charakterbewegung standardmäßig vom Client gesteuert wird. [VORWISSEN, nicht aktuell] Gegenmittel: serverseitige Plausibilitätsprüfung (Reihenfolge der Checkpoints, Mindestzeiten), optional Server Authority (2.6).
  6. **Zu viele Parts** für schwache Handys. Gegenmittel: Instance Streaming und nur die Etagen in der Nähe bauen. [VORWISSEN, nicht aktuell]
  - **Compliance-Risiko: niedrig.** Keine Gewalt, kein Chat-Feature, kein Handel, kein Zufallskauf. Zu prüfen: In der Bestenliste erscheinen Anzeigenamen. Der Tagesturm darf keinen Streak-Zwang und keine Countdown-Kaufanreize haben.
- **Chancen-Bewertung:**

| Kriterium | Wert | Begründung |
|---|---|---|
| Nachfrage | **4** | Obbies sind dauerhaft gefragt (Tower of Hell ~22 Mrd. Besuche). Die „+1“-Escape-Welle war im Aug. 2026 in den Top 10. Die Einzelzahlen stammen aber nur aus Quellen der Güte (C). |
| Konkurrenzdichte | **2** | Dutzende nahezu gleiche „+1“-Klone (RoWatcher-Listings). Die Einstiegshürde ist für alle niedrig. |
| Umsetzbarkeit | **5** | Parts sind das Grundmaterial des Genres. Generator und Erreichbarkeit sind reine Logik und damit testbar. Keine Assets, kaum Netcode (Bewegung macht Roblox). |
| **Gesamt** | **11/15**, gewichtet **16/20** | Gewichtung: Umsetzbarkeit zählt doppelt, weil sie unsere härteste Grenze ist. [ANNAHME, Methodenentscheidung] |

### Konzept B: „Formwächter“ (EN: „Shape Warden“), kindgerechtes Koop-Anomalie-Spiel

- **Pitch:** Als Nachtwächter in einem verzauberten Formen-Museum gehst du allein oder mit bis zu 3 Freunden durch die Säle und meldest, was sich verändert hat. Es geht um Rätseln und Spannung, nicht um Schrecken.
- **Core Loop:**
  1. Eine Schicht starten (Nacht 1–5, je ~3–4 Min. [ANNAHME]).
  2. Durch die Säle gehen und sich den Normalzustand merken.
  3. Veränderungen entdecken: Farbe, Größe, Position, Anzahl, Drehung oder Licht ändern sich.
  4. Die Veränderung per Tippen auf das Objekt melden. Richtige Meldungen bringen Sterne, falsche kosten Zeit.
  5. Bleiben zu viele Anomalien unentdeckt, ist die Schicht verloren. Das Museum „verzaubert sich“, es gibt keinen Jumpscare.
  6. Mit Sternen werden neue Säle und Werkzeuge freigeschaltet, z. B. eine „Vorher-Kamera“ mit Abklingzeit.
- **Passung 9–14 und Mobile:** Tippen auf Objekte passt gut zu Touch. Kurze Schichten. Koop ohne Chat funktioniert über Zeigen (Ping-Marker). Höchstens milde Spannung. Erwartetes Label: Minimal oder Mild. [ANNAHME]
- **Differenzierung:** Der Trend „Anomalie“ ohne Horror. **Prozedural erzeugte Anomalien** geben unbegrenzt viele Varianten und lösen damit die Content-Schwäche des Genres. Die Ausstellungsstücke sind prozedurale „Formen-Skulpturen“, das Primitive-Aussehen ist also Teil der Fiktion.
- **Art-Ansatz mit Primitiven:** Säle aus Parts, Sockel, Glasvitrinen und Skulpturen aus kombinierten Grundkörpern. Für die Nachtstimmung: Spot- und Point-Lights, Lichtkegel einer Taschenlampe, Atmosphere.
- **Risiken:**
  1. **Der Reiz des Genres hängt an Grusel und detailreichen Szenen.** Eine entschärfte Version aus Primitiven könnte weniger viral sein. [ANNAHME]
  2. **Fairness der Unterschiede** (weder unsichtbar noch zu leicht) auf 6-Zoll-Displays lässt sich nur auf dem Gerät abstimmen. Das braucht viele Owner-Playtests.
  3. **Koop-Synchronisation:** Anomalien liegen auf dem Server. Das ist machbar, aber außerhalb von Studio schwer zu testen.
  - **Compliance-Risiko: niedrig bis mittel.** Milde Angstinhalte beeinflussen das Label. Keine Gewalt, kein Handel.
- **Chancen-Bewertung:**

| Kriterium | Wert | Begründung |
|---|---|---|
| Nachfrage | **4** | Anomalie-Spiele sind der Aufsteiger 2025/26: Animal Hospital ~1,2 Mio. CCU, Shawarma Kiosk 192.000. Belegt ist das aber nur für Horror-Varianten, die Nachfrage nach einer entschärften Version ist unsicher. |
| Konkurrenzdichte | **3** | Eine wachsende Klonwelle (Home Alone Anomaly, Night at the Infirmary, Pharmacy Anomalies, (C)), aber kaum gewaltfreie oder kindgerechte Varianten gefunden [ANNAHME]. |
| Umsetzbarkeit | **3** | Raum- und Anomalie-Generator sind gut testbar. Der Spielspaß hängt aber an der *Wahrnehmung* (Atmosphäre, Erkennbarkeit), und die lässt sich ohne Studio kaum iterieren. |
| **Gesamt** | **10/15**, gewichtet **13/20** | |

### Konzept C: „Kreuzbeet“ (EN: „Crossbloom Garden“), prozedurale Pflanzenzucht

- **Pitch:** Züchte Pflanzen, die vor deinen Augen aus Formen wachsen. Kreuze zwei Pflanzen, und ihre sichtbaren „Gene“ (Farbe, Blattform, Wuchs, Leuchten) mischen sich nach verständlichen Regeln zu neuen Sorten für dein Gewächshaus-Album.
- **Core Loop:**
  1. Säen.
  2. Wachsen lassen. Kurze Timer plus ein kleines Pflege-Minispiel (gießen, Licht).
  3. Ernten. Das bringt Münzen und Gen-Proben.
  4. Zwei Pflanzen kreuzen. Die Vererbung ist **deterministisch und wird angezeigt**.
  5. Neue Sorten wandern ins Album.
  6. Münzen fließen in Beete, Gewächshaus-Ausbau und Werkzeuge.
- **Passung 9–14 und Mobile:** Ruhig, gewaltfrei und tippbasiert. Die Genetik ist ein Lern- und Puzzle-Element, das auch Eltern positiv sehen könnten. [ANNAHME]
- **Differenzierung:** Sichtbare, verstehbare Vererbung statt Zufalls-Mutationen. Kein Stehlen (im Gegensatz zu Grow a Garden 2), kein Handel (keine Scams). Pflanzen werden per L-System erzeugt, also prozedural nach Regeln. Das ergibt unbegrenzt viele Sorten ohne Art-Assets.
- **Art-Ansatz mit Primitiven:** Stiele aus Zylindern, Blätter aus Wedges und flachen Parts, Blüten aus Kugeln und Neon. Wachstum per Tween. Gewächshaus aus Glass-Parts.
- **Risiken:**
  1. **Extreme Konkurrenz:** Grow a Garden und Grow a Garden 2 plus Klone.
  2. **Idle-Bindung kippt leicht in FOMO-Design** (Abschnitt 2.6). Das müssen wir bewusst vermeiden.
  3. **Speicherstände und Offline-Wachstum** brauchen DataStores, die nur in Studio und live testbar sind.
  4. **Viele Parts pro Pflanze** belasten die Performance auf schwachen Handys.
  - **Compliance-Risiko: mittel**, falls je Zufall bei Kreuzungen und Monetarisierung zusammenkommen. Dann gilt die Pflicht zur Quotenangabe für indirekte bezahlte Zufallsitems (2.8). Im MVP: niedrig.
- **Chancen-Bewertung:**

| Kriterium | Wert | Begründung |
|---|---|---|
| Nachfrage | **4** | Grow a Garden fast 22 Mio. CCU (A). Grow a Garden 2 ist 2026 gestartet. Der Garten-Trend ist belegt. |
| Konkurrenzdichte | **1** | Ein Platzhirsch mit Nachfolger und großer Partner-Struktur. Spieler wechseln schnell zum nächsten Hit (2.7). |
| Umsetzbarkeit | **4** | L-System und Vererbung sind reine Logik und gut testbar. DataStore, Offline-Wachstum und Part-Budget sind die Unsicherheiten. |
| **Gesamt** | **9/15**, gewichtet **13/20** | |

## 6. Bewertungsmatrix und Empfehlung

| Konzept | Nachfrage | Konkurrenz (5 = wenig) | Umsetzbarkeit | Summe | Gewichtet (Umsetzbarkeit ×2) | Compliance-Risiko |
|---|---|---|---|---|---|---|
| **A Schwungturm** | 4 | 2 | **5** | **11** | **16** | niedrig |
| B Formwächter | 4 | 3 | 3 | 10 | 13 | niedrig bis mittel |
| C Kreuzbeet | 4 | 1 | 4 | 9 | 13 | niedrig, später mittel |

**Empfehlung: Konzept A „Schwungturm“.**

1. **Umsetzbarkeit:** Es ist das einzige Konzept, dessen Spielspaß fast vollständig aus Systemen entsteht (Generator, Fähigkeiten, Bewegung) und dessen Look ganz aus Primitiven bestehen *darf*, weil das Genre so aussieht. Den riskanten Teil (lösbare Level) können wir mit reinen Logik-Tests absichern.
2. **Trend:** Es setzt auf einen nachweislich laufenden Trend 2026 („+1“-Escape-Obbies) und auf ein Evergreen-Genre (Obbies).
3. **Discovery:** Es passt zu dem, was RFY 2025/26 belohnt. Die erste Session hat ein klares Ende (Gipfel, „Play-through“). Der Tagesturm und die persönliche Bestmarke geben Gründe, wiederzukommen. Die Seilschaft (Stretch-Ziel) liefert Co-Play.
4. **Compliance:** Es hat das geringste Risiko: keine Gewalt, kein Stehlen, kein Handel, kein Chat-Fokus, kein Zufallskauf.
5. **Monetarisierung später:** Erspielbare und kaufbare **kosmetische** Leuchtspuren als Game Pass sind möglich, ohne den Fortschritt zu beeinflussen.

**Grobe Aufteilung des MVP** [ANNAHME, Vorschlag für den Orchestrator]:
- **Sprint 1:** Generator, Erreichbarkeitsprüfer, Zone 1, Checkpoints, Mobile-UI. Danach testet der Owner in Studio und auf dem Handy.
- **Sprint 2:** Fähigkeiten, Zonen 2–3, Lokalisierung EN/DE, Speicherstand.
- **Sprint 3:** Tagesturm, Bestenliste mit serverseitiger Plausibilitätsprüfung, Feinschliff.

**Was die Empfehlung kippen würde:**
1. **Bewegung fühlt sich schlecht an:** Der Owner-Playtest nach Sprint 1 zeigt, dass Bewegung oder Schwierigkeit auf Mobile frustrierend sind und das mit Parametern nicht zu beheben ist. → Wechsel zu B.
2. **Neue Daten:** Sie zeigen, dass die „+1“-/Obby-Welle eingebrochen ist oder dass RFY Obbies wegen schwacher D7-Retention dauerhaft schlecht ausspielt. → B neu bewerten.
3. **Der Owner gibt Assets frei** (z. B. Sounds und Modelle aus dem Roblox-Katalog, Licht-Presets). Dann steigt die Umsetzbarkeit von B auf 4 bis 5, und B würde wegen geringerer Konkurrenz vorne liegen.
4. **Compliance stuft etwas als problematisch ein,** etwa Bestenlisten mit Anzeigenamen oder Tages-Ziele als FOMO. → Diese Funktionen abschwächen; nur wenn das den Kern trifft, B wählen.
5. **Der Owner will ausdrücklich ein soziales Koop-Erlebnis** als Kern. → B.

## 7. Offene Fragen an Owner und Compliance

1. Dürfen Sounds aus dem Roblox-Katalog und Standard-Partikeltexturen genutzt werden, oder gelten auch sie als „externe Assets“ mit Freigabepflicht?
2. Sind Bestenlisten mit Roblox-Anzeigenamen für unsere Zielgruppe in Ordnung (Compliance)?
3. Wie genau heißen die Zielgruppen „Roblox Kids“ und „Roblox Select“, und welche Zusatzanforderungen gelten für ein Spiel, das 9- bis 15-Jährige erreichen soll (Compliance, Originalseite des Creator Hub)?
4. Kann der Owner pro Sprint mindestens einen Test auf einem echten Handy machen? Davon hängen A und B stark ab.
5. Markenprüfung der Arbeitstitel „Schwungturm / Momentum Tower“, „Formwächter / Shape Warden“ und „Kreuzbeet / Crossbloom Garden“.

## 8. Quellenliste

Alle Quellen wurden am 2026-10-12 abgerufen, und zwar ausschließlich über Websuche-Zusammenfassungen ohne Seitenabruf.

**(A) Roblox selbst**
- Roblox Q2 2026 Earnings, SEC 8-K: https://www.sec.gov/Archives/edgar/data/0001315098/000162828026051059/ex991-robloxq22026earnin.htm
- Roblox Q2 2026 Earnings Call Transcript: https://s27.q4cdn.com/984876518/files/doc_financials/2026/q2/32789865_2009724400_3775763_Transcript_EditedCopy_20260730233208.pdf
- Roblox Q1 2026 Earnings, SEC 8-K: https://www.sec.gov/Archives/edgar/data/0001315098/000162828026028882/ex991-q12026earningsshar.htm
- Roblox Q1 2026 Earnings Call Transcript: https://s27.q4cdn.com/984876518/files/doc_financials/2026/q1/32789865_1994106683_3707346_Transcript_EditedCopy_20260430235219.pdf
- Roblox Q4 2025 Shareholder Letter: https://s27.q4cdn.com/984876518/files/doc_financials/2025/q4/Q4-2025-Shareholder-Letter.pdf
- Roblox Q3 2025 Shareholder Letter, SEC 8-K: https://www.sec.gov/Archives/edgar/data/1315098/000131509825000326/ex991-q32025shareholderl.htm
- Roblox-Filing via last10k (Q2 2026): https://last10k.com/sec-filings/rblx/0001628280-26-051082.htm
- Roblox Newsroom „Optimizing discovery…“ (Juni 2026): https://about.roblox.com/newsroom/2026/06/optimizing-discovery-great-games-reach-millions-players-roblox
- Roblox Newsroom „RDC 2025“: https://about.roblox.com/newsroom/2025/09/roblox-rdc-2025
- Creator Hub „Discovery“: https://create.roblox.com/docs/discovery
- Creator Hub „Content maturity“: https://create.roblox.com/docs/en-us/production/promotion/content-maturity
- Creator Hub „Paid random items“: https://create.roblox.com/docs/production/monetization/paid-random-items
- Creator Hub „Adaptive design guidelines“: https://create.roblox.com/docs/production/publishing/adaptive-design
- Creator Hub „Automatic translations“: https://create.roblox.com/docs/production/localization/automatic-translations
- DevForum „[Full Release] Ship Fair And Competitive Games with Server Authority“: https://devforum.roblox.com/t/full-release-ship-fair-and-competitive-games-with-server-authority/4727993

**(B) Fachpresse, Analysefirmen, Wissenschaft**
- Shacknews, Q2 2026 DAU: https://www.shacknews.com/article/150208/roblox-daus-grew-10-percent-yoy
- Outlook Respawn, Q2 2026: https://respawn.outlookindia.com/gaming/gaming-news/roblox-q2-2026-revenue-soars-36-to-15b-despite-bookings-miss
- MarketBeat, Q2-Call-Highlights: https://www.marketbeat.com/instant-alerts/roblox-q2-earnings-call-highlights-2026-07-31/
- PocketGamer.biz, 80 % Mobile: https://www.pocketgamer.biz/80-of-roblox-users-are-on-mobile-contributing-46-of-robux-revenue
- PocketGamer.biz, Steal a Brainrot 25 Mio.: https://www.pocketgamer.biz/robloxs-steal-a-brainrot-becomes-first-game-to-surpass-25m-concurrent-players
- Newzoo via GameDevReports: https://gamedevreports.substack.com/p/newzoo-roblox-as-a-platform-in-2025?open=false
- GameAnalytics 2025 Roblox Benchmark Report: https://www.gameanalytics.com/cn/reports/2025-roblox-report (PDF-Spiegel: https://investgame.net/wp-content/uploads/2025/09/2025-Roblox-Benchmark-Report.pdf)
- GameAnalytics, Dead Rails: https://www.gameanalytics.com/blog/dead-rails-and-the-hit-makers-formula
- Tubefilter, Discovery-Roadmap 2025: https://www.tubefilter.com/2025/03/20/roblox-discovery-roadmap-2025/
- Tubefilter, 47-Mio.-Rekord: https://www.tubefilter.com/?p=188004
- Dubit, Top 20 und RFY: https://dubit.io/blog/roblox-top-20-rfy
- GamesBeat, RDC 2026: https://gamesbeat.com/roblox-hits-20-and-opens-rdc-2026-to-invite-the-world-to-play-and-make-games-dave-baszucki-keynote/
- Bloomberg, Steal a Brainrot und Nachahmer: https://www.bloomberg.com/news/articles/2026-03-24/roblox-s-hit-game-steal-a-brainrot-battles-its-many-imitators
- The A.V. Club, 99 Nights: https://www.avclub.com/roblox-99-nights-in-the-forest-movie
- Pocket Tactics, Tower of Hell: https://www.pockettactics.com/tower-of-hell/visits
- TechCrunch, Unter-13-Regeln (2024): https://techcrunch.com/2024/11/07/roblox-adds-new-safety-measures-to-ban-kids-under-13-from-social-spaces
- Fortune, FTC-Beschwerde (Mai 2026): https://fortune.com/2026/05/20/exclusive-advocacy-groups-file-complaint-roblox-manipulative-design/
- CBC, Sammelklage British Columbia: https://www.cbc.ca/lite/story/1.7642727
- ABC News, Sicherheitsmaßnahmen und Klagen: https://abcnews.go.com/family/story/roblox-announces-new-safety-measure-amid-spate-lawsuits-127626071
- ClickOrlando, Gesichtsscan für Chat: https://www.clickorlando.com/news/local/2026/01/08/roblox-launches-mandatory-face-scans-for-chat-safety-amid-lawsuits
- Universität Sydney, Monetarisierungs-Report: https://ses.library.usyd.edu.au/handle/2123/35033
- gamesmarket.global, JIM-Studie: https://www.gamesmarket.global/new-jim-study-reveals-media-ownership-and-usage-among-german-youth/
- Vive Blog, 47,3 Mio. CCU: https://blog.vive.com/us/roblox-beats-steam-but-which-games-attracted-4729-million-players-at-once
- The West Australian (Meinungsbeitrag) via broomead.com.au: https://www.broomead.com.au/opinion/ben-oshea-theres-a-sinister-side-to-kids-sedate-online-gardening-game-c-19274605

**(C) Tracker, Guides, SEO-nahe Seiten (nur Indizien)**
- StudioKrew, Top-Spiele August 2026: https://studiokrew.com/blog/top-roblox-games-august-2026/
- endgametools, Charts und News: https://endgametools.com/en/roblox/charts, https://endgametools.com/en/roblox/news/roblox-most-popular-games
- RoWatcher: Steal An Egg https://rowatcher.com/games/10563114921/steal-an-egg · +1-Speed-Slime-Variante https://rowatcher.com/games/10127090395/w3-1-speed-slime-keyboard-escape · Brainrot-Trend https://rowatcher.com/news/is-the-brainrot-trend-dying-what-ccu-data-from-three-top-games-reveals · DTI https://rowatcher.com/news/dress-to-impress-how-a-teen-developer-s-fashion-game-hit-9-7-billion-visits · Mobile 2026 https://rowatcher.com/news/best-roblox-games-for-mobile-in-2026-10-games-that-actually-play-well-on-phone · Home Alone Anomaly https://rowatcher.com/games/10123059921/home-alone-anomaly
- profitable.app, Steal An Egg: https://profitable.app/roblox/games/steal-an-egg
- Rotrends: Scary Shawarma Kiosk https://rotrends.com/game/8539298853/Scary-Shawarma-Kiosk-the-ANOMALY-horror · Fisch https://rotrends.com/game/5750914919
- Know Your Meme, Animal Hospital: https://knowyourmeme.com/memes/subcultures/animal-hospital-roblox
- Bloxodes, „every second +1 speed“: https://bloxodes.com/stats/games/roblox-but-every-second-you-get-1-speed-4122139330
- Beebom, +1 Speed Keyboard Escape: https://beebom.com/plus-1-speed-keyboard-escape-codes/
- Pro Game Guides, Grow a Garden 2 und RDC 2026: https://progameguides.com/roblox/grow-a-garden-2-release-date/, https://progameguides.com/roblox/rdc-2026-roblox-announces-standalone-apps-offline-play-ai-tools-and-more/
- AllThingsHow, Events in 99 Nights: https://allthings.how/99-nights-in-the-forest-events-schedule/
- Wikipedia, Grow a Garden: https://en.wikipedia.org/wiki/Grow_a_Garden
- Gamezebo, Scams in Grow a Garden: https://www.gamezebo.com/walkthroughs/what-happens-if-you-get-scammed-in-grow-a-garden/
- Sportskeeda, Pet-Gifting abgeschaltet: https://www.sportskeeda.com/roblox-news/why-pet-gifting-disabled-grow-garden
- Multiplayer.it, Spielerwechsel bei Grow a Garden: https://multiplayer.it/notizie/il-fenomeno-grow-a-garden-di-roblox-ha-gia-un-contendente-che-gli-sta-succhiando-utenti.html
- rolearn.dev, Q1 2026 Trends: https://rolearn.dev/trend-reports/q1-2026-market-trends/
- creation.dev, RFY-Signale: https://www.creation.dev/learn/roblox-recommended-for-you-algorithm-signals-2026
- godisageek, Algorithmus-Änderung: https://godisageek.com/2026/08/roblox-9-billion-algorithm-change/
- earnaldo.com, Tower Defense: https://earnaldo.com/blog/tower-defense-simulator-vs-anime-defenders
