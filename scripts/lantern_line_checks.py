#!/usr/bin/env python3
"""Statische Prüfungen für „Lantern Line“ (Teil von scripts/check.sh).

Setzt die prüfbaren Compliance-Auflagen aus reports/lantern-line/compliance_check_concept.md um:
  H-A1  keine Doors-Kennzeichen (Blockliste, ganze Wörter, ohne Groß-/Kleinschreibung)
  H-A5  „Doors“ nur in Recherche- und Compliance-Dokumenten
  H-A6  kein Alkohol / keine Bar in Spieltexten
  H-A7  keine Sitz-Instanzen (Seat/VehicleSeat)
  H-A12 keine TextBox
  H-A13 keine Käufe (MarketplaceService, ProcessReceipt)
  H-A14 keine Asset-IDs ohne Registereintrag (hier: gar keine im Code)
Außerdem: jeder im Client benutzte Textschlüssel, jeder Fallback-Schlüssel und jeder Hinweisschlüssel
steht in der LocalizationTable, und die kopierten Util-Module sind identisch mit dem Original.
Exit-Code 1 bei jedem Befund.
"""
import csv
import filecmp
import pathlib
import re
import sys

ROOT = pathlib.Path(__file__).resolve().parent.parent
GAME = ROOT / "games" / "lantern-line"
CSV_PATH = GAME / "src" / "localization" / "GameStrings.csv"

# Spieltexte (CSV): alle Doors-Namen inkl. allgemeiner Wörter, Alkohol, echte Bahnmarken.
TEXT_BLOCKLIST = [
    "doors", "rush", "ambush", "screech", "eyes", "halt", "seek", "figure", "hide", "dupe", "jack",
    "timothy", "jeff", "guiding light", "curious light", "hotel", "mines", "backdoor", "the rooms",
    "knobs", "knöpfe", "revive", "revives", "pre-run", "elevator", "squid game",
    "red light green light", "lsplash",
    "bar", "bier", "beer", "wein", "wine", "alkohol", "alcohol", "whisky", "cocktail", "sekt",
    "deutsche bahn", "db", "öbb", "nightjet", "sbb", "sncf", "orient-express", "amtrak",
]
# Quellcode: unverwechselbare Namen (allgemeine Wörter wie „eyes“ sind als Bezeichner erlaubt).
CODE_BLOCKLIST = [
    "doors", "screech", "ambush", "timothy", "guiding light", "curious light", "knobs", "revive",
    "revives", "lsplash", "backdoor", "dupe", "jeff", "squid game", "red light green light", "rush",
]
CODE_PATTERNS = {
    "H-A7 Sitz-Instanz": re.compile(r"\bSeat\b|VehicleSeat"),
    "H-A12 TextBox": re.compile(r"\bTextBox\b"),
    "H-A13 Käufe": re.compile(r"MarketplaceService|ProcessReceipt|PromptProductPurchase|PromptGamePassPurchase"),
    "H-A14 Asset-ID": re.compile(r"rbxassetid://|rbxasset://|rbxthumb://"),
}

errors: list[str] = []


def word_pattern(words: list[str]) -> re.Pattern[str]:
    escaped = sorted((re.escape(w) for w in words), key=len, reverse=True)
    return re.compile(r"(?<![\w])(" + "|".join(escaped) + r")(?![\w])", re.IGNORECASE)


def lua_files(*dirs: pathlib.Path) -> list[pathlib.Path]:
    files: list[pathlib.Path] = []
    for d in dirs:
        files.extend(sorted(d.rglob("*.luau")))
    return files


def check_csv() -> set[str]:
    pattern = word_pattern(TEXT_BLOCKLIST)
    keys: set[str] = set()
    with CSV_PATH.open(encoding="utf-8", newline="") as handle:
        for row in csv.DictReader(handle):
            key = row["Key"]
            if key in keys:
                errors.append(f"CSV: doppelter Schlüssel {key}")
            keys.add(key)
            for column in ("Source", "en", "de"):
                text = row.get(column) or ""
                for match in pattern.finditer(text):
                    errors.append(f"H-A1/H-A6 CSV {key}/{column}: verbotenes Wort „{match.group(0)}“")
                if column in ("en", "de") and not text.strip():
                    errors.append(f"CSV {key}: Spalte {column} leer")
    return keys


