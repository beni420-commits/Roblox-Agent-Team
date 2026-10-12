# Telemetrie-Plan – „Schwungturm“

Rolle: Data Analyst · Stand: 2026-10-12 (Sprint 0) · **Version 0.2** (an GDD v0.2 angepasst) · Status: **Entwurf zur Owner-Freigabe**; wird mit dem Vertical Slice umgesetzt.

API-Fakten aus `docs/research_tech_facts_2026-10-12.md` (§3), dort im Original gelesen (creator-docs @af5f853), sowie `creator-docs production/experiments.md` und `configs.md` (gelesen 2026-10-12).

---

## 1. Grundsätze

1. **Jedes Event hat einen Zweck:** eine Hypothese (GDD §10), eine Kernkennzahl (§2) oder ein Gate-/Gesundheitswert (QA/Performance). Events ohne Zweck werden nicht gebaut.
2. **Nur serverseitig.** AnalyticsService-Events gehen nur vom Server und nur aus veröffentlichten Games. Client-Wissen (z. B. erster Sprung) kommt per validiertem Remote (`ReportOnboardingStep`, `ReportAbilityUsed`) zum Server.
3. **Ein Wrapper:** Nur `TelemetryService` (Server) ruft AnalyticsService auf. In Studio und Tests schreibt ein Log-Stub stattdessen in die Ausgabe bzw. in eine Liste, die Tests prüfen.
4. **Budget:** Das Limit liegt bei 120 + 20 × CCU Requests pro Minute (spielweit). Deshalb werden häufige Dinge **aggregiert** (pro Etage, pro Session) statt pro Aktion gesendet. Ziel: ≤ 6 Events pro Spieler und Minute im Mittel. [ANNAHME: konservativ gegenüber dem Limit]
5. **Katalog klein halten:** höchstens 100 Custom-Event-Namen erlaubt, geplant sind **≤ 20**. Dimensionen kommen in die 3 Custom Fields.
6. **Datenschutz:** keine personenbezogenen Daten in Events (keine Namen, keine Texte). Die Zuordnung macht Roblox über das `player`-Argument. Es fließen keine Daten an Dritte (kein HttpService). [Compliance DS-03]

### Custom Fields (fest belegt, max. 3)
| Key | Inhalt | Werte (Kardinalität) |
|---|---|---|
| `CustomField01` | Eingabe/Plattform aus `UserInputService.PreferredInput` (vom Client gemeldet, validiert) | `Touch`, `KeyboardAndMouse`, `Gamepad` (3) |
| `CustomField02` | Build-Version (`BuildInfo`) | z. B. `s1.3` (wenige) |
| `CustomField03` | Kontext je Event (Etage, Fähigkeit, Remote-Name …) | je Event ≤ 40 |

Kombinationen bleiben weit unter der „Other“-Schwelle von 8 000.

## 2. Kernkennzahlen (KPIs)

| KPI | Definition | Quelle | Ziel vor Release (Indikator) | Ziel live (erste 4 Wochen) [ANNAHME] |
|---|---|---|---|---|
| Onboarding-Abschluss | Anteil neuer Spieler mit Funnel-Schritt 5 (Etage 1) | Onboarding-Funnel | Owner-Test: Etage 1 in ≤ 60 s | ≥ 80 % (H1) |
| Zone-1-Abschluss | Anteil neuer Spieler mit Etage 10 | Progression | – | ≥ 40 % |
| Gipfelquote | Anteil neuer Spieler mit Gipfel in der 1. Woche | Custom `SummitReached` | – | ≥ 15 % |
| D1 / D7 / D30 | Roblox-Retention-Dashboard (Kohorte nach Erstbesuch) | Roblox Analytics | – | D1 ≥ 20 %, D7 ≥ 6 % |
| Sessiondauer | Median Sessiondauer | Roblox Engagement + Custom `SessionEnded` | Owner-Test ≥ 12 min | Median ≥ 10 min |
| Funken-Fluss | Quellen und Senken je Spieler, Guthaben-Verteilung | Economy-Events | Simulation laut GDD §6.2 | Median-Guthaben bei Erreichen von Etage 30 im **ersten** Lauf, gemessen **vor** Gipfel-Bonus und vor Käufen am Gipfel: 100–200 |
| Frust-Hotspots | Fehlversuche und Abbrüche je Etage | `FloorSummary`, `SessionEnded` | – | keine Etage mit Abbruchrate > 2× Median |
| Stabilität | Daten-Lade-/Speicherfehler, Remote-Ablehnungen, Plausibilitäts-Flags | Custom-Gesundheitsevents | 0 im Owner-Test | Ladefehler < 0,1 % der Joins |
| Performance | Client-FPS-Median je Plattform, Server-Heartbeat | Custom `ClientPerf`, `ServerHealth` | Gate §5 am Owner-Gerät | FPS-Median Touch ≥ 30 |

