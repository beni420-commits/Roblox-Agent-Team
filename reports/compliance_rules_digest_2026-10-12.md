# Compliance-Regel-Digest Roblox – Stand 2026-10-12

**Erstellt von:** Safety- & Compliance-Officer (KI-Agent), Sprint 0
**Version:** 1.1 (Original-Abgleich mit creator-docs) · **Abrufdatum aller Quellen:** 2026-10-12
**Zweck:** Prüfgrundlage für alle Compliance-Checks im Projekt (Konzept-Vorprüfung, Feature-Review, Release-Prüfung). Regel-IDs (z. B. `PRI-01`) bitte in späteren Prüfberichten zitieren.

## Methodik & Grenzen (bitte zuerst lesen)

- **v1.0** stützte sich nur auf WebSearch-Zusammenfassungen (rund 50 Suchen). Kein Regeltext wurde damals im Original gelesen.
- **v1.1:** Alle Regeln mit Quelle create.roblox.com habe ich gegen die **Originalquelle der Creator-Doku** geprüft. Lokal liegt das Repo `Roblox/creator-docs`, Commit **af5f853 vom 2026-10-10**, unter `/home/user/roblox/creator-docs`. Ausgecheckt sind nur die Ordner `production`, `cloud-services`, `players`, `projects`, `scripting`, `ui`, `input`, `discovery` (und Dateien im Wurzelordner von `content/en-us`). Pfade unten sind relativ zu `content/en-us/`.
- **Nicht im Original verfügbar** (bleiben „via Websuche-Zusammenfassung“): Community Standards, Terms of Use, Advertising Standards und Help-Center-Artikel (en.help.roblox.com, about.roblox.com), Presse sowie die Ordner `audio/` und `chat/` der Creator-Doku.
- Bei Widersprüchen zwischen Doku-Seiten gilt die **speziellere bzw. neuere** Seite. Beispiel: `content-maturity.md` (16+/18+) schlägt die Altseite `experience-guidelines.md` (13+/17+).
- **Grundsatz für unser Projekt:** Ist eine Regel unklar oder nicht verifiziert, gilt die **strengere Auslegung**, bis der Owner im Original nachgelesen hat. Hausregeln (HR-…) sind ausdrücklich als solche gekennzeichnet. Sie sind strenger als Roblox und keine Plattformregeln.
- Das hier ist keine Rechtsberatung. Fragen zu DSGVO, DSA, Jugendschutz und Verbraucherrecht muss vor einem kommerziellen Release eine Fachperson prüfen.

### Legende Verifikationsgrad

| Kürzel | Bedeutung |
|---|---|
| `OG: <Pfad>` | **Original gelesen: creator-docs `content/en-us/<Pfad>` @af5f853** |
| `WS-O` | via Websuche-Zusammenfassung, Originaltext nicht eingesehen. Quelle offiziell (Help Center, Newsroom, DevForum-Announcement) |
| `WS-S` | via Websuche-Zusammenfassung, Originaltext nicht eingesehen. Quelle sekundär (Presse, Kanzlei, Tracker) |
| `WS-F` | via Websuche-Zusammenfassung. Quelle DevForum-Community, keine offizielle Regel |
| `[ANNAHME]` | Eigene konservative Ableitung ohne Quellenbeleg |
| `[VORWISSEN, nicht aktuell]` | Aus Modellwissen, nicht per Suche oder Original bestätigt |

---

## 0. Top-10 harte Regeln (Kurzfassung für jedes Konzept)

1. **Fragebogen Pflicht und Ziel-Label Minimal/Mild.** Ohne vollständige, korrekte Angaben schränkt Roblox die Spielbarkeit für alle ein. Schon das Veröffentlichen für 16+ setzt den Fragebogen voraus. Nur Minimal und Mild erreichen Roblox Kids (5–8), Moderate erreicht höchstens Select (9–15). Bei jeder Inhaltsänderung muss der Fragebogen neu abgegeben werden. → CM-01…09
2. **Keine Romantik oder Sexualisierung.** Romantische Themen (auch im Titel), Spiele, die überwiegend in privaten Räumen spielen, und Erwachsenen-Settings (Bars, Clubs) sind **nur für altersgeprüfte Nutzer ab 18** zugänglich. Die Community Standards verbieten zusätzlich Dating. → CS-01/02, KS-07
3. **Kein Social Hangout als Kernzweck und keine Free-Form User Creation** (freies Zeichnen, Malen oder Schreiben auf 2D- oder 3D-Flächen, Pixel-Raster). Beides gibt es **nur ab 16**, Eltern können das nicht freischalten. Spiele mit „Sensitive Issues“ als Hauptthema gibt es ebenfalls nur ab 16. → KS-01, CM-07
4. **Kein Glücksspiel**, auch kein simuliertes: keine Einsätze, keine Wetten, auch nicht mit Gratiswährung. → CS-06
5. **Bezahlte Zufallsitems** (auch indirekt über Robux-Währung, Schlüssel, Tickets oder Kombinations-Items) brauchen die vollständige Offenlegung in % vor dem Kauf, Summe 100 %, mit beschriftetem Button. Dazu kommen ein `ArePaidRandomItemsRestricted`-Check mit Alternative und für Handel ein `IsPaidItemTradingAllowed`-Check. → PRI-01…06
6. **Jeder Nutzertext, den andere sehen, wird serverseitig über `TextService` gefiltert.** Das gilt auch für gespeicherte und für zufällig generierte Wörter. Fehlt die Filterung, entfernt Roblox das Spiel, bis sie eingebaut ist. Chat läuft nur über TextChatService bzw. nach dessen Berechtigungsprüfung. → TXT-01…06
7. **Datenminimierung und RTBF.** Keine Abfrage persönlicher Daten. Löschpflicht bei RTBF-Anfragen, am besten automatisch über Deletion-Templates. → DS-01/02
8. **Keine Social-Media-Links im Spiel.** Links stehen nur auf der Spiel-Detailseite, sichtbar nur für altersgeprüfte Nutzer ab 16. Keine Engagement-Belohnungen nach Hausregel HR-OFF. Kein Echtgeld-Handel. → OFF-01…06, CS-09
9. **Ehrliche Monetarisierung nach den offiziellen Roblox-Monetarisierungs-Guidelines:** echte und faire Rabatte, keine falsche Knappheit, keine falschen oder neu startenden Countdowns, kein Druck auf Minderjährige. Dazu kommen dynamische Preise und Rewarded Ads nur ab 13, nie als Fortschritts-Sperre. → MON, AD
10. **Nur eigene oder lizenzierte IP und lizenziertes Audio.** Das Urheberrecht schützt den Ausdruck, nicht die Idee, und auch KI-veränderte Kopien gelten als Verletzung. Store-Medien zeigen nur echte Spielinhalte. Nicht eigenständige Spiele („non-unique“) werden in der Discovery abgewertet. → IP, EXP

---

## 1. Community Standards (CS)

