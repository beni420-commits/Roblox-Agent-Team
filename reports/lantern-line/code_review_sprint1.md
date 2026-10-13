# Code-Review Sprint 1 – „Lantern Line – Der Nachtzug“ (Roblox-Schicht)

- **Rolle:** QA-Engineer, unabhängiges statisches Review
- **Datum:** 2026-10-13
- **Geprüfter Stand:** Commit `dd5abc5` (HEAD). Während des Reviews kamen `3dc2613` und `dd5abc5` hinzu. Alle Befunde sind gegen `dd5abc5` abgeglichen; was diese Commits schon behoben haben, steht in §3.
  - Die Arbeitskopie enthält zusätzlich **unkommittierte** Änderungen aus der Playtest-Simulation (`GameConfig`, `CarriageCatalog`, `Fairness`, `RunController`, `TrainBuilder`, CSV). Sie sind nicht Teil dieses Reviews. Wo sie einen Befund berühren, steht ein Hinweis.
- **Pfade:** relativ zu `games/lantern-line/src/`. Zeilennummern beziehen sich auf `dd5abc5`.
- **Doku-Belege:** `docs:` = `/home/user/roblox/creator-docs/content/en-us/`.

## Methode
- `server/**` und `client/**` vollständig gelesen, dazu alle von dort genutzten `shared/**`-Module, `default.project.json` und `sourcemap.json`.
- Engine-Verhalten mit der lokalen Roblox-Doku belegt. Was dort nicht steht, ist als **Verdacht, in Studio prüfen** markiert.
- Eigene Messungen mit dem Luau-CLI auf einer Kopie von `shared/` (Skripte nur im Scratchpad, nicht im Repo):
  - Laufzeit des Generators
  - Bauteile je Wagen
  - Express-Fairness hinter Wagen k−1
  - Versatz der Versteck-Attachments
  - Überlagerung der Flackerpläne
- Logik-Tests: `luau games/lantern-line/tests/run.luau` → **74/74 grün**.
- Nichts wurde in der Engine ausgeführt.

## 1. Ergebnis

| Schweregrad | Anzahl | Befunde |
|---|---|---|
| **Blocker** | 1 | LL-01 |
| **Kritisch** | 1 | LL-02 |
| **Mittel** | 10 | LL-03 bis LL-12 |
| **Gering** | 12 | LL-13 bis LL-24 |

**Die 5 wichtigsten Befunde**
1. **LL-01 (Blocker):** Die Versteck-Prompts sitzen ab Wagen 1 zwischen 46 und über 1800 Studs neben dem Schrank. Verstecken ist dort unmöglich, der erste Express (ab Wagen 5) trifft alle.
2. **LL-02 (Kritisch):** Im Versteck schaut die Kamera 0,25 Studs vor die massive Schranktür. Man sieht nur Holz, keine „Sicht durch die Schlitze“.
3. **LL-05 (Mittel):** Es gibt keinen Handler für einen Roblox-Tod oder eine verlorene Figur. Der Spieler zählt weiter als lebend, der Lauf endet nie, die Figur kippt steif um (H-A8).
4. **LL-04 (Mittel):** Kontrolleur: Das HUD zeigt in der Achtungsphase „Gehen“, und 0,35 s Gnadenzeit decken Reaktion und Latenz nicht ab. Wer auf die Streifenkelle reagiert, bekommt Schaden.
5. **LL-03 (Mittel):** Die Express-Bahn reicht bis Wagen k−3, die Garantie gilt nur für k−1 und k. Gemessen: In 13 % der Fälle ist Wagen k−3 unfair.

---

## 2. Befunde

### LL-01 · Blocker · Versteck-Prompts sitzen weit neben dem Versteck
- **Ort:** `server/TrainBuilder.luau:378-380` (`buildSpot`). Die Folge reicht bis `server/Services/RunController.luau:912-918`, denn `withinReach` misst gegen dieselbe falsche Position.
  ```lua
  local attachment = Instance.new("Attachment")
  attachment.WorldPosition = world(c, spot.x, 3, spot.z) + facing * (depth / 2 + 0.2)
  attachment.Parent = body
  ```
- **Engine-Verhalten:**
  - Ohne Vorfahr vom Typ PVInstance gilt `CFrame == WorldCFrame` (`docs:reference/engine/classes/Attachment.yaml:18-20`).
  - Das Setzen von `WorldPosition` rechnet in den lokalen Raum des *aktuellen* Parents um (`Attachment.yaml:310-313`).
  - Der Parent ist beim Setzen noch `nil`. Deshalb wird die Weltkoordinate als lokaler Versatz gespeichert.
  - Nach `Parent = body` gilt: Weltposition = `body.CFrame * Weltkoordinate`, also etwa doppelt so weit vom Ursprung entfernt.
- **Messung** (Plan-Seed 42, Versteck 1):

  | Wagen | Abstand zum Soll |
  |---|---|
  | 0 | 6,7 Studs (außerhalb der Seitenwand, Höhe 6,8) |
  | 1 | 46 Studs |
  | 10 | 611 Studs |
  | 30 | 1807 Studs |

- **In Studio würde passieren:**
  - Ab Wagen 1 erscheint an keinem Schrank „Verstecken“.
  - Wegen `RequiresLineOfSight = false` (`TrainBuilder.luau:105`) tauchen fremde Prompts an falschen Orten auf. Beispiel: Versteck 2 aus Wagen 0 liegt an der Außenwand von Wagen 1. Wer ihn auslöst, landet im Schrank eines älteren Wagens.
  - Der Express trifft jeden nicht Versteckten (`RunController.luau:650-656`). Damit endet praktisch jeder Lauf beim ersten Express.
  - Die Owner-Testpunkte B5 und C1 schlagen fehl.
