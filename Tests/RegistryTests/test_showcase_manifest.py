"""The Showcase manifest can never drift from registry metadata.

The app's browser and every usage snippet it shows come from
RegistryCatalogManifest.swift, a build product of
Scripts/generate_showcase_manifest.py. A metadata edit without a regeneration
run, or a hand edit of the Swift file, fails here.
"""

import importlib.util
import sys
import unittest
from pathlib import Path

REPOSITORY_ROOT = Path(__file__).resolve().parents[2]
SPEC = importlib.util.spec_from_file_location(
    "generate_showcase_manifest",
    REPOSITORY_ROOT / "Scripts" / "generate_showcase_manifest.py",
)
MODULE = importlib.util.module_from_spec(SPEC)
assert SPEC.loader is not None
sys.modules[SPEC.name] = MODULE
SPEC.loader.exec_module(MODULE)


class ShowcaseManifestTests(unittest.TestCase):
    def test_checked_in_manifest_matches_regenerated_output(self):
        checked_in = REPOSITORY_ROOT / MODULE.DEFAULT_OUTPUT
        self.assertEqual(
            checked_in.read_text(encoding="utf-8"),
            MODULE.render(REPOSITORY_ROOT),
            "RegistryCatalogManifest.swift is stale;"
            " run python3 Scripts/generate_showcase_manifest.py",
        )

    def test_checked_in_ui_test_names_match_regenerated_output(self):
        checked_in = REPOSITORY_ROOT / MODULE.NAMES_OUTPUT
        self.assertEqual(
            checked_in.read_text(encoding="utf-8"),
            MODULE.render_names(REPOSITORY_ROOT),
            "RegistryItemNames.swift is stale;"
            " run python3 Scripts/generate_showcase_manifest.py",
        )

    def test_every_item_is_listed_once_with_its_usage(self):
        # A demo the app cannot find by name would fall through to its
        # "missing demo" screen; the manifest must at least name every item.
        rendered = MODULE.render(REPOSITORY_ROOT)
        installer = MODULE.Installer(REPOSITORY_ROOT)
        for name, item in installer.items.items():
            with self.subTest(item=name):
                self.assertEqual(rendered.count(f'name: "{name}",'), 1)
                self.assertIn(MODULE._swift_string(item["usage"]), rendered)


if __name__ == "__main__":
    unittest.main()
