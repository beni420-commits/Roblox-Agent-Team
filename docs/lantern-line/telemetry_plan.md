# Telemetrie-Plan „Lantern Line“ (v0.1, 2026-10-13)

Rolle: Data Analyst. Grundlage sind die Roblox-`AnalyticsService`-Signaturen aus `docs/research_tech_facts_2026-10-12.md`. Einziger Aufrufer ist `src/server/Services/TelemetryService.luau`; die Namen stehen in `src/shared/Telemetry/Events.luau`. In Studio werden Events nur protokolliert.

## 1. Fragen, die die Daten beantworten sollen
1. Verstehen Erstspieler die Zeichen? Gemessen an Ausscheiden und Schaden je Ursache im ersten Lauf (H2 im GDD).
2. Wo brechen Läufe ab? Gemessen am Lauf-Funnel nach Wagen.
3. Kommen Spieler ins Spiel hinein? Gemessen am Onboarding-Funnel bis Wagen 10 (H1).
4. Ist das Finale lösbar? Gemessen am Verhältnis falscher zu richtigen Mustern und am Anteil gewonnener Läufe.

## 2. Events

| Typ | Name | Auslöser | Wert | Feld 03 |
|---|---|---|---|---|
| Onboarding | 1 Platform … 8 LineComplete | einmal je Spieler und Sitzung: Bahnsteig, eingestiegen, Tür 1, erstes Versteck, Wagen 10, Wagen 25, Wagen 50, gewonnen | – | – |
| Funnel „Run“ | Schritt 1–11 = Wagen 1, 5, 10 … 50; Schritt 12 = Ziel | Öffnen der Meilenstein-Tür bzw. Sieg; `funnelSessionId` = Lauf-Nummer des Servers | – | – |
| Custom | Death | Ausscheiden | Wagen | Ursache (6 Werte) |
| Custom | Damage | Schaden ohne Ausscheiden | Schaden | Ursache |
| Custom | Hide | Versteck betreten | Wagen | – |
| Custom | PatternWrong / PatternSolved | Entwerter | 1 | – |
| Custom | RunEnded | Lauf-Ende | erreichter Wagen | won / lost |
| Custom | RemoteRejected | beim Verlassen, Summe abgelehnter Remote-Aufrufe | Anzahl | – |

**Felder:**
- Feld 01: bevorzugte Eingabe (Touch, KeyboardAndMouse oder Gamepad).
- Feld 02: Build (`s1`).

**Kardinalität:** 8 Custom-Namen, 6 Ursachen, 2 Ergebnisse.

## 3. Nicht erhoben
- Keine personenbezogenen Daten, keine Chat-Inhalte, keine Namen.
- Keine Positionen und keine Aufzeichnung über die Lauf-Nummer hinaus.

## 4. Offene Punkte
- „SettingChanged“ ist im Katalog, wird aber noch nicht gesendet; dafür gibt es keinen Remote. Bei Bedarf in Sprint 2 ergänzen.
- Ob übersprungene Funnel-Schritte bei Läufen, die nach Wagen 5 enden, richtig dargestellt werden, ist erst mit Live-Daten prüfbar [ANNAHME].
