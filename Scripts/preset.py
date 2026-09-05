#!/usr/bin/env python3
"""Preset codes: a `RegistryTheme` as a short shareable string.

A code such as `a2q9T7kPx1` packs every knob of the Showcase's tuning panel
(accent, the label on it, surface and border opacity, border widths, radii,
spacings, disabled opacity, and a custom accent when one is chosen) into one
integer written in base62 behind a version letter. The same code decodes on
the website (`Website/lib/preset.ts`), in the Showcase (`ThemePreset.swift`),
and here, so a theme composed on any of them can be handed to the others, and
to an agent, without pasting Swift. `Tests/RegistryTests/preset_vectors.json`
pins codes every implementation must reproduce.

Usage (from the repository root):

    python3 Scripts/preset.py decode a2q9T7kPx1          # the knobs, the Swift, the URL
    python3 Scripts/preset.py apply a2q9T7kPx1 --destination Sources/YourFeature/Components
    python3 Scripts/preset.py resolve Sources/YourFeature/Components
    python3 Scripts/preset.py url a2q9T7kPx1
    python3 Scripts/preset.py random

`apply` writes `RegistryTheme+App.swift`, an extension declaring
`RegistryTheme.app`, next to the installed items; apply it once at the scene
root with `.registryTheme(.app)`. `resolve` reads that file, or any file with
a `RegistryTheme(...)` initializer in the shape the tuning panel exports, back
into a code.

Format rules, binding on every implementation:

1. Fields pack little-endian in the order of `FIELDS`; field 0 sits in the
   lowest bits. Numeric fields store `(value - minimum) / step`, which is the
   tuning panel's slider grid, so a code is exact on that grid and a value off the
   grid snaps to it on encode
2. Never reorder or resize an existing field. Only append, with the default
   at index 0, so an older code decodes under a newer table
3. A custom accent appends 24 bits of RGB, one flag bit, and 24 more bits for
   a separate dark accent when the flag is set; new fields go after that block
4. A field whose index is beyond its value count makes the code invalid. Bits
   above the known fields are ignored so an older decoder tolerates a newer
   code, and a code has at most 22 characters
"""

from __future__ import annotations

import argparse
import json
import random
import re
import sys
from pathlib import Path

SITE_URL = "https://swiftui-registry.mangobytekw.workers.dev"
THEME_FILE = "RegistryTheme+App.swift"
ALPHABET = "0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz"
VERSION = "a"
VERSIONS = ("a",)
MAX_LENGTH = 22
ACCENTS = (
    "system", "ink", "blue", "indigo", "purple", "pink", "red", "orange",
    "yellow", "green", "mint", "teal", "cyan", "brown", "custom",
)
# The named accents as SwiftUI spells them; `ink` is `.primary`, `system` is the app tint.
ACCENT_SWIFT = {name: f".{name}" for name in ACCENTS if name not in ("system", "ink", "custom")}
ACCENT_SWIFT["ink"] = ".primary"
# Preset names people paste instead of a color; the Showcase's import accepts the same words.
ACCENT_WORDS = {"primary": "ink", "graphite": "ink", "rose": "pink", "emerald": "green", "amber": "yellow"}

FIELDS = (
    {"key": "accent", "bits": 4, "values": ACCENTS},
    {"key": "darkLabelOnAccent", "bits": 1, "values": (False, True)},
    {"key": "surfaceOpacity", "bits": 6, "minimum": 0.0, "step": 0.005, "count": 41, "decimals": 3},
    {"key": "borderOpacity", "bits": 5, "minimum": 0.0, "step": 0.01, "count": 31, "decimals": 2},
    {"key": "borderWidth", "bits": 3, "minimum": 0.5, "step": 0.5, "count": 6, "decimals": 1},
    {"key": "emphasizedBorderWidth", "bits": 3, "minimum": 1.0, "step": 0.5, "count": 7, "decimals": 1},
    {"key": "compactRadius", "bits": 4, "minimum": 0, "step": 1, "count": 13, "decimals": 0},
    {"key": "controlRadius", "bits": 5, "minimum": 0, "step": 1, "count": 23, "decimals": 0},
    {"key": "cardRadius", "bits": 6, "minimum": 0, "step": 1, "count": 33, "decimals": 0},
    {"key": "compactSpacing", "bits": 4, "minimum": 4, "step": 1, "count": 13, "decimals": 0},
    {"key": "standardSpacing", "bits": 5, "minimum": 8, "step": 1, "count": 25, "decimals": 0},
    {"key": "sectionSpacing", "bits": 6, "minimum": 12, "step": 1, "count": 37, "decimals": 0},
    {"key": "controlHorizontalPadding", "bits": 5, "minimum": 8, "step": 1, "count": 17, "decimals": 0},
    {"key": "disabledOpacity", "bits": 4, "minimum": 0.2, "step": 0.05, "count": 13, "decimals": 2},
)
NUMERIC_KEYS = tuple(field["key"] for field in FIELDS if "values" not in field)