Roblox-Performance-Charts gibt es erst ab ≥ 100 DAU. Deshalb messen wir Performance zusätzlich mit eigenen Events.

## 3. Event-Katalog

### 3.1 Onboarding-Funnel – `AnalyticsService:LogOnboardingFunnelStepEvent(player, step, stepName, customFields?)`
Einmaliger Funnel, keine Session-ID nötig; Schritte beginnen bei 1. Wiederholungen zählen nicht, kosten aber Budget. Deshalb merkt sich der Server erledigte Schritte in `onboarding.stepsDone` und sendet jeden Schritt nur einmal.

| Step | `stepName` | Erkannt durch | Hypothese |
|---|---|---|---|
| 1 | `Spawned` | Server: erster Charakter-Spawn eines neuen Spielers | H1 |
| 2 | `FirstMove` | Server: Charakter > 4 Studs vom Spawn entfernt | H1 |
| 3 | `FirstSpark` | Server: erstes validiertes `CollectSpark` | H1 |
| 4 | `FirstJump` | Client → `ReportOnboardingStep(4)` (validiert) | H1 |
| 5 | `Floor1` | Server: Etage 1 erreicht; `CustomField03` = Sekunden seit Spawn (gebündelt: `≤30`, `31-60`, `61-120`, `>120`) | **H1** |
| 6 | `FirstCamp` | Server: Lager Etage 5 | Funnel |
| 7 | `FirstUpgrade` | Server: erster Upgrade-Kauf | H4 (indirekt) |
| 8 | `Zone1Done` | Server: Etage 10 + Doppelsprung freigeschaltet | H3 |

### 3.2 Progression – `LogProgressionStartEvent` / `LogProgressionCompleteEvent` (player, progressionPathName, level, levelName, customFields?)
| Pfad | Level | Wann | Felder |
|---|---|---|---|
| `MainTower` | 0 | Start eines Laufs (`ProgressionStart`) | F03 = Lauf-Nr. gebündelt (`1`, `2`, `3-5`, `6+`) |
| `MainTower` | 1–30 | Etage erstmals im Lauf erreicht (`ProgressionComplete`), `levelName` = `F01`…`F30` | F03 = Zone |
| `DailyTower` *(Should)* | 0–10 | wie oben | F03 = `dayId mod 7` (Wochentag) |

### 3.3 Economy – `LogEconomyEvent(player, flowType, currencyType, amount, endingBalance, transactionType, itemSku, customFields?)`
- Eine einzige Währung: `currencyType = "Sparks"` (zulässig sind bis zu 5).
- **Quellen** (`flowType = Source`), aggregiert pro Etage bzw. Bonus:
  - `transactionType = Gameplay`, `itemSku`: `floor_sparks`, `route_sparks`, `camp_bonus`, `summit_bonus`, `coop_bonus` *(Could)*
- **Senken** (`flowType = Sink`), pro Kauf:
  - `transactionType = Shop`, `itemSku`: `up_jump_1..3`, `up_speed_1..3`, `up_dash_1..2`, `ab_glide`, `ab_walljump` (≤ 12 SKUs)
- `transactionType` nutzt `Enum.AnalyticsEconomyTransactionType.<X>.Name`. `Gameplay` und `Shop` existieren (ebenso `ContextualPurchase`, `IAP`, `Onboarding`, `TimedReward`) [QUELLE: Roblox-Typdefinitionen `globalTypes.d.luau`, luau-lsp @6f90396 (Typen-Dump 2026-10-10), gelesen 2026-10-12].