- **Fix:**
  - Erst `attachment.Parent = body`, dann `WorldPosition` setzen. Alternativ `attachment.Position = body.CFrame:PointToObjectSpace(target)`.
  - Beim Bau prüfen: `assert((attachment.WorldPosition - target).Magnitude < 0.01)`. Die CLI-Tests decken diese Schicht nicht ab.
  - Die übrigen Attachments (Behälter, Fragmente, Entwerter, Kupplung) setzen keine Position und sind korrekt.

### LL-02 · Kritisch · Im Versteck sieht man nur die Innenseite der Tür
- **Ort:**
  - `server/TrainBuilder.luau:340-346`: Augpunkt `depth/2 − 0,25` vor der Versteckmitte, Blick nach außen
  - `TrainBuilder.luau:365-377`: Türblatt „Door“ bei `depth/2 … depth/2 + 0,1`, undurchsichtig; „Slit“-Teile außen auf der Tür
  - `client/Controllers/HidingController.luau:49-50`: Kamera `Scriptable` auf diesen Augpunkt
- **Geometrie:**
  - Das Türblatt (2,2 × 6,9 Studs) steht 0,25 Studs vor der Kamera und füllt den ganzen Sichtkegel.
  - Die „Sehschlitze“ sind zusätzliche dunkle Bauteile, keine Öffnungen.
  - Die UI-Abdeckung (`HidingController.luau:80-88`) lässt zwei Streifen frei. Durch sie schaut man auf das Holz der Tür.
- **In Studio würde passieren** (nach dem Fix von LL-01):
  - Beim Verstecken zeigt der Bildschirm eine dunkle Holzfläche. Express, Lampen und Schaffner sind nicht zu sehen.
  - Das widerspricht GDD §7 („Sicht durch die Schlitze“) und Owner-Test B5.
  - Im Postwagen kann man nicht beurteilen, wann der Schaffner weg ist; nach 20 s schiebt die Kälte hinaus.
- **Sicherheit:** hoch, denn es ist reine Geometrie. Dass Roblox die Innenflächen des Body-Teils, in dem die Kamera steckt, nicht zeichnet, ist Vorwissen. **In Studio bestätigen.**
- **Fix:**
  - Während `HiddenIn > 0` setzt der Client für „Door“ und „Slit“ des eigenen Verstecks `LocalTransparencyModifier = 1` und stellt ihn beim Verlassen zurück. Andere Spieler sehen weiter die geschlossene Tür; die Schlitz-Optik liefert die UI-Abdeckung.
  - Alternative: Augpunkt vor die Tür legen und das Türblatt aus zwei Teilen mit echter Lücke bauen.
  - Danach prüfen, ob die Express-Kugel im Versteck ausblendet (`client/Controllers/EntityController.luau:122-133`, Grenze 12 Studs).

### LL-03 · Mittel · Express-Garantie gilt nur für k−1/k, die Bahn reicht bis k−3
- **Ort:**
  - `shared/Logic/Sweep.luau:32`: `x0 = prev.originX − 140`
  - `shared/Logic/Fairness.luau:141-155`: prüft nur `{prev, cur}`
  - `RunController.luau:650-656`: trifft alle lebenden Teilnehmer mit x in [x0, x1]
- **Messung** (150 Pläne, 478 Express-Ereignisse; Kriterium wie im Prüfer: Weg/16 + 1,5 s ≤ Ankunft, Zellen vor x0 ausgenommen):
  - Wagen k−2 liegt **immer** im Fahrbereich. In 5 Fällen gibt es dort Punkte ohne rechtzeitig erreichbares Versteck.
  - Wagen k−3 liegt immer teilweise im Fahrbereich. In **64 Fällen (13 %)** ist er nicht fair.
- **In Studio würde passieren:** Zu zweit plündert einer zwei bis drei Wagen hinter dem Türöffner. Der Express erwischt ihn ohne realistische Chance, obwohl die Warnung kam.
- Die Ein-Personen-Regel je Versteck schwächt die Garantie in der Gruppe zusätzlich (Playtest LP-02).
- **Fix:**
  - Entweder die Bahn verkürzen: Start an der Rückwand von k−2.
  - Oder `checkExpress` über alle angekoppelten Wagen (k−4 … k) mit derselben Frist rechnen lassen.
  - In beiden Fällen einen Test ergänzen: „jede Zelle mit x ≥ x0 erreicht ein Versteck in Frist“.
  - *Hinweis:* Die Arbeitskopie ergänzt `groupSpotsInTime`, aber nur für k−1/k.

### LL-04 · Mittel · Kontrolleur: HUD sagt „Gehen“ in der Achtungsphase, die Gnadenzeit ist zu kurz
- **Ort:**
  - `client/Controllers/Hud.luau:121-150`: Phase „warn“ fällt in den Zweig `hud.walk` (Z. 149)
  - `shared/Logic/Inspector.luau:93-96`
  - `shared/Config/GameConfig.luau:79-80`: Gnadenzeit 0,35 s, Fenster 0,3 s
  - `shared/Logic/MotionTracker.luau:30-47`
- **Ablauf:**
  - Die Haltphase beginnt auf dem Server bei S. Die erste Messung erfolgt bei S + 0,35 über die serverseitig gesehenen Positionen im Fenster [S + 0,05; S + 0,35].
  - Wer erst auf die Streifenkelle reagiert, ist aus Server-Sicht bis S + Downlink + Reaktionszeit + Uplink in Bewegung.
  - Bei 16 Studs/s sind das schnell mehr als 1,5 Studs, also 40 Schaden.
  - Das HUD bestärkt den Fehler, denn es zeigt während „Achtung“ weiter „Gehen“.