# `RegistryTheme()` with no arguments (Sources/SwiftUIRegistryFoundations/RegistryTheme.swift).
DEFAULT_TUNING = {
    "accent": "system",
    "darkLabelOnAccent": False,
    "surfaceOpacity": 0.055,
    "borderOpacity": 0.08,
    "borderWidth": 1.0,
    "emphasizedBorderWidth": 2.0,
    "compactRadius": 6.0,
    "controlRadius": 8.0,
    "cardRadius": 16.0,
    "compactSpacing": 8.0,
    "standardSpacing": 16.0,
    "sectionSpacing": 24.0,
    "controlHorizontalPadding": 12.0,
    "disabledOpacity": 0.5,
}


class PresetError(ValueError):
    """A code, a tuning, or a theme file that cannot be handled."""


# MARK: Codec


def is_preset_code(value: str) -> bool:
    return (
        isinstance(value, str)
        and 2 <= len(value) <= MAX_LENGTH
        and value[0] in VERSIONS
        and all(character in ALPHABET for character in value[1:])
    )


def preset_code_in(text: str) -> str | None:
    """The code inside pasted text: bare, or behind a `--preset` flag."""
    candidate = text.strip()
    match = re.match(r"^--preset\s+(\S+)$", candidate)
    if match:
        candidate = match.group(1)
    return candidate if is_preset_code(candidate) else None


def to_base62(number: int) -> str:
    if number == 0:
        return "0"
    digits = []
    while number > 0:
        number, remainder = divmod(number, 62)
        digits.append(ALPHABET[remainder])
    return "".join(reversed(digits))


def from_base62(text: str) -> int:
    number = 0
    for character in text:
        number = number * 62 + ALPHABET.index(character)
    return number


def _field_index(field: dict, value) -> int:
    if "values" in field:
        if value not in field["values"]:
            raise PresetError(f"{field['key']} must be one of {', '.join(map(str, field['values']))}, not {value!r}")
        return field["values"].index(value)
    if not isinstance(value, (int, float)) or isinstance(value, bool):
        raise PresetError(f"{field['key']} must be a number, not {value!r}")
    index = round((value - field["minimum"]) / field["step"])
    return max(0, min(field["count"] - 1, index))


def _field_value(field: dict, index: int):
    if "values" in field:
        return field["values"][index]
    value = field["minimum"] + index * field["step"]
    return round(value, field["decimals"]) if field["decimals"] else float(round(value))


def _rgb_bits(hex_color: str) -> int:
    match = re.fullmatch(r"#([0-9A-Fa-f]{6})", hex_color or "")
    if not match:
        raise PresetError(f"a custom accent must be #RRGGBB, not {hex_color!r}")
    return int(match.group(1), 16)


def _hex(bits: int) -> str:
    return f"#{bits & 0xFFFFFF:06X}"


def encode(tuning: dict) -> str:
    """The code for a tuning; numeric values snap to their slider grid."""
    bits = 0
    offset = 0
    for field in FIELDS:
        if field["key"] not in tuning:
            raise PresetError(f"missing {field['key']}")
        bits |= _field_index(field, tuning[field["key"]]) << offset
        offset += field["bits"]
    if tuning["accent"] == "custom":
        bits |= _rgb_bits(tuning.get("customAccent")) << offset
        offset += 24
        dark = tuning.get("customAccentDark")
        if dark:
            bits |= 1 << offset
            offset += 1
            bits |= _rgb_bits(dark) << offset
            offset += 24
        else:
            offset += 1
    return VERSION + to_base62(bits)