### 3.4 Custom Events – `LogCustomEvent(player, eventName, value, customFields?)`
| Event | `value` | F03 | Wann | Zweck |
|---|---|---|---|---|
| `FloorSummary` | Fehlversuche (Rücksetzungen an den Etagenanfang) auf der Etage | Etage `F01`…`F30` | beim Verlassen nach oben | Frust-Hotspots, H2 |
| `HelpShown` | 1 | `trail_Fxx` / `helper_Fxx` | Hilfe eingeblendet | H2 |
| `SummitReached` | Laufzeit in s | Lauf-Nr.-Bündel | Gipfel | Gipfelquote, H4 |
| `RunStarted` | Lauf-Nr. | `after_summit` / `manual` | neuer Lauf | H4 |
| `AbilityUnlocked` | 1 | Fähigkeit | Freischaltung | H3 |
| `AbilityResult` | Erfolgsquote in % (0–100), **vom Server bestimmt** (Landung auf der Zielplattform laut Positionsproben) | `<ability>` | Session-Ende, je benutzter Fähigkeit | H6 (mit F01 = Eingabe) |
| `SessionEnded` | Sessiondauer in s | letzte Etage gebündelt (`F00-05` …) + Freundesstatus (`_f` = mit Freund im Server) | `PlayerRemoving` | Sessiondauer, Abbruchpunkte, H2/H7/H8 |
| `CampLiftUsed` | 1 | `down` / `up` / `friend` | Lager-Lift genutzt | Social-Nutzung (S5) |
| `SignalSent` | Anzahl in der Session | Signal-Art | Session-Ende, nur wenn > 0 | Social-Nutzung, Missbrauchs-Monitoring (C-A30) |
| `SettingChanged` | 1 | `<key>_<on/off>` | Option geändert | Akzeptanz der Hilfe |
| `ClientPerf` | FPS-Median der Session (Clientwert, auf 0–240 gekappt, als clientgemeldet markiert) | Qualitätsstufe gebündelt | Session-Ende | Performance-Gate |
| `ServerHealth` | Heartbeat-Mittel (Hz) der letzten 5 min | `players_<n>` gebündelt | alle 5 min (über den ersten Spieler im Server) | Performance-Gate |
| `RemoteRejected` | Anzahl Ablehnungen in der Session | Remote-Name | Session-Ende, nur wenn > 0 | Sicherheit/Exploit-Monitoring |
| `MovementFlagged` | 1 | Verstoßart (`speed`, `height`, `skip`) | erster Verstoß im Lauf | Cheat-Monitoring, Fehlalarm-Quote |
| `DataError` | 1 | `load_fail`, `save_fail`, `lock_conflict`, `throttled_server`, `throttled_experience` | bei Fehler | Daten-Gate |
| `DailyTowerStarted` *(Should)* | 1 | – | Tagesturm-Start | H5 |
| `MomentumPeak` *(Should)* | max. Schwung-Stufe im Lauf | – | Lauf-Ende | H7 |

Gesamt: 17 Custom-Event-Namen (≤ 20 geplant).

## 4. Hypothesen → Messung → Entscheidungsregel

A/B-Tests laufen über **Roblox Experiments**: In-Game-Experiment über einen Config-Key, abgefragt mit `ConfigService:GetConfigForPlayerAsync(player)` (nur Server). Möglich sind 1 Kontrolle und höchstens 2 Varianten, Laufzeit 14–60 Tage. Roblox zeigt die minimal erkennbare Effektgröße (MDE) vorab an. Weil die Zuordnung pro Session ausgewertet wird, speichern wir die Variante beim ersten Kontakt im Datensatz, damit ein Spieler in derselben Gruppe bleibt. [QUELLE: creator-docs production/experiments.md, configs.md]

