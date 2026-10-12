# UX-Spezifikation

Rolle: Level- & UX-Designer · Stand: 2026-10-12 (Sprint 0) · **Version 0.2** (nach Persona-Playtest) · Status: **Grundspezifikation für das MVP; wird nach Owner-Freigabe im Vertical Slice verfeinert**

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

- **Sperrzonen:** Oben die Roblox-Topbar. Ihre Höhe wird nie hart codiert (Doku-Beispiel 58 px, früher 36 px), sondern dynamisch über `GuiService.TopbarInset` bzw. `ScreenInsets` gelesen. Kein `IgnoreGuiInset` für interaktive Elemente. Unten links ist die Zone des Thumbsticks, unten rechts der Sprungknopf [QUELLE: creator-docs GuiService.yaml, ui/position-and-size.md].
- **Eigene Aktionsknöpfe** stehen rechts **oberhalb bzw. links neben** dem Sprungknopf, im Bogen um ihn herum (Daumenreichweite), nie direkt darauf. Ihre Position wird **zur Laufzeit relativ zum JumpButton** berechnet (`AbsolutePosition`/`AbsoluteSize`), wie Roblox es empfiehlt. Weil die PlayerScripts auf das Input Action System umgestellt wurden, ist der Pfad `PlayerGui.TouchGui.TouchControlFrame.JumpButton` nicht gesichert: deshalb `FindFirstChild` mit Fallback-Position (rechts unten, 20 px Abstand) [QUELLE: creator-docs ui/position-and-size.md; IAS-Umstellung via DevForum, Websuche-Zusammenfassung].
- **Safe Area:** `ScreenGui.ScreenInsets = CoreUISafeInsets` (Default, frei von Topbar und Notch) für alle interaktiven Elemente. `TopbarSafeInsets` nur für kleine Anzeigen in der Topbar-Zeile, `None` nur für Hintergründe [QUELLE: creator-docs includes/ui/screen-insets.md].
- **Mitte frei:** Keine dauerhaften UI-Elemente im mittleren Drittel. Popups sind modal, klein und schließen sich per großem „X“ **und** Tippen außerhalb.

### A2. Touch-Ziele und Lesbarkeit
- Interaktive Elemente mindestens **44 × 44 px** (Hausregel; Roblox dokumentiert keine Mindestgröße, branchenüblich sind 44 pt bzw. 48 dp), abgesichert per `UISizeConstraint`. Hauptaktionen auf kleinen Telefonen ≥ 9 % der Bildschirmhöhe. Abstand zwischen Zielen ≥ 8 px. [ANNAHME]
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

- Eingaben laufen zentral über einen `InputController` auf Basis des **Input Action System** (`InputAction`/`InputBinding`, voll veröffentlicht). Hinweise auf dem Bildschirm zeigen immer das **aktuelle** Gerätesymbol. Umgeschaltet wird nur über `UserInputService.PreferredInput` (`Touch`/`KeyboardAndMouse`/`Gamepad`, Änderung per `GetPropertyChangedSignal`), nicht über `TouchEnabled` [QUELLE: creator-docs input/index.md, UserInputService.yaml].
- Jedes Menü ist vollständig per Gamepad bedienbar: Beim Öffnen wird der Fokus auf den ersten sinnvollen Knopf gesetzt, B/Kreis schließt.

### A5. Spielerführung visuell statt per Text
- Das Ziel ist das **hellste/gesättigtste** Objekt im Bild. Der Rest der Welt ist gedämpft (Primitive-Stil: matte, entsättigte Grundfarben). **Neon nur für Ziele**, Deko in SmoothPlastic.
- **Reservierte Führungssprache:** **goldene Chevron-Pfeile am Boden**, nur für Führung (Onboarding, Rejoin) und Hilfe. Gold kommt sonst nirgends vor. Spuren anderer Spieler sind dünn, kurz (≤ 1 s), nie gold und abschaltbar (P-09).
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

## Teil B – MVP-spezifisch: „Schwungturm“

### B1. Map-Layout (ein Ort: der Turm, Helix)