- **In Studio würde passieren:** Mit Netzwerk-Verzögerung beim Erscheinen der Streifenkelle sofort anhalten: Man bekommt trotzdem Schaden. **Verdacht, in Studio prüfen.** Die Stärke des Effekts hängt von der Latenz ab.
- **Fix:**
  - Eigener HUD-Zustand für „warn“, z. B. „Gleich stillstehen“, mit eigener Form.
  - Bewegung erst ab S + Gnadenzeit messen; das Fenster darf nicht in die Gnadenzeit zurückreichen.
  - Gnadenzeit ≥ 0,6 s.
  - *Hinweis:* Die Arbeitskopie setzt `INSPECTOR_GRACE = 0.7` und legt `hud.getready` an; `Hud.luau` nutzt es noch nicht.
  - Unabhängig bestätigt durch Playtest LP-01.

### LL-05 · Mittel · Roblox-Tod oder verlorene Figur werden nicht behandelt, der Lauf endet nie
- **Ort:**
  - In `src/` gibt es keinen Handler für `Humanoid.Died` oder den Verlust des HRP (grep).
  - `aliveParticipants` filtert Spieler ohne HRP heraus (`RunController.luau:89-100`), `RunState.checkEnd` (`shared/Logic/RunState.luau:195`) zählt sie aber weiter als lebend.
  - Wegen `CharacterAutoLoads = false` (`default.project.json`; `docs:reference/engine/classes/Player.yaml:256-258`) wird keine neue Figur erzeugt.
- **Wege dorthin:**
  - Ein Exploiter setzt lokal die Lebenspunkte auf 0 oder löscht HRP bzw. Humanoid.
  - Der Reset-Knopf, falls alle 10 Versuche von `SetCore("ResetButtonCallback")` scheitern (`client/Main.client.luau:40-50`).
  - Fallen ist seit `3dc2613` durch `rescueFallen` abgedeckt (`RunController.luau:437-453`).
- **In Studio würde passieren:**
  - Die Figur kippt steif um (`BreakJointsOnDeath = false`, kein Verblassen, verletzt H-A8/S4). Es erscheint keine Notiz.
  - Sind alle anderen ausgeschieden, endet der Lauf nie. Der Server hängt, bis dieser Spieler geht.
- **Fix:**
  - In `setupCharacter` (`server/Services/PlayerService.luau:19-49`) `humanoid.Died` und den Verlust des HRP beobachten, dann `eliminate` aufrufen bzw. `RunState.removePlayer`.
  - Zusätzlich in `checkFinish` Teilnehmer, die länger als N s keine Figur haben, als ausgeschieden werten.

### LL-06 · Mittel · Ohne Zeitlimit hält ein untätiger Lebender die ganze Gruppe fest
- **Ort:** `RunState.checkEnd` endet nur mit Sieg oder „niemand lebt“; dazu `RunController.luau:842-861`.
- **In Studio würde passieren** (2 Clients):
  - A scheidet aus, B bleibt in Wagen 3 stehen.
  - Wesen werden nur beim Öffnen einer Tür ausgelöst, also passiert B nichts, und der Lauf läuft weiter.
  - A kann nur zuschauen, bis B geht oder Roblox ihn nach ca. 20 min Untätigkeit trennt [VORWISSEN]. Neue Spieler warten so lange am Bahnsteig.
- **Fix:** Lauf-Timeout, z. B. „5 min keine neue Tür“ ergibt „lost“, und/oder eine Abstimmung „Zurück zum Bahnsteig“ für Ausgeschiedene.

### LL-07 · Mittel · Zuschauer-Kamera ohne Verdeckungsprüfung (neu in `dd5abc5`)
- **Ort:** `client/Controllers/DeathController.luau:42-62`
- **Problem:**
  - Die Kamera steht 7 Studs hinter und 3,5 Studs über dem Ziel, `Scriptable`, ohne Raycast.
  - Der Zug ist innen 12 Studs breit, der Schlafwagen-Gang nur etwa 4 Studs. Steht das Ziel quer oder im Gang, liegt der Kamerapunkt in oder hinter Wand, Schrank oder Abteilwand. Man sieht dann die Außenseite des Zugs oder Schwarz.
  - Mit „Bewegung reduzieren“ (`alpha = 1`) folgt die Kamera jeder Drehung des Ziels sofort auf einem 7-Stud-Kreis. Für Bewegungsempfindliche (H-A18) ist das eher schlechter.
- **Fix:**
  - Raycast vom Ziel zur Wunschposition (nur Zug-Teile) und die Kamera vor den Treffer setzen.
  - Kamera entlang der Zugachse (+x) ausrichten oder den Gierwinkel glätten.
  - Bei reduzierter Bewegung den Gierwinkel nicht mitführen, statt nur das Glätten abzuschalten.

### LL-08 · Mittel · Die versteckte Figur bleibt sichtbar und ragt aus dem Möbel
- **Ort:**
  - `RunController.luau:135-157`: Die Figur wird in die Möbelmitte teleportiert und verankert.
  - Maße in `shared/Logic/CarriageCatalog.luau`: Schrank 2,6 breit, Schließfach im Postwagen 2,6 × 1,4, Überseekoffer 5,5 hoch.
- **Problem:**
  - Eine Standardfigur ist mit Armen etwa 4 Studs breit [VORWISSEN], Accessoires ragen höher.
  - Arme und Hüte stehen seitlich bzw. oben heraus. Mitspieler sehen das bei jedem Verstecken.
  - Spielerisch folgenlos, denn Wesen prüfen logisch. Es bricht aber die Illusion und wirkt wie ein Fehler.
