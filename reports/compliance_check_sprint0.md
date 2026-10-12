# Compliance-Vorprüfung Sprint 0: drei Spielkonzepte

| Feld | Wert |
|---|---|
| Datum | 2026-10-12 |
| Prüfende Rolle | Safety- & Compliance-Officer (KI-Agent) |
| Gegenstand | `docs/research_report.md`, Abschnitt 5 (Konzepte A, B, C) inkl. Risiken und Abschnitt 7 |
| Prüfgrundlage | `reports/compliance_rules_digest_2026-10-12.md` (Regel-IDs, Checkliste K01–K23) |
| Projektparameter | Zielgruppe 9–14, Mobile zuerst (D-002). MVP ohne Monetarisierung, später höchstens kosmetische Game Passes (D-005). Keine bezahlten Zufallsbelohnungen im MVP. Budget 0 Robux (D-006). |
| Status | Vorprüfung auf Konzeptebene. Das ist keine Release-Freigabe. |

## Methodik & Grenzen

- Ich habe jedes Konzept mit K01–K23 aus dem Digest geprüft. Bewertung: ✅ unkritisch, ⚠ nur mit Auflage zulässig, ❌ blockiert.
- Für die Sonderfragen des Orchestrators (Anzeigenamen, Fear, Assets, FOMO, IP, Titel) habe ich am 2026-10-12 zusätzlich 12 Websuchen gemacht. Sie sind unten mit Quelle und Verifikationsgrad belegt. Die Kürzel stehen in der Legende des Digests: `WS-O` offiziell, `WS-S` sekundär, `WS-F` Forum, `[ANNAHME]`, `[VORWISSEN, nicht aktuell]`.
- Auch hier gilt: Ich habe keinen Regeltext im Original gelesen. Wo Regeln unklar sind, wende ich die **strengere Auslegung** an.
- Den Masterprompt-Text (§0.2, §8.5) gibt es nicht im Repo. Für §8.5 nutze ich die Formulierung aus `docs/assets.md`: „Externe Assets/Bibliotheken mit Lizenz- oder Kostenfolgen brauchen Owner-Freigabe.“

---

## 1. Ergebnisse der Sonderfragen (gelten für mehrere Konzepte)

