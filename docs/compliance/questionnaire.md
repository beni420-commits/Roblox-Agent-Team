# Maturity & Compliance Questionnaire – Antwortentwurf „Schwungturm“

Rolle: Compliance-Officer · Stand: 2026-10-12 (Sprint 1, Build `s1` = Zone 1) · Status: **Entwurf; der Owner reicht ihn im Creator Hub ein** (Auflage C-A1)

Quelle der Fragen: Original-Doku `creator-docs content/en-us/production/promotion/content-maturity.md` @af5f853 (2026-10-10), Abschnitt „Questionnaire categories“.
**Regel (C-A1):** Den Fragebogen vor jedem Zugang außerhalb des Edit-Teams einreichen, auch vor Playtests mit Dritten. Ändert ein Update eine Antwort, muss er neu eingereicht werden. Dieses Dokument ist versioniert; Änderungen gehen über `docs/decisions.md`.

| Kategorie | Frage (gekürzt) | Antwort für Build s1 | Begründung / Beleg im Spiel | Bei Änderung neu prüfen |
|---|---|---|---|---|
| Violence | Stellt das Spiel Gewalt dar? | **Nein** | Keine Waffen, kein Schaden, kein Charaktertod. Sturz und Reset-Knopf setzen ohne Tod an den Etagenanfang zurück (GDD §3.1, CR-17). | **Zone 3:** Trifft ein Blitz sichtbar den Avatar, ist das Gewalt (mindestens Mild). Deshalb schlagen Blitze nur in Plattformen ein; der Rückstoß ist ein Windstoß. |
| Blood | Wird Blut dargestellt? | **Nein** | Keine Blut- oder Verletzungsdarstellung. | – |
| Fear | Gibt es Schreckelemente? | **Nein** | Helle Wiese, keine Jumpscares, keine Kreaturen, keine bedrohliche Musik. Es gibt keine Musik (D-024). | **Zone 3 „Gewitter“:** Die Antwort folgt dem tatsächlichen Inhalt. Im Zweifel **Mild / Occasional** angeben, denn laut Original zählen schon Spannung und bedrohliche Musik als Mild, und Falschangaben werden moderiert. |
| Crude humor | Derber Humor? | **Nein** | Keine Texte, keine Witze, keine Körperfunktionen. | – |
| Unplayable gambling content | Nicht spielbare Glücksspielinhalte? | **Nein** | Kein Zufall gegen Währung, keine Casino-Optik. | – |
| Strong language | Starke Sprache erlaubt/dargestellt? | **Nein** | Keine eigenen Texte. Der Chat ist der Roblox-Standard mit Roblox-Filter. Die Spiel-Einstellung **„Allow strong language“ bleibt aus**. | – |
| Romantic themes | Romantik, private Räume, Bars/Clubs? | **Nein** | Kletterturm im Freien, keine Räume. | – |
| Alcohol | Alkohol? | **Nein** | – | – |
| Social hangout | Ist Abhängen das Hauptthema? Private Räume? | **Nein / Nein** | Kern ist Klettern. Keine Sitzecken, keine Aufenthaltsbereiche. C-A29: keine Hangout-Begriffe in Titel, Beschreibung, Tags. | Social-Funktionen aus Sprint 2 (Marker, Lift, Signale): bleibt „Nein“ laut Compliance-Nachtrag v0.2 |
| Free-form user creation | Freies Erstellen (Zeichnen/Schreiben) für andere? | **Nein** | Kein Freitext, keine Zeichenflächen (C-A2). | – |
| Sensitive issues | Sensibles Thema als Hauptthema? | **Nein** | – | – |
| Paid random items | Bezahlte Zufallsitems? | **Nein** | Keine Monetarisierung im MVP (D-005, C-A8). | Jede Monetarisierung → Compliance-Prüfung |
| Paid item trading | Handel mit bezahlten Items? | **Nein** | Kein Handel (GDD §9 Won't). | – |
| Media | Teilen von Medien, Feeds, fremde Captures? | **Nein / Nein / Nein** | – | – |
| AI interaction | Interaktion mit generativer KI? | **Nein** | Kein KI-Feature im Spiel. (Die Entwicklung mit KI-Agenten ist keine Spiel-Interaktion.) | – |

**Erwartetes Ergebnis:** Label **Minimal**, damit Kids- und Select-Konten erreichbar (Compliance CM-06, KS-04) `[ANNAHME: Roblox vergibt das Label selbst auf Basis der Antworten]`.

**Offen für den Owner (Auflagen T-1 bis T-4 aus `reports/compliance_check_sprint1.md`):**
1. **T-1:** Fragebogen im Creator Hub ausfüllen (Configure → Questionnaire) und eintragen:
   - vergebenes Label: `__________` (Datum: `________`)
   - **regionales Compliance-Ergebnis** aus der Fragebogen-Vorschau: `__________`
2. **T-2:** Das Owner-Konto ist altersgeprüft und mindestens 2 Tage alt. Zugang nur über **Audience → Limited → Playtesters**, nicht Public.
3. **T-3:** Kinder testen nur auf dem Owner-Gerät oder als Trusted Friends des Owners; unter 13 nur mit Zustimmung der Eltern.
4. **T-4:** Keine Hangout-Begriffe in Titel und Beschreibung des Test-Place.
5. Vor Zone 2/3 (Sprint 2) wird der Fragebogen neu geprüft (Fear, Violence).
