"""The website's data file can never drift from registry metadata.

Website/content/registry.json is a build product of Scripts/generate_site_data.py.
This gate re-renders it and asserts byte equality, so a metadata or source edit
without a regeneration run, or a hand edit of the JSON, fails loudly.
"""

import importlib.util
import json
import sys
import unittest
from pathlib import Path

REPOSITORY_ROOT = Path(__file__).resolve().parents[2]
SPEC = importlib.util.spec_from_file_location(
    "generate_site_data", REPOSITORY_ROOT / "Scripts" / "generate_site_data.py"
)
MODULE = importlib.util.module_from_spec(SPEC)
assert SPEC.loader is not None
sys.modules[SPEC.name] = MODULE
SPEC.loader.exec_module(MODULE)


class SiteDataTests(unittest.TestCase):
    def test_checked_in_data_matches_regenerated_output(self):
        checked_in = REPOSITORY_ROOT / MODULE.DATA_OUTPUT
        self.assertEqual(
            checked_in.read_text(encoding="utf-8"),
            MODULE.render_text(REPOSITORY_ROOT),
            "Website/content/registry.json is stale; run python3 Scripts/generate_site_data.py",
        )

    def test_every_item_carries_what_a_page_leads_with(self):
        # The page anatomy is the product bar: preview, one install command,
        # the usage snippet, and for installables the full source.
        data = json.loads((REPOSITORY_ROOT / MODULE.DATA_OUTPUT).read_text(encoding="utf-8"))
        names = [item["name"] for item in data["items"]]
        self.assertEqual(names, sorted(names))
        for item in data["items"]:
            with self.subTest(item=item["name"]):
                self.assertTrue(item["usage"].strip())
                if item["kind"] == "recipe":
                    self.assertIsNone(item["source"])
                    self.assertEqual(item["installOrder"], [])
                    self.assertTrue(item["docs"])
                else:
                    self.assertTrue(item["source"])
                    self.assertEqual(item["installOrder"][-1]["name"], item["name"])
                    self.assertTrue(item["requirements"])
                    self.assertTrue(item["screenshots"]["light"])
                    self.assertTrue(item["screenshots"]["dark"])


if __name__ == "__main__":
    unittest.main()