| # | Frage | Befund | Quelle / Verif. | Folgerung |
|---|---|---|---|---|
| S1 | Sind Display Names von Roblox gefiltert? | **Nur teilweise geklärt.** Roblox prüft Display Names bei der Eingabe mit eigenen Filtern („Display Names will still need to be verified by our filters“). Eine offizielle Aussage, dass Entwickler sie **nicht** erneut filtern müssen, habe ich nicht gefunden. Das Forum rät zum Filtern und berichtet von Umgehungen per Unicode. Die Text-Filter-Doku sagt: Wir sind für jeden angezeigten Text verantwortlich, den wir nicht explizit kontrollieren (TXT-01). | „Say Hello to Display Names!“ https://devforum.roblox.com/t/say-hello-to-display-names/1036435 `WS-O`. Forum https://devforum.roblox.com/t/text-filtering-what-needs-to-be-filtered-and-what-does-not-have-to/1178911 und https://devforum.roblox.com/t/do-i-need-to-use-robloxs-filter-for-custom-names/1545478 `WS-F` | Nach strenger Auslegung zeigen wir Namen in der Bestenliste nur **gefiltert** an (Auflage C-A16). Ob `FilterStringAsync` auch für Nutzer funktioniert, die nicht im Server sind, ist offen `[VORWISSEN, nicht aktuell]`. Das prüft der Systems Engineer. |
| S2 | Löst „Anomalie/Nachtschicht“ (B) den Deskriptor Fear aus? | **Ja, wahrscheinlich.** Der Fragebogen fragt zuerst, ob es überhaupt „scary elements“ gibt (Offenlegung Pflicht, auch in Assets), danach die Intensität. Laut Roblox-Ankündigung bekommen Spiele mit gruseligen Elementen den Deskriptor Fear und das Label **Mild oder Moderate**. Maßgeblich ist der extremste erreichbare Inhalt. | Content Maturity https://create.roblox.com/docs/production/promotion/content-maturity `WS-O`. „Upcoming Changes to Experience Guidelines“ https://devforum.roblox.com/t/3070343 `WS-O` | B landet realistisch bei **Mild (Fear)**. Mild bleibt für Kids und Select zugelassen (CM-06). Moderate (Jumpscares, Bedrohung) müssen wir hart ausschließen. |
| S3 | Gibt es Regeln zu Streaks, Tagesinhalten und FOMO? | Eine Roblox-Regel habe ich nicht gefunden. Der UK Children’s Code (ICO) verlangt, Nudge-Techniken bei Kindern zu vermeiden. Der Entwurf von 2019 nennt „reward loops“ und Benachrichtigungen als „sticky features“. Die FTC-Beschwerde von Mai 2026 richtet sich gegen „addictive design“ auf Roblox. | https://www.nelsonslaw.co.uk/ico-guidance-to-game-developers/ und https://www.arthurcox.com/insights/new-ico-guidance-on-childrens-data/ `WS-S`. FTC: MON-03 `WS-S` | Die Hausregel HR-MON wird um **HR-FOMO** ergänzt (Auflage C-A7): Tagesinhalte sind erlaubt, Streak-Druck und Verlustmechaniken nicht. |
| S4 | Wie nah dürfen wir an Referenzspielen sein (IP)? | Die Klagen der Steal-a-Brainrot-Entwickler gegen Nachahmer richten sich gegen „protectable expressions“: Artwork, UI, Objekte, Level-Design, Animationen und die „selection and coordination“ von Elementen, Farben und Formen. Dass Mechaniken an sich geschützt wären, ist dort nicht belegt. Allgemein schützt das Urheberrecht den konkreten Ausdruck, nicht die Spielidee `[VORWISSEN, nicht aktuell]`. | https://opencritic.com/news/22635/robloxs-steal-a-brainrot-devs-sue-fortnites-stealing-brainrots-dev-over-allegedly-stolen-content und https://aftermath.site/brainrot-roblox-court/ `WS-S`. Bloomberg 24.03.2026 (Research-Report 2.7) `WS-S` | Die Ableitung von **Prinzipien ist sauber**, solange wir keine Namen, Titelmuster, UI-Layouts, Farbschemata, Objektkataloge oder Level-Layouts übernehmen. Auch die **Kombination** vieler Merkmale eines Referenzspiels ist riskant (C-A10). |
| S5 | Markenkonflikte der Arbeitstitel? | Zu „Momentum Tower“, „Shape Warden“, „Crossbloom“, „Schwungturm“, „Formwächter“ und „Kreuzbeet“ gab es **keinen exakten Treffer**. Es gibt viele Spiele mit „Momentum“ im Namen, das Wort ist also schwach unterscheidungskräftig. Ähnlich, aber nicht gleich: „Wildbloom Park“ (AU-Marke für Spiele, 2025) und „SHAPE SHIFTER“ (US-Marke für Formen-Spiel). | Suchen vom 2026-10-12, u. a. https://search.ipaustralia.gov.au/trademarks/search/view/2551376/details und https://trademarks.justia.com/770/61/shape-77061780.html → **`[ANNAHME]`**: kein Konflikt erkennbar. Eine Websuche ersetzt **keine** Markenrecherche. | Vor öffentlichem Release recherchiert der Owner in Markenregistern (DPMA, EUIPO bzw. TMview, USPTO, WIPO Global Brand DB) und in der Roblox-Suche (C-A11). |
| S6 | Gelten Roblox-Katalog-Sounds und Standard-Partikeltexturen als „externe Assets“? | Standard-Partikel nutzen eine **engine-interne** Textur (`rbxasset://textures/particles/sparkles_main.dds`, laut API-Changelog), keine Creator-Store-ID. Der Creator Store enthält „free-to-use audio made by Roblox and the Roblox community“, darunter über 100.000 Partner-Tracks und SFX. Lizenzierte Musik darf **nur auf Roblox** genutzt werden (IP-02). | Particle emitters https://create.roblox.com/docs/effects/particle-emitters `WS-O`. API-Ref https://robloxapi.github.io/ref-temp/class/ParticleEmitter.html `WS-S`. Audio assets https://create.roblox.com/docs/en-us/audio/assets `WS-O` | Ich empfehle eine Asset-Kategorien-Regel (Abschnitt 2). Engine-Inhalte sind frei, Roblox-eigene Store-Assets laufen über eine Sammelfreigabe, Assets von Dritten über eine Einzelfreigabe. |

## 2. Empfohlene Regel: Asset-Kategorien (zu Masterprompt §8.5, Freigabe durch Owner)

| Kat. | Was | Beispiele | Owner-Freigabe | Pflichten |
|---|---|---|---|---|
| 0 | **Engine-Bestandteile** (mit dem Client ausgeliefert, `rbxasset://`, ohne Store-ID) | Parts, Materialien (Neon, Glass, ForceField), Standard-Partikeltextur, Standard-Sky, Lighting-Effekte, Standard-Charaktersounds, Roblox-Systemschriften | **nein** | In `docs/assets.md` unter „Engine-Inhalte“ einmal sammelnd aufführen. |
| 1 | **Roblox-eigene Store-Assets**, vom Konto „Roblox“ veröffentlicht (auch Partner-Musik und SFX der Roblox-Lizenzbibliothek) | SFX und Musik aus dem Creator Store mit Uploader „Roblox“ | **einmalige Sammelfreigabe** der Kategorie durch den Owner | Jede Asset-ID einzeln ins Register: Uploader, Titel, Datum, Verwendung. **Nicht** außerhalb von Roblox nutzen (Trailer auf YouTube oder TikTok, Website), IP-02. Vor dem Release prüfen, ob das Asset noch verfügbar und öffentlich ist. |
| 2 | **Creator-Store-Assets von Dritten** (Community) | Modelle, Meshes, Audio und Texturen anderer Nutzer | **Einzelfreigabe** je Asset | Herkunft und Lizenz prüfen. Modelle **ohne Skripte** (Risiko Backdoor bzw. Schadcode `[ANNAHME]`). Keine IP fremder Marken. |
| 3 | **Eigene Uploads** (Audio, Bilder) | selbst erzeugte Sounds, Thumbnails | **Einzelfreigabe** (Upload macht der Owner) | Upload durch den Spiel-Owner bzw. die Gruppe, wegen Audio-Privacy (IP-03). Rechte dokumentieren. |
| 4 | **Bibliotheken / Code von Dritten** | ProfileStore, Jest-Lua | **Einzelfreigabe** (wie D-012) | Lizenz prüfen, Version pinnen. |