| ID | Regel (sinngemäß) | Quelle (Titel + URL) | Abruf | Verif. | Konsequenz für unser Projekt |
|---|---|---|---|---|---|
| CS-01 | Roblox ist kein Ort für romantische Beziehungen oder sexuelle Inhalte. Seit Aug. 2025 ist auch verboten, was sexuelle Aktivität **impliziert**. Laut Presse sind Hochzeiten sowie Kuss- und Händchen-Animationen eingeschlossen. Laut Fragebogen sind „romantic themes“ (z. B. ein kurzer Kuss) **nur für altersgeprüfte Nutzer ab 18** zulässig, auch wenn sie nur im Titel stehen. | Newsroom https://about.roblox.com/newsroom/2025/08/extending-roblox-policy-on-romantic-and-sexual-content · Axios (s. v1.0) · Content Maturity | 2026-10-12 | WS-O / WS-S · **OG: `production/promotion/content-maturity.md`** (Romantic themes) | Keine Dating-, Hochzeits- oder Paar-Mechaniken und keine Kuss-, Umarmungs- oder Händchen-Emotes. Auch der Titel darf keine Romantik enthalten. |
| CS-02 | **Private Räume und Erwachsenen-Settings:** Spiele, die überwiegend in privaten Räumen spielen (Duschkabine, Hotelzimmer, Schlafzimmer, kleines Zelt) oder in Settings für Erwachsene (Clubs, Bars), sind **nur für altersgeprüfte Nutzer ab 18** zugänglich. Social Hangouts mit privaten Räumen ebenfalls ab 18. *(Korrigiert: v1.0 nannte nach Newsroom 2025 „17+“.)* | Content Maturity · Safety-Doku | 2026-10-12 | **OG: `production/promotion/content-maturity.md`**, **OG: `safety.md`** | Schlafzimmer, Bäder, Umkleiden, Bars und Clubs sind nie Haupt-Schauplatz. Betten und Bäder sind nur Deko mit Bounding-Box (KS-07). |
| CS-03 | Automatische Erkennung von Szenen mit Verstößen. Bei vielen Verstößen schaltet das System den Server ab. | Newsroom 2025/08 | 2026-10-12 | WS-O | Freie Posen und Animationen sowie das Stapeln von Avataren begrenzen wir. |
| CS-04 | Verboten ist, reale sensible Ereignisse nachzustellen (Massengewalt, Katastrophen, Menschenrechtsverletzungen) sowie Opfer zu verspotten oder Täter zu verherrlichen. Laut Fragebogen sind extreme Gewalt, Tierquälerei, Folter und die Verherrlichung von Kriegsverbrechen generell unzulässig. | Community Standards https://about.roblox.com/en-nz/community-standards · Content Maturity (Violence-Alert) | 2026-10-12 | WS-O · **OG: `production/promotion/content-maturity.md`** | Nur fiktive Welten, keine realen Orte, Ereignisse oder Personen. Gewalt bleibt unrealistisch. |
| CS-05 | Sexuelle Inhalte, sexuelle Ausbeutung und Kindergefährdung sind absolut verboten (Nulltoleranz). | Rules of Conduct https://en.help.roblox.com/hc/en-us/articles/203313410-Roblox-Rules-of-Conduct | 2026-10-12 | WS-O + `[VORWISSEN, nicht aktuell]` | Keine sexuelle Konnotation. Verdachtsfälle sofort an den Owner. |
| CS-06 | **Glücksspiel** heißt: Echtgeld, Robux oder Items mit Wert für ein Glücksspiel einsetzen. Spiele **dürfen kein spielbares Glücksspiel enthalten, auch kein simuliertes**. Erlaubt ist nur unspielbares Glücksspiel (Casino als Kulisse), und das hebt das Label auf Moderate. Pferderennen oder Pokerchips ohne Zufallsspiel müssen nicht angegeben werden. | Content Maturity (Unplayable gambling) · Rules of Conduct | 2026-10-12 | **OG: `production/promotion/content-maturity.md`** · WS-O | Keine Slots, kein Roulette, keine Wetten, keine Casino-Kulisse (die würde Moderate auslösen). Zufall nur nach den PRI-Regeln. |
| CS-07 | Persönliche Informationen werden geblockt, das Teilen persönlicher Daten anderer ist verboten. Die Text-Filterung soll ausdrücklich auch die Weitergabe personenbezogener Daten verhindern. | Rules of Conduct · Text filtering | 2026-10-12 | WS-O · **OG: `ui/text-filtering.md`**, **OG: `safety.md`** | Keine UI fragt nach Name, Alter, Ort, Schule, Kontakt oder Foto (DS-01). |
| CS-08 | **Off-Platform-Links:** Laut Community Standards (zitiert in der Creator-Doku) dürfen Social-Media-Links **nur auf der Spiel-Detailseite** stehen, **nicht im Spiel**. Im Spiel erlaubt ist ein Verweis wie „Links auf unserer Spielseite“. Nicht erlaubt sind URLs, Discord-Invites oder E-Mail-Adressen. | Social media links | 2026-10-12 | **OG: `production/promotion/social-media-links.md`** | Im Spiel stehen keine Links, Handles oder Invite-Codes (OFF-03/04). |
| CS-09 | Deals außerhalb der offiziellen Systeme setzt Roblox nicht durch. Echtgeld-Handel und Account-Verkauf sind verboten. | Help-Artikel https://en.help.roblox.com/hc/articles/203312390 · Vice | 2026-10-12 | WS-O / WS-S | Kein Echtgeld-Bezug. Handel nur innerhalb des Spiels und mit Schutz. |
| CS-10 | Creator Rewards verbieten künstliche oder automatisierte Aktivität (Bots, Tools, Erweiterungen, Plugins, manipulierte Teleports). Ebenso verboten sind Anreize für Alt-Accounts und Imitation bzw. Falschdarstellung. Laut Discovery wird das Spiel außerdem abgewertet, wenn es „mit Giveaways“ wirbt (Metadaten, die Geld bzw. Robux implizieren). | Creator Rewards · Discovery | 2026-10-12 | **OG: `creator-rewards.md`**, **OG: `discovery.md`** | Keine Bots, keine Alt-Accounts, kein „Robux!“ im Titel. |

## 2. Terms of Use – relevant für Entwickler (TOU)

*Alle TOU-Regeln bleiben „nicht im Original gelesen“. Die ToS liegen nicht im creator-docs-Repo.*

| ID | Regel (sinngemäß) | Quelle | Abruf | Verif. | Konsequenz |
|---|---|---|---|---|---|
| TOU-01 | User Terms + Creator Terms (gelten für alle) + Zusatzbedingungen (Advertising Standards u. a.) | https://en.help.roblox.com/hc/article_attachments/20957353013908 | 2026-10-12 | WS-O | Der Owner liest die Creator Terms im Original. |
| TOU-02 | Weitreichende UGC-Lizenz an Roblox, auch für Marketing | ConductAtlas (s. v1.0) | 2026-10-12 | WS-S | Nichts hochladen, an dem wir nicht alle Rechte halten. |
| TOU-03 | Update vom 30.06.2025: Marken-IP-Tools, Screen-Recording, „Roblox“/„Blox“-Namensverbot, UK-OSA-Anhang | https://en.help.roblox.com/hc/article_attachments/37066946324884 | 2026-10-12 | WS-O / WS-S | Kein „Roblox“ oder „Blox“ in Namen. |
| TOU-04 | Fassung vom 30.04.2026 bzw. 19.05.2026 (widersprüchlich), KI-Bedingungen konsolidiert | ConductAtlas, tostracker | 2026-10-12 | WS-S | Der Owner prüft die gültige Fassung und die KI-Klauseln. |
| TOU-05 | Extended Services Terms (Überschreitungskosten) | ConductAtlas | 2026-10-12 | WS-S | Kostenregeln vor intensiver Nutzung von Open Cloud bzw. DataStores prüfen. |

## 3. Content Maturity & Maturity & Compliance Questionnaire (CM)

| ID | Regel (sinngemäß) | Quelle | Abruf | Verif. | Konsequenz |
|---|---|---|---|---|---|
| CM-01 | Es gibt vier Stufen. **Minimal:** gelegentliche milde Gewalt, leichtes unrealistisches Blut. **Mild:** wiederholte milde Gewalt, viel unrealistisches Blut, milde Angst, milder derber Humor. **Moderate:** moderate Gewalt, leichtes realistisches Blut, moderate Angst, moderater derber Humor, unspielbares Glücksspiel. **Restricted:** starke Gewalt, viel realistisches Blut, romantische Themen, Alkohol, starke Sprache. | Content maturity | 2026-10-12 | **OG: `production/promotion/content-maturity.md`** | Standardziel ist Minimal oder Mild. |
| CM-02 | Restricted ist nur für altersgeprüfte Nutzer ab 18. In Korea, Saudi-Arabien und der Türkei sind Restricted-Spiele nicht spielbar. **Extended AI interactions** (Gedächtnis über Sessions hinweg oder KI-Gespräch als Hauptzweck) **erfordern Restricted**. *(Korrigiert: Social Hangouts sind kein Restricted-Deskriptor, sondern eine eigene 16+/18+-Regel, s. KS-01.)* | Content maturity · Games with Generative AI | 2026-10-12 | **OG: `production/promotion/content-maturity.md`**, **OG: `generative-AI.md`** | Keine Extended-AI-Features (EXP-05). |
| CM-03 | Ohne vollständige, korrekte Angaben **schränkt Roblox die Spielbarkeit für alle ein**. Ohne Fragebogen gibt es keine Veröffentlichung für 16+ bzw. Limited (Playtester, Freunde, Community). Den Stichtag 30.09.2025 für unbewertete Spiele gibt es nur aus Newsroom und Presse. | Content maturity · Publish games and places · Newsroom 2025/08 | 2026-10-12 | **OG: `production/promotion/content-maturity.md`**, **OG: `production/publishing/publish-games-and-places.md`** · Stichtag WS-O | Der Fragebogen gehört zur Definition of Done **vor jedem Zugang außerhalb des Edit-Teams**, auch vor Playtests mit Dritten. |
| CM-04 | Pfad im Dashboard: **Configure → Questionnaire** *(korrigiert, v1.0 nannte den alten Pfad)*. Maßgeblich ist der extremste erreichbare Inhalt. Ändert ein Update Antworten, **muss** der Fragebogen neu abgegeben werden. Bei Abweichungen entfernt Roblox Label bzw. Deskriptoren, und bei wiederholten Fehlangaben folgen Konsequenzen für Spiel bzw. Account. | Content maturity · Safety | 2026-10-12 | **OG: `production/promotion/content-maturity.md`**, **OG: `safety.md`** | Jedes Inhalts-Update löst einen Fragebogen-Check aus. Die Antworten versionieren wir im Repo. |
| CM-05 | Das Label gilt nur für eigene Inhalte, nicht für Avatar-UGC der Spieler. Realistische oder exzessive Darstellungen können unabhängig vom Label moderiert werden (Restricted Content Policy). | Content maturity | 2026-10-12 | **OG: `production/promotion/content-maturity.md`** | Ein Label ist kein Freibrief. |
| CM-06 | Zugang je Kontotyp: **Kids** (5–8) sehen Minimal und Mild, **Select** (9–15, auch Selbstangabe ab 9 bis zur Altersprüfung) sehen Minimal, Mild und Moderate, **Roblox** (altersgeprüft ab 16) sieht alles außer Restricted. Eltern können über „Approved Experience“ einzelne Spiele freigeben (nicht Restricted). | Roblox Kids and Select · Content maturity | 2026-10-12 | **OG: `production/publishing/kids-and-select.md`** | Unsere Zielgruppe 9–14 ist **Select**. Mit Moderate verlieren wir Kids. |
| CM-07 | **Sensitive Issues als Hauptthema** (polarisierte soziale, politische oder religiöse Themen): nur ab 16, ohne Altersprüfung weder empfohlen noch auffindbar. Eltern können freigeben. Einzelne Assets und Chat zählen nicht. *(Korrigiert: v1.0 nannte „unter 13 gesperrt“.)* | Content maturity | 2026-10-12 | **OG: `production/promotion/content-maturity.md`** | Keine Streitthemen als Kern. |
| CM-08 | Die Altseite „Experience Guidelines“ (All Ages/9+/13+/17+, Pfad Audience → Maturity & Compliance) liegt noch im Repo, nennt aber **veraltete Schwellen** (13+/17+). | Experience guidelines | 2026-10-12 | **OG: `production/promotion/experience-guidelines.md`** → überholt durch CM-01…07 | Nicht mehr als Quelle verwenden. |
| CM-09 | **Neu – Fear.** Unter **Mild** fallen u. a. schweres Atmen, Herzklopfen, Schreie, unheimlich aussehende NPCs, **Jumpscares**, bedrohliche Musik und „gameplay that builds suspense“. Unter **Moderate** fallen realistisch-blutige Entstellungen, freiliegendes Gewebe bzw. Organe, offene Wunden, blutende Augen. Abgefragt wird auch die Häufigkeit (occasional oder repeated). Weitere Fragebogen-Kategorien: Crude Humor, Strong Language (18+), Alcohol (18+), Paid Random Items, Paid Item Trading, Media bzw. Content-Sharing, AI interaction. | Content maturity | 2026-10-12 | **OG: `production/promotion/content-maturity.md`** | Jedes Spannungselement führt zu **Mild (Fear)**. Moderate Fear entsteht erst durch Gore-Darstellungen. |