- **Fix:**
  - Während `HiddenIn > 0` die Figur für alle ausblenden: Transparenz der BaseParts und Decals sichern, auf 1 setzen und beim Verlassen zurücksetzen.
  - Alternativ setzt jeder Client `LocalTransparencyModifier` für fremde Figuren mit `HiddenIn > 0`.
  - **Verdacht, in Studio prüfen** mit der R15-Standardfigur und einem Rthro-Avatar. Avatar-Typ und Skalierung in den Game Settings festlegen.

### LL-09 · Mittel · Taste E im Versteck konkurriert mit Prompts in Reichweite (Verdacht)
- **Ort:**
  - `client/Controllers/HidingController.luau:52-57`: `BindAction` auf E/ButtonB
  - `server/TrainBuilder.luau:93-116`: Prompts mit Taste E, `RequiresLineOfSight = false`
- **Problem** (nach dem Fix von LL-01):
  - Ein Versteckter hat weitere Prompts in Reichweite:
    - Schlafwagen: der Koffer im Abteil, 5,9–7,3 Studs vom Kleiderschrank, bei Reichweite 8 (`CarriageCatalog.luau:181-182`)
    - Speisewagen: zwei Vorratsschränke, 5 Studs auseinander, bei Reichweite 6 (`:211-212`)
  - Ob E dann „Aussteigen“ oder den Prompt auslöst, hängt davon ab, wie Roblox Prompt-Tasten bindet. Das ist nicht dokumentiert.
  - Der Server lehnt Prompts Versteckter ab (`RunController.luau:928-930`). Gewinnt der Prompt, passiert auf E also nichts.
  - Kommt das Remote zuerst an, steigt man aus und sofort ins Nachbarversteck.
- **Fix:**
  - Während des Versteckens auf dem Client `ProximityPromptService.Enabled = false` setzen und danach wieder auf `true`. Die Eigenschaft hat keine Sicherheitsstufe (`docs:reference/engine/classes/ProximityPromptService.yaml:25-45`).
  - Serverseitig in den ersten 0,3 s nach `leaveHiding` kein neues Verstecken annehmen.

### LL-10 · Mittel · Clientseitige Bewegung: Ein Exploiter kann den Lauf für alle steuern
- **Ort:**
  - Türen öffnen sich nach der Serverposition im Türbereich (`RunController.luau:455-482`).
  - Das Ziel gilt bei x hinter dem Postwagen als erreicht (`:842-861`).
  - Es gibt keine Plausibilitätsprüfung der Position.
- **Was ein Exploiter erreicht** (ohne Speicherstand nur Lauf-Schaden, D-035):
  - **Türen:** Mit Teleport öffnet er alle Türen in Sekunden; Schlüssel holt er per Teleport, die Reichweite wird nur am Ziel geprüft. So löst er Ereignisse aus, während die Mitspieler hinten sind. „Der Ruck“ zieht sie nach vorn hinein, die Kofferlawine holt Nachzügler.
  - **Finale:** Er liest die Fragmente und löst das Muster. Der Lauf gilt als gewonnen, die Telemetrie (RunEnded, Finish-Funnel) ist verfälscht.
  - **Unverwundbarkeit:** Bei |z| > 7 trifft der Express nicht (`RunController.luau:653`); Stehen in Wänden schützt ebenfalls.
  - **Softlock:** Selbst-Tod oder gelöschter HRP führen zu LL-05, also zum Stillstand für alle.
- **Remotes sind sauber:**
  - 3 Remotes vom Client zum Server mit exakter Argumentzahl, Typ- und Bereichsprüfung
  - Rate-Limit vor der Prüfung, `pcall` um jeden Handler
  - Belege: `shared/Net/Definitions.luau`, `shared/Net/Guard.luau`, `server/Services/NetService.luau`
  - Prompts prüfen die Reichweite; zur Lücke siehe LL-16.
- **Fix** (billig, nutzt Vorhandenes):
  - `MotionTracker` liefert das Tempo. Über ca. 1 s gemittelt mehr als 24 Studs/s: Figur auf die letzte gültige Position zurücksetzen.
  - Tür n nur öffnen, wenn der Auslöser mindestens 1 s in Wagen n−1 gemessen wurde.
  - Verdächtige Läufe in der Telemetrie markieren.

### LL-11 · Mittel · Performance-Verdacht: Alle Deckenlampen werfen Schatten
- **Ort:** `server/TrainBuilder.luau:448-469` (`light.Shadows = true` für jede Lampe), dazu `Lighting.Technology = Future` (`default.project.json`).
- **Messung:**
  - bis 14 Lampen je Wagen (Postwagen), 6 Wagen gleichzeitig gebaut
  - typisch 40–60 schattenwerfende PointLights, dazu das SpotLight des Schaffners mit Schatten (`:969`) und 4 Bahnsteiglaternen
  - Die Bauteilzahl ist unkritisch: Ø 89, max. 118 je Wagen, zusammen etwa 550–700.
- **Fix:**
  - Schatten nur für 1–2 Lampen je Wagen, oder clientseitig nur im aktuellen Wagen.
  - Im Studio-Emulator für Mobilgeräte mit MicroProfiler prüfen.

### LL-12 · Mittel · Hinweis-Notiz und Ergebnis-Fahrkarte überlagern sich (allein oder als Letzter)
- **Ort:** `client/Controllers/DeathController.luau:125-145`; `checkFinish` läuft alle 0,1 s.
- **Ablauf:**
  - Scheidet der letzte Lebende aus, kommt „summary“ höchstens 0,1 s nach „death“.
  - `onSummary` blendet die (noch unsichtbare) Notiz aus.
  - `onDeath` macht sie 1 s später trotzdem sichtbar (Z. 127-131).
  - Beide liegen in derselben ScreenGui. Die später erzeugte Ergebnis-Fahrkarte (Z. 185) verdeckt den Großteil der Notiz (`ZIndexBehavior.Sibling`).
