# UX-Spezifikation

Rolle: Level- & UX-Designer · Stand: 2026-10-12 (Sprint 0) · Status: **Grundspezifikation für das MVP; wird nach Owner-Freigabe im Vertical Slice verfeinert**

Evidenz: Alles in diesem Dokument ist Planung. Ohne Studio/Geräte-Emulator ist hier nichts am Gerät geprüft (`[SIMULIERT]`/`[ANNAHME]`). Plattform-Fakten stammen aus `docs/research_tech_facts_2026-10-12.md`, sonst sind sie als `[VORWISSEN, nicht aktuell]` markiert.

---

## Teil A – Plattformübergreifende Grundregeln (gelten für jedes Konzept)

### A1. Bildschirmzonen (Touch zuerst, Querformat)

```
┌──────────────────────────────────────────────────────────────┐
│ [Roblox-Topbar: Menü, Chat …]   (Sperrzone oben, GuiInset)   │
│  ┌─Status (oben links unter Topbar)─┐      ┌─Ziel/Hinweis──┐  │
│  │ Währung · Fortschritt           │      │ (oben Mitte/   │  │
│  └─────────────────────────────────┘      │  rechts)       │  │
│                                                              │
│                 SPIELWELT (Mitte frei halten)                │
│                                                              │
│  ┌──────────┐                                 ┌───────────┐  │
│  │ Joystick │  (Sperrzone unten links)        │ Aktion    │  │
│  │ (Roblox) │                                 │ [Sprung]  │  │
│  └──────────┘                                 └───────────┘  │
└──────────────────────────────────────────────────────────────┘
```

- **Sperrzonen:** Oben die Roblox-Topbar (über `GuiService:GetGuiInset()` bzw. `ScreenGui.ScreenInsets` respektieren; kein `IgnoreGuiInset` für interaktive Elemente). Unten links etwa das untere linke Viertel, wo der dynamische Thumbstick erscheint. Unten rechts der Sprungknopf. [VORWISSEN, nicht aktuell: genaue Maße – Verifikation in Studio-Emulator, Owner-Checkliste]
- **Eigene Aktionsknöpfe** stehen rechts **oberhalb bzw. links neben** dem Sprungknopf, im Bogen um ihn herum (Daumenreichweite), nie direkt darauf.
- **Safe Area:** `ScreenGui.ScreenInsets = DeviceSafeInsets` für alle HUD-Elemente (Notch/abgerundete Ecken).
- **Mitte frei:** Keine dauerhaften UI-Elemente im mittleren Drittel. Popups sind modal, klein und schließen sich per großem „X“ **und** Tippen außerhalb.

### A2. Touch-Ziele und Lesbarkeit
- Interaktive Elemente mindestens **48 × 48 dp-äquivalent**. Auf kleinen Telefonen: Höhe ≥ 9 % der Bildschirmhöhe für Hauptaktionen. Abstand zwischen Zielen ≥ 8 px. [ANNAHME, angelehnt an gängige Mobile-Richtlinien]
- Umsetzung über `UDim2`-Skalierung plus `UISizeConstraint` (Min-Größe) und `UIAspectRatioConstraint`. Text über `TextScaled` mit `UITextSizeConstraint` (Min. 14, Max. 36).
- **Kontrast:** Text vor Hintergrund ≥ 4,5 : 1. Wichtige Zahlen bekommen einen `UIStroke` als Kontur für Lesbarkeit vor der 3D-Welt.
- **Schrift:** eine gut lesbare Roblox-Standardschrift (z. B. Builder Sans / Gotham-Familie) [VORWISSEN, nicht aktuell]; keine verspielten Schriften für Zahlen.

### A3. Keine Information nur über Farbe
- Zustände (verfügbar/gesperrt/fertig) immer mit **Form/Icon + Farbe**, z. B. Schloss-Icon, Haken, Ausgrauen **plus** Muster/Rahmen.
- Teams, Seltenheiten oder Kategorien bekommen zusätzlich Symbol oder Text.
- Farbpalette ist auf Rot-Grün-Schwäche geprüft: kein Rot/Grün als einziges Unterscheidungsmerkmal; stattdessen Blau/Orange als Hauptkontrast. [ANNAHME: Prüfung mit Simulator-Tool beim Owner]

