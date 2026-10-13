# Marktrecherche „Doors“ – Grundlage für „CARRIAGES“

Rolle: Market Researcher · Stand: 2026-10-13 · Bezug: `docs/lantern-line/game_design_doc.md` (v0.1)

**Methode und Grenzen:** Etwa 40 Websuchen. Ausgewertet wurden nur Suchtreffer (Titel, URL, Kurzfassung), keine vollständigen Seiten: WebFetch funktioniert hier nicht, `*.roblox.com` ist gesperrt. Was nur auf der Roblox-Spielseite steht (Label, aktuelle CCU, Servergröße), ist deshalb **nicht direkt verifiziert**. Viele Treffer sind Fan-Wikis (Fandom) oder SEO-Seiten von geringer Qualität. Das ist jeweils vermerkt, SEO-Seiten ohne erkennbaren Autor wurden nicht verwendet. Alle Abrufe am 2026-10-13.
Kennzeichnung: `[QUELLE: …]` = belegt (Qualität beachten) · `[ANNAHME]` = eigene Einschätzung · „nicht verifiziert“ = keine belastbare Quelle gefunden.

---

## Kurzfassung

1. Doors (LSPLASH) erschien am 10.08.2022, hatte nach einem halben Jahr 2 Mrd. Besuche und liegt heute je nach Quelle bei 5–7,7 Mrd.; das Team rechnete laut offiziellem Wiki ursprünglich mit nur ~5.000 gleichzeitigen Spielern.
2. Der Kern ist ein kurzer, nummerierter Raum-für-Raum-Lauf mit bis zu 4 Spielern, nur einem Leben und Wesen, die sich durch ein klares Zeichen ankündigen, auf das es genau eine richtige Reaktion gibt (verstecken, ansehen, wegsehen, umkehren, schleichen).
3. Der Erfolg kam stark über Streamer/YouTube; Kritikpunkte sind Schreckintensität für Jüngere und Wiederbelebung gegen Robux. Eine gezielte Monetarisierungskritik an Doors fand ich aber nicht belegt.
4. Unser Konzept bildet 4 von 5 Doors-Wesen mechanisch fast 1:1 nach; besonders das Postwagen-Rätsel (Symbol + Ziffer, Reihenfolge am Schloss, blinder Wächter, Regalgänge) liegt sehr nah an der Doors-Bibliothek und sollte eigenständiger werden.
5. Ein Roblox-Spiel „CARRIAGES“, „Night Train“ oder „Nachtzug“ fand ich nicht. Mit **LastStop** ist aber ein fast identisches Konzept angekündigt (endloser Horror-Zug, prozedurale Wagen, Monster), und **Dead Rails** besetzt „Zug“ auf Roblox bereits stark. Der Titel ist daher nur bedingt unterscheidbar.

---

## 1. Doors – Fakten mit Quellen

### 1.1 Eckdaten