## 4. Kinderschutz 2024–2026 (KS)

| ID | Regel (sinngemäß) | Quelle | Abruf | Verif. | Konsequenz |
|---|---|---|---|---|---|
| KS-01 | **Social Hangouts** (Hauptthema: per Voice oder Text reden bzw. interagieren, auch „vibe games“ und „sad rooms“, aber **nicht** Rollenspiel) sind **nur ab 16**, mit privaten Räumen ab 18 (altersgeprüft). **Free-Form User Creation** ist **nur ab 16**. Dazu zählen freies Zeichnen, Malen, Schreiben oder Sprühen auf **2D- oder 3D-Flächen**, leere Pixel-Raster sowie temporäre bzw. rundenbasierte Zeichnungen, die andere sehen. Nicht dazu zählen Bauen mit 3D-Assets und vorab moderierte Inhalte. **Eltern können beides nicht freischalten.** Erwähnt der Titel oder die Beschreibung einen Hangout, wird das Spiel als Hangout eingestuft. *(Korrigiert: v1.0 nannte 13+ nach Presse 2024. Das ist der alte Stand, den `experience-guidelines.md` noch zeigt.)* | Content maturity | 2026-10-12 | **OG: `production/promotion/content-maturity.md`** | Keine Zeichen- oder Schreibflächen und keine Raster zum freien Markieren. Der Kern ist nie „abhängen und chatten“. Kein „Hangout“ in Titel oder Beschreibung. |
| KS-02 | Seit 07.01.2026 ist eine Altersprüfung Pflicht für Chat (sechs Altersbänder). Laut Creator-Doku ist Chat bei **Kids** standardmäßig aus (nur nach Altersprüfung und mit Eltern-Konto). Bei **Select** ist er für Selbstangaben aus und wird nach Altersprüfung schrittweise eingeführt. Bei **Roblox** (16+) ist er standardmäßig an. | Pressemitteilung (s. v1.0) · Kids and Select | 2026-10-12 | WS-O · **OG: `production/publishing/kids-and-select.md`** | Viele Spieler unserer Zielgruppe haben keinen Chat. Das Spiel muss ohne Chat funktionieren. |
| KS-03 | Private Server: Spieler unter 13 können je nach Privatsphäre- und Elterneinstellungen **eventuell nicht** beitreten. Private Server gibt es nur für öffentliche Spiele. *(Abgeschwächt: Laut Help Center sind es „nur Freunde“.)* | Private servers · Help-Artikel 205345050 | 2026-10-12 | **OG: `production/monetization/private-servers.md`** · WS-O | Keine Features, die Spieler unter 13 per Code auf fremde Server bringen. |
| KS-04 | **Kids/Select:** Kids (5–8) haben das volle Elternkontroll-Set inkl. „Approved Experience“. Select (9–15) hat volle Elternkontrollen bis 12 und Teil-Kontrollen bis 15. Spiele erreichen Nutzer unter 16 **nur nach bestandener Evaluation** (KS-05). | Kids and Select | 2026-10-12 | **OG: `production/publishing/kids-and-select.md`** | Für 9–14 sind Evaluation und Publishing-Anforderungen Pflicht. |
| KS-05 | **Publishing Requirements.** *Für 16+ und Trusted Friends:* Konto in gutem Stand und ≥ 2 Tage alt, Altersprüfung, Fragebogen. Kostenlos. *Für alle Altersgruppen (Kids/Select):* zusätzlich Verifizierung (Gesichtsschätzung unter 18, Ausweis ab 18), 2FA und **entweder** Plus/Premium seit 2 Monaten **oder** eine einmalige, rückerstattbare **Veröffentlichungsgebühr von 1.000 Robux pro Spiel**. Dazu kommt die **Evaluation**: Trial-Phase nur für altersgeprüfte Spieler ab 16, Analyse „highly engaged users“, Safety-Review, **Schwelle 250 unique plays durch highly engaged, altersgeprüfte Nutzer in 60 Tagen**. „Highly engaged“ bedeutet: Kontoalter, Spielzeit **und ein Kauf irgendwo auf Roblox in den letzten 60 Tagen**. Das Spiel selbst muss nicht monetarisieren. Alternativ gibt es ein **Expedited Review für 50.000 Robux** (rückerstattbar). Der Fortschritt ist im Dashboard „Audience Reach“ sichtbar. „Private“ Spiele sind nur für Edit-Berechtigte. Playtester brauchen die 16+-Anforderungen und die Einstellung Audience **Limited → Playtesters**. Die Anforderungen gelten für **jede** Veröffentlichung, auch Updates. **Widerspruch zur Rückerstattung:** 90 Tage nach Eignung bzw. nach Zahlung (`kids-and-select.md`) oder „25 highly engaged players über 60 Tage“ (`publish-games-and-places.md`). *(Korrigiert und präzisiert: v1.0 hatte unklare Zahlen 100/250/500.)* | Kids and Select · Publish games and places | 2026-10-12 | **OG: `production/publishing/kids-and-select.md`**, **OG: `production/publishing/publish-games-and-places.md`** | **Owner-Aufgabe:** Kontoanforderungen sowie Gebühr oder Abo (kollidiert mit Budget 0, D-006). Die Launch-Planung braucht **250 qualifizierte 16+-Spieler** (mit Käufen auf Roblox) in 60 Tagen. |
| KS-06 | Elternkontrollen: Ausgabenlimit, Ausgaben pro Spiel, Verbindungen, Spielzeit. Ab 16 bis 18 noch Einblick in Freunde, Bildschirmzeit und Ausgaben. | Kids and Select · Presse | 2026-10-12 | **OG: `production/publishing/kids-and-select.md`** · WS-S | Aggressive Monetarisierung ist ein Reputationsrisiko. |
| KS-07 | Safety-Leitfaden: UGC vorab moderieren, ephemer machen oder nur vordefinierte Optionen erlauben. Avatar-Editoren überwachen. Für Spieler unter 18 **keine Umgebungen, die überwiegend in privaten Räumen spielen**, **Bounding-Box-Grenzen** für Betten. Nachtclubs und Bars nur ab 18. Ban-API und `IsVerified` für Ranglisten-Integrität. Safety-Dashboard beobachten. | Safety | 2026-10-12 | **OG: `safety.md`** | Jedes Level-Design wird auf Missbrauchspotenzial geprüft. Wir beobachten das Safety-Dashboard nach jedem Release. |
| KS-08 | Voice-Chat nur altersgeprüft ab 13 und nur, wenn im Spiel aktiviert. Die Studio-Voice-Features sind altersbeschränkt. | Presse (geringe Qualität) · Account verification | 2026-10-12 | WS-S → `[ANNAHME]` · Studio-Teil **OG: `production/publishing/account-verification.md`** | Voice standardmäßig aus. |
| KS-09 | **Neu – Experience Notifications** gehen nur an opt-in-Nutzer **ab 13**. Auch der Opt-in-Prompt ist nur ab 13 erlaubt. | Experience notifications | 2026-10-12 | **OG: `production/promotion/experience-notifications.md`** | MVP ohne Benachrichtigungen (HR-FOMO). |

