# Compliance-Vorprüfung Sprint 0: drei Spielkonzepte

| Feld | Wert |
|---|---|
| Datum | 2026-10-12 |
| Prüfende Rolle | Safety- & Compliance-Officer (KI-Agent) |
| Gegenstand | `docs/research_report.md`, Abschnitt 5 (Konzepte A, B, C) inkl. Risiken und Abschnitt 7 |
| Prüfgrundlage | `reports/compliance_rules_digest_2026-10-12.md` (Regel-IDs, Checkliste K01–K23) |
| Projektparameter | Zielgruppe 9–14, Mobile zuerst (D-002). MVP ohne Monetarisierung, später höchstens kosmetische Game Passes (D-005). Keine bezahlten Zufallsbelohnungen im MVP. Budget 0 Robux (D-006). |
| Status | Vorprüfung auf Konzeptebene. Das ist keine Release-Freigabe. **Version 1.1**: aktualisiert nach dem Original-Abgleich des Digests (v1.1) mit creator-docs @af5f853. |

## Methodik & Grenzen

- Ich habe jedes Konzept mit K01–K23 aus dem Digest geprüft. Bewertung: ✅ unkritisch, ⚠ nur mit Auflage zulässig, ❌ blockiert.
- Für die Sonderfragen des Orchestrators (Anzeigenamen, Fear, Assets, FOMO, IP, Titel) habe ich am 2026-10-12 zusätzlich 12 Websuchen gemacht. Sie sind unten mit Quelle und Verifikationsgrad belegt. Die Kürzel stehen in der Legende des Digests: `OG: <Pfad>` Original gelesen in creator-docs @af5f853, `WS-O` offiziell, `WS-S` sekundär, `WS-F` Forum, `[ANNAHME]`, `[VORWISSEN, nicht aktuell]`.
- **In v1.1 habe ich Regeln der Creator-Doku im Original gelesen** (`/home/user/roblox/creator-docs`, Commit af5f853 vom 2026-10-10). Community Standards, ToS und Help Center bleiben ungelesen. Wo Regeln unklar sind, wende ich die **strengere Auslegung** an.
- **Was sich in v1.1 gegenüber v1.0 geändert hat**, steht in Abschnitt 10. Kein Urteil ist gekippt. Die Auflagen C-A1, C-A5, C-A6, C-A12, C-A16, C-A19 und C-A23 sind präzisiert, ebenso Owner-Frage 1.
- Den Masterprompt-Text (§0.2, §8.5) gibt es nicht im Repo. Für §8.5 nutze ich die Formulierung aus `docs/assets.md`: „Externe Assets/Bibliotheken mit Lizenz- oder Kostenfolgen brauchen Owner-Freigabe.“

---

## 1. Ergebnisse der Sonderfragen (gelten für mehrere Konzepte)