---

## 3. Konzept A „Schwungturm“ (Momentum Tower)

### 3.1 Checkliste K01–K23

| # | Prüffrage (Kurz) | Antwort für A | Bew. | Regel-IDs |
|---|---|---|---|---|
| K01 | Minimal/Mild erreichbar? | Ja, **Minimal**: keine Gewalt, kein Fear. Die Zone „Gewitter“ muss stilisiert und nicht bedrohlich sein (sonst stellt sich die Fear-Frage). | ✅ | CM-01, S2 |
| K02 | Romantik/Paar-Elemente? | Nein | ✅ | CS-01 |
| K03 | Social Hangout als Zweck? | Nein, das Ziel ist der Aufstieg | ✅ | KS-01/04 |
| K04 | Private Räume, Bar, Club? | Nein | ✅ | CS-02 |
| K05 | Freies 2D-Zeichnen/Schreiben? | Nein | ✅ | KS-01 |
| K06 | Glücksspiel? | Nein. Die „Zufallsstrecken“ sind prozedurale Level ohne Einsatz. | ✅ | CS-06 |
| K07 | Bezahlte Zufallsitems? | Nein (MVP). Funken sind deterministisch. | ✅ | PRI-01 |
| K08 | Reales, Marken, Politik? | Nein | ✅ | CS-04, CM-07 |
| K09 | Gewalt über mild hinaus? | Nein. Ein Sturz bedeutet Reset ohne Schadensdarstellung. | ✅ | CM-01 |
| K10 | Persönliche Daten? | Nein | ✅ | DS-01 |
| K11 | Off-Platform- oder Engagement-Belohnung? | Nicht geplant. Der **Seilschaft-Bonus** ist zulässig, solange er an gemeinsames Spielen gebunden ist und nicht an Einladen, Hinzufügen oder Folgen. | ⚠ | OFF-01/06 → C-A17 |
| K12 | Freitext, den andere sehen? | Kein Freitext, aber die **Bestenliste zeigt Anzeigenamen** (Filterpflicht unklar, S1). Generierte Turmnamen kämen hinzu, falls geplant. | ⚠ | TXT-01, S1 → C-A16, C-A3 |
| K13 | Eigenes Kommunikationssystem? | Nein. Leuchtspur-Marker übertragen keine Inhalte. | ✅ | TXT-05 |
| K14 | Kernloop ohne Kauf fair? | Ja, Tempo ist nicht kaufbar und es gibt eine kostenlose Hilfe. | ✅ | HR-MON |
| K15 | Frei von Dark Patterns/FOMO? | **Risiko:** Tagesturm, Bestmarke und Rangliste sind genau die Bausteine für Streak- und FOMO-Druck. | ⚠ | MON-03, S3 → C-A7 |
| K16 | Handel? | Nein | ✅ | CS-09 |
| K17 | Bezahlte Items verlierbar? | Nein (später nur Kosmetik) | ✅ | EXP-04 |
| K18 | Assets eigen oder lizenziert? | Primitive ja. Partikeltextur und Sounds sind noch offen. | ⚠ | IP-02, S6 → C-A9 |
| K19 | KI-Laufzeittext? | Nein | ✅ | EXP-05 |
| K20 | Werbung/Brand/Ads? | Nein | ✅ | AD-01…04 |
| K21 | Ohne Chat spielbar? | Ja | ✅ | KS-02 |
| K22 | Avatar-Nähe, Missbrauchspotenzial? | Auf schmalen Plattformen können Spieler sich **schubsen oder blockieren** (Griefing), und die Seilschaft fördert Nähe. | ⚠ | KS-07, CS-03 → C-A13 |
| K23 | 16+-Startphase machbar? | Obbies sprechen breite Altersgruppen an, also wahrscheinlich ja `[ANNAHME]`. Die Kontoanforderungen kollidieren aber mit Budget 0 (siehe Owner-Fragen). | ⚠ | KS-05 → C-A15 |

### 3.2 Die drei größten Schwachstellen (aktive Prüfung)

1. **Die Bestenliste ist das heikelste Element.** Erstens zeigt sie fremden Kindern Namen, deren Filterpflicht ungeklärt ist (S1). Zweitens erzeugt ein globaler Wettbewerb Druck, und Cheats machen ihn unfair (Client-Bewegung, Research 2.6). Drittens bleiben UserIds in OrderedDataStores dauerhaft gespeichert und müssen bei Löschanfragen mit gelöscht werden (DS-02).
2. **Der Tagesturm kann zur FOMO-Mechanik werden.** Ein Streak-Zähler, Tagesbelohnungen nur für heute oder „Komm morgen wieder“-Hinweise wären nach HR-MON/HR-FOMO unzulässig und genau die Muster der FTC-Beschwerde. Dazu kommt: Die „+1“-Funkenlogik lädt später zum Verkauf von Tempo oder Funken ein (Pay-to-Skip). Das ist ausgeschlossen.
3. **Griefing durch Avatar-Kollision und Frust bei 9-Jährigen.** Auf engen Etagen können Fremde andere absichtlich herunterstoßen. Für Kinder ist das Belästigung, und es macht die Bestenliste wertlos. Die Zone „Gewitter“ birgt zusätzlich ein Fotosensitivitäts-Risiko (Blitze, UX A7).

