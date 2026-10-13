#!/usr/bin/env bash
# Lokale Qualitätsprüfung: Format, Lint, Typprüfung, Rojo-Build, Logik-Tests – für beide Spiele:
# „Schwungturm“ (Repo-Wurzel) und „Lantern Line“ (games/lantern-line).
# Aufruf: scripts/check.sh   (Exit-Code ≠ 0 bei jedem Fehler)
# Werkzeuge: siehe rokit.toml und docs/tech_notes.md („Toolchain“).
set -euo pipefail
cd "$(dirname "$0")/.."

ROBLOX_DEFS="${LUAU_LSP_ROBLOX_DEFS:-.tools/globalTypes.d.luau}"
LL="games/lantern-line"
LUAU_BIN="${LUAU_BIN:-luau}"

step() { printf '\n== %s ==\n' "$1"; }

step "Format (StyLua)"
stylua --check src tests "$LL/src" "$LL/tests"

step "Lint (Selene)"
selene src tests "$LL/src" "$LL/tests"

step "Rojo-Build + Sourcemap"
mkdir -p build
rojo build default.project.json -o build/place.rbxlx
rojo sourcemap default.project.json -o sourcemap.json
rojo build "$LL/default.project.json" -o build/LanternLine.rbxlx
rojo sourcemap "$LL/default.project.json" -o "$LL/sourcemap.json"

step "Typprüfung (luau-lsp, Roblox-Typen)"
if [[ ! -f "$ROBLOX_DEFS" ]]; then
	echo "Roblox-Typdefinitionen fehlen: $ROBLOX_DEFS – zuerst scripts/setup_tools.sh ausführen." >&2
	exit 1
fi
luau-lsp analyze --platform=roblox --sourcemap=sourcemap.json \
	--definitions=@roblox="$ROBLOX_DEFS" --flag:LuauSolverV2=true src
# Sourcemap-Pfade sind relativ zum Projektordner – deshalb im Spielordner analysieren.
DEFS_ABS="$(cd "$(dirname "$ROBLOX_DEFS")" && pwd)/$(basename "$ROBLOX_DEFS")"
(cd "$LL" && luau-lsp analyze --platform=roblox --sourcemap=sourcemap.json \
	--definitions=@roblox="$DEFS_ABS" --flag:LuauSolverV2=true src)

step "Typprüfung Tests (luau-analyze)"
luau-analyze tests/ "$LL/tests/"

step "Logik-Tests (Luau-CLI)"
"$LUAU_BIN" tests/run.luau
"$LUAU_BIN" "$LL/tests/run.luau"

step "Lantern Line: Compliance- und Textprüfungen"
python3 scripts/lantern_line_checks.py

step "Installer-Tests (PowerShell 7)"
if command -v pwsh >/dev/null 2>&1; then
	pwsh -NoProfile -File installer/tests/Test-Installer.ps1
else
	echo "pwsh nicht gefunden – Installer-Tests übersprungen."
fi

printf '\nAlle Prüfungen bestanden.\n'