- **Folge:** Allein sieht man den Hinweis nie. Die Lernschleife nach dem Tod fehlt. Unabhängig bestätigt durch Playtest LP-05.
- **Fix:** In `onDeath` nach dem Warten `summary.Visible` prüfen, oder den Hinweis als Zeile auf die Ergebnis-Fahrkarte setzen.

### LL-13 · Gering · Schaffner: Tempowechsel ohne neue Wegrevision
- **Ort:**
  - `shared/Logic/Conductor.luau:155`: `planTo` kehrt bei gleichem Zielknoten früh zurück
  - `:254`: `mode = "hunt"`
  - `RunController.luau:759-781`: gesendet wird nur bei neuer Revision, sonst alle 1 s
- **Problem:**
  - Bemerkt der Schaffner einen Spieler nahe seinem aktuellen Streifenziel, wechselt er auf 13 Studs/s, die Revision bleibt aber gleich.
  - Clients rechnen bis zu 1 s mit 7 Studs/s weiter. Der Versatz erreicht ca. 6 Studs bei einem Fangradius von 3,5.
- **Fix:** Die Revision auch beim Moduswechsel erhöhen.

### LL-14 · Gering · Versteck bleibt gesperrt, wenn ein Versteckter ausscheidet oder geht
- **Ort:**
  - `RunController.luau:172-175` (`eliminate`) und `:1028-1033` (`onPlayerRemoving`) leeren `HideState`.
  - `prompt.Enabled` bleibt aber `false`; nur `leaveHiding` schaltet ihn wieder ein (`:119-122`).
- **Fall:** Ein Spieler sitzt in Wagen c−1 im Schrank, die Kofferlawine holt ihn (LL-15), oder er verlässt das Spiel im Schrank. Der Schrank ist dann für den Rest des Laufs unbenutzbar, obwohl der Fairness-Prüfer mit ihm rechnet.
- **Fix:** Eine gemeinsame Funktion „Versteck freigeben“ (Prompt an, `Anchored` aus) in allen drei Pfaden.

### LL-15 · Gering · Kofferlawine: Verstecke in Wagen c−1 sind nutzbar, schützen aber nicht
- **Ort:**
  - `RunController.luau:202-226`: Prompts werden nur in Lawinenwagen deaktiviert.
  - `shared/Logic/Sweep.luau:97-103`: Die Lawine ignoriert Verstecke.
- **Problem:** Beim Auslösen stehen die meisten Spieler in c−1, einem ruhigen Wagen mit aktiven Schränken. Wer aus Express-Gewohnheit in den Schrank steigt, wird sicher geholt.
- **Fix:** Beim Lawinenstart Verstecke in allen Wagen ≤ c+4 deaktivieren und Versteckte aus c−1 herausholen, wie die Nachzügler (`:310-320`).

### LL-16 · Gering · Exploit: Versteck im noch geschlossenen Nachbarwagen
- **Ort:** `RunController.luau:912-940`. Für „hide“ fehlt die Prüfung `carriage <= current.opened`; Behälter haben sie in `RunState.openContainer`. Die Reichweite hat 3 Studs Toleranz.
- **Problem** (nach dem Fix von LL-01): Der Schrank bei x = 2 im Großraum- und im Speisewagen liegt ca. 6,8 Studs hinter der geschlossenen Tür. Normal ist der Prompt unsichtbar (Reichweite 6). Ein direkt ausgelöster Prompt liegt aber innerhalb von 9 Studs, und der Spieler landet hinter der geschlossenen Tür.
- **Fix:** In `onPrompt`: `if kind == "hide" and carriage > current.opened then return end`.

### LL-17 · Gering · HUD-Warnungen erscheinen auch am Bahnsteig; die Lawinen-Warnleiste läuft nach dem Abkoppeln weiter
- **Ort:**
  - `EntityController.luau:119,169,178` rufen `Hud.setWarning`/`setOncoming` ohne `Context.inRun()` auf
  - Anzeige in `Hud.luau:168-190`
- **Problem:**
  - Wer am Bahnsteig wartet, sieht bei jedem Express die Warnleiste und beim Gegenzug die Pfeile.
  - Nach `chaseStop` läuft die orange Leiste bis zum ursprünglichen `endAt` weiter.
- **Fix:**
  - Warnungen nur im Lauf oder beim Zuschauen zeigen.
  - Bei `chaseStop` `warnUntil = 0` setzen.

### LL-18 · Gering · Kamera-Schwanken ohne Figur summiert sich womöglich auf (Verdacht)
- **Ort:** `client/Controllers/AmbienceController.luau:169-179`
- **Problem:**
  - Das Schwanken läuft, solange `RunPhase == "running"` und `InRun` gilt, also auch nach dem Ausscheiden. Es multipliziert `camera.CFrame` in jedem Bild mit einer kleinen Rollung.
  - Ohne `CameraSubject` (die Figur ist entfernt, `PlayerService.luau:171-176`) schreibt das Kameramodul die CFrame vermutlich nicht neu. Dann addiert sich der Rollwinkel bis etwa ±30°, bis man „OK“ drückt. Die Abblende verdeckt das meiste.
- **Fix:** Nur schwanken, wenn `Context.alive()` gilt und eine Figur existiert.

