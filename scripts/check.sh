#!/usr/bin/env bash
# Lokale Qualitätsprüfung: Format, Lint, Typprüfung, Rojo-Build, Logik-Tests.
# Aufruf: scripts/check.sh   (Exit-Code ≠ 0 bei jedem Fehler)
# Werkzeuge: siehe rokit.toml und docs/tech_notes.md („Toolchain“).
set -euo pipefail
cd "$(dirname "$0")/.."

ROBLOX_DEFS="${LUAU_LSP_ROBLOX_DEFS:-.tools/globalTypes.d.luau}"
LUAU_BIN="${LUAU_BIN:-luau}"

step() { printf '\n== %s ==\n' "$1"; }

step "Format (StyLua)"
stylua --check src tests

step "Lint (Selene)"
selene src tests

step "Rojo-Build + Sourcemap"
mkdir -p build
rojo build default.project.json -o build/place.rbxlx
rojo sourcemap default.project.json -o sourcemap.json

step "Typprüfung (luau-lsp, Roblox-Typen)"
if [[ ! -f "$ROBLOX_DEFS" ]]; then
	echo "Roblox-Typdefinitionen fehlen: $ROBLOX_DEFS – zuerst scripts/setup_tools.sh ausführen." >&2
	exit 1
fi
luau-lsp analyze --platform=roblox --sourcemap=sourcemap.json \
	--definitions=@roblox="$ROBLOX_DEFS" --flag:LuauSolverV2=true src

step "Typprüfung Tests (luau-analyze)"
luau-analyze tests/

step "Logik-Tests (Luau-CLI)"
"$LUAU_BIN" tests/run.luau

printf '\nAlle Prüfungen bestanden.\n'