| # | Frage | Befund | Quelle / Verif. | Folgerung |
|---|---|---|---|---|
| S1 | Sind Display Names von Roblox gefiltert? | **Teilweise.** Roblox prüft Display Names bei der Eingabe mit eigenen Filtern (`WS-O`). Eine Ausnahme von der Filterpflicht für Entwickler steht **nicht** in der Creator-Doku. Die Text-Filter-Doku verlangt, jeden angezeigten Text zu filtern, den wir nicht explizit kontrollieren. Fehlt die Filterung, wird das Spiel entfernt (TXT-01). **Neu aus dem Original:** `FilterStringAsync` **wirft einen Fehler, wenn der Autor nicht im aktuellen Server online ist** (TXT-02). Namen von Offline-Spielern in einer globalen Bestenliste lassen sich so also nicht filtern. **Lösung im Original:** Die **persistente PlayerList-Bestenliste** (Beta) zeigt „Here“, „Friends“ und „Global“ aus einem registrierten OrderedDataStore, und **Roblox rendert die Namen selbst** (EXP-07). | „Say Hello to Display Names!“ https://devforum.roblox.com/t/say-hello-to-display-names/1036435 `WS-O`. **OG: `ui/text-filtering.md`**, **OG: `reference/engine/classes/TextService.yaml`**, **OG: `players/leaderboards.md`** | Fremde Namen zeigt **nur die Roblox-eigene PlayerList**. Unsere eigene UI zeigt keine Namen von Spielern außerhalb des Servers (Auflage C-A16). |
| S2 | Löst „Anomalie/Nachtschicht“ (B) den Deskriptor Fear aus? | **Ja, sicher.** Laut Fragebogen sind **Mild Fear** u. a. „creepy-looking NPCs, **jump scares**, ominous music, and/or **gameplay that builds suspense**“. **Moderate Fear** entsteht erst durch realistisch-blutige Entstellungen, freiliegendes Gewebe oder Organe, offene Wunden oder blutende Augen. Abgefragt werden auch Intensität und Häufigkeit, maßgeblich ist der extremste Inhalt. *(Korrigiert gegenüber v1.0: Jumpscares sind „Mild“, nicht „Moderate“.)* | **OG: `production/promotion/content-maturity.md`** (Fear, Questions 1–3) | B landet sicher bei **Mild (Fear)** und bleibt damit für Kids und Select zugelassen (CM-06). Moderate droht nur bei Gore-Elementen, das Label-Risiko ist also **geringer** als in v1.0 angenommen. Die Tabu-Liste aus C-A19 bleibt als **Hausregel** für Ton und Zielgruppe. |
| S3 | Gibt es Regeln zu Streaks, Tagesinhalten und FOMO? | **Teilweise offiziell.** Laut den Roblox-Monetarisierungs-Guidelines müssen Rabatte echt und fair sein. Verboten sind falsche Knappheit und Countdowns, die ungenau sind oder neu starten („Deal of the Day“, der jeden Tag wiederkommt). Bei Minderjährigen ist drängende Sprache zu vermeiden. Zu Streaks ohne Kaufbezug gibt es keine Roblox-Regel. Der UK Children’s Code (ICO) verlangt, Nudge-Techniken bei Kindern zu vermeiden. Die FTC-Beschwerde vom Mai 2026 richtet sich gegen „addictive design“. Notifications sind nur ab 13 mit Opt-in möglich. | **OG: `production/monetization/index.md`**, **OG: `production/promotion/experience-notifications.md`**. ICO https://www.nelsonslaw.co.uk/ico-guidance-to-game-developers/ `WS-S`. FTC `WS-S` | **HR-FOMO** (Auflage C-A7) bleibt. Der Teil mit Kaufbezug ist jetzt offizielle Regel (MON-03), der Rest ist Hausregel. |
| S4 | Wie nah dürfen wir an Referenzspielen sein (IP)? | **Offiziell:** „Copyright does not protect facts or ideas, but it may protect the specific expression.“ Auch **KI-veränderte Kopien** geschützten Ausdrucks sind meldefähig. Laut Discovery werden „**Non-unique games**“, deren Metadaten und Place-Dateien bestehenden Spielen stark ähneln, nicht mehr bevorzugt empfohlen. Die Brainrot-Klagen richten sich gegen Artwork, UI, Objekte, Level-Design und die „selection and coordination“ von Elementen. | **OG: `production/publishing/ip-guidelines.md`**, **OG: `discovery.md`**. Klagen: https://opencritic.com/news/22635/robloxs-steal-a-brainrot-devs-sue-fortnites-stealing-brainrots-dev-over-allegedly-stolen-content `WS-S` | Die Ableitung von **Prinzipien ist sauber**. Namen, Titelmuster, UI-Layouts, Farbschemata, Objektkataloge und Level-Layouts übernehmen wir nicht, auch nicht über KI-Generierung (C-A10). |
| S5 | Markenkonflikte der Arbeitstitel? | Zu „Momentum Tower“, „Shape Warden“, „Crossbloom“, „Schwungturm“, „Formwächter“ und „Kreuzbeet“ gab es **keinen exakten Treffer**. Es gibt viele Spiele mit „Momentum“ im Namen, das Wort ist also schwach unterscheidungskräftig. Ähnlich, aber nicht gleich: „Wildbloom Park“ (AU-Marke für Spiele, 2025) und „SHAPE SHIFTER“ (US-Marke für Formen-Spiel). | Suchen vom 2026-10-12, u. a. https://search.ipaustralia.gov.au/trademarks/search/view/2551376/details und https://trademarks.justia.com/770/61/shape-77061780.html → **`[ANNAHME]`**: kein Konflikt erkennbar. Eine Websuche ersetzt **keine** Markenrecherche. | Vor öffentlichem Release recherchiert der Owner in Markenregistern (DPMA, EUIPO bzw. TMview, USPTO, WIPO Global Brand DB) und in der Roblox-Suche (C-A11). |
| S6 | Gelten Roblox-Katalog-Sounds und Standard-Partikeltexturen als „externe Assets“? | Standard-Partikel nutzen eine **engine-interne** Textur (`rbxasset://textures/particles/sparkles_main.dds`, laut API-Changelog), keine Creator-Store-ID. Der Creator Store enthält Assets „made by Roblox and independent creators“. Store-Assets können **Schadskripte** enthalten (Remote-`require`, Obfuskation), deshalb rät Roblox zu „Disable Scripts“. Lizenzierte Musik darf **nur auf Roblox** genutzt werden (IP-02). | **OG: `production/creator-store.md`**. Particle emitters https://create.roblox.com/docs/effects/particle-emitters `WS-O` (Ordner `effects/` nicht im Checkout). Audio assets https://create.roblox.com/docs/en-us/audio/assets `WS-O` (Ordner `audio/` nicht im Checkout) | Ich empfehle eine Asset-Kategorien-Regel (Abschnitt 2). Engine-Inhalte sind frei, Roblox-eigene Store-Assets laufen über eine Sammelfreigabe, Assets von Dritten über eine Einzelfreigabe. |

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
| K12 | Freitext, den andere sehen? | Kein Freitext, aber die **Bestenliste zeigt Anzeigenamen**. Eine eigene UI kann Namen von Offline-Spielern nicht filtern (S1). Lösung: die Roblox-PlayerList-Bestenliste. Generierte Turmnamen kämen hinzu, falls geplant. | ⚠ | TXT-01/02, EXP-07, S1 → C-A16, C-A3 |
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
| K23 | 16+-Startphase machbar? | Gefordert sind laut Original **250 unique plays** durch altersgeprüfte 16+-Spieler mit einem Roblox-Kauf in den letzten 60 Tagen, innerhalb von 60 Tagen. Obbies sprechen breite Altersgruppen an, also wahrscheinlich machbar `[ANNAHME]`. Gebühr (1.000 R$) oder Abo kollidieren mit Budget 0 (Owner-Fragen). | ⚠ | KS-05 → C-A15 |