## 5. Monetarisierung (MON), bezahlte Zufallsitems (PRI), Werbung (AD)

### 5a. Allgemein

| ID | Regel (sinngemäß) | Quelle | Abruf | Verif. | Konsequenz |
|---|---|---|---|---|---|
| MON-01 | Produktbeschreibungen müssen „accurate and truthful“ sein. Developer Products laufen **ausschließlich über `ProcessReceipt`** (nicht über `PromptProductPurchaseFinished`). Passes werden beim Join geprüft und ihre Rechte zugewiesen. | Monetization foundations · Developer products · Passes | 2026-10-12 | **OG: `production/game-design/monetization-foundations.md`**, **OG: `production/monetization/developer-products.md`**, **OG: `production/monetization/passes.md`** | Idempotentes `ProcessReceipt`. Beschreibung = Lieferung. |
| MON-02 | **Managed Pricing** (Regional Pricing + Preisoptimierung): Für Passes standardmäßig aktiv, **neue Spiele und Items werden automatisch eingeschrieben** (Opt-out pro Item möglich). Regionalpreise liegen zwischen 30 % und 100 % des Standardpreises. Preise nie hart codieren, sondern per `GetProductInfo`. Laut Plus-Doku sehen Plus-Abonnenten sonst falsche Preise (10–20 % Rabatt). Für Transfers bzw. Geschenke gibt es `GetUsersPriceLevelsAsync`, ohne Caching. | Regional pricing · Managed pricing · Roblox Plus | 2026-10-12 | **OG: `production/monetization/regional-pricing.md`**, **OG: `production/monetization/managed-pricing.md`**, **OG: `production/monetization/roblox-plus.md`** | Preise immer live laden. Ob automatische **Preistests** bei Kindern gewollt sind, entscheidet der Owner (EU-Verbraucherrecht zu personalisierten Preisen: `[VORWISSEN, nicht aktuell]`, Rechtsprüfung). |
| MON-03 | **Offizielle Monetarisierungs-Guidelines** *(korrigiert: v1.0 meinte, es gäbe keine)*. Produkte müssen „transparent, honest, and user-friendly“ präsentiert werden. Rabatte müssen **echt** sein (nicht dauerhaft „im Angebot“) und **fair** (kein extrem kurzes Zeitfenster als Druckmittel). Nutzer dürfen nie irregeführt, verwirrt oder unter Druck gesetzt werden. **Verboten:** falsche Knappheit oder „nur kurz verfügbar“, Countdowns, die ungenau sind oder neu starten (Beispiel „Deal of the Day“, der jeden Tag wiederkommt). Bei Minderjährigen sind drängende Formulierungen zu vermeiden („GET IT NOW“, „LAST CHANCE“, besser „View Item“ oder „Open Shop“). Angebote sollen standardmäßig für alle Altersgruppen passen. Daneben stehen FTC-Beschwerde, Klagen und Studien (WS-S). | Monetization (Guidelines) | 2026-10-12 | **OG: `production/monetization/index.md`** · Kontext WS-S | **HR-MON** (strenger als Roblox, bleibt): auch keine echten Countdowns mit Kaufbezug, keine Kauf-Popups nach Niederlagen, keine Verlustdrohungen, Robux-Preis immer sichtbar. |
| MON-04 | Abos: Leistungen über die volle Laufzeit gewähren. **Nicht** zum Kauf auf anderen Plattformen leiten. **Bezahlte Leistungen nicht an Zusatzaufgaben wie Social-Media-Posts knüpfen.** Premium-Anreize: keine Paywall, keine taktischen Vorteile, keine Robux-Versprechen, die wir nicht kontrollieren. | Subscriptions · Engagement-based payouts | 2026-10-12 | **OG: `production/monetization/subscriptions.md`**, **OG: `production/monetization/engagement-based-payouts.md`** | Abos frühestens nach erneuter Compliance-Prüfung. |
| MON-05 | Pässe, die im „Buy Robux“-Bonuspool beworben werden, dürfen **keine bezahlten Zufallsitems** gewähren. | Passes | 2026-10-12 | **OG: `production/monetization/passes.md`** | Für spätere Kosmetik-Pässe irrelevant, nur zur Kenntnis. |

### 5b. Bezahlte Zufallsitems (Paid Random Items)

| ID | Regel (sinngemäß) | Quelle | Abruf | Verif. | Konsequenz |
|---|---|---|---|---|---|
| PRI-01 | Für Zufallsitems, die direkt mit Robux oder mit einer per Robux gekauften Spielwährung erworben werden, sind **alle Ergebnisse und die tatsächlichen Wahrscheinlichkeiten in %** anzuzeigen, Summe exakt 100 %, **vor dem Kauf**. Kategorien: **Capsule** (Rad, Ei, Truhe), **Enhancement** (Trank mit zufälliger Dauer, Upgrade mit Erfolgschance), **Combination** (zwei seltene Eier verschmelzen für ein besseres Ergebnis), **Probability Modifier** (Luck-Boosts, Pity, Rate-up). Gerundete Werte sind mit Hinweis erlaubt. Sind Ergebnisse nur einmal erhältlich, werden die Rest-Odds pro Nutzer aktualisiert. | Paid random items | 2026-10-12 | **OG: `production/monetization/paid-random-items.md`** | Ein Odds-Panel aus **einer** Config-Tabelle, die auch die Logik nutzt. **Achtung Kreuzungs-Mechaniken** (Combination items). |
| PRI-02 | Bei vielen Ergebnissen ist ein Popup erlaubt, mit sichtbarem „Info“- oder „Details“-Icon **vor dem Kauf**. Ein (i) ohne Wort reicht nicht. Bei gleichen Odds genügt eine Sammelangabe („Odds for each item: X %“). | Paid random items | 2026-10-12 | **OG: `production/monetization/paid-random-items.md`** | Button-Text „Wahrscheinlichkeiten“ bzw. „Details“. |
| PRI-03 | Indirekte Käufe zählen (Schlüssel, Reroll-Token, Spin-Tickets). Odds-verändernde Bezahlitems muss das Spiel **numerisch erklären**, und die neuen Odds müssen sich bei aktivem Item **dynamisch aktualisieren**. **Unbezahlte** Zufallsbelohnungen (z. B. ein gefundener Schlüssel) brauchen **keine** Offenlegung und keine Fragebogen-Angabe. | Paid random items · Content maturity | 2026-10-12 | **OG: `production/monetization/paid-random-items.md`**, **OG: `production/promotion/content-maturity.md`** | Unbezahlter Zufall ist unkritisch. Sobald Robux oder Robux-Währung den Zufall beeinflussen, gilt PRI voll. |
| PRI-04 | Ist `ArePaidRandomItemsRestricted` **true**, muss das Spiel eine von sechs Behandlungen anwenden: unbezahlten erspielbaren Weg anbieten, **vorab offengelegte feste Reihenfolge**, Direktkauf zum Erwartungswert, Entfernen bzw. Verstecken, Kauf mit Fehlermeldung blockieren oder Spieler wegteleportieren. **Handel:** Ist `IsPaidItemTradingAllowed` **false**, darf der Spieler Ergebnisse bezahlter Zufallsitems und andere bezahlte Items **nicht handeln**. *(Korrigiert: v1.0 hing die Handelssperre an ArePaidRandomItemsRestricted.)* Die Integration der PolicyService ist laut Monetarisierungs-Guideline **Pflicht**. Eine Länderliste ist nicht veröffentlicht. | Paid random items · PolicyService · Monetization | 2026-10-12 | **OG: `production/monetization/paid-random-items.md`**, **OG: `reference/engine/classes/PolicyService.yaml`**, **OG: `production/monetization/index.md`** | Beide Flags serverseitig in `pcall` prüfen, fail-closed `[ANNAHME]`. |
| PRI-05 | Laut Presse wurde die Offenlegung im Juni 2026 wegen des koreanischen Rechts verschärft und global ausgerollt. | TechTimes | 2026-10-12 | WS-S | Bundles brauchen Odds pro Einzelitem `[ANNAHME]`. |
| PRI-06 | Belohnungen für Rewarded Video Ads dürfen **nicht zufällig** sein. | Rewarded video ads | 2026-10-12 | **OG: `production/promotion/rewarded-video-ads.md`** | Belohnung fest. |

### 5c. Werbung & Markenintegrationen