### 3.3 Urteil A: **Freigabe mit Auflagen** (geringstes Risiko der drei)

Begründung: Kein Punkt ist ❌. Alle ⚠ lassen sich durch Design-Auflagen lösen, ohne den Kern anzutasten (Generator, Fähigkeiten, Tagesturm). Erwartetes Label: **Minimal**. Damit ist das Spiel für Kids und Select geeignet (CM-06, KS-04). Gilt: C-A1–C-A18.

---

## 4. Konzept B „Formwächter“ (Shape Warden)

### 4.1 Checkliste K01–K23

| # | Prüffrage (Kurz) | Antwort für B | Bew. | Regel-IDs |
|---|---|---|---|---|
| K01 | Minimal/Mild erreichbar? | Realistisch **Mild (Fear)**. „Nachtschicht“, Dunkelheit mit Taschenlampe und Spannung gelten als „scary elements“, die wir offenlegen müssen. Minimal geht nur mit heller, nicht bedrohlicher Gestaltung. Mild ist weiterhin für Kids und Select zugelassen. | ⚠ | CM-01/06, S2 → C-A19 |
| K02 | Romantik? | Nein | ✅ | CS-01 |
| K03 | Social Hangout? | Nein, das Spiel ist zielgerichtet. Die Lobby darf aber nicht zur Aufenthaltsfläche werden. | ✅ | KS-01 → C-A20 |
| K04 | Private Räume? | Museumssäle sind öffentlich. Keine Toiletten oder Personalräume als Säle. | ✅ | CS-02, KS-07 |
| K05 | Freies Zeichnen/Schreiben? | Nein | ✅ | KS-01 |
| K06 | Glücksspiel? | Nein | ✅ | CS-06 |
| K07 | Bezahlte Zufallsitems? | Nein. Prozedurale Anomalien sind unbezahlter Zufall. | ✅ | PRI-01 |
| K08 | Reales, Marken? | Nein, nur fiktive Formen-Skulpturen. **Keine realen Kunstwerke oder Museen** (IP). | ✅ | IP-04, CS-04 |
| K09 | Gewalt/Angst über mild? | Keine Gewalt. Angst muss **mild** bleiben, Jumpscares und Kreaturen sind tabu. | ⚠ | CM-01, S2 → C-A19 |
| K10 | Persönliche Daten? | Nein | ✅ | DS-01 |
| K11 | Off-Platform/Engagement? | Nein | ✅ | OFF |
| K12 | Freitext? | Nein | ✅ | TXT |
| K13 | Eigenes Kommunikationssystem? | **Ping-Marker** sind Kommunikation, aber vordefiniert, also zulässig. Risiken: Spam, und Fremde im selben Koop-Server. | ⚠ | TXT-05, KS-02 → C-A20 |
| K14 | Ohne Kauf fair? | Ja | ✅ | HR-MON |
| K15 | Dark Patterns/FOMO? | Nächte 1–5 als Progression, keine Tageslogik. Unkritisch, solange keine Streaks hinzukommen. | ✅ | C-A7 |
| K16 | Handel? | Nein | ✅ | CS-09 |
| K17 | Bezahlte Items verlierbar? | Nein | ✅ | EXP-04 |
| K18 | Assets? | Die Atmosphäre braucht wahrscheinlich Sounds (Kat. 1/3). | ⚠ | S6 → C-A9 |
| K19 | KI-Laufzeittext? | Nein | ✅ | EXP-05 |
| K20 | Werbung? | Nein | ✅ | AD |
| K21 | Ohne Chat spielbar? | Ja, über Pings | ✅ | KS-02 |
| K22 | Avatar-Nähe? | Gering. Kollision aus, damit niemand Vitrinen oder Durchgänge blockiert. | ✅ | C-A13 |
| K23 | 16+-Startphase machbar? | **Risiko.** Ein ausdrücklich kindgerechtes Spiel muss erst die Engagement-Schwelle bei Spielern ab 16 erreichen (KS-05, Zahlen unverifiziert). | ⚠ | KS-05 → C-A15 |

### 4.2 Die drei größten Schwachstellen (aktive Prüfung)

1. **Das Label driftet in Richtung Fear.** Das Genre lebt von Grusel (Research-Risiko 1). Jede Iteration „für mehr Spannung“ schiebt das Spiel Richtung Moderate, und dann verlieren wir Kids (5–8). Außerdem müssen Thumbnails und Titel so ehrlich sein, dass sie weder Horror versprechen noch die Fear-Elemente verschweigen (EXP-01, CM-04).
2. **Koop mit Fremden.** Pings lassen sich spammen oder zum Belästigen nutzen. Falsche Meldungen kosten die **ganze Gruppe** Zeit, das lädt zu Schuldzuweisungen ein. Eine Party-Bildung über Join-Codes oder eigene Private Server würde die Unter-13-Regeln (KS-03) und das Off-Platform-Verbot berühren (Codes werden extern geteilt).
3. **Launch-Hürde und Klon-Nähe.** Ein kindlicher Look kann in der 16+-Evaluationsphase scheitern (KS-05). Das Anomalie-Genre hat zudem eine Klonwelle mit typischen Titelmustern („… Anomaly“, „Night Shift at …“) und Anomalie-Katalogen. Wer die übernimmt, rückt in die Nähe von IP-Streit (S4). Daneben, kein Compliance-Thema im engeren Sinn: Anomalien, die nur über Farbe erkennbar sind, benachteiligen farbenblinde Spieler (UX A3).