def decode(code: str) -> dict | None:
    """The tuning a code carries, or None when the code is not one."""
    if not is_preset_code(code):
        return None
    bits = from_base62(code[1:])
    offset = 0
    tuning = {}
    for field in FIELDS:
        index = (bits >> offset) & ((1 << field["bits"]) - 1)
        count = len(field["values"]) if "values" in field else field["count"]
        if index >= count:
            return None
        tuning[field["key"]] = _field_value(field, index)
        offset += field["bits"]
    if tuning["accent"] == "custom":
        tuning["customAccent"] = _hex(bits >> offset)
        offset += 24
        if (bits >> offset) & 1:
            offset += 1
            tuning["customAccentDark"] = _hex(bits >> offset)
            offset += 24
        else:
            tuning["customAccentDark"] = None
            offset += 1
    return tuning


def random_tuning(generator: random.Random | None = None) -> dict:
    generator = generator or random.Random()
    tuning = {}
    for field in FIELDS:
        count = len(field["values"]) if "values" in field else field["count"]
        tuning[field["key"]] = _field_value(field, generator.randrange(count))
    if tuning["accent"] == "custom":
        tuning["customAccent"] = _hex(generator.getrandbits(24))
        tuning["customAccentDark"] = _hex(generator.getrandbits(24)) if generator.random() < 0.5 else None
    return tuning


def preset_url(code: str) -> str:
    return f"{SITE_URL}/create?preset={code}"


# MARK: Swift


def _points(value: float) -> str:
    return str(int(value)) if float(value) == int(value) else f"{value:.1f}"


def _channels(hex_color: str) -> tuple[str, str, str]:
    bits = _rgb_bits(hex_color)
    return tuple(f"{((bits >> shift) & 0xFF) / 255:.3f}" for shift in (16, 8, 0))


def _color_source(hex_color: str, ui: bool) -> str:
    red, green, blue = _channels(hex_color)
    if ui:
        return f"UIColor(red: {red}, green: {green}, blue: {blue}, alpha: 1)"
    return f"Color(red: {red}, green: {green}, blue: {blue})"


def initializer_lines(tuning: dict) -> list[str]:
    """The `RegistryTheme(...)` call, one argument per line, in the exact shape
    the Showcase's Copy Swift writes so both parse the same way."""
    accent = tuning["accent"]
    lines = ["RegistryTheme("]
    if accent == "custom" and tuning.get("customAccentDark"):
        lines += [
            "    accent: Color(uiColor: UIColor { traits in",
            "        traits.userInterfaceStyle == .dark",
            f"            ? {_color_source(tuning['customAccentDark'], ui=True)}",
            f"            : {_color_source(tuning['customAccent'], ui=True)}",
            "    }),",
        ]
    elif accent == "custom":
        lines.append(f"    accent: {_color_source(tuning['customAccent'], ui=False)},")
    elif accent in ACCENT_SWIFT:
        lines.append(f"    accent: {ACCENT_SWIFT[accent]},")
    if accent == "ink":
        on_accent = "Color(uiColor: .systemBackground)"
    else:
        on_accent = ".black" if tuning["darkLabelOnAccent"] else ".white"
    lines += [
        f"    onAccent: {on_accent},",
        f"    surface: .primary.opacity({tuning['surfaceOpacity']:.3f}),",
        f"    border: .primary.opacity({tuning['borderOpacity']:.3f}),",
        f"    disabledOpacity: {tuning['disabledOpacity']:.3f},",
        "    metrics: RegistryMetrics(",
        f"        compactSpacing: {_points(tuning['compactSpacing'])},",
        f"        standardSpacing: {_points(tuning['standardSpacing'])},",
        f"        sectionSpacing: {_points(tuning['sectionSpacing'])},",
        f"        controlHorizontalPadding: {_points(tuning['controlHorizontalPadding'])},",
        f"        borderWidth: {_points(tuning['borderWidth'])},",
        f"        emphasizedBorderWidth: {_points(tuning['emphasizedBorderWidth'])},",
        f"        compactRadius: {_points(tuning['compactRadius'])},",
        f"        controlRadius: {_points(tuning['controlRadius'])},",
        f"        cardRadius: {_points(tuning['cardRadius'])}",
        "    )",
        ")",
    ]
    return lines


