#!/usr/bin/env bash
# Lädt die Roblox-Typdefinitionen für luau-lsp (gepinnt auf denselben Commit wie in docs/tech_notes.md).
# Die Werkzeuge selbst installiert man lokal z. B. mit `rokit install` (siehe rokit.toml);
# das Luau-CLI (`luau`) gibt es unter https://github.com/luau-lang/luau/releases.
set -euo pipefail
cd "$(dirname "$0")/.."

LUAU_LSP_COMMIT="${LUAU_LSP_COMMIT:-6f90396fa8f6ac253deb3c7e2c11458c2e67227d}"
mkdir -p .tools
curl -fsSL "https://raw.githubusercontent.com/JohnnyMorganz/luau-lsp/${LUAU_LSP_COMMIT}/scripts/globalTypes.d.luau" \
	-o .tools/globalTypes.d.luau
echo "Roblox-Typdefinitionen gespeichert: .tools/globalTypes.d.luau"