| ID | Regel (sinngemäß) | Quelle | Abruf | Verif. | Konsequenz |
|---|---|---|---|---|---|
| AD-01 | **Rewarded Video Ads nur für Nutzer ab 13.** Unabhängige Werbung muss mit `AreAdsAllowed` gegated werden: hide, replace oder block. **Aufrufe an Ad-Server Dritter sind verboten, auch zu Analysezwecken.** Laut Help Center und Kanzlei gibt es seit 2023 generell keine Werbung an Nutzer unter 13. | Ad integrations · Comply with advertising standards · Ad safety | 2026-10-12 | **OG: `production/promotion/ad-integrations.md`**, **OG: `production/promotion/comply-with-advertising-standards.md`** · Stichtag WS-O/WS-S | Alle Werbeinhalte per `AreAdsAllowed` gaten. Keine externen Ad- oder Tracking-Calls. |
| AD-02 | Die Advertising Standards gelten für Roblox-Ads **und** unabhängige Ads. Kein Inhalt, der Nutzer per Telefonnummer o. ä. vom Plattform weglockt. | Comply with advertising standards | 2026-10-12 | **OG: `production/promotion/comply-with-advertising-standards.md`** · Standards selbst WS-S | Keine Fremdwerbung ohne Owner-Freigabe. |
| AD-03 | **Ad Integrations:** Als Werbung gilt, was gegen Vergütung erscheint **oder** Off-Platform-Produkte bzw. -Dienste bewirbt, **auch eigenes Merch**. Pflicht sind Registrierung im Ads Manager, Asset-Moderation **vor** dem Einsatz, Roblox-Ad-Labels bzw. Disclosure und Prüfung der Nutzerberechtigung. Kein „free Robux“. Die Termine (15.04. bzw. 04.05.2026) und der Rev-Share ab 2027 sind nur aus der Presse belegt. | Ad integrations · Presse | 2026-10-12 | **OG: `production/promotion/ad-integrations.md`** · Termine WS-S | Auch Eigenwerbung für Merch ist Werbung. MVP ohne jede Werbung. |
| AD-04 | **Rewarded Video Ads – Voraussetzungen:** öffentliches, uneingeschränktes Spiel **ohne Free-Form User Creation**, Fragebogen von Roblox **geprüft und genehmigt**, ≥ 2.000 Unique Visitors pro Monat. Publisher ab 13, guter Stand, 2FA und ID-Verifizierung. Vor dem Abspielen eine klare Nutzeraktion und eine eindeutige Ankündigung der Belohnung. Belohnung **sofort**, als **Developer Product, das sonst kaufbar wäre**, ohne die Wirtschaft aufzublähen. **Keine Fortschritts-Sperre**, kein Verdecken des Bildschirms, keine betrügerischen Belohnungen. | Rewarded video ads | 2026-10-12 | **OG: `production/promotion/rewarded-video-ads.md`** | Erst nach dem MVP prüfen. Nie als Pflicht. |

## 6. Text-Filterung (TXT)

| ID | Regel (sinngemäß) | Quelle | Abruf | Verif. | Konsequenz |
|---|---|---|---|---|---|
| TXT-01 | Roblox filtert In-Game-Chat automatisch. Für **jeden angezeigten Text, den wir nicht explizit kontrollieren**, sind wir selbst verantwortlich. **Erkennt Roblox fehlende Filterung, wird das Spiel entfernt, bis die Filterung eingebaut ist.** Laut Safety-Doku: alles filtern, was ein Spieler tippen kann und andere sehen (Schilder, Haustiernamen). | Text filtering · Safety | 2026-10-12 | **OG: `ui/text-filtering.md`**, **OG: `safety.md`** | Pflicht-Code-Regel: Kein Nutzertext erreicht andere ungefiltert. |
| TXT-02 | `TextService:FilterStringAsync(text, fromUserId, context)` → `TextFilterResult` mit `GetNonChatStringForBroadcastAsync` (alle), `GetNonChatStringForUserAsync` (ein Empfänger) und `GetChatForUserAsync`. **Einmal pro Eingabe aufrufen. Schlägt der Aufruf fehl, den Text niemandem zeigen** und nicht selbst erneut versuchen (eingebautes Retry). **Wirft einen Fehler, wenn `fromUserId` nicht im aktuellen Server online ist.** Nicht pro Tastendruck filtern. | Text filtering · TextService · TextFilterResult | 2026-10-12 | **OG: `ui/text-filtering.md`**, **OG: `reference/engine/classes/TextService.yaml`**, **OG: `reference/engine/classes/TextFilterResult.yaml`** | Ein zentrales Server-Modul, fail-closed. **Texte von Offline-Spielern lassen sich so nicht filtern**, das ist relevant für Bestenlisten. |
| TXT-03 | Gespeicherte Texte (z. B. Haustiernamen im DataStore) werden **beim Abrufen** gefiltert. | Text filtering | 2026-10-12 | **OG: `ui/text-filtering.md`** | Rohtext mit Autor-ID speichern und bei der Anzeige neu filtern, solange der Autor online ist. Sonst nicht anzeigen. |
| TXT-04 | Filter-Szenarien: TextBox oder eigene Tastaturen, **Wörter, die aus Zufallszeichen generiert werden**, Inhalte von externen Webservern und gespeicherte Texte. | Text filtering | 2026-10-12 | **OG: `ui/text-filtering.md`** | Generierte Namen nur aus kuratierten Wortlisten mit Blocklist-Test. Silben- oder Zeichengeneratoren nur **mit** Filter. |
| TXT-05 | Berechtigungsprüfung: `TextChatService:CanUserChatAsync` (Nutzer im Server), `CanUsersChatAsync` (beide im Server; Elterneinstellungen, Blocks) und `CanUsersDirectChatAsync` für nutzerinitiierte, geschlossene Direktkanäle. Laut Generative-AI-Seite müssen Texteingaben und -ausgaben von KI-Drittanbietern über TextChatService laufen. | TextChatService · Games with Generative AI | 2026-10-12 | **OG: `reference/engine/classes/TextChatService.yaml`**, **OG: `generative-AI.md`** | Keine eigenen Kommunikationskanäle ohne diese Prüfungen. Lieber feste Phrasen bzw. Emotes. |
| TXT-06 | Free-Form-Zeichnen bzw. -Schreiben gibt es nur ab 16 (KS-01). | Content maturity | 2026-10-12 | **OG: `production/promotion/content-maturity.md`** | Keine Freitext-Schilder oder Zeichenflächen. |

## 7. Off-Platform-Aktionen & Social Links (OFF)

| ID | Regel (sinngemäß) | Quelle | Abruf | Verif. | Konsequenz |
|---|---|---|---|---|---|
| OFF-01 | **Auch in der Creator-Doku gibt es keine Regel** zu Belohnungen für Like, Favorite oder Gruppenbeitritt (Volltextsuche in af5f853 ohne Treffer). Im Forum gelten Like-Belohnungen überwiegend als unzulässig, Gruppen-Perks meist als zulässig, Follow-Belohnungen als unangemessen. | DevForum (s. v1.0) · Volltextsuche creator-docs | 2026-10-12 | WS-F · Negativbefund OG | **HR-OFF (Hausregel):** keine Belohnung für Like, Favorite oder Follow. Gruppen-Perk nur kosmetisch und erst nach Owner-Prüfung der Community Standards. |
| OFF-02 | Alte Community-Regel laut Forum: keine Gewinnspiele mit Preisen, Promo-Codes nicht im Tausch gegen etwas. Laut Discovery gilt „Leading with giveaways“ in Metadaten als **Grund für weniger Reichweite**. | DevForum · Discovery | 2026-10-12 | WS-F · **OG: `discovery.md`** | Keine Gewinnspiele. Codes bedingungslos. Keine Belohnungsversprechen im Titel. |
| OFF-03 | `PolicyService.AllowedExternalLinkReferences` ist ein **„legacy field. It always returns an empty array.“** *(Korrigiert: v1.0 hielt es für ein mögliches Gate.)* Die Safety-Seite erwähnt noch PolicyService für „approved external social media sites“, das ist veraltet. | PolicyService · Safety | 2026-10-12 | **OG: `reference/engine/classes/PolicyService.yaml`** · Widerspruch **OG: `safety.md`** | Im Spiel gibt es keine Off-Platform-Links oder Handles. |
| OFF-04 | **Social Links:** Nur Nutzer, die per Altersprüfung **mindestens 16** sind, können bis zu **3 Links** auf der Spiel-Detailseite setzen (Facebook, Twitter, YouTube, Twitch, Discord, Guilded, Roblox-Community). Bei Community-Spielen braucht es mindestens einen altersgeprüften Mitwirkenden ab 16. **Sichtbar nur für altersgeprüfte Nutzer ab 16.** Im Spiel erlaubt: „Links auf unserer Spielseite“. Verboten: URLs, Discord-Invites, E-Mail. | Social media links | 2026-10-12 | **OG: `production/promotion/social-media-links.md`** | Unsere Zielgruppe 9–15 sieht keine Social Links. Diese Kanäle taugen nicht als Support-Weg für Kinder. |
| OFF-05 | Belohnungen für Discord-Beitritt bzw. -Boost sind im Forum eine Grauzone. Für Abos gilt offiziell: bezahlte Leistungen **nicht an Social-Media-Posts koppeln** (MON-04). | DevForum · Subscriptions | 2026-10-12 | WS-F · **OG: `production/monetization/subscriptions.md`** | Verboten (HR-OFF). |
| OFF-06 | **Offiziell unterstützt:** das **Friend-Referral-System**, das Einladende und Eingeladene über `GetJoinData().ReferredByPlayerId` belohnt, Perks für Beitritte über **Share Links** (`LaunchData`) und **Creator Rewards** (35 % auf die ersten 100 $ qualifizierter Käufe neuer bzw. reaktivierter Nutzer über Share Links; Bedingungen siehe Doku). *(Ergänzt: v1.0 nahm an, Einladungsbelohnungen seien heikel. Roblox sieht sie aber ausdrücklich vor.)* | Referral system · Invite prompts · Share links · Creator Rewards | 2026-10-12 | **OG: `production/promotion/referral-system.md`**, **OG: `production/promotion/share-links.md`**, **OG: `creator-rewards.md`** | Plattformseitig erlaubt. **HR-OFF für das MVP:** keine Einladungsbelohnungen, um sozialen Druck auf Kinder zu vermeiden. Neubewertung nach dem MVP. |