```
            ★ Gipfel (Etage 30) + persistentes Gipfel-Leuchtfeuer (Lichtsäule, nie ausgestreamt)
            │
   Zone 3 „Gewitter“  Etage 21–30  (Violett/Orange, dunkler Himmel, Takt-Licht ≤ 1 Hz)
            ├── Lager E25 (Funkenschrein, Lager-Lift)
            ├── Lager E20 → Dash-Freischaltung + Übungsstrecke (Dash, dann Sprung + Dash)
   Zone 2 „Wolken“    Etage 11–20  (Weiß/Hellblau, dunkle Unterseiten/Konturen, Nebel erst ab ~120 Studs)
            ├── Lager E15
            ├── Lager E10 → Doppelsprung-Freischaltung + Übungsstrecke
   Zone 1 „Wiese“     Etage 1–10   (Grün/Gelb, Tageslicht)
            ├── Lager E5 (erster Funkenschrein)
            └── Etage 0: Turmfuß, „Neuer Lauf“-Tor (nach dem 1. Gipfel)
   Spawn-Plaza ~40 Studs neben dem Turm, freie Sichtachse zum Gipfel-Leuchtfeuer
```

- **Turmform (Helix):** Jede Etage liegt im nächsten 90°-Sektor um eine zentrale, leuchtende Säule. Erst nach 4 Etagen ist der Luftraum wieder überbaut, das gibt Kopffreiheit und Kamerafreiheit (P-04).
- **Sichtachse:** Das Gipfel-Leuchtfeuer ist vom Spawn aus sichtbar, unabhängig vom Streaming (Ziel ohne Text, S1). Jede Zone hat eine eigene Farbe.
- **Fallschutz:** Unter jeder Etage liegt eine unsichtbare Auffangzone. Wer unter die Etagenbasis − 4 Studs fällt, steht nach ≤ 1,5 s mit „Plopp“ und kurzer Partikelwolke **am Anfang derselben Etage**. Das zählt als 1 Fehlversuch. Kein Charaktertod, keine Gewalt-Darstellung.
- **Lager:** breite, sichere Plattform mit Funkenschrein (pulsierender Kristall aus Neon-Parts, ProximityPrompt), **Lager-Lift** (Plattform mit Pfeilsymbolen, zweiter ProximityPrompt), Lagerfeuer-Licht und Etagennummer als Zahlen-Icon (keine Freitexte).

### B1a. Kamera
- Eigene Verfolgerkamera: feste Neigung ~35°, Abstand 14–22 Studs, Zoom-Untergrenze. Verdeckende Teile (Säule, Etagen darüber) werden per `LocalTransparencyModifier` ausgeblendet statt heranzuzoomen. Feinabstimmung im Owner-Gerätetest (Sprint 1).
- Fremde Avatare im Umkreis von 6 Studs werden einheitlich halbtransparent (alle Teile gleich, inkl. Layered Clothing) oder als neutrale Geist-Silhouette dargestellt, damit sie keine Kanten verdecken. Das Erscheinungsbild prüft der Owner in Studio (C-A32).

### B2. HUD (Querformat, Touch)

```
┌──────────────────────────────────────────────────────────────────┐
│ [Roblox-Topbar]                                                  │
│ ✦ 128  (Funken)          ▲ 12/30 ███████░░░░░░  (Etagen-Leiste)  │
│                                                         ┌──┐     │
│                                                         │⚙│ Opt. │
│                                                         └──┘     │
│                                                                  │
│                     (Spielwelt, Mitte frei)                      │
│                                                                  │
│                                                   ┌─────┐        │
│                                                   │ ➤➤  │ Dash   │
│  (Thumbstick)                                     └─────┘ ┌────┐ │
│                                                           │Jump│ │
└──────────────────────────────────────────────────────────────────┘
```

