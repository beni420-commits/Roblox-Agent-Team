# Assets – Herkunft und Lizenzen

Jedes externe Asset (Modell, Mesh, Textur, Audio, Schrift, Bibliothek, Code) wird hier **vor** der Verwendung eingetragen.
Externe Assets/Bibliotheken mit Lizenz- oder Kostenfolgen brauchen Owner-Freigabe (Masterprompt §8, Punkt 5).

| ID | Asset / Bibliothek | Typ | Quelle | Lizenz | Verwendet in | Owner-Freigabe | Status |
|---|---|---|---|---|---|---|---|
| – | (noch keine externen Assets im Spiel) | – | – | – | – | – | – |

## Entwicklungswerkzeuge (nicht Teil des Spiels, werden nicht ausgeliefert)

| Werkzeug | Version | Quelle | Lizenz [ANNAHME, nicht im Original geprüft] | Zweck |
|---|---|---|---|---|
| Rojo | 7.7.1 | crates.io (`cargo install rojo`) | MPL-2.0 | Dateisystem ↔ Roblox-Place |
| Selene | 0.31.0 | crates.io (`cargo install selene`) | MPL-2.0 | Linter |
| StyLua | 2.6.0 | crates.io (`cargo install stylua`) | MPL-2.0 | Formatter |
| luau-lsp | 1.70.1 (Commit 6f90396, Typen-Dump 2026-10-10) | github.com/JohnnyMorganz/luau-lsp (aus Quellcode gebaut) | MIT | Typprüfung mit Roblox-Typen |
| Luau CLI (`luau`, `luau-analyze`) | Submodul-Commit 8387cfb (2026-10-09) | github.com/Roblox/luau (aus Quellcode gebaut) | MIT | Ausführung von Logik-Tests |

## Asset-Kategorien (Vorschlag Compliance, **Owner-Freigabe offen**)

| Kat. | Was | Owner-Freigabe |
|---|---|---|
| 0 | Engine-Bestandteile (`rbxasset://`, ohne Store-ID): Parts, Materialien, Standard-Partikeltextur, Lighting-Effekte, Standard-Charaktersounds, Systemschriften | nein (hier sammelnd aufgeführt) |
| 1 | Roblox-eigene Store-Assets (Uploader „Roblox“, inkl. lizenzierter SFX/Musik) | einmalige Sammelfreigabe; jede ID einzeln eintragen; nie außerhalb von Roblox nutzen |
| 2 | Creator-Store-Assets Dritter | Einzelfreigabe; Modelle nur ohne Skripte |
| 3 | Eigene Uploads (Audio, Bilder) | Einzelfreigabe; Upload durch den Owner |
| 4 | Bibliotheken/Code Dritter | Einzelfreigabe; Lizenz prüfen, Version pinnen |

Details: `reports/compliance_check_sprint0.md` §2.

### Engine-Inhalte (Kategorie 0), die das MVP nutzt
Parts (Block, Kugel, Zylinder, Keil), Materialien Neon/Glass/SmoothPlastic/ForceField, Lighting/Atmosphere/Bloom/ColorCorrection, Beam/Trail/ParticleEmitter mit Standardtextur, Highlight, Roblox-Systemschriften.

## Vorgeschlagene, noch NICHT freigegebene Bibliotheken

| Bibliothek | Version | Lizenz | Zweck | Status |
|---|---|---|---|---|
| ProfileStore (MadStudioRoblox) | 1.0.3 | Apache-2.0 (LICENSE gelesen) | Alternative zu eigenem PlayerDataService | **nicht** empfohlen für Sprint 2 (hier nicht testbar); Freigabe nur falls Owner es wünscht |
| Jest-Lua (jsdotlua) | 3.10.0 | MIT (laut Tech-Recherche) | Tests innerhalb von Roblox (mit B-004) | Freigabe erst zusammen mit B-004 |

Freigabeanfragen: `reports/owner_report_sprint0.md`.