| Punkt | Befund | Beleg |
|---|---|---|
| Entwickler | LSPLASH (Roblox-Gruppe) | [QUELLE: https://www.pcgamesn.com/roblox/doors-horror-game, abgerufen 2026-10-13] |
| Team | Lightning_Splash (Programmierung/Musik), RediblesQW „Red“ (Umgebung/Modelle), GhostlyWowzers | nur Fan-Seiten: [QUELLE: https://shapes.inc/fandom/doors-video-game/author, abgerufen 2026-10-13]; nicht verifiziert |
| Erstellt | März 2021 (Platz erstmals veröffentlicht 14.03.2021) | [QUELLE: https://knowyourmeme.com/memes/43749, abgerufen 2026-10-13]; [QUELLE: https://profitable.app/roblox/games/doors, abgerufen 2026-10-13] |
| Erscheinungsdatum | 10.08.2022 (Ankündigungsvideo von LSPLASH) | [QUELLE: https://knowyourmeme.com/memes/43749, abgerufen 2026-10-13]; [QUELLE: https://www.pcgamesn.com/roblox/doors-horror-game, abgerufen 2026-10-13] |
| Besuche | kurz nach Start > 86 Mio.; 2 Mrd. am 11.02.2023; heute > 5 Mrd. (offizielles Wiki) bzw. ~7,5 Mrd. (Tracker-Schätzung, undatiert) | [QUELLE: https://www.pcgamesn.com/roblox/doors-horror-game, abgerufen 2026-10-13]; [QUELLE: https://knowyourmeme.com/memes/43749, abgerufen 2026-10-13]; [QUELLE: https://doorsgame.wiki/wiki/DOORS, abgerufen 2026-10-13]; [QUELLE: https://profitable.app/roblox/games/doors, abgerufen 2026-10-13] |
| CCU-Größenordnung | Spitze „über 100.000–200.000“ gleichzeitig, ohne Datum; ursprünglich erwartet ~5.000 | nur Wiki: [QUELLE: https://doorsgame.wiki/wiki/DOORS, abgerufen 2026-10-13]; genaue Spitzenwerte (z. B. zum Start von Floor 2) nicht verifiziert |
| Content-Maturity-Label | „Mild (Ages 9+)“ laut Drittanbieter-Tracker; andere Seiten sprechen von „alle Altersgruppen“ (vermutlich der Stand vor dem neuen Label-System) | [QUELLE: https://rotrends.com/game/2440500124/DOORS, abgerufen 2026-10-13]; [QUELLE: https://cyberpost.co/is-doors-roblox-kid-friendly/, abgerufen 2026-10-13]; auf roblox.com **nicht verifiziert** |
| Spieler je Lauf | ursprünglich bis 4 (12 auf privaten Servern); das Wiki nennt heute eigene Fahrstühle mit bis zu 50 Spielern | [QUELLE: https://knowyourmeme.com/memes/43749, abgerufen 2026-10-13]; [QUELLE: https://breezewiki.discard.no/doors-game/wiki/Lobby, abgerufen 2026-10-13] (Fandom-Spiegel); widersprüchlich, aktueller Stand nicht verifiziert |
| Umfang | Hotel: Türen 1–100, Raum 100 ist das Finale; Floor 2 „The Mines“ (30.08.2024) mit 200 Türen | [QUELLE: https://knowyourmeme.com/memes/43749, abgerufen 2026-10-13]; [QUELLE: https://en.wikipedia.org/wiki/Doors_(game), abgerufen 2026-10-13]; [QUELLE: https://www.sportskeeda.com/roblox-news/beat-doors-floor-2-the-mines, abgerufen 2026-10-13] |
| Weitere Updates | Hotel+ (29.01.2023), Aprilscherz „Super Hard Mode“ (1.–7.04.2023), „The Backdoor“ (15.03.2024, Roblox-Event „The Hunt“), „Retro Mode“ (April 2024) | [QUELLE: https://progameguides.com/roblox/when-is-the-hotel-update-releasing-in-doors-roblox/, abgerufen 2026-10-13]; [QUELLE: https://www.gameskinny.com/tips/roblox-doors-how-to-beat-super-hard-mode/, abgerufen 2026-10-13]; [QUELLE: https://doors-game.fandom.com/wiki/The_Backdoor, abgerufen 2026-10-13]; [QUELLE: https://en.wikipedia.org/wiki/Doors_(game), abgerufen 2026-10-13] |
| Auszeichnungen | Roblox Innovation Awards 2023: „Best New Experience“; 2026: „Best Use of Audio“ | [QUELLE: https://www.ginx.tv/en/?p=57278, abgerufen 2026-10-13]; [QUELLE: https://www.pocketgamer.biz/roblox-reveals-2026-innovation-awards-winners/, abgerufen 2026-10-13] |
| Vorbild | „Rooms“ von nicorocks5555 gilt als Hauptinspiration für Doors (und Pressure) | nur Fan-Wiki: [QUELLE: https://r-rooms.fandom.com/wiki/Nicorocks5555, abgerufen 2026-10-13] |

### 1.2 Kernmechaniken (Hotel)

- **Raumgenerierung:** Räume werden zufällig aus vorgefertigten Teilen zusammengesetzt, manche Räume sind fest an bestimmte Türnummern gebunden (z. B. 50, 100) [QUELLE: https://en.wikipedia.org/wiki/Doors_(game), abgerufen 2026-10-13] (Kurzfassung der Suchmaschine).
- **Schlüssel:** Verschlossene Türen brauchen einen Schlüssel, den man im selben Raum findet. Das stammt aus Guides und ist Allgemeinwissen, im Einzelnen nicht verifiziert. Belegt ist der Elektroraum-Schlüssel in Raum 100, der sich auch durch Dietrich oder Generalschlüssel ersetzen lässt [QUELLE: https://doors-game.fandom.com/wiki/Electrical_Room_Key, abgerufen 2026-10-13].
- **Schränke/Verstecke:** Schränke schützen vor den meisten Wesen. Wer zu lange drin bleibt (~12 s), bekommt eine Warnung und wird von „Hide“ hinausgestoßen (laut Wiki 40 Schaden, kurze Versteck-Sperre) [QUELLE: https://doors-game.fandom.com/wiki/Hide, abgerufen 2026-10-13]. Andere Guides nennen abweichende Werte.
- **Schubladen:** Beim Durchsuchen findet man die Lauf-Währung (Gold) und Gegenstände [QUELLE: https://www.pcgamesn.com/roblox/doors-horror-game, abgerufen 2026-10-13].
- **Dunkelräume:** Dort taucht ein Wesen auf, das man ansehen muss; Licht (Feuerzeug, Taschenlampe) gibt es im Shop [QUELLE: https://attackofthefanboy.com/guides/roblox-doors-all-entities-and-how-to-survive-them/, abgerufen 2026-10-13]; [QUELLE: https://breezewiki.discard.no/doors-game/wiki/Shops, abgerufen 2026-10-13].
- **Bibliothek (Raum 50):** Ein blinder Wächter jagt nach Gehör, also schleicht man und versteckt sich. In den Regalen liegen Bücher mit je einer Form und einer Ziffer. Ein Hinweisblatt zeigt die Reihenfolge der Formen, daraus ergibt sich der Schloss-Code. Im Versteck läuft ein Tasten-Minispiel. Zur Code-Länge (4 oder 5 Stellen) und zur Zahl erlaubter Fehler widersprechen sich die Guides [QUELLE: https://progameguides.com/roblox/roblox-doors-walkthrough-how-to-solve-and-escape-level-50/, abgerufen 2026-10-13]; [QUELLE: https://www.ginx.tv/en/doors-room-50-code, abgerufen 2026-10-13].
- **Verfolgungsjagden:** Zweimal pro Lauf kündigt sich eine Jagd an: Augen erscheinen an den Wänden. Danach rennt man durch einen festen Korridor mit Hindernissen (ducken, ausweichen; manche kosten Leben, manche töten), und Lichtfunken zeigen den richtigen Weg [QUELLE: https://dotesports.com/roblox/news/how-to-beat-seek-in-roblox-doors, abgerufen 2026-10-13]; [QUELLE: https://progameguides.com/roblox/how-to-beat-seek-in-roblox-doors/, abgerufen 2026-10-13].
- **Finale Raum 100:** Hebel → Wächter jagt → Schlüssel holen → Sicherungskasten-Rätsel → Flucht zum Fahrstuhl [QUELLE: https://www.touchtapplay.com/how-to-beat-door-100-in-roblox-doors/, abgerufen 2026-10-13]. Die Details des Rätsels sind widersprüchlich.
- **Tod und Hinweise:** Nach dem Tod gibt das wohlgesinnte „Guiding Light“ Hinweise zur Todesursache [QUELLE: https://en.wikipedia.org/wiki/Doors_(game), abgerufen 2026-10-13].
- **Wiederbelebung:** Man hat ein Leben, kann sich aber mit Robux wiederbeleben [QUELLE: https://www.pcgamesn.com/roblox/doors-horror-game, abgerufen 2026-10-13]. Wiederbelebungen gibt es auch über Codes [QUELLE: https://progameguides.com/roblox/roblox-doors-codes/, abgerufen 2026-10-13].
- **Pre-Run-Shop und Währung:** Vor dem Lauf gibt es einen Shop mit 30-s-Timer und „Knobs“ als Meta-Währung (Vitamine, Dietrich, Feuerzeug, Taschenlampe). Im Lauf gibt es einen zweiten Shop, der Gold annimmt (u. a. das Kruzifix). Die Preisangaben widersprechen sich [QUELLE: https://breezewiki.discard.no/doors-game/wiki/Shops, abgerufen 2026-10-13] (Fandom-Spiegel); [QUELLE: https://doors-game.fandom.com/wiki/Knobs, abgerufen 2026-10-13].

### 1.3 Wesen in Floor 1 und ihre Ankündigung (nur interne Analyse, wir übernehmen weder Namen noch Designs)

| Doors-Wesen | Zeichen | Reaktion | Unser Gegenstück (GDD) | Beleg |
|---|---|---|---|---|
| Rush | Licht flackert beim Betreten, Geräusch | verstecken | Express | [QUELLE: https://attackofthefanboy.com/guides/roblox-doors-all-entities-and-how-to-survive-them/, abgerufen 2026-10-13] |
| Ambush | wie Rush, kehrt mehrmals um (Guides: 2–6×) | versteckt bleiben, mehrfach | Pendel (2–4×) | ebd. (Werte je Guide verschieden) |
| Halt | Flackern ohne Rush; Text „turn back“ | im Flur umkehren, Pfeilen folgen | – (Kontrolleur ist eigene Mechanik) | ebd. |
| Screech | nur in Dunkelräumen, „psst“-Geräusch | hinsehen | Blinder Passagier | ebd. |
| Eyes | violettes Leuchten | wegsehen | – | ebd. |
| Seek | Augen an den Wänden, dann Jagd | rennen, Hindernisse | – (Verfolgungsjagd = Won't im MVP) | [QUELLE: https://dotesports.com/roblox/news/how-to-beat-seek-in-roblox-doors, abgerufen 2026-10-13] |
| Figure | blind, hört (Raum 50 und 100) | schleichen, verstecken, Rätsel lösen | Schaffner | [QUELLE: https://progameguides.com/roblox/roblox-doors-walkthrough-how-to-solve-and-escape-level-50/, abgerufen 2026-10-13] |
| Hide | Warnung nach langem Verstecken | Versteck verlassen | „Kälte“ (14 s/20 s, kein Schaden) | [QUELLE: https://doors-game.fandom.com/wiki/Hide, abgerufen 2026-10-13] |
| Guiding Light | erscheint nach dem Tod | Hinweis lesen | Notiz des Bahnhofsvorstehers | [QUELLE: https://en.wikipedia.org/wiki/Doors_(game), abgerufen 2026-10-13] |

Harmlose Schreckmomente wie „Jack“ im Schrank sind nur aus einem Forenbeitrag bekannt, nicht verifiziert.

---

## 2. Warum Doors funktioniert

**Erfolgsfaktoren**
- **Streamer/YouTube als Motor:** Kurz nach dem Start spielten große Roblox-YouTuber und Variety-Streamer (u. a. iShowSpeed, xQc) das Spiel, ein Video hieß „The scariest game on Roblox?“ [QUELLE: https://www.pcgamesn.com/roblox/doors-horror-game, abgerufen 2026-10-13].
- **Koop:** Bis zu 4 Spieler erleben dieselben Schreckmomente gemeinsam [QUELLE: https://knowyourmeme.com/memes/43749, abgerufen 2026-10-13]. Das passt zu Reaktionsvideos und Spielen mit Freunden [ANNAHME].
- **Lesbare Warnsignale:** Jedes Wesen hat ein eigenes Zeichen und genau eine Gegenreaktion (siehe 1.3, belegt durch die Guides). Das macht den Tod nachvollziehbar und lernbar [ANNAHME].
- **Spannungskurve:** Ruhige Erkundung wechselt mit plötzlicher Gefahr; die Atmosphäre (Licht, Ton) trägt mehr als Gewalt [ANNAHME]. Die Belege dafür stammen nur von SEO-Seiten. Gestützt wird das durch den Audio-Preis 2026 [QUELLE: https://www.pocketgamer.biz/roblox-reveals-2026-innovation-awards-winners/, abgerufen 2026-10-13].
- **Wiederspielwert:** Zufällige Räume verhindern Auswendiglernen [QUELLE: https://earnaldo.com/blog/dead-rails-vs-doors, abgerufen 2026-10-13] (geringe Quellenqualität). Dazu kommen Meta-Währung, Shop, Erfolge und neue Etagen [QUELLE: https://breezewiki.discard.no/doors-game/wiki/Shops, abgerufen 2026-10-13].
- **Feste Höhepunkte:** Raum 50, die Jagden und Raum 100 sind Meilensteine, über die gesprochen wird; Guides dazu gibt es massenhaft [ANNAHME].
- **Kurze Etappen:** Ein Raum dauert wenige Sekunden bis Minuten, man kann jederzeit „noch einen Lauf“ starten. Eine belastbare Quelle für die Laufdauer fand ich nicht (nicht verifiziert) [ANNAHME].

**Typische Kritik**
- **Wiederbelebung gegen Robux:** Sie existiert [QUELLE: https://www.pcgamesn.com/roblox/doors-horror-game, abgerufen 2026-10-13]. Eine gezielte Kritikwelle an Doors deswegen fand ich nicht, nur allgemeine „Pay-to-win“-Kritik an Roblox [QUELLE: https://thehowleronline.org/12464/viewpoint/roblox-should-be-fun-but-it-isnt-anymore/, abgerufen 2026-10-13]. Doors-spezifisch nicht verifiziert.
- **Zu gruselig für Jüngere:** Jumpscares und eine ständige Bedrohung können jüngere oder ängstliche Kinder überfordern [QUELLE: https://cyberpost.co/is-doors-roblox-kid-friendly/, abgerufen 2026-10-13].
- **Frust:** Ein Leben, Sofort-Tode, Hindernis-Jagden und das Hinauswerfen aus dem Versteck [ANNAHME]. Guides warnen etwa vor Hindernissen, die sofort töten [QUELLE: https://dotesports.com/roblox/news/how-to-beat-seek-in-roblox-doors, abgerufen 2026-10-13].
- **Klonflut:** Kopien von Doors-Abschnitten tauchen auf Roblox auf (Forenanekdote) [QUELLE: https://devforum.roblox.com/t/is-that-allowed/2204318, abgerufen 2026-10-13]. Für uns heißt das: Wer zu nah kopiert, verschwindet in der Masse [ANNAHME].

---

## 3. Doors-ähnliche Roblox-Spiele

| Spiel | Abgrenzung | Was wir lernen | Beleg |
|---|---|---|---|
| **Rooms** (nicorocks5555) | Vorläufer: endlose Räume, ein Wesen rast durch, man versteckt sich | „Rennen und verstecken“ ist eine Genre-Konvention, die schon vor Doors existierte, nicht Doors' Eigentum | [QUELLE: https://r-rooms.fandom.com/wiki/Nicorocks5555, abgerufen 2026-10-13] (Fan-Wiki) |
| **Pressure** (Urbanshade / YourFriendZeal) | Unterwasser-Forschungsstation, Spieler als Häftlinge („Expendables“); Ressourcen (Sauerstoff, Batterien), nicht jeder Raum hat ein Versteck, Wesen jagen freier, falsche Türen, Minispiel im Spind; mehrere hundert Mio. Besuche, Spitzen-CCU laut Fanseiten > 100.000 | Ein eigenes Setting mit eigener Fiktion („Doors trifft Iron Lung“) und **eine zusätzliche Kernressource** reichen, damit es als eigenständig gilt | [QUELLE: https://www.dexerto.com/roblox/best-scary-roblox-games-horror-1494718/, abgerufen 2026-10-13]; [QUELLE: https://dungeonpath.com/posts/pillar/roblox-horror-games-compared/, abgerufen 2026-10-13]; [QUELLE: https://dotesports.com/roblox/news/all-monsters-in-pressure-and-how-to-avoid-them, abgerufen 2026-10-13]; [QUELLE: https://rowatcher.com/games/4367208330/pressure, abgerufen 2026-10-13]; Erscheinungsdatum widersprüchlich (Juli 2024 wahrscheinlich, nicht verifiziert) |
| **Rooms & Doors** | Fan-Spiel, das Rooms- und Doors-Elemente mischt | Ein reines Mischen bekannter Wesen schafft keine eigene Marke [ANNAHME] | [QUELLE: https://roblox-rooms-doors.fandom.com/wiki/The_Darkness, abgerufen 2026-10-13] (nur Fan-Wiki) |
| **The Exit 8** (Roblox) | Kein Doors-Klon, sondern ein Anomalie-Spiel in einem sich wiederholenden U-Bahn-Gang; offizielle Roblox-Version seit 10.04.2026 | Eine einzige, sofort verständliche Regel kann ein Spiel tragen. Unser Kontrolleur (rotes Licht = stillstehen) hat dieses Potenzial [ANNAHME] | [QUELLE: https://respawn.outlookindia.com/gaming/gaming-news/exit-8-expands-to-roblox-ahead-of-theatrical-debut, abgerufen 2026-10-13] |
| Weitere (The Mimic, Dead Silence u. a.) | Kapitel-Horror bzw. Schlüsselsuche, kein Wagen-für-Wagen-Lauf | – | [QUELLE: https://www.dexerto.com/roblox/best-scary-roblox-games-horror-1494718/, abgerufen 2026-10-13] |

**Lehre für einen wiedererkennbaren Stil** [ANNAHME, abgeleitet aus der Tabelle]: Erfolgreiche Nachfolger übernehmen den Lauf-Rahmen (nummerierte Räume, Verstecke, Zeichen und Reaktion), ändern aber **(a)** Setting und Fiktion konsequent, **(b)** fügen mindestens eine eigene Kernregel oder Ressource hinzu und **(c)** haben Wesen, deren Gestalt sich aus dem Setting ergibt. Unsere Säulen „Licht verrät alles“, die Fahrkarten-UI und der Kontrolleur decken (a) bis (c) bereits teilweise ab.

---

## 4. Kinder und Altersgruppe

- **Roblox-Publikum allgemein:** Von den altersgeprüften Nutzern (45 % der DAU, Stand 31.01.2026) sind 35 % unter 13, 38 % 13–17 und 27 % über 18 Jahre alt [QUELLE: https://s27.q4cdn.com/984876518/files/doc_financials/2025/q4/Q4-2025-Shareholder-Letter.pdf, abgerufen 2026-10-13] (Kurzfassung der Suchmaschine; Aktionärsbrief von Roblox).
- **Doors-Publikum:** Eine belastbare Altersverteilung für Doors fand ich nicht (nicht verifiziert). Das Label „Mild (9+)“ (Tracker, siehe 1.1), die Thumbnails und die YouTuber-Zielgruppe deuten auf einen Kern von etwa 9–15 Jahren hin [ANNAHME].
- **Eltern-Ratgeber:**
  - Family Gaming Database: Einstufung in Australien PG („mild violence“). Kinder ab 9 haben meist die nötigen Fähigkeiten, Eltern sollen aber prüfen, ob ihr Kind den Grusel verkraftet [QUELLE: https://www.familygamingdatabase.com/game/Doors, abgerufen 2026-10-13].
  - IMDb-Elternratgeber (von Nutzern erstellt): Gewalt „mild“, „Frightening & Intense“ dagegen „severe“ [QUELLE: https://m.imdb.com/title/tt33097031/parentalguide, abgerufen 2026-10-13].
  - Ein Ratgeber für Eltern empfiehlt Doors ab 13 wegen Jumpscares und Atmosphäre, auch ohne Blut und Gewalt [QUELLE: https://cyberpost.co/is-doors-roblox-kid-friendly/, abgerufen 2026-10-13].
  - **Common Sense Media:** Eine Rezension zu Doors fand ich nicht. Dass Roblox dort mit „13+“ eingestuft ist, steht nur auf Sekundärseiten (nicht verifiziert).
  - PEGI führt Roblox nicht mehr als PEGI 7, sondern mit dem Hinweis „Parental Guidance“, weil die Inhalte nutzergeneriert und sehr unterschiedlich sind [QUELLE: https://pegi.info/index.php/cs/node/76, abgerufen 2026-10-13].
- **Fazit:** Bei Doors stören sich Eltern am Schreckfaktor, nicht an Gewalt. Unsere Säule S4 („gruselig, nicht grausam“, Sanfter Modus, Flackern reduzieren) trifft genau diesen Punkt und kann in der Beschreibung ein Vorteil gegenüber Doors sein [ANNAHME].

---

## 5. Namenskollision und Zug-Konkurrenz

| Suchbegriff | Ergebnis | Beleg |
|---|---|---|
| „CARRIAGES“ / „Carriage“ (Roblox) | kein Roblox-Spiel gefunden; außerhalb von Roblox kleine itch.io-Titel: „Off The Rails“ (jeder Wagen steht für ein Trauma), „Carriage Creepshow“, „A Carriage Pulled By Death“ | [QUELLE: https://aboveaveragegames.itch.io/off-the-rails/devlog/776606/devlog-4, abgerufen 2026-10-13]; [QUELLE: https://rainonthemoon.itch.io/carriage-creepshow, abgerufen 2026-10-13] |
| „Night Train“ | kein Roblox-Spiel gefunden; auf Steam ähnliche Titel: „Night Train Simulator: Blackout“, „Nightmare Train“ (2025), „The Last Train: Baquedano“ (2025) | [QUELLE: https://gg.deals/game/night-train-simulator-blackout/, abgerufen 2026-10-13]; [QUELLE: https://rawg.io/games/nightmare-train, abgerufen 2026-10-13]; [QUELLE: https://www.dekudeals.com/items/the-last-train-baquedano, abgerufen 2026-10-13] |
| „Nachtzug“ | nichts gefunden | – |
| **LastStop** (Roblox, in Entwicklung) | „endloses Zug-Horrorspiel“: prozedural erzeugte Wagen, Monster, Flucht nach vorn; das Team suchte im DevForum Builder. **Konzeptuell der engste Konkurrent.** Ob es schon veröffentlicht ist: nicht verifiziert | [QUELLE: https://devforum.roblox.com/t/infinite-train-horror-game/4777237, abgerufen 2026-10-13] |
| **Dead Rails** (RCM Games, 2025) | Koop-Überleben auf einem Zug durch den Wilden Westen (Zombies, Schießen), kein Doors-Lauf; laut Tracker ~6,4 Mrd. Besuche | [QUELLE: https://profitable.app/roblox/games/dead-rails, abgerufen 2026-10-13]; [QUELLE: https://earnaldo.com/blog/dead-rails-vs-doors, abgerufen 2026-10-13] |
| The Horror Train (MaskedBrick, 2018) | kleines Zug-Horrorspiel, ~1,7 Mio. Besuche | [QUELLE: https://rowatcher.com/games/948201974/the-horror-train, abgerufen 2026-10-13] |
| „Anomaly Exit“ | Zug hält immer wieder an scheinbar derselben Station (Exit-8-Prinzip) | nur Download-Aggregator, nicht verifiziert |

**Bewertung „CARRIAGES“** [ANNAHME, auf Basis der Funde oben]:
- **Keine direkte Kollision gefunden.** Die Websuche deckt die Roblox-Suche aber nicht ab. Vor dem Veröffentlichen muss jemand in Roblox Discover nach „Carriages“, „Carriage“, „Night Train“, „Nachtzug“ und „LastStop“ suchen (Owner oder Producer, manuell).
- **Unterscheidbarkeit mittel:** „Carriages“ ist ein gewöhnliches Wort. Im US-Englisch denkt man eher an Pferde- oder Kinderwagen (siehe die Suchtreffer zu Kutschen-Modellen), im britischen Englisch an Eisenbahnwagen. Ohne Untertitel ist der Bezug zum Zug für viele Spieler nicht sofort klar, und das Wort ist schwer auffindbar.
- **Nähe zu „DOORS“:** Ein einzelnes Substantiv im Plural in Großbuchstaben erinnert an das Benennungsmuster von Doors. Das signalisiert das Genre, kann aber als Abklatsch gelesen werden. Rechtlich ist das unkritisch, solange „Doors“ weder im Titel noch in den Metadaten steht (GDD §2).
- **Vorschlag:** Den Titel behalten, aber immer mit Zug-Untertitel führen (EN z. B. „CARRIAGES: The Night Line“, DE „Der Nachtzug“). Im Logo und im Thumbnail sofort Zug und Laterne zeigen. Gegenüber LastStop ist der Stil das Unterscheidungsmerkmal („Laternen-Noir“, Fahrkarte), nicht das Setting.

---

## 6. Empfehlungen für das GDD (10 Punkte)

**Beibehalten (Kern des Spielgefühls)**
1. **Nummerierter Lauf, 4er-Koop, ein Leben, Countdown-Lobby.** Das ist der belegte Kern von Doors (1.1/1.2) und im GDD bereits richtig umgesetzt.
2. **Ein Zeichen, eine Reaktion.** Die Licht-Farbcodes (S1) sind eine lesbarere, barrierefreie Weiterentwicklung der Doors-Warnsignale und können unser Markenzeichen werden. Keine Ausnahmen zulassen [ANNAHME].
3. **Feste Höhepunkte und Hinweise nach dem Tod.** Wagen 50 als Meilenstein und die Notiz des Bahnhofsvorstehers beibehalten (Doors: Raum 50, Guiding Light).
4. **Keine Wiederbelebung gegen Robux** und ein „Mild“-tauglicher Inhalt. Damit vermeiden wir den Hauptkritikpunkt und den Elternvorbehalt (§2, §4). In der Spielbeschreibung offen ansprechen [ANNAHME].

**Anders machen (Eigenständigkeit)**
5. **Postwagen-Rätsel umbauen.** Die Kombination aus Symbol und Ziffer, Reihenfolge am Schloss, blindem, lauschendem Wächter, Regalgängen und Versteck-Schließfächern entspricht fast genau der Doors-Bibliothek (1.2). Besser wäre ein zugeigenes Rätsel, z. B. Abfahrtszeiten aus einem Fahrplan oder ein Lochmuster der Fahrkarte als Code. Den Raum als langen Postwagen mit Sortierfächern statt „Regalgängen“ bauen [ANNAHME].
6. **Pendel und Blinder Passagier mit eigenem Dreh versehen.** Beide sind mechanisch Ambush und Screech (1.3). Zum Beispiel: Der Pendel kündigt jede Rückkehr durch ein Signal an der Wagendecke an, und den Passagier vertreibt man mit Licht, statt ihn nur anzusehen [ANNAHME]. Den Express als Genre-Konvention (schon in Rooms vorhanden, §3) dagegen beibehalten.
7. **Eine Zug-eigene Kernregel stärken.** Der Kontrolleur (rotes Laternenlicht) und „Der Ruck“ sind unsere eigensten Ideen. Den Kontrolleur früher (z. B. ab Wagen 8) und sichtbar im Marketing einsetzen, so wie Pressure sich über Ressourcen abhebt [ANNAHME].
8. **Eine kurze Verfolgungsjagd vorziehen.** Die Jagden gehören zu den bekanntesten Doors-Momenten (1.2). Eine einfache Version (z. B. „Gepäckberg“ um Wagen 30) sollte als „Should“ in Linie 1 statt erst danach kommen [ANNAHME].
9. **Ton nicht vernachlässigen.** Doors wurde 2026 für den Ton ausgezeichnet. „Licht verrät alles“ macht uns ohne Ton spielbar, aber Schienenrhythmus, Bremsenquietschen und Durchsagen sind das Zug-Gefühl. Die Ton-Freigabe (D-030) deshalb früh einplanen [ANNAHME].
10. **Marke früh absichern.** Den Titel immer mit Zug-Untertitel führen. Manuell in Roblox nach „Carriages“, „Night Train“ und LastStop suchen. Thumbnail und Logo in eigener Fahrkarten- und Laternen-Optik gestalten, keine Doors-Anmutung (Augen-Emoji, Türnummer-Schild). Vor dem Start mit Streamern einen „teilbaren“ Moment testen (Express-Lichtwand) [ANNAHME].

---

## Quellenliste (alle abgerufen 2026-10-13, nur Suchtreffer-Zusammenfassungen ausgewertet)

**Nachrichten/Presse:** https://www.pcgamesn.com/roblox/doors-horror-game · https://knowyourmeme.com/memes/43749 · https://en.wikipedia.org/wiki/Doors_(game) · https://www.pocketgamer.biz/roblox-reveals-2026-innovation-awards-winners/ · https://www.ginx.tv/en/?p=57278 · https://www.ginx.tv/en/doors-room-50-code · https://respawn.outlookindia.com/gaming/gaming-news/exit-8-expands-to-roblox-ahead-of-theatrical-debut · https://www.dexerto.com/roblox/best-scary-roblox-games-horror-1494718/ · https://pegi.info/index.php/cs/node/76 · https://s27.q4cdn.com/984876518/files/doc_financials/2025/q4/Q4-2025-Shareholder-Letter.pdf
**Guides:** https://progameguides.com/roblox/roblox-doors-walkthrough-how-to-solve-and-escape-level-50/ · https://progameguides.com/roblox/how-to-beat-seek-in-roblox-doors/ · https://progameguides.com/roblox/when-is-the-hotel-update-releasing-in-doors-roblox/ · https://progameguides.com/roblox/roblox-doors-codes/ · https://dotesports.com/roblox/news/how-to-beat-seek-in-roblox-doors · https://dotesports.com/roblox/news/all-monsters-in-pressure-and-how-to-avoid-them · https://attackofthefanboy.com/guides/roblox-doors-all-entities-and-how-to-survive-them/ · https://www.touchtapplay.com/how-to-beat-door-100-in-roblox-doors/ · https://www.gameskinny.com/tips/roblox-doors-how-to-beat-super-hard-mode/ · https://www.sportskeeda.com/roblox-news/beat-doors-floor-2-the-mines
**Wikis (Fan/Fandom):** https://doorsgame.wiki/wiki/DOORS · https://doors-game.fandom.com/wiki/Hide · https://doors-game.fandom.com/wiki/Knobs · https://doors-game.fandom.com/wiki/Electrical_Room_Key · https://doors-game.fandom.com/wiki/The_Backdoor · https://breezewiki.discard.no/doors-game/wiki/Lobby · https://breezewiki.discard.no/doors-game/wiki/Shops · https://r-rooms.fandom.com/wiki/Nicorocks5555 · https://roblox-rooms-doors.fandom.com/wiki/The_Darkness · https://shapes.inc/fandom/doors-video-game/author
**Tracker/Datenbanken:** https://profitable.app/roblox/games/doors · https://profitable.app/roblox/games/dead-rails · https://rotrends.com/game/2440500124/DOORS · https://rowatcher.com/games/4367208330/pressure · https://rowatcher.com/games/948201974/the-horror-train · https://www.familygamingdatabase.com/game/Doors · https://m.imdb.com/title/tt33097031/parentalguide
**Sonstige (geringere Qualität):** https://cyberpost.co/is-doors-roblox-kid-friendly/ · https://dungeonpath.com/posts/pillar/roblox-horror-games-compared/ · https://earnaldo.com/blog/dead-rails-vs-doors · https://thehowleronline.org/12464/viewpoint/roblox-should-be-fun-but-it-isnt-anymore/ · https://devforum.roblox.com/t/is-that-allowed/2204318 · https://devforum.roblox.com/t/infinite-train-horror-game/4777237 · https://aboveaveragegames.itch.io/off-the-rails/devlog/776606/devlog-4 · https://rainonthemoon.itch.io/carriage-creepshow · https://gg.deals/game/night-train-simulator-blackout/ · https://rawg.io/games/nightmare-train · https://www.dekudeals.com/items/the-last-train-baquedano
