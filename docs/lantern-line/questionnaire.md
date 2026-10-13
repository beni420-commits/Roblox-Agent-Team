# Maturity & Compliance Questionnaire – Antwortentwurf „Lantern Line – Der Nachtzug“

Rolle: Compliance-Officer · Stand: 2026-10-13 (Build `s1`, Commit `3dc2613`, „Linie 1“ = Wagen 0–50) · Status: **Entwurf; der Owner reicht ihn im Creator Hub ein** (Auflagen H-A8, T-1)

- **Quelle der Fragen:** Original-Doku `creator-docs content/en-us/production/promotion/content-maturity.md` @af5f853 (2026-10-10), Abschnitt „Questionnaire categories“, abgerufen 2026-10-13.
- **Prüfbericht dazu:** `reports/lantern-line/compliance_check_sprint1_ll.md`.

**Regeln:**
- Jedes Spiel (Universe) hat einen **eigenen** Fragebogen. Lantern Line bekommt ein eigenes Universe; der Fragebogen von Schwungturm (`docs/compliance/questionnaire.md`) gilt hier nicht.
- Vor jedem Zugang außerhalb des Edit-Teams einreichen, auch vor Playtests mit Dritten (C-A1, T-1).
- Grundlage ist der **intensivste** Inhalt, dem Spieler begegnen können („base your answers on the most mature or extreme content“).
- Ändert ein Update eine Antwort, muss der Fragebogen neu eingereicht werden. Änderungen an diesem Dokument laufen über `docs/decisions.md`.

| Kategorie | Frage (gekürzt) | Antwort für Build s1 | Begründung / Beleg im Spiel | Bei Änderung neu prüfen |
|---|---|---|---|---|
| Violence | Stellt das Spiel Gewalt dar? | **Ja** | Wesen fügen Schaden zu (35/40/50) oder lassen Figuren ausscheiden (GDD §6). Gewalt ist laut Original „physical or psychological force against players“. Auch Licht ohne Körper zählt | – |
| ↳ Intensität | Wie intensiv? | **Mild** | Unrealistische Folge: Die Figur wird verankert, verblasst in 0,6 s und wird entfernt. Kein Ragdoll, keine Verletzung, keine Leiche (`PlayerService.luau:148,156-177`; D-036). Laut Original Mild: „bodies disappearing the moment their health reaches zero“ | **Moderate**, sobald eine einzige realistische Todesfolge vorkommt (Ragdoll mit Verletzung, Körperteile, Zerquetschen) |
| ↳ Häufigkeit | Wie oft? | **Repeated** | Begegnungen gibt es alle paar Wagen, im Lauf ca. 3 Express, 1–2 Gegenzüge, Augen, Kontrolleur, Lawine und Schaffner. „Even a small part … repeated“ | – |
| Blood | Wird Blut dargestellt? | **Nein** | Kein Blut, auch kein unrealistisches; Schaden nur als kurzes Abdunkeln ohne Rot (`Hud.luau:373-376`) | Jede Spritzer- oder Fleck-Optik |
| Fear | Gibt es Schreckelemente? | **Ja** | Horror-Spiel: dunkle Wagen, Lichtwesen, Verfolgung, Wächter im Finale | – |
| ↳ Intensität | Welche Stufe? | **Mild** | „creepy-looking NPCs, jump scares, … gameplay that builds suspense“. Keine Gesichter, Münder, Organe, Wunden oder blutenden Augen (Moderate-Liste). Todesbild ≤ 1 s. Derzeit keine Sounds | **Moderate** bei entstellten Mündern mit realistischem Blut, sichtbaren Organen oder Wunden. Bei Sounds (Schreie, Herzschlag, Atmen) bleibt es Mild, die Begründung wird ergänzt |
| ↳ Häufigkeit | Wie oft? | **Repeated** | Schreckmomente im ganzen Lauf | – |
| Crude humor | Derber Humor? | **Nein** | Keine Körperfunktionen, keine Witze | – |
| Unplayable gambling content | Nicht spielbare Glücksspielinhalte? | **Nein** | Kein Casino, keine Karten- oder Würfelspiele. Zufall nur im Wagenplan, ohne Einsatz | – |
| Strong language | Starke Sprache dargestellt/erlaubt? | **Nein** | Feste, geprüfte Texte (`GameStrings.csv`, 59 Schlüssel, Blockliste). Nur Roblox-Standard-Chat. **Die Spieleinstellung „Allow strong language“ bleibt aus** | – |
| Romantic themes | Romantik, überwiegend private Räume, Bars/Clubs? | **Nein** | Keine Romantik. Schlafwagen machen höchstens 25 % je Lauf aus (Test `TrainGenerator.spec.luau:239`); die Abteile sind offen, ohne Türen. Keine WC- oder Waschräume. Verstecke sind Schränke für eine Person, aber nicht der Schauplatz. **Keine Bar:** Teesalon mit Samowar (H-A6). Der Titel enthält keine Romantik | Mehr als 25 % Schlafwagen; ein Wagen mit Bar, Club oder Bad; Romantik in Titel oder Text |
| Alcohol | Alkohol dargestellt/erwähnt? | **Nein** | Keine Flaschen, Gläser oder Zapfhähne, keine Texte dazu (Wortliste in `scripts/lantern_line_checks.py`). Im Speisewagen nur Küche und Tresen ohne Getränke | Jede Darstellung → nur 18+ |
| Social hangout | Ist Abhängen das Hauptthema? Private Räume? | **Nein / Nein** | Kern ist Überleben in Wagen 0–50. Am Bahnsteig gibt es keine Sitzplätze und keine Bühne. In Titel und Beschreibung keine Hangout-Begriffe (C-A29, T-4) | Neue Treffpunkte, Emote-Bühnen |
| Free-form user creation | Freies Zeichnen/Schreiben für andere? | **Nein** | Keine Texteingabe (`TextBox` ist ausgeschlossen). Das 3×3-Lochmuster am Entwerter ist **lokal**: Nur der Server erhält die Maske 0–511, andere Spieler sehen das Raster nicht (`ValidatorController.luau`; `Net/Definitions.luau:23`). Der Notizzettel zeigt nur feste Rätselinhalte | Wird ein Raster oder eine Fläche für andere sichtbar markierbar, gilt die Antwort „Ja“ (16+) |
| Sensitive issues | Sensibles Thema als Hauptthema? | **Nein** | Fiktiver Nachtzug, keine realen Unglücke oder Marken (H-A14) | – |
| Paid random items | Bezahlte Zufallsitems? | **Nein** | Keine Käufe (kein `MarketplaceService`; H-A13, V3) | Jede Monetarisierung → Compliance-Prüfung |
| Paid item trading | Handel mit bezahlten Items? | **Nein** | Kein Handel, kein Inventar über Läufe hinweg | – |
| Media | Teilen von Medien, Feeds, fremde Captures? | **Nein / Nein / Nein** | Zuschauen bei Mitreisenden ist eine Live-Kamera im selben Server, kein Teilen von Medien. Keine `VideoFrame`, keine Feeds | – |
| AI interaction | Interaktion mit generativer KI? | **Nein** | Kein KI-Feature im Spiel. Die Entwicklung mit KI-Agenten zählt nicht | – |