## 8. Urheberrecht / IP (IP)

| ID | Regel (sinngemäß) | Quelle | Abruf | Verif. | Konsequenz |
|---|---|---|---|---|---|
| IP-01 | Roblox entfernt rechtsverletzende Inhalte und sperrt bzw. kündigt Konten, die **wiederholt oder gravierend** verletzen. Es gibt Counter-Notices (Wiederherstellung meist binnen 14 Werktagen), Strafbarkeit falscher Notices, ein eigenes DSA-Meldeverfahren und für Uploader unter 13 die Vertretung durch Erwachsene. Eine „Three Strikes“-Regel steht dort nicht. *(Die Seite `dmca-guidelines.md` ist durch `ip-guidelines.md` ersetzt.)* | IP Guidelines · DSA IP reporting | 2026-10-12 | **OG: `production/publishing/ip-guidelines.md`** | Null-Risiko-Asset-Politik. |
| IP-02 | Musik nur, wenn sie uns gehört oder lizenziert ist. Lizenzierte Musik nur auf Roblox. | Help „Licensed Music“ | 2026-10-12 | WS-O (Ordner `audio/` nicht im Checkout) | Audio nur aus der Lizenzbibliothek oder selbst erstellt. Nicht in Trailern außerhalb von Roblox. |
| IP-03 | Audio-Privacy (Audio > 6 s privat, nur für denselben Owner) | DevForum 1701697 | 2026-10-12 | WS-O + `[VORWISSEN, nicht aktuell]` | Upload durch den Spiel-Owner bzw. die Gruppe. |
| IP-04 | **„Copyright does not protect facts or ideas, but it may protect the specific expression.“** Verletzung liegt auch vor ohne Monetarisierung, mit Nennung der Quelle, bei Download aus dem Netz oder wenn „andere es auch tun“. **KI-veränderte Kopien** geschützten Ausdrucks sind meldefähig. Creator-Store-Assets müssen den IP-Guidelines folgen. Assets können **Schadskripte** enthalten (Remote-`require`, Obfuskation), daher „Disable Scripts“ nutzen. | IP Guidelines · Creator Store | 2026-10-12 | **OG: `production/publishing/ip-guidelines.md`**, **OG: `production/creator-store.md`** | Mechaniken übernehmen ist zulässig, Ausdruck nicht. **Auch KI-generierte Assets** dürfen keinen fremden Ausdruck reproduzieren. Store-Modelle nur ohne Skripte. |

## 9. Datenschutz & Rechtliches (DS)

| ID | Regel (sinngemäß) | Quelle | Abruf | Verif. | Konsequenz |
|---|---|---|---|---|---|
| DS-01 | Die Seite „About GDPR and CCPA“ gibt es in af5f853 nicht mehr. Die Nachfolgeseite **„RTBF and creators“** definiert personenbezogene Daten breit (alles, was auf eine Person zurückführbar ist) und verlangt, Daten **nicht unbegrenzt** zu halten, sondern zu löschen, sobald kein Zweck mehr besteht. *(Korrigiert: Der Satz „nur UserId und Username speichern, keine Geburtsdaten oder Fotos“ war im Original nicht auffindbar und gilt jetzt als **Hausregel HR-DATA**.)* | RTBF and creators | 2026-10-12 | **OG: `production/publishing/RTBF-and-creators.md`** | HR-DATA: nur User-ID und Spielstand speichern, keine Namen, keine Freitexte mit persönlichen Daten. |
| DS-02 | **RTBF:** Roblox schickt **täglich** eine Nachricht mit offenen Anfragen pro Spiel. **Automatische Löschung über Deletion-Templates** im Data Stores Manager (Token `{UserId}` im Key-Namen oder Scope, statisches Muster; Standard- **und Ordered**-Keys; maximal 100 Templates). Alternativ ein Creator-Webhook („Right to Erasure Request“). **Der Creator bleibt verantwortlich**, auch für Daten außerhalb der Templates. Eine 30-Tage-Frist steht dort nicht. | RTBF and creators · Data store RTBF | 2026-10-12 | **OG: `production/publishing/RTBF-and-creators.md`**, **OG: `cloud-services/data-stores/right-to-be-forgotten.md`** | Jeder Key enthält die UserId im statischen Muster, damit die Templates greifen. Ordered Stores mit Tagesnamen sind **nicht** per Template abdeckbar, deshalb tägliche Bestenlisten über MemoryStore mit TTL ≤ 45 Tage `[ANNAHME, Systems Engineer prüft]`. |
| DS-03 | Creator erhalten Username, Display Name, ID, Metriken und Region. Ob der Creator Verantwortlicher oder Auftragsverarbeiter ist, ist ungeklärt. RTBF-Doku: Pflichten gelten für „controllers“. | ConductAtlas · RTBF and creators | 2026-10-12 | WS-S · **OG: `production/publishing/RTBF-and-creators.md`** | Analytics nur Roblox-intern, keine Calls an Dritte (vgl. AD-01). |
| DS-04 | EU-DSA: Eine VLOP-Designierung von Roblox ist möglich, aber nicht bestätigt. Es gibt ein IP-Meldeverfahren nach DSA. | Presse · DSA IP reporting | 2026-10-12 | WS-S · Existenz **OG: `production/publishing/ip-guidelines.md`** | Rechtsprüfung der Trader-Frage durch eine Fachperson. |
| DS-05 | USK stuft Roblox ab 16 ein (Richtwert). | Presse | 2026-10-12 | WS-S | Kaufanreize und Interaktion minimieren. |
| DS-06 | **Neu – Domain-scoped User IDs:** Neue Spieler bekommen **pro Spiel eine eigene ID**. Wer vor dem Rollout schon gespielt hat, behält die globale ID. Empfohlen ist `player.User` bzw. `Datatype.User`. | Users and domain-scoped user IDs | 2026-10-12 | **OG: `players/users.md`** | Der Systems Engineer nutzt `player.User`. IDs nicht spielübergreifend verknüpfen. |

## 10. Sonstige Entwickler-Pflichten (EXP)