def swift_source(tuning: dict) -> str:
    """The snippet to paste, in the tuning panel's Copy Swift shape."""
    lines = initializer_lines(tuning)
    lines[0] = "let theme = " + lines[0]
    lines += [
        "",
        "// Apply once at the root of your scene; every registry item below inherits it.",
        "ContentView()",
        "    .registryTheme(theme)",
    ]
    return "\n".join(lines)


def needs_uikit(tuning: dict) -> bool:
    return tuning["accent"] == "ink" or (tuning["accent"] == "custom" and bool(tuning.get("customAccentDark")))


def theme_file(tuning: dict, code: str) -> str:
    """`RegistryTheme+App.swift`: the theme as `RegistryTheme.app`."""
    body = initializer_lines(tuning)
    lines = ["import SwiftUI", "import SwiftUIRegistryFoundations"]
    if needs_uikit(tuning):
        lines.append("import UIKit")
    lines += [
        "",
        f"// swiftui-registry preset {code}",
        f"// {preset_url(code)}",
        "// Written by `python3 Scripts/preset.py apply`. Edit freely; `preset.py resolve` reads it back into a code.",
        "",
        "extension RegistryTheme {",
        "    /// Apply once at the scene root: `ContentView().registryTheme(.app)`.",
        f"    static let app = {body[0]}",
    ]
    lines += [f"    {line}" for line in body[1:]]
    lines += ["}", ""]
    return "\n".join(lines)


# MARK: Parsing Swift


def parse_swift(text: str, base: dict | None = None) -> dict:
    """The knobs in a `RegistryTheme(...)` initializer, in the shape Copy Swift
    and `apply` write or any labeled subset of it; unnamed knobs keep the base.
    Raises PresetError when no initializer is present or an accent is unknown."""
    if "RegistryTheme(" not in text:
        raise PresetError("no RegistryTheme( initializer found")
    tuning = dict(base or DEFAULT_TUNING)
    flat = text.replace("\n", " ")

    rgbs = re.findall(r"(?:UI)?Color\(red:\s*([0-9.]+),\s*green:\s*([0-9.]+),\s*blue:\s*([0-9.]+)", flat)
    if "accent: Color(uiColor: UIColor {" in flat and len(rgbs) >= 2:
        # The dual form lists the dark color after `?`, then the light one after `:`.
        tuning["accent"] = "custom"
        tuning["customAccentDark"] = _hex_from_channels(rgbs[0])
        tuning["customAccent"] = _hex_from_channels(rgbs[1])
    elif (match := re.search(r"accent:\s*\.([a-zA-Z]+)", flat)):
        word = match.group(1)
        accent = ACCENT_WORDS.get(word, word)
        if accent not in ACCENTS or accent == "custom":
            raise PresetError(f"unknown accent .{word}")
        tuning["accent"] = accent
        tuning.pop("customAccent", None)
        tuning.pop("customAccentDark", None)
    elif (match := re.search(r"accent:\s*Color\(red:\s*([0-9.]+),\s*green:\s*([0-9.]+),\s*blue:\s*([0-9.]+)", flat)):
        tuning["accent"] = "custom"
        tuning["customAccent"] = _hex_from_channels(match.groups())
        tuning["customAccentDark"] = None

    if "onAccent: .black" in flat:
        tuning["darkLabelOnAccent"] = True
    elif "onAccent: .white" in flat:
        tuning["darkLabelOnAccent"] = False
    for key in ("surface", "border"):
        match = re.search(rf"\b{key}:\s*\.primary\.opacity\(([0-9.]+)\)", flat)
        if match:
            tuning[f"{key}Opacity"] = float(match.group(1))
    for key in ("disabledOpacity",) + tuple(k for k in NUMERIC_KEYS if k not in ("surfaceOpacity", "borderOpacity", "disabledOpacity")):
        match = re.search(rf"\b{key}:\s*([0-9]+(?:\.[0-9]+)?)", flat)
        if match:
            tuning[key] = float(match.group(1))
    if tuning["accent"] == "custom" and not tuning.get("customAccent"):
        raise PresetError("a custom accent needs its color")
    return tuning


def _hex_from_channels(channels) -> str:
    values = [max(0, min(255, round(float(channel) * 255))) for channel in channels]
    return f"#{values[0]:02X}{values[1]:02X}{values[2]:02X}"


# MARK: Files