### 3.2 Die drei größten Schwachstellen (aktive Prüfung)

1. **Die Bestenliste ist das heikelste Element.** Erstens zeigt sie fremden Kindern Namen. Eine eigene UI könnte Namen von Offline-Spielern gar nicht filtern, weil `FilterStringAsync` einen Online-Autor braucht (S1, TXT-02). Zweitens erzeugt ein globaler Wettbewerb Druck, und Cheats machen ihn unfair (Client-Bewegung, Research 2.6). Roblox verlangt selbst, Score-Schreibvorgänge serverseitig zu validieren (EXP-07). Drittens bleiben UserIds in OrderedDataStores gespeichert und müssen per RTBF-Template löschbar sein. Tägliche Store-Namen passen nicht in ein statisches Template (DS-02).
2. **Der Tagesturm kann zur FOMO-Mechanik werden.** Ein Streak-Zähler, Tagesbelohnungen nur für heute oder „Komm morgen wieder“-Hinweise wären nach HR-MON/HR-FOMO unzulässig und genau die Muster der FTC-Beschwerde. Dazu kommt: Die „+1“-Funkenlogik lädt später zum Verkauf von Tempo oder Funken ein (Pay-to-Skip). Das ist ausgeschlossen.
3. **Griefing durch Avatar-Kollision und Frust bei 9-Jährigen.** Auf engen Etagen können Fremde andere absichtlich herunterstoßen. Für Kinder ist das Belästigung, und es macht die Bestenliste wertlos. Die Zone „Gewitter“ birgt zusätzlich ein Fotosensitivitäts-Risiko (Blitze, UX A7).

### 3.3 Urteil A: **Freigabe mit Auflagen** (geringstes Risiko der drei)

Begründung: Kein Punkt ist ❌. Alle ⚠ lassen sich durch Design-Auflagen lösen, ohne den Kern anzutasten (Generator, Fähigkeiten, Tagesturm). Erwartetes Label: **Minimal**. Damit ist das Spiel für Kids und Select geeignet (CM-06, KS-04). Gilt: C-A1–C-A18.

---

## 4. Konzept B „Formwächter“ (Shape Warden)

### 4.1 Checkliste K01–K23

| # | Prüffrage (Kurz) | Antwort für B | Bew. | Regel-IDs |
|---|---|---|---|---|
| K01 | Minimal/Mild erreichbar? | **Mild (Fear), sicher.** Laut Original ist schon „gameplay that builds suspense“ Mild Fear. Minimal ginge nur ganz ohne Spannung, und das widerspricht dem Konzept. Mild ist für Kids und Select zugelassen. Moderate entsteht nur durch Gore. | ⚠ | CM-01/06/09, S2 → C-A19 |
| K02 | Romantik? | Nein | ✅ | CS-01 |
| K03 | Social Hangout? | Nein, das Spiel ist zielgerichtet. Die Lobby darf aber nicht zur Aufenthaltsfläche werden, und „Hangout“ darf nicht in Titel oder Beschreibung stehen (sonst Einstufung **16+**). | ✅ | KS-01 → C-A20 |
| K04 | Private Räume? | Museumssäle sind öffentlich. Keine Toiletten oder Personalräume als Säle. | ✅ | CS-02, KS-07 |
| K05 | Freies Zeichnen/Schreiben? | Nein | ✅ | KS-01 |
| K06 | Glücksspiel? | Nein | ✅ | CS-06 |
| K07 | Bezahlte Zufallsitems? | Nein. Prozedurale Anomalien sind unbezahlter Zufall. | ✅ | PRI-01 |
| K08 | Reales, Marken? | Nein, nur fiktive Formen-Skulpturen. **Keine realen Kunstwerke oder Museen** (IP). | ✅ | IP-04, CS-04 |
| K09 | Gewalt/Angst über mild? | Keine Gewalt. Angst bleibt **Mild**, keine Gore-Elemente. Jumpscares wären nach Roblox noch Mild, sind bei uns aber per Hausregel tabu. | ⚠ | CM-09, S2 → C-A19 |
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
| K23 | 16+-Startphase machbar? | **Hohes Risiko.** Ein ausdrücklich kindgerechtes Spiel muss erst **250 unique plays** durch altersgeprüfte 16+-Spieler mit einem Roblox-Kauf in 60 Tagen erreichen (KS-05, im Original bestätigt). Alternative wäre ein Expedited Review für 50.000 R$. | ⚠ | KS-05 → C-A15 |

