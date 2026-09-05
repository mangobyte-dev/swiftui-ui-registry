#!/usr/bin/env python3
"""Export the registry as the website's data file and copy its captures.

`Website/` is a Next.js site built with shadcn/ui. It never reads
`Registry/` directly; it reads `Website/content/registry.json`, written here
from the validated installer path so an invalid catalog can never be published.
Each item carries its metadata, usage snippet, canonical source text, and
screenshot paths. Item and theme captures are copied into `Website/public/`
so the static export can serve them.

Output is deterministic; `Tests/RegistryTests/test_site_data.py` rejects
drift byte for byte. Never edit the JSON by hand.
"""

from __future__ import annotations

import argparse
import json
import shutil
import sys
from pathlib import Path

_SCRIPTS = Path(__file__).resolve().parent
if str(_SCRIPTS) not in sys.path:
    sys.path.insert(0, str(_SCRIPTS))

from install import Installer, RegistryError

DATA_OUTPUT = Path("Website/content/registry.json")
IMAGE_OUTPUT = Path("Website/public/images")
REPOSITORY_URL = "https://github.com/mangobyte-dev/swiftui-ui-registry"
THEME_PRESETS = [
    {"name": "System", "slug": "system", "blurb": "Inherits the app tint. The default."},
    {"name": "Graphite", "slug": "graphite", "blurb": "Ink on paper: primary accent, background label."},
    {"name": "Indigo", "slug": "indigo", "blurb": "The Showcase's own accent."},
    {"name": "Rose", "slug": "rose", "blurb": "Warm and friendly."},
    {"name": "Emerald", "slug": "emerald", "blurb": "Growth and confirmation."},
    {"name": "Amber", "slug": "amber", "blurb": "A light accent that proves the on-accent token."},
]


def render(repository_root: Path) -> dict:
    installer = Installer(repository_root)
    items = []
    for name in sorted(installer.items):
        item = installer.items[name]
        is_recipe = item["kind"] == "recipe"
        screenshots = item.get("preview", {}).get("screenshots") or []
        source_path = item["files"][0]["source"] if item["files"] else None
        items.append({
            "name": name,
            "kind": item["kind"],
            "version": item["version"],
            "description": item["description"],
            "usage": item["usage"],
            "docs": item.get("docs"),
            "tags": item["tags"],
            "aliases": item.get("aliases", []),
            "platforms": [f'{p["name"]} {p["minimumVersion"]}+' for p in item["platforms"]],
            "dependencies": item["registryDependencies"],
            "installOrder": [] if is_recipe else [
                {"name": member, "version": installer.items[member]["version"]}
                for member in installer.resolve(name)
            ],
            "accessibility": item["accessibility"],
            "sourcePath": f"Registry/{source_path}" if source_path else None,
            "sourceURL": f"{REPOSITORY_URL}/blob/main/Registry/{source_path}" if source_path else None,
            "source": (
                (repository_root / "Registry" / source_path).read_text(encoding="utf-8")
                if source_path else None
            ),
            "previewName": item.get("preview", {}).get("name"),
            "screenshots": {
                appearance: next(
                    (f"/images/items/{Path(path).name}" for path in screenshots
                     if path.endswith(f"-{appearance}.png")),
                    None,
                )
                for appearance in ("light", "dark")
            },
            "requirements": [] if is_recipe else [
                {
                    "instruction": Installer.dependency_instruction(entry),
                    "manifest": "\n".join(Installer.dependency_manifest_snippet(entry)),
                    "xcode": Installer.dependency_xcode_instruction(entry),
                }
                for entry in installer.package_requirements(name)
            ],
        })

    themes_root = repository_root / "docs" / "images" / "themes"
    presets = [
        {
            **preset,
            "screenshots": {
                appearance: (
                    f"/images/themes/{preset['slug']}-{appearance}.png"
                    if (themes_root / f"{preset['slug']}-{appearance}.png").is_file() else None
                )
                for appearance in ("light", "dark")
            },
        }
        for preset in THEME_PRESETS
    ]
    return {
        "name": installer.registry_name,
        "repositoryURL": REPOSITORY_URL,
        "counts": {
            kind: sum(1 for item in installer.items.values() if item["kind"] == kind)
            for kind in ("component", "block", "recipe")
        },
        "items": items,
        "presets": presets,
    }


def render_text(repository_root: Path) -> str:
    return json.dumps(render(repository_root), indent=2, ensure_ascii=False) + "\n"


def copy_images(repository_root: Path, destination: Path) -> int:
    copied = 0
    for folder in ("items", "themes"):
        source = repository_root / "docs" / "images" / folder
        target = destination / folder
        if target.exists():
            shutil.rmtree(target)
        if not source.is_dir():
            continue
        target.mkdir(parents=True, exist_ok=True)
        for image in sorted(source.glob("*.png")):
            shutil.copy2(image, target / image.name)
            copied += 1
    return copied


def main() -> int:
    parser = argparse.ArgumentParser(description=__doc__, formatter_class=argparse.RawDescriptionHelpFormatter)
    repository_root = Path(__file__).resolve().parents[1]
    parser.add_argument("--output", type=Path, default=repository_root / DATA_OUTPUT)
    parser.add_argument("--images", type=Path, default=repository_root / IMAGE_OUTPUT)
    arguments = parser.parse_args()
    try:
        text = render_text(repository_root)
    except RegistryError as error:
        parser.error(str(error))
    arguments.output.parent.mkdir(parents=True, exist_ok=True)
    arguments.output.write_text(text, encoding="utf-8")
    print(f"wrote {arguments.output}")
    print(f"copied {copy_images(repository_root, arguments.images)} images to {arguments.images}")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