### 4.3 Urteil B: **Freigabe mit Auflagen** (mittleres Risiko)

Begründung: Kein ❌, aber eine dauerhafte Pflicht, Fear zu begrenzen und zu überwachen, dazu ein Koop-Schutzpaket. Erwartetes Label: **Mild (Fear)**. Die Auflagen C-A19 und C-A20 sind **kernnah**: Wird eine von beiden aufgeweicht, kippt das Urteil auf Veto. Gilt: C-A1–C-A15, C-A19–C-A22.

---

## 5. Konzept C „Kreuzbeet“ (Crossbloom Garden)

### 5.1 Checkliste K01–K23

| # | Prüffrage (Kurz) | Antwort für C | Bew. | Regel-IDs |
|---|---|---|---|---|
| K01 | Minimal/Mild erreichbar? | Ja, **Minimal** | ✅ | CM-01 |
| K02 | Romantik? | Nein. Das Kreuzen darf aber **nicht vermenschlicht oder romantisiert** werden (keine Herzchen, kein „Heiraten“ der Pflanzen). | ✅ | CS-01 → C-A23 |
| K03 | Social Hangout? | Nein, solange es keine begehbaren Gärten anderer mit Aufenthaltsfunktion gibt | ✅ | KS-01 → C-A25 |
| K04 | Private Räume? | Nein (Gewächshaus) | ✅ | CS-02 |
| K05 | Freies Zeichnen/Schreiben? | Nein | ✅ | KS-01 |
| K06 | Glücksspiel? | Nein, die Vererbung ist **deterministisch**. Kommt Zufall dazu, bleibt er unbezahlt, also kein Glücksspiel (kein Einsatz). Glücksspielnah wird es erst, wenn Bezahlung oder Handel hinzukommt. | ✅ | CS-06 → C-A23 |
| K07 | Bezahlte Zufallsitems? | Im MVP nein. Die **Struktur** (Samen, Gen-Proben, Boosts) ist aber für spätere indirekte PRI vorgezeichnet, z. B. Robux-Samen oder Mutations-Boosts. | ⚠ | PRI-01/03 → C-A23, C-A26 |
| K08 | Reales, Regulierte Waren? | Nein. **L-System-Blattformen dürfen keinen Drogenpflanzen ähneln** (Cannabisblatt), denn regulierte Waren können je nach Darstellung zu Moderation oder Labelfolgen führen `[ANNAHME]`. | ⚠ | CS-04, AD-02 → C-A28 |
| K09 | Gewalt? | Nein | ✅ | CM-01 |
| K10 | Persönliche Daten? | Nein | ✅ | DS-01 |
| K11 | Off-Platform/Engagement? | Nein (kein „teile deine Pflanze“ nach außen) | ✅ | OFF |
| K12 | Freitext? | **Sortennamen:** Sind sie generiert, braucht es eine Blocklist. Benennen Spieler sie selbst, muss gefiltert werden. | ⚠ | TXT-01/03 → C-A3 |
| K13 | Kommunikationssystem? | Nein | ✅ | TXT-05 |
| K14 | Ohne Kauf fair? | Im MVP ja. Wachstumstimer erzeugen aber **künstliche Wartezeit**, die sich später als Pay-to-Skip verkaufen ließe. | ⚠ | HR-MON → C-A26 |
| K15 | FOMO? | **Hohes Risiko:** Echtzeit- und Offline-Wachstum, Pflege (Gießen) und eventuelle Wetter-Events oder Saisonsorten | ⚠ | MON-03, S3 → C-A7, C-A24 |
| K16 | Handel? | Im Konzept ausgeschlossen. Die Community wird ihn aber fordern (Genre-Erwartung). | ✅ | CS-09 → C-A25 |
| K17 | Bezahlte Items verlierbar? | Nein | ✅ | EXP-04 |
| K18 | Assets? | Primitive. Sounds sind noch offen. | ⚠ | S6 → C-A9 |
| K19 | KI-Laufzeittext? | Nein | ✅ | EXP-05 |
| K20 | Werbung? | Nein | ✅ | AD |
| K21 | Ohne Chat? | Ja | ✅ | KS-02 |
| K22 | Avatar-Nähe? | Gering | ✅ | KS-07 |
| K23 | 16+-Startphase? | Das Garten-Genre zieht breite Altersgruppen an, also wahrscheinlich ja `[ANNAHME]` | ✅ | KS-05 |

### 5.2 Die drei größten Schwachstellen (aktive Prüfung)

1. **Monetarisierungsfalle.** Timer, Samen und Genetik sind exakt die Infrastruktur, die im Genre später zu Pay-to-Skip, Robux-Samen und Mutations-Boosts führt. Das wären indirekte bezahlte Zufallsitems (PRI-01/03) und Kritikpunkte aus der Univ.-Sydney-Studie (MON-03). Sobald Zufall in der Kreuzung steckt und irgendein bezahlter Input ihn beeinflusst, greifen Offenlegungs- und Länderpflichten.
2. **FOMO durch Echtzeit-Mechaniken.** Welken bei Abwesenheit, Gießen-Pflicht, Restock-Countdowns, Wetter-Events oder Saisonsorten widersprechen HR-FOMO und dem Nudge-Verbot des UK Children’s Code (S3). Weil Eltern die Ausgaben pro Spiel sehen (KS-06), bringt jede spätere Monetarisierung hier ein erhöhtes Reputationsrisiko.
3. **Nähe zum Platzhirsch.** Grow a Garden und GaG 2 prägen die Erwartungen des Genres (Samen-Shop mit Restock, Mutations-Multiplikatoren, Handel). Ein „Grow a …“-ähnlicher Titel oder dieselben Shop- und UI-Muster riskieren den Klon-Vorwurf (S4). Generierte Sortennamen können außerdem anstößige Wörter bilden, was einen Text-Verstoß bedeuten würde.