def header_code(text: str) -> str | None:
    match = re.search(r"^// swiftui-registry preset (\S+)$", text, re.MULTILINE)
    return match.group(1) if match and is_preset_code(match.group(1)) else None


def resolve_file(path: Path) -> str:
    """The code a theme file resolves to: parsed from its initializer, never
    trusted from its header alone."""
    if path.is_dir():
        path = path / THEME_FILE
    if not path.is_file():
        raise PresetError(f"no theme file at {path}")
    return encode(parse_swift(path.read_text(encoding="utf-8")))


def apply(code: str, destination: Path, force: bool = False) -> Path:
    """Write `RegistryTheme+App.swift` for the code. An existing file is
    replaced only when it still resolves to the code in its own header, that
    is, nobody edited it since `apply` wrote it, unless `force` is set."""
    tuning = decode(code)
    if tuning is None:
        raise PresetError(f"invalid preset code: {code}")
    target = destination / THEME_FILE
    if target.exists() and not force:
        existing = target.read_text(encoding="utf-8")
        written = header_code(existing)
        try:
            current = encode(parse_swift(existing))
        except PresetError:
            current = None
        if written is None or current != written:
            raise PresetError(
                f"{target} was edited since it was written"
                f" (it resolves to {current or 'no theme'}, its header says {written or 'nothing'});"
                " pass --force to replace it"
            )
    destination.mkdir(parents=True, exist_ok=True)
    target.write_text(theme_file(tuning, code), encoding="utf-8")
    return target


# MARK: CLI


def describe(code: str) -> dict:
    tuning = decode(code)
    if tuning is None:
        raise PresetError(f"invalid preset code: {code}")
    return {
        "code": code,
        "version": code[0],
        "tuning": tuning,
        "swift": swift_source(tuning),
        "url": preset_url(code),
    }


def _print_description(described: dict) -> None:
    print("Preset")
    print(f"  {'code':<26}{described['code']}")
    print(f"  {'version':<26}{described['version']}")
    for key, value in described["tuning"].items():
        shown = "none" if value is None else str(value).lower() if isinstance(value, bool) else value
        print(f"  {key:<26}{shown}")
    print(f"  {'url':<26}{described['url']}")
    print()
    print(described["swift"])


def main(argv: list[str] | None = None) -> int:
    parser = argparse.ArgumentParser(description=__doc__, formatter_class=argparse.RawDescriptionHelpFormatter)
    commands = parser.add_subparsers(dest="command", required=True)

    decode_parser = commands.add_parser("decode", help="Print the knobs, the Swift, and the URL a code carries")
    decode_parser.add_argument("code")
    decode_parser.add_argument("--json", action="store_true")

    url_parser = commands.add_parser("url", help="Print the website URL for a code")
    url_parser.add_argument("code")

    apply_parser = commands.add_parser("apply", help=f"Write {THEME_FILE} for a code into the destination")
    apply_parser.add_argument("code")
    apply_parser.add_argument("--destination", required=True, type=Path)
    apply_parser.add_argument("--force", action="store_true", help="Replace an edited theme file")

    resolve_parser = commands.add_parser("resolve", help="Print the code a theme file (or its folder) resolves to")
    resolve_parser.add_argument("path", type=Path)
    resolve_parser.add_argument("--json", action="store_true")

    random_parser = commands.add_parser("random", help="Print a random code")
    random_parser.add_argument("--seed", type=int)

    arguments = parser.parse_args(argv)
    try:
        if arguments.command == "decode":
            described = describe(arguments.code)
            if arguments.json:
                print(json.dumps(described, indent=2))
            else:
                _print_description(described)
        elif arguments.command == "url":
            if not is_preset_code(arguments.code):
                raise PresetError(f"invalid preset code: {arguments.code}")
            print(preset_url(arguments.code))
        elif arguments.command == "apply":
            target = apply(arguments.code, arguments.destination, force=arguments.force)
            print(f"wrote {target}")
            print("apply once at the scene root: ContentView().registryTheme(.app)")
        elif arguments.command == "resolve":
            code = resolve_file(arguments.path)
            if arguments.json:
                print(json.dumps(describe(code), indent=2))
            else:
                _print_description(describe(code))
        elif arguments.command == "random":
            print(encode(random_tuning(random.Random(arguments.seed))))
    except PresetError as error:
        print(error, file=sys.stderr)
        return 2
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
