# Owner-Bericht Sprint 0 (2026-10-12)

**Kurzfassung:** Wir empfehlen Konzept A „Schwungturm“ (EN „Momentum Tower“): einen prozeduralen Kletterturm aus Bausteinen mit freischaltbaren Bewegungs-Fähigkeiten. Es ist das Konzept, das wir mit unseren Mitteln am besten bauen und testen können. Es hat das geringste Compliance-Risiko (Label Minimal). **Wir stoppen hier und warten auf deine Freigabe** (Masterprompt §11, Schritt 6).

## 1. Sprintziel erreicht?
**Ziel:** ein freigabefähiges MVP-Konzept vorlegen. → **Ja.** Alle Sprint-0-Artefakte aus §11 liegen vor, die Toolchain ist `[GETESTET]`. **Einschränkung:** Das Gate „Spielspaß“ ist nur simuliert und noch nicht bestanden (siehe 3).

## 2. Wichtigste Ergebnisse
- **Fähigkeiten** [GETESTET]:
  - Websuche ja, direkter Seitenabruf nein. `*.roblox.com` ist gesperrt, kein Studio, keine Live-Daten.
  - Die offizielle Roblox-Doku lesen wir im Original über das Git-Repo `Roblox/creator-docs` (D-017).
- **Toolchain** [GETESTET]: Rojo 7.7.1, StyLua 2.6.0, Selene 0.31.0, luau-lsp 1.70.1 mit Roblox-Typen und Luau-CLI. `scripts/check.sh` ist grün, die 3 Logik-Tests bestehen. Die Gegenproben (absichtlicher Fehler) schlagen wie erwartet fehl.
- **Research** [QUELLE, nur Suchzusammenfassungen; Spielerzahlen meist Tracker-Güte C]: 3 Konzepte, Bewertung gewichtet: A 16/20, B 13/20, C 13/20. Der Algorithmus belohnt 2025/26 Retention und gemeinsames Spielen.
- **Compliance** (Regeln aus creator-docs im Original gelesen): Alle drei Konzepte sind „Freigabe mit Auflagen“. A hat das geringste Risiko: Auflagen C-A1–C-A18 und C-A29–C-A32.
- **Persona-Playtest** [SIMULIERT]: 8 schwere Designfehler gefunden, u. a. zu weite Rücksetzung beim Fallen, Sprünge im Tagesturm unlösbar, Kopfstoß beim Doppelsprung. Alle sind in **GDD v0.2** behoben (GDD §13).
- **Design:** GDD v0.2 mit 8 Hypothesen, Telemetrie-Plan, UX-Spezifikation, Tech Notes (Architektur, Datenschema v1, Remotes, Budgets) und ICE-Backlog.

## 3. Gate-Status

| Gate | Status | Evidenz |
|---|---|---|
| Spielspaß | **nicht bestanden** (offen) | [SIMULIERT]; die 8 „hoch“-Befunde sind nur im Design behoben. Nötig ist ein Test mit dir bzw. echten Spielern. |
| Stabilität | nicht anwendbar (kein Spielbuild) | Bootstrap baut und ist typgeprüft [GETESTET] |
| Sicherheit | nicht anwendbar | Design: Remote-Schema, Rate-Limits, Bewegungsprüfung |
| Daten | nicht anwendbar | Schema v1 und Session-Lock-Design; Datenverlust-Suite folgt in Sprint 2 |
| Performance | nicht anwendbar | Budgets festgelegt (Tech Notes §5) |
| Compliance | **Freigabe mit Auflagen** (Konzept-Vorprüfung) | Regelquellen mit Datum, teils im Original |

## 4. Offene Freigaben