### 4.2 Die drei größten Schwachstellen (aktive Prüfung)

1. **Ton und Fear-Drift.** Das Genre lebt von Grusel (Research-Risiko 1). Laut Original bleibt Spannung bis hin zu Jumpscares zwar „Mild“, Moderate entsteht nur durch Gore (CM-09). Das eigentliche Risiko ist also weniger das Label als der **Ton für 9- bis 14-Jährige** und Elternkritik. Thumbnails und Video müssen das Thema ehrlich zeigen: Ein Spiel mit Fear-Elementen darf sie nicht verschweigen und darf keinen Horror versprechen, den es nicht hat (EXP-01, CM-04).
2. **Koop mit Fremden.** Pings lassen sich spammen oder zum Belästigen nutzen. Falsche Meldungen kosten die **ganze Gruppe** Zeit, das lädt zu Schuldzuweisungen ein. Eine Party-Bildung über Join-Codes oder eigene Private Server würde die Unter-13-Regeln (KS-03) und das Off-Platform-Verbot berühren (Codes werden extern geteilt).
3. **Launch-Hürde und Klon-Nähe.** Ein kindlicher Look kann in der 16+-Evaluationsphase scheitern: 250 unique plays durch zahlende, altersgeprüfte 16+-Spieler in 60 Tagen (KS-05). Erst danach erreicht das Spiel seine eigentliche Zielgruppe. Das Anomalie-Genre hat zudem eine Klonwelle mit typischen Titelmustern („… Anomaly“, „Night Shift at …“) und Anomalie-Katalogen. Wer die übernimmt, rückt in die Nähe von IP-Streit (S4). Daneben, kein Compliance-Thema im engeren Sinn: Anomalien, die nur über Farbe erkennbar sind, benachteiligen farbenblinde Spieler (UX A3).

### 4.3 Urteil B: **Freigabe mit Auflagen** (mittleres Risiko)

Begründung: Kein ❌, aber eine dauerhafte Pflicht, Fear zu begrenzen und zu überwachen, dazu ein Koop-Schutzpaket. Erwartetes Label: **Mild (Fear)**, laut Original sicher Mild und nicht Moderate, solange es keine Gore-Elemente gibt. **C-A20 (Koop-Schutz) ist kernnah:** Wird sie aufgeweicht, kippt das Urteil auf Veto. C-A19 ist seit v1.1 als Hausregel eingestuft, weil Roblox Spannung bis hin zu Jumpscares als Mild führt. Sie aufzuweichen braucht eine Owner-Entscheidung, ist aber kein Plattformverstoß. Gilt: C-A1–C-A15, C-A19–C-A22.

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
| K07 | Bezahlte Zufallsitems? | Im MVP nein. Unbezahlter Zufall bräuchte laut Original keine Offenlegung. Die **Struktur** ist aber genau das, was Roblox als **„Combination items“** führt („two rare eggs for a better chance“) und als Probability Modifier. Robux-Samen, Gen-Proben oder Boosts würden PRI sofort voll auslösen. | ⚠ | PRI-01/03 → C-A23, C-A26 |
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
| K23 | 16+-Startphase? | Das Garten-Genre zieht breite Altersgruppen an, also wahrscheinlich ja `[ANNAHME]`. Die Schwelle von 250 unique plays gilt auch hier (KS-05). | ✅ | KS-05 |

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
| B Formwächter | Mild (Fear) | Freigabe mit Auflagen | mittel | C-A20 (Koop-Schutz). C-A19 (Fear) als Hausregel. |
| C Kreuzbeet | Minimal | Freigabe mit Auflagen (MVP), bedingtes Veto für spätere Monetarisierung | niedrig, später hoch | C-A23–C-A26 |

Aus Compliance-Sicht stütze ich die Empfehlung des Research-Reports für **A**.

---

## 7. Auflagen (vom Game Designer ins GDD zu übernehmen)

Gilt für: **A**, **B**, **C** bzw. „alle“.

### 7.1 Allgemeine Auflagen