def check_code(keys: set[str]) -> None:
    pattern = word_pattern(CODE_BLOCKLIST)
    for path in lua_files(GAME / "src"):
        text = path.read_text(encoding="utf-8")
        rel = path.relative_to(ROOT)
        for match in pattern.finditer(text):
            errors.append(f"H-A1 {rel}: verbotenes Wort „{match.group(0)}“")
        for label, regex in CODE_PATTERNS.items():
            if regex.search(text):
                errors.append(f"{label}: {rel}")
        # Textschlüssel im Client
        for key in re.findall(r'Strings\.format\("([^"]+)"', text):
            if key not in keys:
                errors.append(f"Textschlüssel fehlt in der CSV: {key} ({rel})")
        for key in re.findall(r'\[\"([a-z]+\.[a-z.]+)\"\]\s*=', text):
            if key not in keys:
                errors.append(f"Fallback-Schlüssel fehlt in der CSV: {key} ({rel})")
        # Prompt-Texte werden über die Source-Spalte automatisch übersetzt
    causes_text = (GAME / "src" / "shared" / "Logic" / "Causes.luau").read_text(encoding="utf-8")
    causes = re.search(r"Causes\.LIST = table\.freeze\(\{([^}]*)\}\)", causes_text)
    variants = re.search(r"local VARIANTS = (\d+)", causes_text)
    if not causes or not variants:
        errors.append("Causes.luau: Liste oder VARIANTS nicht gefunden")
    else:
        for cause in re.findall(r'"([a-z]+)"', causes.group(1)):
            for v in range(1, int(variants.group(1)) + 1):
                key = f"HINT_{cause.upper()}_{v}"
                if key not in keys:
                    errors.append(f"Hinweisschlüssel fehlt in der CSV: {key}")


def check_prompt_sources() -> None:
    sources: set[str] = set()
    with CSV_PATH.open(encoding="utf-8", newline="") as handle:
        for row in csv.DictReader(handle):
            sources.add(row["Source"])
    builder = (GAME / "src" / "server" / "TrainBuilder.luau").read_text(encoding="utf-8")
    texts = set(re.findall(r'newPrompt\([^,]+,\s*"([^"]+)",\s*(?:"([^"]+)"|[A-Za-z_.\[\] ]+or "([^"]+)")', builder))
    flat = {t for group in texts for t in group if t}
    flat |= set(re.findall(r'text = "([^"]+)"', builder))
    flat |= set(re.findall(r'(?:rack|suitcase|drawer|crate) = "([^"]+)"', builder))
    for text in sorted(flat):
        if text not in sources:
            errors.append(f"Prompt-Text ohne CSV-Source (keine Übersetzung): „{text}“")


def check_docs() -> None:
    allowed = {"research_doors.md", "compliance_check_concept.md", "compliance_check_sprint1_ll.md"}
    pattern = re.compile(r"\bdoors\b", re.IGNORECASE)
    for folder in (ROOT / "docs" / "lantern-line", ROOT / "games" / "lantern-line"):
        for path in sorted(folder.rglob("*")):
            if path.is_file() and path.suffix in {".md", ".luau", ".csv", ".json"} and path.name not in allowed:
                if pattern.search(path.read_text(encoding="utf-8")):
                    errors.append(f"H-A5: „Doors“ in {path.relative_to(ROOT)}")


def check_copies() -> None:
    pairs = [
        (ROOT / "src" / "shared" / "Util", GAME / "src" / "shared" / "Util"),
    ]
    for original, copy in pairs:
        comparison = filecmp.dircmp(original, copy)
        if comparison.left_only or comparison.right_only or comparison.diff_files:
            errors.append(f"Kopie weicht ab: {copy.relative_to(ROOT)} ↔ {original.relative_to(ROOT)}")
    for original, copy in [
        (ROOT / "src" / "shared" / "Net" / "Guard.luau", GAME / "src" / "shared" / "Net" / "Guard.luau"),
    ]:
        if not filecmp.cmp(original, copy, shallow=False):
            errors.append(f"Kopie weicht ab: {copy.relative_to(ROOT)}")


def main() -> int:
    keys = check_csv()
    check_code(keys)
    check_prompt_sources()
    check_docs()
    check_copies()
    if errors:
        for e in errors:
            print("✗ " + e)
        print(f"{len(errors)} Befund(e)")
        return 1
    print(f"Lantern-Line-Prüfungen: OK ({len(keys)} Textschlüssel)")
    return 0


if __name__ == "__main__":
    sys.exit(main())