**Erwartetes Ergebnis:** Label **Mild** mit den Deskriptoren Violence und Fear `[ANNAHME: Roblox vergibt Label und Bezeichnungen selbst auf Basis der Antworten]`.
- **Zielgruppen:** Roblox Kids (5–8), Roblox Select (9–15) und 16+ sind zulässig [QUELLE: `production/publishing/kids-and-select.md` @af5f853]. Ob Kids gewollt ist, entscheidet der Owner (Compliance §9.1).
- **Minimal ist ausgeschlossen:** wegen Fear und wiederholter Gewalt („Minimal: occasional mild violence“).

**Grenzen, die das Label Mild halten:**
- Figuren verblassen und kippen nicht um.
- Kein Blut, keine Gesichter oder Münder an Wesen.
- Todesbild höchstens 1 s.
- Keine Bar und kein Alkohol.
- Schlafwagen höchstens 25 %.
- Kein Freitext und kein für andere sichtbares Zeichnen.

**Offen für den Owner** (Auflagen T-1 bis T-5, `reports/compliance_check_sprint1.md` §7 und `reports/lantern-line/compliance_check_sprint1_ll.md` §7):
1. **T-1:** Fragebogen im Creator Hub ausfüllen (Configure → Questionnaire) und eintragen:
   - vergebenes Label: `__________` (Datum: `________`)
   - Deskriptoren: `__________`
   - **regionales Compliance-Ergebnis** aus der Fragebogen-Vorschau: `__________`
2. **T-2:** Das Owner-Konto ist altersgeprüft und mindestens 2 Tage alt. Zugang nur über **Audience → Limited → Playtesters**, nicht Public. Servergröße auf 4 setzen.
3. **T-3:** Kinder testen nur auf dem Owner-Gerät oder als Trusted Friends; unter 13 nur mit Zustimmung der Eltern.
4. **T-4:** Keine Hangout-Begriffe in Titel und Beschreibung. „Allow strong language“ bleibt aus.
5. **T-5:**
   - Eltern vorab auf Grusel-Inhalt hinweisen; Sanften Modus und „Flackern reduzieren“ erklären.
   - Niemand mit bekannter Fotosensibilität testet.
   - Bis zur Kids-Entscheidung testen nur Kinder ab 9 Jahren.
6. **Vor dem Zugang Dritter** muss Auflage H-A16 umgesetzt sein (Lichteffekte ≤ 2 Wechsel pro Sekunde, Einstellungen wirken überall).
7. **Neu prüfen** bei: Sounds (D-030), neuen Wesen oder Linien (Wagen 51–100), Speicherstand, Monetarisierung, geänderter Todesdarstellung.