| ID | Gilt für | Auflage | Regel-IDs |
|---|---|---|---|
| C-A1 | alle | Den Maturity & Compliance Questionnaire (Creator Hub → Configure → Questionnaire) **vor jedem Zugang außerhalb des Edit-Teams** ausfüllen, also auch vor Playtests mit Dritten (Audience Limited → Playtesters setzt die 16+-Anforderungen samt Fragebogen voraus). Die Antworten versioniert ablegen (z. B. `docs/compliance/questionnaire.md`). Ändert ein Update Antworten, **muss** der Fragebogen neu abgegeben werden. Ziel-Label: A Minimal, B Mild (Fear), C Minimal. | CM-03/04, KS-05 |
| C-A2 | alle | **Kein Freitext von Spielern im MVP** (keine Benennung von Items, Pflanzen, Teams oder Bases). Kommt später Freitext hinzu: zentrales Server-Modul `TextFilter` (fail-closed), Filterung auch beim Laden gespeicherter Texte, Eintrag ins Text-Register. | TXT-01…04 |
| C-A3 | alle (v. a. C) | **Generierte Namen** (Turm des Tages, Sorten, Säle) nur aus kuratierten Wortlisten in DE und EN. Jede mögliche Kombination wird per Unit-Test gegen eine Blocklist geprüft (DE und EN, auch zusammengesetzt). Keine Silben-Zufallsgeneratoren. | TXT-01, CS-05 |
| C-A4 | alle | Kommunikation läuft nur über den **unveränderten Roblox-Standard-Chat** (TextChatService). Keine eigenen Kanäle, Briefe oder Notizen. Nonverbale Signale (Pings, Emotes) sind nur vordefiniert und enthalten keine romantischen oder körperlichen Gesten. | TXT-05, KS-02, CS-01 |
| C-A5 | alle | **Keine Social-Links, Handles oder Invite-Codes im Spiel** (Roblox-Regel: Links nur auf der Detailseite). Das PolicyService-Feld `AllowedExternalLinkReferences` ist Legacy und immer leer. **Keine Belohnungen** für Like, Favorite, Follow, Gruppenbeitritt, Discord oder Social Media (Hausregel HR-OFF). Einladungen: Das offizielle Roblox-Referral-System dürfte belohnen, **im MVP verzichten wir per Hausregel** darauf (sozialer Druck auf Kinder). Den Einladungsdialog gibt es ohne Belohnung. Keine Aufforderungen zu Freundschaftsanfragen. | OFF-01…06, CS-08 |
| C-A6 | alle | DataStores enthalten **nur User-ID (`player.User`) und Spielstand** (Hausregel HR-DATA). Namen werden **nicht gespeichert**. **RTBF:** Jeder Key bzw. Scope mit Nutzerdaten folgt einem statischen Muster mit `{UserId}`, damit Roblox' **Deletion-Templates** automatisch löschen (auch Ordered Keys). Tägliche Bestenlisten nicht über täglich wechselnde Store-Namen bauen, sondern z. B. über MemoryStore mit TTL ≤ 45 Tage `[ANNAHME, Systems Engineer prüft]`. Für die tägliche RTBF-Nachricht von Roblox braucht es einen festen Prozess. | DS-01/02/06 |
| C-A7 | alle | **HR-FOMO** (konkretisiert HR-MON). **Erlaubt:** Tagesinhalte, die man jederzeit am Tag spielen kann. Verpasste Tage haben keine Folgen. Belohnungen sind flach und nicht eskalierend. Persönliche Bestmarken, Archiv bzw. Wiederholung vergangener Tage, Ruhepunkte zum Aufhören. **Verboten:** Streak-Zähler, die man verlieren kann. Eskalierende Login-Belohnungen. Belohnungen, die es nur heute gibt. Countdowns mit Kauf- oder Verlustbezug. Verfall, Welken oder Verlust bei Abwesenheit. Push- bzw. Experience-Benachrichtigungen (keine im MVP). Texte wie „Komm zurück, sonst …“. Hinweise auf Rangverlust. | MON-03, KS-06, S3 |
| C-A8 | alle | Später nur **kosmetische Game Passes ohne Gameplay-Wirkung**. Keine Developer Products im MVP. **Kein Pay-to-Skip** (kein Tempo, keine Timer, keine Fähigkeiten, keine Etagen). Keine bezahlten Zufallsinhalte. Preise immer live laden. Managed Pricing schreibt neue Spiele standardmäßig ein, über Preistests entscheidet der Owner (MON-02). Laut den offiziellen Monetarisierungs-Guidelines nur echte und faire Rabatte, keine falsche Knappheit, keine falschen Countdowns, keine drängende Sprache (MON-03). Vor jeder Monetarisierung prüft Compliance erneut. | MON-01…04, PRI |
| C-A9 | alle | Die **Asset-Kategorien-Regel** (Abschnitt 2) gilt nach Owner-Freigabe. Lizenzierte Roblox-Musik gehört nicht in Trailer oder Clips außerhalb von Roblox. | IP-01…04, S6 |
| C-A10 | alle | **Prinzipien statt Kopie.** Das GDD enthält eine Tabelle „Referenzspiel → übernommenes Prinzip → was wir ausdrücklich NICHT übernehmen“ (Namen, Titelmuster, UI-Layout, Farbschema, Objekt- und Anomaliekataloge, Level-Layouts). Keine Namen von Referenzspielen in Titel, Beschreibung, Tags oder Thumbnails. | IP-04, EXP-03, S4 |
| C-A11 | alle | Der Owner prüft die **Marken** des gewählten Titels (DPMA, EUIPO bzw. TMview, USPTO, WIPO) und gleicht mit der Roblox-Suche ab, bevor das Spiel öffentlich geht. Kein „Roblox“ oder „Blox“ im Namen. | TOU-03, S5 |
| C-A12 | alle | Thumbnails, Icons und Video entstehen **nur aus echten In-Game-Captures**. Keine Werbebehauptungen. Im Video kein Voice-over und **keine Musik mit Gesang**. Titel und Visuals sind eigenständig, keine fremden Spielnamen in der Beschreibung (Reichweitenabwertung bei „non-unique“ und abweichenden Metadaten). Bei B **kein Horror-Framing**, aber die Spannungselemente auch nicht verschweigen. | EXP-01…03 |
| C-A13 | alle | **Spieler-Kollision deaktivieren** (CollisionGroup Spieler↔Spieler). Keine Avatar-zu-Avatar-Interaktionen (Tragen, Stapeln, Sitzen auf anderen). | CS-03, KS-07 |
| C-A14 | alle | Kein Flackern über 3 Blitze pro Sekunde und keine großflächigen Vollbild-Blitze. Betrifft „Gewitter“ (A) sowie Licht- und Anomalie-Effekte (B). | UX A7, CM-01 |
| C-A15 | alle | Der Owner klärt die **Publishing Requirements** (Altersprüfung bzw. ID, 2FA, Plus/Premium seit 2 Monaten oder 1.000 R$ Gebühr pro Spiel). Der Launch-Plan sieht die **16+-Trial-Phase** vor: 250 unique plays durch qualifizierte 16+-Spieler in 60 Tagen, Fortschritt im Dashboard „Audience Reach“. | KS-05 |