| ID | Messgröße | Mindeststichprobe / Laufzeit | Entscheidungsregel |
|---|---|---|---|
| H1 | Anteil `Floor1` mit F03 ∈ {`≤30`, `31-60`} unter allen `Spawned` | ≥ 500 neue Spieler **und** ≥ 14 Tage | bestätigt, wenn die untere Grenze des 95-%-Konfidenzintervalls ≥ 80 % liegt; widerlegt, wenn die obere Grenze < 80 % liegt; sonst unklar |
| H2 | Abbruchrate auf Etagen mit ≥ 3 Fehlversuchen (Session endet auf dieser Etage); Experiment Hilfe nach 3 vs. nach 6 Fehlversuchen | Experiment, ≥ 400 Spieler je Variante, ≥ 14 Tage | bestätigt bei signifikanter Senkung (α = 0,05) **und** relativ ≥ 30 % |
| H3 | Anteil Etage 15 unter Spielern mit Etage 10 | ≥ 300 Spieler mit Etage 10 | bestätigt bei unterer KI-Grenze ≥ 70 % |
| H4 | Anteil `RunStarted` (Lauf 2) in derselben Session unter `SummitReached` (Lauf 1) | ≥ 200 Gipfel-Erreicher, ≥ 21 Tage | bestätigt bei unterer KI-Grenze ≥ 35 % |
| H5 | D1 der Gipfel-Erreicher, Experiment (Tagesturm an/aus) | ≥ 300 je Gruppe, ≥ 21 Tage | bestätigt bei signifikanter Steigerung ≥ 5 Prozentpunkte |
| H6 | `AbilityResult` (Dash) Touch vs. Maus/Tastatur | ≥ 200 Spieler je Eingabeart, ≥ 14 Tage | bestätigt, wenn die Differenz ≤ 10 Prozentpunkte ist (Obergrenze des 95-%-KI) |
| H7 | Median `SessionEnded`, Experiment (Schwung an/aus) | ≥ 400 je Variante, ≥ 14 Tage | bestätigt bei signifikanter Steigerung ≥ 10 % |
| H8 | Median `SessionEnded` mit Freund vs. ohne (beobachtend, kein Kausalurteil) | ≥ 150 Spieler mit Freund, ≥ 21 Tage | „Indikator positiv“, wenn das 95-%-KI des Verhältnisses über 1,2 liegt; sonst „unklar“ |

**Regeln:**
- Unter der Mindeststichprobe gibt es **kein Urteil**; die Hypothese bleibt „unklar (zu wenig Daten)“.
- Wird eine Hypothese zweimal widerlegt, wird sie verworfen (Masterprompt §6).
- Pro Experiment ändert sich nur eine Variable.
- Während eines Experiments keine Content-Änderungen, außer Bugfixes.

## 5. Umsetzung und Qualitätssicherung der Telemetrie

- `TelemetryService` bekommt eine Event-Konstantentabelle (`Shared/Telemetry/Events.luau`). Nur Namen aus dieser Tabelle sind erlaubt; ein Test prüft Tabelle und Budget-Grenzen.
- Ein Logik-Test simuliert einen 20-minütigen Lauf mit dem Stub und prüft: Event-Anzahl ≤ 6 pro Minute, Funnel-Schritte einmalig und in Reihenfolge, Economy-Endbilanz = Datensatz-Guthaben.
- Nach der Veröffentlichung prüft QA die Instrumentierung über „View Events“ (nahezu Echtzeit). Die Charts kommen erst nach ~24 h.
- Erste D7-Aussagen sind frühestens 8 Tage nach Launch möglich (Kohortenlogik).

## 6. Grenzen

- Vor dem Release gibt es **keine** `[GEMESSEN]`-Daten. Alle Zielwerte in §2 sind `[ANNAHME]` und werden nach 4 Wochen live kalibriert.
- Die Launch-Phase ist laut Compliance zunächst nur für altersgeprüfte Spieler ab 16 sichtbar (Publishing Requirements). Daten aus dieser Phase repräsentieren die Zielgruppe 9–14 **nicht**. Hypothesen-Urteile zur Zielgruppe deshalb erst nach Freischaltung für alle Altersgruppen. Phase-1-Daten werden getrennt markiert (`CustomField02` = Build mit Präfix `p16`).
