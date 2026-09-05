#!/usr/bin/env python3
"""Capture light and dark screenshots of every registry item from the Showcase.

The Showcase's `-item <name>` launch renders one demo alone and writes the
demo's on-screen frame to the path given by `-capture-info`, so each capture
is cropped to the content instead of a whole phone screen. Images land in
`docs/images/items/<name>-<appearance>.png` at half resolution, ready for the
item metadata (`preview.screenshots`), the catalog, and the website.

Runs against the pinned simulator (`docs/visual-testing.md`) and drives it
through `xcrun simctl`, the batch-friendly path for forty-plus launches.

Usage (from the repository root):

    python3 Scripts/capture_previews.py            # every item, light and dark
    python3 Scripts/capture_previews.py badge card # a subset
    python3 Scripts/capture_previews.py --themes   # the theme presets page

`--app` points at a built SwiftUIRegistryShowcase.app; without it the script
builds one with xcodebuild into a scratch derived-data directory.
"""

from __future__ import annotations

import argparse
import json
import shutil
import subprocess
import sys
import tempfile
import time
from pathlib import Path

_SCRIPTS = Path(__file__).resolve().parent
if str(_SCRIPTS) not in sys.path:
    sys.path.insert(0, str(_SCRIPTS))

from install import Installer, RegistryError

REPOSITORY_ROOT = _SCRIPTS.parent
PINNED_UDID = "1807166B-C557-4F6B-B177-D5F3F701CBD7"
BUNDLE_ID = "com.example.swiftuiregistry.showcase"
WORKSPACE = REPOSITORY_ROOT / "Examples" / "Showcase" / "SwiftUIRegistryShowcase.xcworkspace"
SCHEME = "SwiftUIRegistryShowcase"
OUTPUT = REPOSITORY_ROOT / "docs" / "images" / "items"
THEME_OUTPUT = REPOSITORY_ROOT / "docs" / "images" / "themes"
APPEARANCES = ("light", "dark")
THEME_PRESETS = ("System", "Graphite", "Indigo", "Rose", "Emerald", "Amber")
# No top margin: the demo starts at the safe-area edge, right under the Dynamic Island.
TOP_MARGIN_POINTS = 0
BOTTOM_MARGIN_POINTS = 12


def run(command: list[str], **kwargs) -> subprocess.CompletedProcess:
    return subprocess.run(command, check=True, capture_output=True, text=True, **kwargs)


def build_app(derived_data: Path, udid: str) -> Path:
    print("building the Showcase...", flush=True)
    run([
        "xcodebuild",
        "-workspace", str(WORKSPACE),
        "-scheme", SCHEME,
        "-destination", f"id={udid}",
        "-derivedDataPath", str(derived_data),
        "-quiet",
        "build",
    ])
    products = derived_data / "Build" / "Products"
    apps = list(products.glob("*/SwiftUIRegistryShowcase.app"))
    if not apps:
        raise RuntimeError(f"No built app under {products}")
    return apps[0]


def boot(udid: str) -> None:
    subprocess.run(["xcrun", "simctl", "boot", udid], capture_output=True)
    run(["xcrun", "simctl", "bootstatus", udid, "-b"])