### 7.2 Auflagen für Konzept A

| ID | Gilt für | Auflage | Regel-IDs |
|---|---|---|---|
| C-A16 | A | **Bestenliste.** (a) Die Standardansicht zeigt die **persönliche Bestmarke**. Vergleiche mit anderen sind sekundär. (b) **Namen anderer Spieler zeigt nur die Roblox-eigene PlayerList**: „Here“ über `leaderstats` und „Friends“ bzw. „Global“ über den registrierten OrderedDataStore (Beta, eine aktive Liste pro Spiel). Roblox rendert die Namen dort selbst. **Unsere eigene UI zeigt keine Namen** von Spielern außerhalb des Servers, sondern nur den eigenen Rang bzw. Score, weil `FilterStringAsync` für Offline-Autoren fehlschlägt. Fällt die Beta weg, gibt es globale Ränge ohne Namen und Namen nur für Spieler im aktuellen Server (filterbar). (c) **Keine exklusiven oder zeitlich begrenzten Belohnungen für Ranglistenplätze.** (d) **Score-Schreibvorgänge nur serverseitig mit Plausibilitätsprüfung** (Roblox-Vorgabe). Unplausible Einträge werden still ausgeblendet, niemand wird öffentlich bloßgestellt. (e) Tagesbestenliste ohne Rang-Verlust-Meldungen, positive Formulierungen. Die Speicherform ist RTBF-tauglich (C-A6). | TXT-01/02, EXP-07, DS-02, MON-03 |
| C-A17 | A | Den **Seilschaft-Bonus** gibt es nur für das gemeinsame Erreichen eines Checkpoints im selben Server. Er ist nicht an Einladen, Hinzufügen, Folgen oder an eine bestimmte Gruppengröße geknüpft und bringt nur Kosmetik oder Funken, keinen Rangvorteil. | OFF-01/06 |
| C-A18 | A | **Frustschutz bleibt kostenlos.** Leuchtspur bzw. Hilfe nach X Fehlversuchen gibt es ohne Kauf. Ein „Etage überspringen“ gegen Robux ist auch später ausgeschlossen. Die Zone „Gewitter“ ist stilisiert: Blitze sind ein Hindernis mit Rückstoß, ohne Schaden oder Schreckeffekt. | HR-MON, S2 |

### 7.3 Auflagen für Konzept B