| Element | Position | Größe | Verhalten |
|---|---|---|---|
| Funken-Zähler | oben links unter der Topbar | Höhe ≈ 6 % | +n fliegt von der Welt in den Zähler; Zahl „poppt“ |
| Etagen-Leiste | oben Mitte | Breite ≈ 35 % | Fortschritt 0–30 mit Zonen-Farben; Lager als Kerben |
| Optionen | oben rechts unter der Topbar | ≥ 44 px | öffnet Optionen (Hilfe an/aus, Spuren anderer an/aus, Signale: alle / nur Freunde / aus, Musik, Effekte; die Sprache folgt Roblox) |
| Dash-Knopf | im Daumenbogen links-oberhalb des Sprungknopfs, 80 % seiner Größe | ≥ 44 px | sichtbar erst nach Freischaltung; Abklingzeit als Kreis-Füllung **und** Ziffer (nicht nur Farbe) |
| „2×“-Hinweis | am Sprungknopf | – | pulsiert in der Luft, solange ein Doppelsprung möglich ist |
| Signal-Knopf | über dem Dash-Knopf (klein) | ≥ 44 px | öffnet einen Fächer mit 3 Symbolen: Winken, Daumen hoch, „Hier!“ (Ping auf den anvisierten Ort) |
| Freundes-Marker | in der Welt über Freunden | – | farbiger Ring + Icon **ohne Namenstext**, durch Wände sichtbar; Pfeil am Bildschirmrand, wenn außerhalb (C-A32) |
| Gleiter | kein eigener Knopf: Sprung halten | – | Gleiter-Symbol am Sprungknopf, wenn verfügbar |
| Hilfe-Hinweis | über der Plattform in der Welt (BillboardGui) | – | Leuchtspur + Pfeil, keine Textpflicht |

Maus/Tastatur: Dash = `Shift`/`Q`, Optionen = `Esc`-unabhängig über Icon bzw. `O`. Gamepad: Dash = `X`, Optionen = `Select`. Die Knopf-Hinweise wechseln mit `PreferredInput`.

### B3. Funkenschrein (Upgrade-Menü)

```
┌──────────────── Funkenschrein ────────────────┐   ✦ 128
│  ┌─────────┐  ┌─────────┐  ┌─────────┐        │
│  │  ⤒      │  │  ≫      │  │  ⟳      │        │
│  │ Sprung  │  │ Tempo   │  │ Dash    │        │
│  │ ●●○     │  │ ●○○     │  │ 🔒      │        │
│  │ ✦ 120   │  │ ✦ 70    │  │ (E20)   │        │
│  └─────────┘  └─────────┘  └─────────┘        │
│   Gleiter: ✦ 96/150 ▓▓▓▓▓▓░░░░                │
│             [ ✦ Tauschen ]   [ ✕ ]            │
└───────────────────────────────────────────────┘
```

- Öffnen: ProximityPrompt am Schrein (Touch: Prompt antippen; Tastatur `E`; Gamepad `Y`). Modal, mittig, max. 60 % Bildbreite; die Spielwelt läuft weiter (Lager ist sicher).
- Der Knopf heißt **„Tauschen“** mit ✦-Symbol (Schlüssel `shrine.trade`), nicht „Kaufen“, um keine Echtgeld-Assoziation zu wecken (P-19).
- Der Schrein pulsiert nur für das **empfohlene nächste Ziel**. Für den Gleiter gibt es eine Spar-Leiste (P-12).
- Eine **Messlatte** neben dem Schrein zeigt mit einem Geist-Sprung „vorher/nachher“, was ein Sprung-Upgrade bewirkt.
- Karten zeigen Symbol, Stufe als **gefüllte Punkte**, Preis. Ist ein Upgrade nicht leistbar, zeigt die Karte **Schloss-/Grau-Muster plus fehlende Funken als Zahl**, nicht nur eine andere Farbe.
- Kauf: Karte wählen → „Kaufen“ → Server bestätigt → Effekt (Partikel + Ton) und Zähler sinkt. Doppeltipp-Schutz: Der Knopf ist bis zur Server-Antwort gesperrt.
- **Kein** Robux-Bezug, keine Rabatt-Optik, keine Countdown-Elemente (Compliance HR-MON).
- Gamepad: Start-Fokus auf der ersten leistbaren Karte; `B` schließt.

### B4. Interaktionsflüsse

**Erster Start (≤ 60 s, siehe GDD §7):** Spawn → Kamera-Schwenk zum Gipfel (2 s, überspringbar durch jede Eingabe) → Leuchtpfad zur Treppe → Funken auf dem Pfad → Etage 1 mit Tor-Effekt.

**Fehlsprung:** Fall in die Auffangzone → Bildschirm-Vignette 0,3 s → „Plopp“ **am Anfang derselben Etage** → die Chevrons zur nächsten Plattform blinken einmal auf. Nach **3** Fehlversuchen auf derselben Etage erscheinen goldene Führungs-Chevrons (Geist-Pfad). Nach **6** erscheinen Hilfsstufen mit Funkel-Effekt, nur lokal für diesen Spieler.