### 5.3 Urteil C: **Freigabe mit Auflagen für das MVP**, mit **bedingtem Veto** gegen bestimmte spätere Monetarisierung

Begründung: Das MVP selbst ist unkritisch (Minimal, deterministisch, kein Handel). Ich spreche aber schon jetzt ein Veto gegen folgende spätere Erweiterungen aus: (a) bezahltes Beschleunigen von Wachstum oder Timern, (b) bezahlte Samen, Proben oder Boosts, die einen Zufallsausgang beeinflussen, (c) Handel bzw. Verschenken. Gilt: C-A1–C-A15, C-A23–C-A28.

---

## 6. Gesamtvergleich

| Konzept | Erwartetes Label | Urteil | Risiko | Kernnahe Auflagen |
|---|---|---|---|---|
| **A Schwungturm** | Minimal | **Freigabe mit Auflagen** | niedrig | C-A7 (Tagesturm ohne FOMO), C-A16 (Bestenliste) |
| B Formwächter | Mild (Fear) | Freigabe mit Auflagen | mittel | C-A19 (Fear-Grenze), C-A20 (Koop-Schutz) |
| C Kreuzbeet | Minimal | Freigabe mit Auflagen (MVP), bedingtes Veto für spätere Monetarisierung | niedrig, später hoch | C-A23–C-A26 |

Aus Compliance-Sicht stütze ich die Empfehlung des Research-Reports für **A**.

---

## 7. Auflagen (vom Game Designer ins GDD zu übernehmen)

Gilt für: **A**, **B**, **C** bzw. „alle“.

### 7.1 Allgemeine Auflagen

| ID | Gilt für | Auflage | Regel-IDs |
|---|---|---|---|
| C-A1 | alle | Den Maturity & Compliance Questionnaire vor dem **ersten** öffentlichen Zugang ausfüllen. Die Antworten versioniert ablegen (z. B. `docs/compliance/questionnaire.md`). Jede Inhaltsänderung löst eine neue Prüfung aus. Ziel-Label: A Minimal, B Mild (Fear), C Minimal. | CM-03/04, EXP-06 |
| C-A2 | alle | **Kein Freitext von Spielern im MVP** (keine Benennung von Items, Pflanzen, Teams oder Bases). Kommt später Freitext hinzu: zentrales Server-Modul `TextFilter` (fail-closed), Filterung auch beim Laden gespeicherter Texte, Eintrag ins Text-Register. | TXT-01…04 |
| C-A3 | alle (v. a. C) | **Generierte Namen** (Turm des Tages, Sorten, Säle) nur aus kuratierten Wortlisten in DE und EN. Jede mögliche Kombination wird per Unit-Test gegen eine Blocklist geprüft (DE und EN, auch zusammengesetzt). Keine Silben-Zufallsgeneratoren. | TXT-01, CS-05 |
| C-A4 | alle | Kommunikation läuft nur über den **unveränderten Roblox-Standard-Chat** (TextChatService). Keine eigenen Kanäle, Briefe oder Notizen. Nonverbale Signale (Pings, Emotes) sind nur vordefiniert und enthalten keine romantischen oder körperlichen Gesten. | TXT-05, KS-02, CS-01 |
| C-A5 | alle | Keine Off-Platform-Verweise im Spiel. **Keine Belohnungen** für Like, Favorite, Follow, Gruppenbeitritt, Discord, Social Media oder Einladungen. Der Roblox-Einladungsdialog ist erlaubt, aber **ohne Belohnung**. Keine Aufforderungen zu Freundschaftsanfragen. | OFF-01…06, CS-08 |
| C-A6 | alle | DataStores enthalten **nur UserId und Spielstand**. Namen werden **nicht gespeichert**, sondern live abgefragt. Das Löschskript `deleteUserData(userId)` deckt alle Stores ab, **inklusive OrderedDataStores bzw. Bestenlisten** (auch tägliche Keys). | DS-01/02 |
| C-A7 | alle | **HR-FOMO** (konkretisiert HR-MON). **Erlaubt:** Tagesinhalte, die man jederzeit am Tag spielen kann. Verpasste Tage haben keine Folgen. Belohnungen sind flach und nicht eskalierend. Persönliche Bestmarken, Archiv bzw. Wiederholung vergangener Tage, Ruhepunkte zum Aufhören. **Verboten:** Streak-Zähler, die man verlieren kann. Eskalierende Login-Belohnungen. Belohnungen, die es nur heute gibt. Countdowns mit Kauf- oder Verlustbezug. Verfall, Welken oder Verlust bei Abwesenheit. Push- bzw. Experience-Benachrichtigungen (keine im MVP). Texte wie „Komm zurück, sonst …“. Hinweise auf Rangverlust. | MON-03, KS-06, S3 |
| C-A8 | alle | Später nur **kosmetische Game Passes ohne Gameplay-Wirkung**. Keine Developer Products im MVP. **Kein Pay-to-Skip** (kein Tempo, keine Timer, keine Fähigkeiten, keine Etagen). Keine bezahlten Zufallsinhalte. Preise immer live laden (MON-02). Vor jeder Monetarisierung prüft Compliance erneut. | MON-01…03, PRI |
| C-A9 | alle | Die **Asset-Kategorien-Regel** (Abschnitt 2) gilt nach Owner-Freigabe. Lizenzierte Roblox-Musik gehört nicht in Trailer oder Clips außerhalb von Roblox. | IP-01…04, S6 |
| C-A10 | alle | **Prinzipien statt Kopie.** Das GDD enthält eine Tabelle „Referenzspiel → übernommenes Prinzip → was wir ausdrücklich NICHT übernehmen“ (Namen, Titelmuster, UI-Layout, Farbschema, Objekt- und Anomaliekataloge, Level-Layouts). Keine Namen von Referenzspielen in Titel, Beschreibung, Tags oder Thumbnails. | IP-04, EXP-03, S4 |
| C-A11 | alle | Der Owner prüft die **Marken** des gewählten Titels (DPMA, EUIPO bzw. TMview, USPTO, WIPO) und gleicht mit der Roblox-Suche ab, bevor das Spiel öffentlich geht. Kein „Roblox“ oder „Blox“ im Namen. | TOU-03, S5 |
| C-A12 | alle | Thumbnails, Icons und Video entstehen **nur aus echten In-Game-Captures**. Keine Werbebehauptungen. Bei B **kein Horror-Framing**, aber die Fear-Elemente auch nicht verschweigen. | EXP-01…03 |
| C-A13 | alle | **Spieler-Kollision deaktivieren** (CollisionGroup Spieler↔Spieler). Keine Avatar-zu-Avatar-Interaktionen (Tragen, Stapeln, Sitzen auf anderen). | CS-03, KS-07 |
| C-A14 | alle | Kein Flackern über 3 Blitze pro Sekunde und keine großflächigen Vollbild-Blitze. Betrifft „Gewitter“ (A) sowie Licht- und Anomalie-Effekte (B). | UX A7, CM-01 |
| C-A15 | alle | Der Owner klärt die **Publishing Requirements** (Altersprüfung bzw. ID, 2SV, Plus/Premium oder Gebühr) und plant die **16+-Startphase** im Launch-Plan ein. | KS-05 |