### LL-19 · Gering · Raureif-Rand vermutlich unsichtbar (Verdacht)
- **Ort:** `client/Controllers/Hud.luau:225-245`: `UIStroke` mit Dicke 40 an einem Vollbild-Frame
- **Problem:** Die Standardlage des Strichs (`BorderStrokePosition`) nennt die Doku nicht (`docs:reference/engine/classes/UIStroke.yaml:100-118`). Liegt er außen, ist er außerhalb des Bildschirms.
- **Fix:** `BorderStrokePosition = Inner` ausdrücklich setzen.

### LL-20 · Gering · Lücken in der Lokalisierung
- `Hud.luau:281`: „notes.title“ wird einmal gesetzt, bevor der Translator geladen ist. `Strings.init` läuft in `task.spawn` (`Main.client.luau:28`), daher bleibt der Text englisch.
- Die `HINT_*`-Schlüssel haben keinen Fallback in `Strings.luau`. Scheitert der Translator, steht dort z. B. „HINT_EXPRESS_1“.
- „OK“ auf der Notiz ist nicht lokalisiert (`DeathController.luau:171`).

### LL-21 · Gering · Figur laden: keine Wiederholung, unnötige und doppelte Aufrufe
- **Ort:** `server/Services/PlayerService.luau:92-112`; `RunController.luau:565-583, 1017-1026`
- **Probleme:**
  - Scheitert `LoadCharacterAsync` (im `pcall`), bleibt der Spieler ohne Figur bis zum nächsten Reset. Am Bahnsteig gibt es keinen, also womöglich für immer.
  - Der Reset lädt auch die Wartenden am Bahnsteig neu.
  - Die Doku rät von einem zweiten Aufruf vor `CharacterAppearanceLoaded` ab (`docs:reference/engine/classes/Player.yaml:2258-2261`). Wer kurz vor einem Reset beitritt, bekommt genau das.
- **Fix:**
  - Wiederholung mit Backoff.
  - Beim Reset nur Teilnehmer und Spieler ohne Figur neu laden.
  - Ein „lädt gerade“-Flag je Spieler.

### LL-22 · Gering · Rest-Punkte der Licht-Compliance
- **Vorbeiziehende Lichter** (`AmbienceController.luau:119-167`) bleiben bei „Flackern reduzieren“ unverändert. H-A16 (b) verlangt „gedimmt“. Die Frequenz ist unkritisch: je Seite 3 Lichter im Abstand von 80 Studs bei 70 Studs/s, also ca. 0,9 Hz.
- **Überlagerung zweier Flackerpläne** (H-A16 d) ist nicht per Test ausgeschlossen.
  - Messung über 500 Pläne: Ein Express in c−2/c−3 vor der Lawine kommt in 83 Plänen vor.
  - Eine zeitliche Überlappung ist nur in einem Plan denkbar, und nur bei Luftlinien-Sprint (Abstand −0,01 s).
  - Praktisch erfüllt; einen Test ergänzen.
- **Rote Kontrolleur-Laterne:** ein PointLight mit Reichweite 14 und Helligkeit 1,4 (`TrainBuilder.luau:885`), eingefärbt per Tween (`EntityController.luau:298-340`). In der Haltphase färbt sie einen Teil des Wagens rot. H-A10 (c) erlaubt nur eine „schwache Tönung“ → in Studio ansehen.

### LL-23 · Gering · Kleinere Lasten
- **Generator:** `TrainGenerator.generate` braucht im Median 38 ms, maximal 65 ms (Luau-CLI, 30 Seeds). Das ergibt direkt nach der Abfahrt einen Server-Hänger von 2–4 Frames (`prepareNextPlan`, `RunController.luau:496-500`). Unkritisch; der Aufruf könnte in die Bahnsteig-Phase.
- **Speicher:** `lampDefaults` behält Einträge abgekoppelter Lampen bis zum Reset (`AmbienceController.luau:32, 98-108`).
- **HUD:** `Hud.update` ruft in jedem Bild `Strings.format` auf (`FormatByKey` in `pcall`), solange die Kelle sichtbar ist (`Hud.luau:121-150`).

### LL-24 · Gering · Eingabe und Rahmenbedingungen
- **Gamepad-Select:** Die Einstellungen liegen auf Select (`SettingsPanel.luau:75-80`). Select schaltet in Roblox auch die UI-Navigation; ein Konflikt ist möglich (Verdacht, vgl. LP-11).
- **Einstellungsknopf:** Im Ich-Modus ist der HUD-Knopf nicht anklickbar, weil er nicht `Modal` ist und die Maus gesperrt ist (`docs:reference/engine/classes/GuiButton.yaml:100-106`). M und Touch funktionieren.
- **Servergröße:** Die Grenze von 4 Spielern wird im Code nicht erzwungen; `startRun` nimmt alle Bereiten. In den Game Settings auf 4 stellen.

---

## 3. Während des Reviews behoben (Commits `3dc2613`, `dd5abc5`)

| Ursprünglicher Befund | Schwere damals | Behoben durch | Geprüft |
|---|---|---|---|
| Die hintere Türöffnung von Wagen 0 und die des ältesten Wagens nach dem Ruck führten ins Leere. Ein Sturz zerstörte den HRP; ohne Neuerzeugung blieb der Spieler „lebend“, der Lauf endete nie | Blocker | `TrainBuilder.sealRear` (`:684-702`), `RunController.rescueFallen` (`:437-453`) | Die Abdeckung schließt die Öffnung von 5 × 8 Studs. Die Rettung bei y < −30 läuft alle 0,1 s, lange vor der Zerstörungshöhe |
| Ankunftsbahnsteig ohne Absperrung | Gering | `3dc2613` | ja |
| Gegenzug-Lichter wechselten mit ca. 8 Hz und Helligkeitssprung | Mittel (Compliance) | `dd5abc5`: ruhiges Anschwellen, Rampen 0,35 s | ja |
| Express-Kugel bildfüllend | Mittel (Compliance) | `dd5abc5`: Ausblenden unter 12 Studs | ja |
| Kontrolleur konnte die Tür dauerhaft blockieren | Mittel | `dd5abc5`: Zeitlimit 40 s | ja |
| Zuschauen in fremder Ich-Perspektive | Gering | `dd5abc5` | dafür neu LL-07 |
| Sanfter Modus ohne „Flackern reduzieren“; Wackeln und Puls ohne „Bewegung reduzieren“ | Gering | `dd5abc5` | ja |