| ID | Regel (sinngemäß) | Quelle | Abruf | Verif. | Konsequenz |
|---|---|---|---|---|---|
| EXP-01 | **Video-Thumbnails:** authentisch. Erlaubt sind leichte Nachbearbeitung, Logo-Overlay, kuratierte Sequenzen und In-Game-UI-Text. Verboten sind nicht vorhandene Mechaniken, **falsch dargestelltes Thema** (ein Horrorspiel muss Horror zeigen), künstlich aufgewertete Grafik, Realfilm, **Voice-over, Sprachchat und Musik mit Gesang** sowie Werbe- oder subjektive Behauptungen („50 % off“, „Free UGC!“). Kontingent: 3 pro Monat. Alle Bilder werden moderiert. Thumbnail-Personalisierung ab 2 aktiven Thumbnails. | Thumbnails | 2026-10-12 | **OG: `production/publishing/thumbnails.md`** | Nur echte Captures. Musik ohne Gesang. |
| EXP-02 | Icons werden vorab moderiert, quadratisch mit ≥ 512×512 px. Mehrdeutige Grafiken vermeiden. | Icons | 2026-10-12 | **OG: `production/publishing/experience-icons.md`** | Das Icon zeigt das eigene Spiel. |
| EXP-03 | **Weniger Reichweite** bei „Leading with giveaways“, **stark abweichenden Metadaten** (Titel oder Thumbnail versprechen etwas anderes) und **„Non-unique games“** (Metadaten und Place-Dateien ähneln bestehenden Spielen stark). Titel: kein Spam, Emojis sparsam, Beschreibung ohne Keyword-Spam (auch keine fremden Spielnamen). | Discovery · Discovery FAQ · Publish games and places | 2026-10-12 | **OG: `discovery.md`**, **OG: `discovery-faq.md`**, **OG: `production/publishing/publish-games-and-places.md`** | Eigenständige Titel und Visuals. Keine fremden Spielnamen in der Beschreibung. |
| EXP-04 | „Steal“-Mechaniken: keine Regel (auch nicht im Original gefunden) | – | 2026-10-12 | `[ANNAHME]` | Bezahlte Items sind nie stehlbar. |
| EXP-05 | **Generative KI im Spiel:** muss im Fragebogen angegeben werden. **Extended interactions erfordern Restricted (18+).** Pflicht-Hinweise: „Das ist ein KI-Gespräch“ zu Beginn und während der Sitzung, Verweis auf Hilfe bei Krisen. Ausgaben müssen zum Label passen. Bei Drittanbietern ist der Creator verantwortlich, Text läuft über TextChatService. | Games with Generative AI · Content maturity | 2026-10-12 | **OG: `generative-AI.md`**, **OG: `production/promotion/content-maturity.md`** | Keine Laufzeit-KI-Dialoge im MVP. |
| EXP-06 | Ban-API: Spielregeln müssen gut sichtbar sein, fair angewendet werden und dürfen den Community Standards nicht widersprechen. Ban-Nachrichten dürfen keine Handles oder direkten Links enthalten. | Players (Bans) | 2026-10-12 | **OG: `players/index.md`** | Falls Bans: Regeln im Spiel sichtbar machen. |
| EXP-07 | **Neu – Persistente Bestenlisten (Beta):** Die Roblox-PlayerList zeigt „Here“ (leaderstats), „Friends“ und „Global“ aus **einem** registrierten OrderedDataStore. Die Namen **rendert Roblox selbst**. Score-Schreibvorgänge serverseitig validieren, unmögliche Werte prüfen. Eine aktive Bestenliste pro Spiel. | Leaderboards | 2026-10-12 | **OG: `players/leaderboards.md`** | Bevorzugter Weg, um Namen fremder Spieler ohne eigene Text-Anzeige zu zeigen (C-A16 im Konzeptcheck). |

---

## 11. Checkliste Konzept-Vorprüfung (Ja/Nein)

| # | Frage | Erwartet | Bei Abweichung | Regel |
|---|---|---|---|---|
| K01 | Ist ein Label **Minimal oder Mild** realistisch erreichbar? (Jedes Spannungselement bedeutet mindestens Mild.) | Ja | ⚠ Owner | CM-01/06/09 |
| K02 | Gibt es Romantik, Dating, Hochzeit oder Kuss, auch im Titel? | Nein | ❌ (18+) | CS-01 |
| K03 | Ist der Hauptzweck Abhängen bzw. Chatten (Hangout)? Steht „Hangout“ im Titel oder in der Beschreibung? | Nein | ❌ (16+) | KS-01 |
| K04 | Spielt das Konzept überwiegend in privaten Räumen oder Erwachsenen-Settings? | Nein | ❌ (18+) | CS-02 |
| K05 | Gibt es freies Zeichnen, Malen oder Schreiben auf 2D- oder 3D-Flächen oder frei markierbare Raster, die andere sehen? | Nein | ❌ (16+) | KS-01 |
| K06 | Gibt es Glücksspiel oder eine Casino-Kulisse? | Nein | ❌ / Moderate | CS-06 |
| K07 | Gibt es bezahlte Zufallsitems (auch Combination- oder Enhancement-Items)? Falls ja: Odds, Boost-Erklärung, beide PolicyService-Flags? | Nein, oder Ja mit allem | ⚠ | PRI-01…04 |
| K08 | Kommen Reales, Marken oder Sensitive Issues als Hauptthema vor? | Nein | ❌ / ⚠ | CS-04, CM-07, IP-04 |
| K09 | Geht Gewalt oder Blut über mild bzw. unrealistisch hinaus? | Nein | ⚠ | CM-01 |
| K10 | Werden persönliche Daten abgefragt? | Nein | ❌ | CS-07, DS-01 |
| K11 | Gibt es Off-Platform-Links im Spiel oder Belohnungen für Like, Favorite oder Follow? | Nein | ❌ | OFF-01…05 |
| K12 | Gibt es Freitext oder generierte Wörter, die andere sehen? Falls ja: Filter eingeplant (Autor muss online sein)? | Nein, oder Ja mit Filter | ⚠ | TXT-01…04 |
| K13 | Gibt es ein eigenes Kommunikationssystem? | Nein | ⚠ | TXT-05 |
| K14 | Ist der Kernloop ohne Kauf fair spielbar? | Ja | ⚠ | MON-03, HR-MON |
| K15 | Ist das Konzept frei von falschen Rabatten, Knappheit, Countdowns oder drängender Sprache (MON-03) und von Streak- bzw. FOMO-Druck (HR-FOMO)? | Ja | ❌ | MON-03 |
| K16 | Gibt es Handel? Falls ja: `IsPaidItemTradingAllowed`, Scam-Schutz? | Nein, oder Ja mit Schutz | ⚠ | PRI-04, CS-09 |
| K17 | Können bezahlte Items verloren gehen oder gestohlen werden? | Nein | ❌ | EXP-04 |
| K18 | Sind alle Assets eigen oder lizenziert, Store-Modelle ohne Skripte? | Ja | ❌ | IP |
| K19 | Gibt es generative KI zur Laufzeit (Extended bedeutet Restricted)? | Nein | ⚠ / ❌ | EXP-05 |
| K20 | Sind Werbung, Markenintegration oder Eigenwerbung für Merch geplant? | Nein | ⚠ | AD |
| K21 | Funktioniert das Spiel ohne Chat? | Ja | ⚠ | KS-02 |
| K22 | Gibt es Avatar-Nähe mit Missbrauchspotenzial? | Nein, oder begrenzt | ⚠ | KS-07 |
| K23 | Kann das Spiel in der **16+-Trial-Phase 250 qualifizierte Spieler** (mit Käufen auf Roblox) in 60 Tagen gewinnen? | Ja | ⚠ | KS-05 |

## 12. Checkliste Release-Prüfung

- [ ] **R01** Fragebogen (Configure → Questionnaire) vollständig und nach der letzten Inhaltsänderung neu abgegeben. Die Antworten liegen im Repo. (CM-03/04)
- [ ] **R02** Publishing Requirements je Zielgruppe erfüllt: 16+ (Altersprüfung, Konto ≥ 2 Tage) bzw. alle Altersgruppen (Verifizierung, 2FA, Gebühr 1.000 R$ oder Plus/Premium seit 2 Monaten). Evaluation läuft. (KS-05)
- [ ] **R03** Text-Register vollständig. Serverseitiger Filter, fail-closed, gespeicherte Texte nur mit Online-Autor. (TXT-01…04)
- [ ] **R04** Keine Kommunikation ohne TextChatService-Berechtigung. Spielbar ohne Chat. (TXT-05, KS-02)
- [ ] **R05** PRI: Odds, Details-Button, Boosts, `ArePaidRandomItemsRestricted` samt Behandlung, `IsPaidItemTradingAllowed` samt Handelssperre. (PRI-01…04)
- [ ] **R06** Preise live geladen, Hard-Code-Check bestanden. Entscheidung zu Managed Pricing bzw. Preistests getroffen. (MON-02)
- [ ] **R07** `ProcessReceipt` idempotent. Beschreibung = Lieferung. (MON-01)
- [ ] **R08** Monetarisierungs-Guidelines (MON-03) und HR-MON bzw. HR-FOMO auditiert.
- [ ] **R09** Keine Links, Handles oder Invites im Spiel. Social Links nur auf der Detailseite. Keine Engagement-Belohnungen. (OFF)
- [ ] **R10** Thumbnails, Icons und Video authentisch, ohne Gesang bzw. Voice-over, Metadaten passend und eigenständig. (EXP-01…03)
- [ ] **R11** Asset- und Audio-Register vollständig. Store-Modelle ohne Skripte. (IP)
- [ ] **R12** RTBF-Deletion-Templates für alle Stores mit Nutzerdaten konfiguriert und getestet. Prozess für die tägliche RTBF-Nachricht steht. (DS-01/02)
- [ ] **R13** Werbung nur mit `AreAdsAllowed`, Rewarded Ads nur ab 13, keine Ad-Server oder Tracker von Dritten. (AD)
- [ ] **R14** Safety-Design geprüft (private Räume, Bounding-Box, Avatar-Editor, Emotes). Safety-Dashboard eingerichtet. (KS-07)
- [ ] **R15** Gewalt, Blut, Fear und Humor entsprechen dem Label. Keine Sensitive Issues. (CM)
- [ ] **R16** Test mit eingeschränktem Konto (Select bzw. ohne Altersprüfung): keine gesperrten Features. `[ANNAHME: Test-Account klären]`
- [ ] **R17** Glücksspiel-Audit bestanden. (CS-06)
- [ ] **R18** Steal- und Verlustmechaniken schützen bezahlte Items. (EXP-04)
- [ ] **R19** Owner hat die Liste „Nicht verifiziert“ im Original geprüft.
- [ ] **R20** Freigabeprotokoll unter `reports/` abgelegt.
- [ ] **R21** Keine Experience Notifications im MVP. Später nur ab 13 mit Opt-in. (KS-09)