### 7.2 Auflagen für Konzept A

| ID | Gilt für | Auflage | Regel-IDs |
|---|---|---|---|
| C-A16 | A | **Bestenliste.** (a) Die Standardansicht zeigt die **persönliche Bestmarke und Freunde**. Die globale Liste zeigt nur die Top N und den eigenen Rang. (b) Namen sind Roblox-DisplayNames bzw. @Usernames, live abgefragt, **serverseitig per TextService (Broadcast) gefiltert** und gecacht. Schlägt das fehl, erscheint ein neutraler Platzhalter („Kletterer“). Lässt sich `FilterStringAsync` für Nutzer außerhalb des Servers nicht nutzen, sind Namen nur für Freunde sichtbar. Die Filterpflicht entfällt erst, wenn der Owner im Original belegt, dass Roblox-Namen ausgenommen sind. (c) **Keine exklusiven oder zeitlich begrenzten Belohnungen für Ranglistenplätze.** (d) Serverseitige Plausibilitätsprüfung: Unplausible Einträge werden still ausgeblendet, niemand wird öffentlich bloßgestellt. (e) Die Tagesliste wird täglich zurückgesetzt. Formulierungen sind positiv („Neue Bestmarke!“), Rangverluste werden nicht gemeldet. | TXT-01, S1, DS-01/02, MON-03 |
| C-A17 | A | Den **Seilschaft-Bonus** gibt es nur für das gemeinsame Erreichen eines Checkpoints im selben Server. Er ist nicht an Einladen, Hinzufügen, Folgen oder an eine bestimmte Gruppengröße geknüpft und bringt nur Kosmetik oder Funken, keinen Rangvorteil. | OFF-01/06 |
| C-A18 | A | **Frustschutz bleibt kostenlos.** Leuchtspur bzw. Hilfe nach X Fehlversuchen gibt es ohne Kauf. Ein „Etage überspringen“ gegen Robux ist auch später ausgeschlossen. Die Zone „Gewitter“ ist stilisiert: Blitze sind ein Hindernis mit Rückstoß, ohne Schaden oder Schreckeffekt. | HR-MON, S2 |

### 7.3 Auflagen für Konzept B

