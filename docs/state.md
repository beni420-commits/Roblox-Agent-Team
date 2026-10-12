# Projektstand (state.md)

> Jede Rolle liest diese Datei zu Beginn jeder Sitzung zuerst. Max. 1 Seite.

**Datum:** 2026-10-12 · **Sprint:** 0 (Research & Konzept) · **Status:** in Arbeit – Recherche läuft

## Sprint-0-Ziel
**Primärziel:** Ein vom Owner freigabefähiges MVP-Konzept vorlegen (Research → Compliance-Vorprüfung → GDD → Telemetrie/UX → Tech-Grundlage → Owner-Bericht).
**Erfolgskriterium:** Owner-Bericht mit Empfehlung liegt vor; alle Sprint-0-Artefakte nach §11 existieren; Toolchain-Nachweis `[GETESTET]`.
**Nebenziele:** (1) Toolchain lauffähig, (2) Projektgerüst baut mit Rojo, (3) Regelgrundlage für Compliance mit Quellen.
**Umfang:** Kein Spielcode vor der Owner-Freigabe (D-016).

## Fähigkeitsinventar (§0.2) – geprüft am 2026-10-12

| Fähigkeit | Verfügbar? | Details / Konsequenz |
|---|---|---|
| Webzugriff | **teilweise** | Websuche (Titel, URLs, Zusammenfassungen) ja. Direkter Seitenabruf **nein** (DNS-Fehler für alle Domains). `*.roblox.com` ist per Egress-Policy gesperrt. → Research und Regeln nur aus Suchzusammenfassungen (D-010). |
| Dateisystem / Git | ja | Repo `beni420-commits/Roblox-Agent-Team`, Branch `claude/roblox-studio-masterprompt-v2-feuzkm` |
| Roblox Studio | **nein** | Engine-Tests (Physik, UI, DataStore-Realverhalten, Performance) muss der Owner machen → Owner-Studio-Checkliste in `tech_notes.md` §7 |
| Luau-Ausführung | im Aufbau | Luau-CLI wird aus dem Quellcode gebaut (Lune abgebrochen). Open Cloud Luau Execution: `apis.roblox.com` gesperrt, kein API-Key → nicht verfügbar |
| Lint / Format | ja | Selene 0.31.0 (Std `roblox_lite`, D-011), StyLua 2.6.0 – [GETESTET] |
| Typprüfung | im Aufbau | luau-lsp 1.70.1 wird aus dem Quellcode gebaut; Roblox-Typen vom 2026-10-10 geladen |
| Build | ja | Rojo 7.7.1 – `rojo build` [GETESTET] |
| Creator-Analytics / Live-Daten | **nein** | Kein Live-Spiel, kein Zugang. Vor dem Release gibt es keine `[GEMESSEN]`-Evidenz. |

## Artefakte Sprint 0
| Artefakt | Rolle | Status |
|---|---|---|
| `docs/research_report.md` | Market Researcher | in Arbeit |
| `reports/compliance_rules_digest_2026-10-12.md` | Compliance | in Arbeit |
| `reports/compliance_check_sprint0.md` (Konzept-Vorprüfung) | Compliance | offen |
| `docs/game_design_doc.md` | Game Designer | offen |
| `docs/telemetry_plan.md` | Data Analyst | offen |
| `docs/ux_spec.md` | UX-Designer | Teil A fertig, Teil B offen |
| `docs/tech_notes.md` | Systems Engineer | Teil 1–5, 7, 8 fertig; §6 (Schema v1) offen |
| `reports/owner_report_sprint0.md` | Orchestrator | offen |

## Offene Freigaben an den Owner
Noch keine. Sie folgen gesammelt im Owner-Bericht.

## Nächster Schritt
Recherche-Ergebnisse einarbeiten → Compliance-Vorprüfung der drei Konzepte → GDD.