| ID | Gilt für | Auflage | Regel-IDs |
|---|---|---|---|
| C-A19 | B | **Fear-Grenze.** Wir deklarieren **Mild (Fear)** wahrheitsgemäß, denn schon Spannung ist laut Fragebogen Mild Fear. **Plattformgrenze:** keine Gore-Elemente (Entstellung, Wunden, Organe, Blut), sonst Moderate und kein Zugang mehr für Kids. **Hausregel (strenger als Roblox):** keine Jumpscares, keine plötzlichen lauten Sounds, keine Kreaturen, Gesichter oder Augen, keine Verfolgung, keine Dunkelheit als Bedrohung, keine unheimlichen Stimmen. Scheitern sieht freundlich und magisch aus. Wer die Spannung erhöhen will, braucht vorher ein Compliance-Review. | CM-01/04/09, S2 |
| C-A20 | B | **Koop-Schutz (kernnah).** Pings nur auf Objekte und Orte, vordefiniert, mit Rate-Limit und pro Spieler stummschaltbar. **Keine individuelle Fehlerstatistik** für andere sichtbar, es gibt nur Team-Ergebnisse. Gruppenbildung nur über Roblox-Beitritt zu Freunden bzw. Matchmaking, **keine Join-Codes**, keine eigenen Private-Server-Codes. Die Lobby hat keine Aufenthaltsfunktionen (keine Sitzecken, keine Emote-Bühne). | TXT-05, KS-01/03, OFF-03 |
| C-A21 | B | Farb-Anomalien haben immer ein zweites Merkmal oder nutzen eine farbenblind-sichere Palette (Fairness und Barrierefreiheit). | UX A3 |
| C-A22 | B | Keine Titelmuster aus dem Anomalie-Genre („… Anomaly“, „Night Shift at …“). Keine übernommenen Anomalie-Listen oder Map-Layouts aus Referenzspielen. Keine realen Kunstwerke oder Museen. | IP-04, S4 |

### 7.4 Auflagen für Konzept C

| ID | Gilt für | Auflage | Regel-IDs |
|---|---|---|---|
| C-A23 | C | Die Vererbung bleibt **deterministisch** und wird angezeigt. Falls doch Zufall dazukommt: Unbezahlter Zufall braucht laut Roblox keine Offenlegung, wir zeigen die Wahrscheinlichkeiten trotzdem freiwillig an. **Niemals bezahlter Input** in Kreuzungen, denn Roblox wertet das als „Combination item“ bzw. „Probability modifier“ und damit als PRI. Keine Mutationen mit Seltenheits-Multiplikatoren. Das Kreuzen wird neutral dargestellt (keine Herzchen, keine romantische Symbolik). | PRI-01/03, CS-06, CS-01 |
| C-A24 | C | **Kein Welken und kein Verlust** bei Abwesenheit. Offline-Wachstum ist nur positiv und gedeckelt. Keine zeitlich begrenzten Sorten und keine exklusiven Wetter- oder Saison-Events. Keine Shop-Restock-Countdowns. | C-A7, MON-03 |
| C-A25 | C | **Kein Handel und kein Verschenken.** Keine begehbaren fremden Gärten mit Aufenthaltsfunktion. Keine Seltenheitswerte, die Handelsdruck erzeugen. | CS-09, KS-01 |
| C-A26 | C | **Bedingtes Veto:** Kein bezahltes Beschleunigen von Wachstum oder Timern. Keine bezahlten Samen, Proben oder Boosts. Das gilt auch nach dem MVP. | HR-MON, PRI |
| C-A27 | C | Abgrenzung zu Grow a Garden: kein „Grow a …“-Titelmuster, kein Samen-Shop-Layout mit Restock, keine Mutationsnamen oder -multiplikatoren nach GaG-Muster. | IP-04, S4 |
| C-A28 | C | Der L-System-Generator schließt Blattformen aus, die Drogenpflanzen ähneln (z. B. gefiederte, siebenfingrige Fächerblätter). Abgesichert wird das per Regel-Test im Generator `[ANNAHME]`. | CS-04, AD-02 |

---

## 8. Owner-Fragen

1. **Budget gegen Publishing Requirements (im Original bestätigt):** Für Reichweite in allen Altersgruppen braucht das Publisher-Konto (bei Gruppenspielen der Gruppen-Owner) eine Verifizierung (ab 18 per Ausweis), 2FA und **entweder** Plus/Premium seit 2 Monaten **oder** eine einmalige, rückerstattbare **Gebühr von 1.000 Robux pro Spiel**. Danach muss das Spiel die Evaluation bestehen: **250 unique plays durch altersgeprüfte 16+-Spieler, die in den letzten 60 Tagen etwas auf Roblox gekauft haben, innerhalb von 60 Tagen**. Die Alternative ist ein Expedited Review für 50.000 R$. Das kollidiert mit Budget 0 Robux (D-006). Ohne Gebühr bzw. Abo bleibt die Reichweite bei altersgeprüften Spielern ab 16 bzw. Trusted Friends, also **nicht** bei unserer Zielgruppe 9–14. Übernimmt der Owner diese Kosten, und welches Konto bzw. welche Gruppe veröffentlicht? Auch Playtests mit Dritten setzen die 16+-Anforderungen voraus (Altersprüfung, Konto ≥ 2 Tage, Fragebogen).
2. **Asset-Regel:** Gibt der Owner die Kategorien 0 und 1 aus Abschnitt 2 als Sammelfreigabe frei?
3. **Persistente Bestenliste (Beta):** Ist der Owner einverstanden, dass A Namen anderer Spieler nur über die Roblox-PlayerList zeigt (C-A16 b)? Kann er in Studio prüfen, ob die Beta verfügbar ist?
4. **Markenrecherche** des gewählten Titels in den Registern (C-A11), denn die Websuche ergab keinen Treffer `[ANNAHME]`.
5. **Nur falls B gewählt wird:** Akzeptiert der Owner das Label Mild (Fear), oder soll das Ziel Minimal sein (helleres Setting)?
6. **Experience-Benachrichtigungen:** Bestätigt der Owner, dass im MVP keine Push- bzw. Experience-Benachrichtigungen genutzt werden (C-A7)?
7. **Test-Account unter 13** (bzw. ohne Altersprüfung) für die Release-Prüfung R16: Ist das möglich?