| ID | Gilt für | Auflage | Regel-IDs |
|---|---|---|---|
| C-A19 | B | **Fear-Grenze (kernnah).** Wir deklarieren Mild (Fear). **Tabu:** Jumpscares, plötzliche laute Sounds, Kreaturen, Gesichter oder Augen, Verfolgung, Dunkelheit als Bedrohung, Blut, unheimliche Stimmen. Scheitern sieht freundlich und magisch aus. Wer die Spannung erhöhen will, braucht vorher ein Compliance-Review. Optional: Minimal mit heller „Abendschicht“ prüfen. | CM-01/04, S2 |
| C-A20 | B | **Koop-Schutz (kernnah).** Pings nur auf Objekte und Orte, vordefiniert, mit Rate-Limit und pro Spieler stummschaltbar. **Keine individuelle Fehlerstatistik** für andere sichtbar, es gibt nur Team-Ergebnisse. Gruppenbildung nur über Roblox-Beitritt zu Freunden bzw. Matchmaking, **keine Join-Codes**, keine eigenen Private-Server-Codes. Die Lobby hat keine Aufenthaltsfunktionen (keine Sitzecken, keine Emote-Bühne). | TXT-05, KS-01/03, OFF-03 |
| C-A21 | B | Farb-Anomalien haben immer ein zweites Merkmal oder nutzen eine farbenblind-sichere Palette (Fairness und Barrierefreiheit). | UX A3 |
| C-A22 | B | Keine Titelmuster aus dem Anomalie-Genre („… Anomaly“, „Night Shift at …“). Keine übernommenen Anomalie-Listen oder Map-Layouts aus Referenzspielen. Keine realen Kunstwerke oder Museen. | IP-04, S4 |

### 7.4 Auflagen für Konzept C

| ID | Gilt für | Auflage | Regel-IDs |
|---|---|---|---|
| C-A23 | C | Die Vererbung bleibt **deterministisch** und wird angezeigt. Falls doch Zufall dazukommt: Wahrscheinlichkeiten von Anfang an anzeigen, und **niemals bezahlter Input** in Zufallsprozesse. Keine Mutationen mit Seltenheits-Multiplikatoren. Das Kreuzen wird neutral dargestellt (keine Herzchen, keine romantische Symbolik). | PRI-01/03, CS-06, CS-01 |
| C-A24 | C | **Kein Welken und kein Verlust** bei Abwesenheit. Offline-Wachstum ist nur positiv und gedeckelt. Keine zeitlich begrenzten Sorten und keine exklusiven Wetter- oder Saison-Events. Keine Shop-Restock-Countdowns. | C-A7, MON-03 |
| C-A25 | C | **Kein Handel und kein Verschenken.** Keine begehbaren fremden Gärten mit Aufenthaltsfunktion. Keine Seltenheitswerte, die Handelsdruck erzeugen. | CS-09, KS-01 |
| C-A26 | C | **Bedingtes Veto:** Kein bezahltes Beschleunigen von Wachstum oder Timern. Keine bezahlten Samen, Proben oder Boosts. Das gilt auch nach dem MVP. | HR-MON, PRI |
| C-A27 | C | Abgrenzung zu Grow a Garden: kein „Grow a …“-Titelmuster, kein Samen-Shop-Layout mit Restock, keine Mutationsnamen oder -multiplikatoren nach GaG-Muster. | IP-04, S4 |
| C-A28 | C | Der L-System-Generator schließt Blattformen aus, die Drogenpflanzen ähneln (z. B. gefiederte, siebenfingrige Fächerblätter). Abgesichert wird das per Regel-Test im Generator `[ANNAHME]`. | CS-04, AD-02 |

---

## 8. Owner-Fragen

1. **Budget gegen Publishing Requirements:** Für Reichweite in allen Altersgruppen braucht es Plus oder Premium seit 2 Monaten **oder** eine (rückerstattbare) Veröffentlichungsgebühr (KS-05). Das kollidiert mit Budget 0 Robux (D-006). Ohne das bleibt die Reichweite bei altersgeprüften Spielern ab 16 bzw. Trusted Friends, also **nicht** bei unserer Zielgruppe 9–14. Übernimmt der Owner diese Kosten? Welches Konto bzw. welche Gruppe veröffentlicht?
2. **Asset-Regel:** Gibt der Owner die Kategorien 0 und 1 aus Abschnitt 2 als Sammelfreigabe frei?
3. **Display Names:** Kann der Owner in der Original-Doku (create.roblox.com/docs/ui/text-filtering) nachlesen, ob Roblox-Namen vom Filtern ausgenommen sind? Bis dahin gilt C-A16 (b).
4. **Markenrecherche** des gewählten Titels in den Registern (C-A11), denn die Websuche ergab keinen Treffer `[ANNAHME]`.
5. **Nur falls B gewählt wird:** Akzeptiert der Owner das Label Mild (Fear), oder soll das Ziel Minimal sein (helleres Setting)?
6. **Experience-Benachrichtigungen:** Bestätigt der Owner, dass im MVP keine Push- bzw. Experience-Benachrichtigungen genutzt werden (C-A7)?
7. **Test-Account unter 13** (bzw. ohne Altersprüfung) für die Release-Prüfung R16: Ist das möglich?

## 9. Nicht verifiziert (ergänzt die Liste im Digest)

- Ob Display Names und Usernames vom Entwickler-Filter ausgenommen sind (S1) und ob `FilterStringAsync` für Nutzer außerhalb des Servers funktioniert.
- Wortlaut und Intensitätsstufen der Fear-Fragen im Fragebogen (S2).
- Lizenzumfang der Roblox-eigenen Creator-Store-Audio (Roblox Audio Terms), z. B. Nutzung in Clips auf der Roblox-Plattform (Moments).
- Ob die Standard-Partikeltextur in aktuellen Engine-Versionen weiterhin `sparkles_main.dds` heißt (S6).
- Markenlage der Titel (S5).