### A4. Eingabegeräte
| Aktion | Touch | Maus/Tastatur | Gamepad |
|---|---|---|---|
| Bewegen | Roblox-Thumbstick | WASD | linker Stick |
| Springen | Roblox-Sprungknopf | Leertaste | A / Kreuz |
| Hauptaktion | großer Knopf rechts | Linksklick / E | X / Viereck |
| Interagieren (in Reichweite) | ProximityPrompt antippen | E | Y / Dreieck (über ProximityPrompt-Standard) |
| Menü/Inventar | Icon oben links | Tab / I | Select / Touchpad |
| UI navigieren | Tippen | Maus | Steuerkreuz + A/B (`GuiService.SelectedObject`, `NextSelection*` gesetzt) |

- Eingaben laufen zentral über einen `InputController`. Hinweise auf dem Bildschirm zeigen immer das **aktuelle** Gerätesymbol (Wechsel über `UserInputService.LastInputTypeChanged` bzw. `PreferredInput`, falls verfügbar) [VORWISSEN, nicht aktuell].
- Jedes Menü ist vollständig per Gamepad bedienbar: Beim Öffnen wird der Fokus auf den ersten sinnvollen Knopf gesetzt, B/Kreis schließt.

### A5. Spielerführung visuell statt per Text
- Das Ziel ist das **hellste/gesättigtste** Objekt im Bild. Der Rest der Welt ist gedämpft (Primitive-Stil: matte, entsättigte Grundfarben, Ziele in Neon + `Highlight`).
- **Leitlinien:** Beam/Trail-Pfad zum nächsten Ziel während des Onboardings. Er blendet sich aus, sobald der Spieler den Schritt einmal geschafft hat.
- **Feedback auf jede Aktion** innerhalb von 100 ms: Ton, Partikelstoß, Zahl, die zum Zähler fliegt, leichtes Kamera-/UI-„Punch“. Auf Mobile zusätzlich Haptik (`HapticService`), wo unterstützt. [ANNAHME: Feedback-Dichte ist der wichtigste Spaßhebel ohne Art-Content]
- Text ist nur ergänzend: max. **5 Wörter** pro Hinweis, über Lokalisierungsschlüssel, nie die einzige Erklärung.

### A6. Lokalisierung
- Alle Texte werden über Schlüssel (`Shared/Localization/Keys.luau`) und eine `LocalizationTable` mit `en` (Quelle) und `de` angesprochen. Es gibt keine hart kodierten UI-Strings.
- Zahlen werden über einen Formatter dargestellt (1.2K / 1,2 Tsd.). Layout mit 30 % Längen-Puffer für Deutsch.

### A7. Accessibility-Checkliste (je Feature abzuhaken; Prüfung im Studio-Geräte-Emulator durch den Owner)
- [ ] Touch-Ziele ≥ Mindestgröße, nicht von Joystick/Sprungknopf/Topbar verdeckt (Telefon klein, Telefon groß, Tablet)
- [ ] Lesbar auf 5,5"-Telefon im Querformat; Kontrast ≥ 4,5 : 1
- [ ] Keine Information nur über Farbe
- [ ] Vollständig mit Gamepad bedienbar, sichtbarer Fokus
- [ ] Vollständig mit Maus/Tastatur bedienbar
- [ ] Spielerführung funktioniert ohne Lesen (Persona „Neuling 7–10“)
- [ ] Texte über Lokalisierung; Deutsch passt ins Layout
- [ ] Keine schnell blinkenden Effekte (> 3 Blitze/s), keine großflächigen Vollbild-Blitze
- [ ] Ton ist nicht nötig, um das Spiel zu verstehen (visuelles Gegenstück zu jedem Audio-Hinweis)

---

## Teil B – MVP-spezifisch

*Wird nach Abschluss der Konzeptwahl in diesem Sprint ergänzt (Map-Layout, Flows, Wireframes).*