**Fähigkeit freigeschaltet (E10/E20):** Lager wird zur „Bühne“: Lichtsäule, Symbol der Fähigkeit schwebt zum Spieler, Knopf erscheint mit Puls-Animation. Ein **Geist-Avatar** führt die Fähigkeit einmal vor (beim DJ mit sichtbarem „2×“-Puls). Direkt danach kommt eine **Übungsstrecke**, die genau die Kombination verlangt, die die nächste Zone braucht. Beim Dash ist sie zweistufig: erst Dash allein, dann Sprung + Dash. Es gibt unbegrenzt viele Versuche mit sofortigem Respawn, nach 3 Fehlversuchen eine erneute Vorführung und nach 6 eine Hilfsplattform. **Nie eine Sackgasse.** Eine absolvierte Übung wird gespeichert.

**Gipfel:** Leuchtfeuer entzündet sich, Konfetti aus Parts, Laufzeit als große Zahl, erspielte Leuchtspur wird angelegt. Optionen danach: „Neuer Lauf“ (Tor) oder frei herumklettern.

**Rejoin:** Der Spieler erscheint am letzten erreichten Lager des laufenden Laufs (`run.campFloor`). Die Chevrons leuchten 3 s lang zur nächsten Plattform. Bereits gesammelte Funken bleiben verschwunden (keine Doppelvergabe). Die Kamerafahrt gibt es nur beim allerersten Join.

**Lager-Lift / Freund helfen:** Am Lager den Lift-Prompt wählen → Liste der **selbst erreichten** Lager als große Zahlen-Kacheln; Lager mit einem Freund tragen dessen Marker-Icon → antippen → „Plopp“-Teleport. Nach oben geht es nie über das eigene höchste Lager hinaus.

**Signale:** Signal-Knopf → Fächer mit 3 Symbolen → antippen. Beim „Hier!“-Ping erscheint 3 s lang ein Marker am anvisierten **Ort** (nie an einem Avatar). Freunde sehen ihn überall, Nicht-Freunde nur in ±1 Etage. Unsichtbar für Spieler, die den Absender stummgeschaltet oder blockiert haben oder „nur Freunde“ gewählt haben. Höchstens 1 Signal pro 2 s (C-A30).

### B5. Feedback-Katalog (Spaß ohne Art-Content)

| Ereignis | Visuell | Audio [Owner-Freigabe für Sounds offen] | Haptik (Mobile) |
|---|---|---|---|
| Landung | kleiner Staubring aus Parts (nur eigene) | dumpfer Tap | – |
| Funke | Partikelstoß + Zahl fliegt zum Zähler | heller „Pling“ mit steigender Tonhöhe in Serie | leicht |
| Etage geschafft | Tor-Bogen leuchtet, Leiste springt | kurzer Akkord | – |
| Lager | Lagerfeuer flammt auf, Kamera-Punch | Fanfare kurz | mittel |
| Fehlsprung | Vignette, „Plopp“-Wolke | weiches „Plopp“ (kein Schmerz-/Todeston) | – |
| Upgrade gekauft | Lichtring um den Spieler | „Power-up“-Klang | mittel |

Keine Effekte mit > 3 Blitzen pro Sekunde. Die Takt-Plattformen in Zone 3 pulsieren ≤ 1 Hz.
**Fremd-Effekte** (andere Spieler) sind gedrosselt (≤ 1/s je Spieler) und auf Low-End-Geräten reduziert. Lager-Feiern gibt es nur beim **ersten** Erreichen pro Lauf, nicht bei jedem Respawn. Erreichen mehrere Spieler ein Lager innerhalb von 20 s, gibt es eine **gemeinsame Feier** (größerer Lichtring).

### B6. Offene UX-Punkte (Owner-Gerätetest Sprint 1)
1. Kamera-Parameter (Neigung, Abstand, Ausblenden) auf dem kleinsten Android-Gerät feinjustieren (B1a).
2. Ist der Dash-Knopf im Daumenbogen auf kleinen Telefonen ohne Fehlgriffe erreichbar (H6)?
3. Erkennbarkeit der nächsten Plattform in Zone 2 (dunkle Konturen) auf schwachen Displays.
4. Touch-Hilfe „Dash am Boden = Hüpfer + Dash“: hilft sie oder verwirrt sie?
5. AutoJump: Zone 1 an, ab Zone 2 aus. Fühlt sich das konsistent an?