## 13. Nicht verifiziert – vor öffentlichem Release vom Owner/Compliance im Original nachzulesen

1. **Community Standards** (about.roblox.com bzw. en.help), vollständig. Vor allem: Romantik bzw. Dating, Off-Platform, Spam, Scams, Advertising-Abschnitt, **Engagement-Belohnungen** (Like, Favorite, Gruppe; auch im Original der Creator-Doku nicht geregelt).
2. **Terms of Use und Creator Terms** (gültige Fassung, KI-Klauseln, Extended Services). (TOU)
3. **Advertising Standards** (Help-Artikel 13722260778260): verbotene Kategorien, Stichtag für das Werbeverbot unter 13.
4. **Widerspruch bei der Rückerstattung** der Veröffentlichungsgebühr (`kids-and-select.md` gegenüber `publish-games-and-places.md`). Aktuelle Kriterien für „highly engaged“. (KS-05)
5. **Länderliste** für Einschränkungen bei PRI bzw. Handel (nicht veröffentlicht). Bundle-Pflichten nach koreanischem Recht. (PRI-04/05)
6. **Audio** (Ordner `audio/` nicht im Checkout): Lizenzumfang der Roblox-Audio, Audio-Privacy, Nutzung in Clips. (IP-02/03)
7. **Voice-Chat-Regeln** (Ordner `chat/` nicht im Checkout). (KS-08)
8. **Status der DSA-Designierung**, Trader-Pflichten, Creator-Rolle nach DSGVO. (DS-03/04)
9. **Persistente Bestenlisten (Beta):** Verfügbarkeit, Darstellung für Kids/Select, eventuelle Einschränkungen. (EXP-07)
10. **Managed Pricing bzw. Preistests** aus Sicht des EU-Verbraucherrechts (personalisierte Preise). (MON-02)
11. **Steal-Mechaniken** (keine Regel gefunden). (EXP-04)
12. **Private Server** für Spieler unter 13 (Help Center und Creator-Doku formulieren unterschiedlich). (KS-03)

## 14. Änderungsliste v1.0 → v1.1 (Original-Abgleich creator-docs @af5f853)

**Hochgestuft auf „Original gelesen“, inhaltlich bestätigt:**
CM-01, CM-05, CM-06, KS-04, KS-07, MON-01, PRI-01, PRI-02, PRI-03, PRI-06, AD-04, TXT-01, TXT-03, TXT-04, TXT-06, OFF-04, OFF-06, EXP-01, EXP-02, IP-04 (Grundsatz Idee vs. Ausdruck), CS-06 (Glücksspiel-Definition), CS-10 (Creator-Rewards-Verbote).

**Korrigiert oder präzisiert:**

| Regel | v1.0 | v1.1 (Original) |
|---|---|---|
| KS-01 | Hangouts und Free-Form-Erstellung für unter 13 gesperrt (Presse 2024) | **Nur ab 16**, Eltern können nicht freischalten. Free-Form umfasst auch 3D-Flächen und Pixel-Raster. Hangout-Begriff im Titel führt zur Einstufung. |
| CS-02 | Private Räume, Bars und Clubs → ID-verifiziert ab 17 | **Altersgeprüft ab 18.** Auch „romantic themes“, sogar im Titel. |
| CM-07 | Sensitive Issues → unter 13 gesperrt | **Nur ab 16**, ohne Altersprüfung nicht auffindbar. Eltern können freigeben. |
| CM-02 | Social Hangouts und Extended AI als Restricted-Deskriptoren (widersprüchlich) | Hangouts sind eine eigene 16+/18+-Regel. **Extended AI → Restricted** bestätigt. Restricted ist in KR, SA und TR nicht spielbar. |
| CM-04 | Pfad Audience → Maturity & Compliance | **Configure → Questionnaire**. Neuabgabe bei Änderungen ist Pflicht. |
| CM-09 (neu) | Fear-Stufen unbekannt | **Jumpscares und Spannung sind „Mild“.** Moderate Fear entsteht erst durch realistische Gore-Elemente. |
| KS-05 | Gebühr unklar, Schwelle 100/250/500 | **1.000 R$ pro Spiel** (rückerstattbar) oder Plus/Premium seit 2 Monaten. **250 unique plays** durch highly engaged, altersgeprüfte 16+-Nutzer in 60 Tagen, „highly engaged“ setzt einen Kauf auf Roblox voraus. Expedited Review 50.000 R$. Playtester brauchen die 16+-Anforderungen. |
| KS-03 | Unter 13 nur Freunde-Server | Unter 13 „eventuell nicht“, je nach Einstellungen |
| MON-03 | „Kein offizielles Dark-Pattern-Regelwerk gefunden“ | **Offizielle Guidelines:** echte und faire Rabatte, keine falsche Knappheit, keine falschen oder neu startenden Countdowns, keine drängende Sprache gegenüber Minderjährigen. PolicyService ist Pflicht. |
| MON-02 | Regional Pricing | Managed Pricing: **neue Spiele und Items standardmäßig eingeschrieben** (inkl. Preistests), Spanne 30–100 %, Plus-Rabatte erfordern Live-Preise. |
| PRI-04 | Handelssperre über ArePaidRandomItemsRestricted | Handelssperre über **`IsPaidItemTradingAllowed`**. Sechs Behandlungen, darunter eine feste Reihenfolge. |
| PRI-01 | Lootbox, Rad, Ei, Boost, Pity | Zusätzlich **Combination-** und **Enhancement-Items**, Rest-Odds bei Einmal-Items, Rundungsregel |
| OFF-03 | `AllowedExternalLinkReferences` als mögliches Gate | **Legacy, liefert immer ein leeres Array.** Social Links **nie im Spiel**. |
| OFF-06 | Einladungs-Belohnungen heikel | **Offiziell unterstütztes Referral-System** inkl. Belohnungen. Unser MVP-Verzicht ist eine Hausregel. |
| AD-01 | Keine Ads an unter 13 (Presse) | Original: Rewarded Video nur ab 13, `AreAdsAllowed`-Pflicht, **keine Ad- oder Analytics-Calls an Dritte** |
| AD-03 | Registrierungspflicht (Presse) | Bestätigt. **Eigenwerbung für eigenes Merch ist Werbung.** Termine weiter nur aus der Presse. |
| AD-04 | 13+, ID, 2FA, 2.000 Visitors | Zusätzlich: **kein Free-Form**, Fragebogen genehmigt, Belohnung als Developer Product, keine Fortschritts-Sperre, sofortige Vergabe |
| TXT-01/02 | Filterpflicht | Zusätzlich: **Spiel wird ohne Filter entfernt.** `FilterStringAsync` **wirft einen Fehler bei Offline-Autor**. Nicht selbst erneut versuchen. |
| TXT-05 | [VORWISSEN] | Bestätigt: Can(User/Users/UsersDirect)ChatAsync |
| DS-01 | „Nur UserId und Username“ (GDPR-Seite) | Seite nicht mehr vorhanden. Jetzt RTBF-Seite (Datenminimierung, Löschung), Satz als **Hausregel HR-DATA** |
| DS-02 | Webhook, ~30 Tage [VORWISSEN] | **Tägliche RTBF-Nachricht, Deletion-Templates** (UserId im Key bzw. Scope), Webhook. Creator bleibt verantwortlich. Keine Frist genannt. |
| DS-06 (neu) | – | Domain-scoped User IDs (`player.User`) |
| IP-01 | DMCA-Seite, „Three Strikes“ unbestätigt | Seite jetzt `ip-guidelines.md`: Sperre bei „repeatedly or egregiously“. **KI-veränderte Kopien** sind meldefähig. |
| EXP-01 | Kein Voice-over | Präzisiert: keine Musik **mit Gesang**. Thema muss stimmen (Horror zeigt Horror). |
| EXP-03 | Keine offizielle Clickbait-Regel | **Offiziell:** weniger Reichweite bei Giveaways, abweichenden Metadaten und **non-unique games** |
| EXP-05 | Extended AI → Restricted (Help Center) | Bestätigt in `generative-AI.md`, dazu **KI-Hinweispflicht** |
| EXP-06/07, KS-09 (neu) | – | Ban-Regeln, persistente PlayerList-Bestenlisten (Beta), Notifications nur ab 13 mit Opt-in |
| CM-08 | Experience Guidelines als Quelle | Als **veraltete Altseite** markiert |

**Unverändert „nicht im Original gelesen“:** alle CS-Regeln mit Help-Center- bzw. Newsroom-Quelle (CS-01 teilweise, CS-03, CS-05, CS-09), alle TOU, PRI-05, IP-02/03, KS-08, DS-03…05, Termine aus AD-03.

---
*Ende des Digests. Bei jeder Regeländerung: Version hochzählen, Datum aktualisieren, betroffene Regel-IDs in der Änderungsliste nennen.*