## 4. Geprüft ohne Befund (Auszug)
- **Require-by-string:** `@game/`, `./` und `../` sind dokumentiert (`docs:reference/engine/globals/LuaGlobals.yaml:616-633`) und passen zum Rojo-Baum (`sourcemap.json`: Server/Client als Folder, `StarterCharacterScripts` mit Script „Health“). Require-by-string wartet nicht (`:630-633`); deshalb wartet der Client richtigerweise auf `game.Loaded` und `Shared` (`Main.client.luau:9-13`).
- **Figuren-API:** `LoadCharacterAsync` ist die aktuelle API (`Player.yaml:2163-2187, 2238-2277`). `Player.Character` ist schreibbar (`Player.yaml:248-288`).
- **Kein Roblox-Tod:** Die Lebenspunkte erreichen nie 0, `BreakJointsOnDeath = false`, die Figur verblasst in 0,6 s (`PlayerService.luau:141-177`). Lücke siehe LL-05.
- **Verankern beim Verstecken:** `Anchored` wird vor dem Teleport ins Versteck gesetzt und vor dem Ausstiegs-Teleport gelöst (`RunController.luau:125-130, 150-153`). Das Lösen in Studio prüfen (Tabelle, S-05).
- **Netz-Konsistenz:** Ereignistypen und Payload-Felder stimmen zwischen Server und Client überein (express, chase, oncoming, conductor, chaseStop, death, summary, found, pattern, cold, validator, reset, start). Der Client verarbeitet „ruck“, „solved“ und „conductorWake“ nicht (fehlende Rückmeldung, vgl. LP-16).
- **Attribute und Tags** sind gleich benannt: RunPhase, RunCarriage, KeyDoor, LobbyEndsAt, Note1–3, InRun, Alive, HiddenIn, Index, OriginX, Length, EyeCFrame, SpotKey, Phase, Carriage sowie die drei Tags. `TrainView.carriageAt` und `TrainGenerator.carriageAt` ordnen den Übergang gleich zu (dem folgenden Wagen).
- **Server-Autorität bei Prompts:** Der Server prüft Lauf, Teilnahme, Leben, Versteckt-Status, Reichweite (+3) und Einmaligkeit (RunState). Die Kupplung prüft `canUncouple` beim Auslösen erneut.
- **Geometrie gegen Fairness-Prüfer:**
  - Die Hülle ist geschlossen: Boden, Wände, Fenster und Decke ohne Lücke.
  - Die Stirnwand-Öffnung (|z| < 2,5, Höhe 8) entspricht `NavGrid.doorCells`. Der Übergang ist 4 Studs lang, Bälge bei |z| 3,0–3,6, mit Dach.
  - Jedes Möbelteil liegt innerhalb seiner Box; Verstecke entsprechen der Box (plus 0,1 Studs Tür).
  - Behälter, Lampen, Augen, Kontrolleur, Schaffner, Schilder und Kupplung sind kollisionsfrei.
  - Der Entwerter kollidiert, steht nicht in `obstacles`, liegt aber neben dem Tor (|z| 2,9–4,3) und blockiert nichts.
  - Alle Teleportziele liegen in jedem Wagentyp frei: Start x = 2,5; Ruck und Rettung x = 3, z = 0; Ausstieg aus dem Versteck am Zugangspunkt.
- **Ablauf:** Bahnsteig-Countdown → Start → Türen → Ruck → Ende → Reset. Beim Reset werden Server und Client vollständig zurückgesetzt: `TrainBuilder.clear`, Tabellen und Attribute; auf dem Client Wesen, Effekte, Notiz, Kamera und Bindungen. Doppelte Ereignisse verhindert `RunState.openDoor`.
- **Kupplung** (neu): Bedingung, Freigabe, Türschluss, Stopp der Lawine und Ende sind schlüssig (`RunController.luau:392-435`, `Sweep.luau:105-140`).
- **Compliance-Greps:** kein `TextBox`, keine Spielernamen in eigener UI, kein `Seat`.

## 5. Abgleich mit dem Playtest-Bericht (`reports/lantern-line/playtest_report_sim.md`, unkommittiert)
- **Bestätigt:**
  - LP-01 entspricht LL-04.
  - LP-02 entspricht LL-03; k−2 und k−3 sind hier gemessen.
  - LP-05 entspricht LL-12.
  - LP-16: „ruck“ und „solved“ haben keinen Empfänger im Client.
- **Nicht bestätigt:**
  - LP-10 sagt: „Gamepad-B schaltet Schleichen um und verlässt zugleich das Versteck“. Laut Doku nutzt ContextActionService nur die zuletzt gebundene Aktion, und „LanternLeaveHiding“ schluckt die Eingabe (`docs:reference/engine/classes/ContextActionService.yaml:175-183`; `HidingController.luau:52-57`). In Studio gegenprüfen (S-24).
- **Widerspruch:** Der Simulationsbericht beschreibt das Verstecken als funktionierend („wirkt sofort“, „durch die Schlitze zieht weißes Licht vorbei“). Das widerspricht LL-01 und LL-02.

