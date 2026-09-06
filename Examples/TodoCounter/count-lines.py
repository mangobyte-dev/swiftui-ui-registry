#!/usr/bin/env python3
"""Counts the Swift lines behind each UI layer of the Todo Counter app.

A line counts when it is not blank and not a comment-only line. The registry layer
splits into the lines the app wrote (its views and the theme file it edited) and the
lines it installed and owns (the copied items, previews included). Run from this folder.
"""

from pathlib import Path

FEATURE = Path(__file__).resolve().parent / "TodoCounterPackage" / "Sources" / "TodoCounterFeature"


def count(paths):
    lines = 0
    for path in paths:
        for line in path.read_text(encoding="utf-8").splitlines():
            stripped = line.strip()
            if stripped and not stripped.startswith("//"):
                lines += 1
    return lines


def files(*patterns):
    found = []
    for pattern in patterns:
        found += sorted(FEATURE.glob(pattern))
    return found


groups = {
    "shared reducers and switch": files("*.swift"),
    "registry layer, written by the app": files("Variants/Registry/*.swift", "Registry/RegistryTheme+App.swift"),
    "registry layer, installed and owned": [p for p in files("Registry/*.swift") if p.name != "RegistryTheme+App.swift"],
    "plain layer, written by the app": files("Variants/Plain/*.swift"),
    "handmade layer, written by the app": files("Variants/Handmade/*.swift"),
}
for name, paths in groups.items():
    print(f"{count(paths):5d} lines in {len(paths):2d} files: {name}")