```
FREIGABE ERBETEN: Konzept A „Schwungturm“ als MVP, GDD v0.2 als Grundlage für Sprint 1
WARUM: §11 Schritt 6 – ohne Konzeptwahl kein Vertical Slice
ERWARTETE WIRKUNG: spielbare Zone 1 nach Sprint 1; Onboarding-Ziel ≥ 80 % erreichen Etage 1 in ≤ 60 s (H1) [ANNAHME]
RISIKEN: Obby-Genre hat starke Konkurrenz (2/5); das Bewegungsgefühl ist nur in Studio bzw. auf dem Handy prüfbar
RÜCKFALLOPTION: Plan B „Formwächter“ (research_report §5), wenn dein Test nach Sprint 1 zeigt, dass Bewegung auf Mobile frustriert
EMPFEHLUNG: ja
```
```
FREIGABE ERBETEN: Compliance-Auflagen C-A1–C-A18, C-A29–C-A32 als verbindlich (§8 Punkt 6)
WARUM: Compliance hat „Freigabe mit Auflagen“ erteilt
ERWARTETE WIRKUNG: Label Minimal, erreichbar für Kids- und Select-Konten
RISIKEN: einzelne Hausregeln sind strenger als Roblox (z. B. keine Einladungsbelohnung), das kann etwas Reichweite kosten
RÜCKFALLOPTION: Einzelne Hausregeln lassen sich später per Owner-Entscheidung lockern
EMPFEHLUNG: ja
```
```
FREIGABE ERBETEN: Asset-Regel (§8 Punkt 5): Kat. 0 (Engine-Inhalte) frei; Kat. 1 (Roblox-eigene Store-Sounds) als Sammelfreigabe
WARUM: Ohne Ton halbiert sich das Feedback, unser wichtigster Spaßhebel
ERWARTETE WIRKUNG: besseres Spielgefühl [ANNAHME]; jede Asset-ID wird in docs/assets.md eingetragen
RISIKEN: Lizenzierte Musik darf nur auf Roblox genutzt werden (nicht in YouTube-Trailern)
RÜCKFALLOPTION: Sounds entfernen bzw. nur Kat. 0 nutzen
EMPFEHLUNG: ja (Kat. 0 + Kat. 1); Kat. 2–4 nur einzeln
```
```
FREIGABE ERBETEN (spätestens vor öffentlichem Release, nicht für Sprint 1): Veröffentlichungskosten
WARUM: Ohne 1.000 R$ Gebühr pro Spiel (rückerstattbar) bzw. 2 Monate Plus/Premium erreicht das Spiel nur altersgeprüfte Spieler ab 16, nicht unsere Zielgruppe 9–14. Das kollidiert mit Budget 0 (D-006).
ERWARTETE WIRKUNG: Freischaltung für alle Altersgruppen nach der 16+-Evaluation
RISIKEN: Evaluation verlangt 250 Spielstarts in 60 Tagen durch altersgeprüfte 16+-Spieler, die in den letzten 60 Tagen auf Roblox gekauft haben; für ein Kinderspiel schwer
RÜCKFALLOPTION: Die Gebühr ist laut Doku rückerstattbar; ohne Zahlung bleibt das Spiel bei 16+
EMPFEHLUNG: mit Auflage – bis Sprint 3 entscheiden; vorher einen Launch-Plan für die 16+-Phase erstellen
```

**Weitere Fragen an dich** (keine Freigaben):
1. Welches Konto oder welche Gruppe veröffentlicht (Altersprüfung/ID, 2FA)?
2. Kannst du pro Sprint einen Studio-Test und einen Test auf einem echten (möglichst schwachen) Android-Handy machen? Checkliste: Tech Notes §7.
3. Bitte vor jedem Test mit Dritten den Maturity-Fragebogen ausfüllen (C-A1).
4. Markenrecherche zum Titel (C-A11).
5. Keine Benachrichtigungen im MVP: einverstanden (C-A7)?

## 5. Größte Risiken und was nicht geprüft werden konnte
1. **Launch-Hürde 16+** (siehe 4): Das ist das größte strategische Risiko für ein Spiel für 9- bis 14-Jährige.
2. **Kein Studio:** Bewegungsgefühl, Kamera, Touch-Layout, Performance und echtes DataStore-Verhalten sind **ungeprüft**. Spielspaß ist nur `[SIMULIERT]`.
3. **Marktzahlen** stammen aus Suchzusammenfassungen und widersprechen sich teils. Für Deutschland gibt es keine Roblox-Zahlen.
4. **Nicht im Original gelesen:** Community Standards, Nutzungsbedingungen (ToS), Advertising Standards (B-006).
5. **Umfang:** Durch den Playtest ist der Must-Umfang gewachsen. Realistisch braucht das MVP 3 Sprints statt 2–3, und die erste Turmbesteigung dauert im Modell ≈ 24 statt 15–20 min. Der Hebel ist die Pfadlänge; kalibriert wird nach deinem Test.

## 6. Vorschlag Sprint 1 (Vertical Slice)
- **Primärziel:** Zone 1 (Etagen 1–10) ist in Studio spielbar. Generator und Erreichbarkeitsprüfer sind `[GETESTET]` (200 Seeds), dazu Etagen-Rücksetzpunkt, Lager, Funken, Onboarding ohne Text und Mobile-Steuerung.
- **Erfolgskriterium:** `check.sh` grün. Dein Studio- und Handy-Test zeigt: Etage 1 in ≤ 60 s erreicht, Zone 1 ohne Frust-Stelle „hoch“.
- **Nebenziele:** (1) Remote-Sicherheitsschicht mit Exploit-Tests, (2) CI-Workflow, (3) Entwurf der Fragebogen-Antworten.