---

## 6. In Studio zu prüfen (Owner-Test)

Vorbereitung:
- Für Mehrspieler: **Test → Clients and Servers → 2 Players**.
- Für Latenz: **File → Studio Settings → Network → Incoming Replication Lag** auf 0,15 s.
- Für das Finale: das Workspace-Attribut `DebugStartCarriage` setzen.

| Nr | Prüfung | Vorgehen | Erwartet (korrekt) | Bezug |
|---|---|---|---|---|
| S-01 | Position der Versteck-Prompts | Wagen 1–5 ablaufen; in der Server-Command-Bar je `Hiding_*` den Abstand des Attachments zur Schranktür ausgeben | „Verstecken“ erscheint direkt an jeder Schranktür; Abstand < 0,1 | LL-01 |
| S-02 | Sicht aus dem Versteck | Verstecken und zur Tür hinausschauen; einen Express im Versteck erleben | Wagen und Lampen sind durch die Schlitze sichtbar; die Express-Kugel füllt nie das Bild | LL-02 |
| S-03 | Versteckte Figur von außen | Client A versteckt sich, Client B schaut auf den Schrank (Standardfigur und Rthro) | nichts ragt heraus | LL-08 |
| S-04 | Taste E im Versteck neben einem Prompt | Schlafwagen-Schrank mit ungeöffnetem Koffer; Speisewagen-Vorratsschrank | E heißt immer „Aussteigen“; kein fremder Prompt sichtbar | LL-09 |
| S-05 | Bewegung nach dem Aussteigen | Aus dem Versteck laufen, mit Latenz | kein Zurückschnappen und kein Ruckeln (Netzwerkbesitz nach `Anchored`) | §4 |
| S-06 | Kontrolleur mit Latenz | Erst beim Erscheinen der Streifenkelle anhalten; ein zweites Mal schon in der Achtungsphase | Ziel: kein Schaden, wenn man bei „Halt“ steht; das HUD zeigt „Achtung“ | LL-04 |
| S-07 | Schaffner synchron | `DebugStartCarriage = 50`; von der Seite in seine Nähe laufen, bis er jagt | Modell und Fang passen zusammen; kein Fang auf sichtbar > 4 Studs Abstand | LL-13 |
| S-08 | Schaffner-Gehör mit Latenz | In 7–15 Studs Abstand schleichen | kein Alarm durch Positionssprünge | LL-13 |
| S-09 | Zuschauen | A scheidet aus; B läuft durch den Schlafwagen-Gang und dreht sich, einmal mit „Bewegung reduzieren“ | Die Kamera bleibt im Zug; keine harten Schwenks; keine Übelkeit | LL-07 |
| S-10 | Notiz gegen Ergebnis | Allein ausscheiden | Der Hinweis ist lesbar | LL-12 |
| S-11 | `Modal`-Knöpfe in unsichtbaren Frames | PC, Ich-Modus, ohne offenes Panel | Die Maus ist gesperrt; frei nur bei Notiz, Panel oder Versteck | §4 |
| S-12 | GUIs nach dem Neuladen der Figur | Lauf beenden, Reset abwarten | HUD, Tafel und Einstellungen bleiben (`ResetOnSpawn = false`, per Skript erzeugt; `docs:reference/engine/classes/LayerCollector.yaml:55-69`) | §4 |
| S-13 | Laterne an der Figur | Nach dem Spawn und nach dem Reset in einen dunklen Wagen gehen | Das eigene Licht leuchtet (Zeitpunkt von `CharacterAdded`) | §4 |
| S-14 | Raureif | 14 s im Versteck bleiben | Ein sichtbarer Frost-Rand | LL-19 |
| S-15 | Kamera nach dem Ausscheiden | Mit 2 Spielern ausscheiden, die Notiz 10 s offen lassen | Das Bild kippt nicht | LL-18 |
| S-16 | Möbel ohne Springen betretbar? | Gegen Bett (2), Bank (1,8), Sitz (1,6), Sofa (1,4) und Kiste (2,2) laufen | nicht betretbar (H-A7) | §4 |
| S-17 | Performance | Mobilgerät-Emulator, MicroProfiler/Stats mit 6 gebauten Wagen | stabile Bildrate | LL-11 |
| S-18 | Rote Laterne des Kontrolleurs | Die Haltphase ansehen, auch in Graustufen | nur kleine rote Tönung | LL-22 |
| S-19 | Gamepad-Select | Mit dem Gamepad Select drücken und den „OK“-Knopf der Notiz erreichen | Roblox-UI-Navigation und Einstellungen sind beide nutzbar | LL-24 |
| S-20 | Untätiger Mitspieler | A scheidet aus, B bleibt stehen | heute: Der Lauf endet nie. Nach dem Fix: Timeout greift | LL-06 |
| S-21 | Roblox-Tod | Nur zum Test, in der Client-Command-Bar: `Humanoid.Health = 0` | Nach dem Fix: gilt als ausgeschieden, kein Umfallen, der Lauf endet | LL-05 |
| S-22 | Teleport-Exploit | In der Server-Command-Bar die eigene Figur mehrfach vor die nächste Tür setzen | Zeigt die Wirkung; nach dem Fix: Rücksetzen | LL-10 |
| S-23 | Game Settings | Servergröße und Avatar-Einstellungen | Servergröße 4; R15 mit fester Skalierung (wegen der Versteckgrößen) | LL-08, LL-24 |
| S-24 | Gamepad B im Versteck | Verstecken, dann B drücken | Nur Aussteigen; Schleichen bleibt unverändert | §5 |