def capture(
    udid: str,
    name: str,
    appearance: str,
    destination: Path,
    *,
    theme: str | None = None,
    scratch: Path,
) -> None:
    info_path = scratch / f"{name}-{appearance}.json"
    raw_path = scratch / f"{name}-{appearance}-raw.png"
    info_path.unlink(missing_ok=True)

    run(["xcrun", "simctl", "ui", udid, "appearance", appearance])
    launch = [
        "xcrun", "simctl", "launch", "--terminate-running-process", udid, BUNDLE_ID,
        "-item", name, "-appearance", appearance, "-capture-info", str(info_path),
    ]
    if theme:
        launch += ["-theme", theme]
    run(launch)

    deadline = time.monotonic() + 8
    while not info_path.exists() and time.monotonic() < deadline:
        time.sleep(0.1)
    if not info_path.exists():
        raise RuntimeError(f"{name} ({appearance}) never reported its frame; is the demo registered?")
    # Let the first layout pass, symbol effects, and the tab-less window settle.
    time.sleep(0.9)
    run(["xcrun", "simctl", "io", udid, "screenshot", "--type=png", str(raw_path)])

    info = json.loads(info_path.read_text())
    scale = info["scale"]
    screen = run(["sips", "-g", "pixelWidth", "-g", "pixelHeight", str(raw_path)]).stdout
    pixel_width = int(next(line.split()[-1] for line in screen.splitlines() if "pixelWidth" in line))
    pixel_height = int(next(line.split()[-1] for line in screen.splitlines() if "pixelHeight" in line))

    top = max(0, int((info["y"] - TOP_MARGIN_POINTS) * scale))
    bottom = min(pixel_height, int((info["y"] + info["height"] + BOTTOM_MARGIN_POINTS) * scale))
    height = max(1, bottom - top)
    # sips crops around the center; offset it to the content's top edge.
    run([
        "sips", str(raw_path),
        "--cropToHeightWidth", str(height), str(pixel_width),
        "--cropOffset", str(top), "0",
        "--out", str(raw_path),
    ])
    destination.parent.mkdir(parents=True, exist_ok=True)
    run([
        "sips", str(raw_path),
        "--resampleWidth", str(pixel_width // 2),
        "--setProperty", "format", "png",
        "--out", str(destination),
    ])


def record_screenshots(names: list[str]) -> None:
    """Point each captured item's metadata at its images, then say what to regenerate."""
    for name in names:
        path = REPOSITORY_ROOT / "Registry" / "items" / f"{name}.json"
        item = json.loads(path.read_text(encoding="utf-8"))
        preview = item.setdefault("preview", {})
        preview["screenshots"] = [
            f"docs/images/items/{name}-{appearance}.png" for appearance in APPEARANCES
        ]
        path.write_text(json.dumps(item, indent=2, ensure_ascii=False) + "\n", encoding="utf-8")
    print("metadata updated; run generate_catalog.py, generate_showcase_manifest.py, and generate_site.py")


def main() -> int:
    parser = argparse.ArgumentParser(description=__doc__, formatter_class=argparse.RawDescriptionHelpFormatter)
    parser.add_argument("items", nargs="*", help="Item names to capture (default: every item)")
    parser.add_argument("--udid", default=PINNED_UDID)
    parser.add_argument("--app", type=Path, help="A built SwiftUIRegistryShowcase.app")
    parser.add_argument("--themes", action="store_true", help="Capture the theme presets instead of items")
    parser.add_argument("--no-metadata", action="store_true", help="Do not write preview.screenshots")
    arguments = parser.parse_args()

    try:
        installer = Installer(REPOSITORY_ROOT)
    except RegistryError as error:
        parser.error(str(error))
    names = arguments.items or sorted(installer.items)
    unknown = [name for name in names if name not in installer.items]
    if unknown:
        parser.error(f"unknown items: {', '.join(unknown)}")

    with tempfile.TemporaryDirectory() as directory:
        scratch = Path(directory)
        boot(arguments.udid)
        app = arguments.app or build_app(scratch / "DerivedData", arguments.udid)
        run(["xcrun", "simctl", "install", arguments.udid, str(app)])

        if arguments.themes:
            for preset in THEME_PRESETS:
                for appearance in APPEARANCES:
                    destination = THEME_OUTPUT / f"{preset.lower()}-{appearance}.png"
                    capture(
                        arguments.udid, "theme-preview", appearance, destination,
                        theme=preset, scratch=scratch,
                    )
                    print(f"captured {destination.relative_to(REPOSITORY_ROOT)}")
        else:
            for name in names:
                for appearance in APPEARANCES:
                    destination = OUTPUT / f"{name}-{appearance}.png"
                    capture(arguments.udid, name, appearance, destination, scratch=scratch)
                    print(f"captured {destination.relative_to(REPOSITORY_ROOT)}")
            if not arguments.no_metadata:
                record_screenshots(names)

        run(["xcrun", "simctl", "ui", arguments.udid, "appearance", "light"])
        subprocess.run(["xcrun", "simctl", "terminate", arguments.udid, BUNDLE_ID], capture_output=True)
    return 0


if __name__ == "__main__":
    try:
        raise SystemExit(main())
    except subprocess.CalledProcessError as error:
        sys.stderr.write(error.stderr or str(error))
        raise SystemExit(1)