## 9. Nicht verifiziert (ergänzt die Liste im Digest)

- Ob Display Names und Usernames vom Entwickler-Filter ausgenommen sind (S1). Mit C-A16 (b) ist die Frage für A erledigt.
- Lizenzumfang der Roblox-eigenen Creator-Store-Audio (Roblox Audio Terms), z. B. Nutzung in Clips auf der Roblox-Plattform (Moments). Der Ordner `audio/` ist nicht im Checkout.
- Ob die Standard-Partikeltextur in aktuellen Engine-Versionen weiterhin `sparkles_main.dds` heißt (S6). Der Ordner `effects/` ist nicht im Checkout.
- Markenlage der Titel (S5).
- Community Standards zu Engagement-Belohnungen (Like, Favorite, Gruppe). Auch im Original der Creator-Doku nicht geregelt.
- Ab v1.1 **im Original geklärt**: Wortlaut und Stufen der Fear-Fragen (S2), Verhalten von `FilterStringAsync` bei Offline-Autoren (S1), Publishing-Schwelle (250) und Gebühr (1.000 R$).

## 10. Änderungen v1.0 → v1.1 (nach Original-Abgleich creator-docs @af5f853)

| Fundstelle | Änderung | Wirkung auf Urteil bzw. Auflagen |
|---|---|---|
| S1, A-K12, C-A16 | `FilterStringAsync` wirft einen Fehler bei Offline-Autor. Roblox bietet persistente PlayerList-Bestenlisten (Beta), die Namen selbst rendern. | C-A16 (b) neu: Fremde Namen zeigt nur die Roblox-PlayerList. Urteil A unverändert. |
| S2, B-K01/K09, C-A19 | Jumpscares und Spannung sind „Mild“, Moderate erst bei Gore | B sicher Mild. C-A19 aufgeteilt in Plattformgrenze und Hausregel. Kernnah ist nur noch C-A20. Urteil B unverändert. |
| S3, C-A8 | Offizielle Monetarisierungs-Guidelines (Rabatte, Knappheit, Countdowns, Sprache gegenüber Minderjährigen) | HR-FOMO teils offizielle Regel. C-A8 ergänzt. |
| S4, C-A10, C-A12 | „Ideas not protected“, KI-veränderte Kopien, Discovery-Abwertung „non-unique“ | Prinzipien-Ableitung offiziell gedeckt. C-A12 ergänzt. |
| B-K03, KS-01 | Hangouts und Free-Form **ab 16** (nicht 13). „Hangout“ in Titel oder Beschreibung führt zur Einstufung. | Kein Konzept betroffen. Strenge Schwelle macht C-A20 (Lobby) wichtiger. |
| K23 (alle), Owner-Frage 1, C-A1 | 250 unique plays durch zahlende, altersgeprüfte 16+-Spieler in 60 Tagen. Gebühr 1.000 R$. Playtests brauchen die 16+-Anforderungen. | Risiko für B steigt (kindlicher Look in der 16+-Phase). Empfehlung A gestärkt. |
| C-K07, C-A23 | PRI umfasst „Combination items“, unbezahlter Zufall braucht keine Offenlegung | C bleibt im MVP unkritisch. Bedingtes Veto (C-A26) bestätigt. |
| C-A5 | `AllowedExternalLinkReferences` ist Legacy. Social Links nie im Spiel. Referral-Belohnungen sind offiziell erlaubt. | Verzicht auf Einladungsbelohnungen als Hausregel gekennzeichnet. |
| C-A6 | RTBF: tägliche Nachricht, Deletion-Templates mit statischem `{UserId}`-Muster, domain-scoped IDs | Datenschema und Tagesbestenliste RTBF-tauglich planen. |

**Urteile unverändert:** A Freigabe mit Auflagen (empfohlen), B Freigabe mit Auflagen (kernnah: C-A20), C Freigabe mit Auflagen für das MVP mit bedingtem Veto gegen spätere Monetarisierung (C-A26).
