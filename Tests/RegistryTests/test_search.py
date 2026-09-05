import importlib.util
import json
import subprocess
import sys
import unittest
from pathlib import Path


REPOSITORY_ROOT = Path(__file__).resolve().parents[2]
SCRIPTS = REPOSITORY_ROOT / "Scripts"
sys.path.insert(0, str(SCRIPTS))
SPEC = importlib.util.spec_from_file_location("registry_search", SCRIPTS / "search.py")
SEARCH_MODULE = importlib.util.module_from_spec(SPEC)
assert SPEC.loader is not None
SPEC.loader.exec_module(SEARCH_MODULE)
Installer = SEARCH_MODULE.Installer
search_items = SEARCH_MODULE.search_items


class SearchTests(unittest.TestCase):
    def setUp(self):
        self.installer = Installer(REPOSITORY_ROOT)

    def test_exact_name_ranks_the_requested_block_first(self):
        matches = search_items(self.installer, "finance-overview")

        self.assertEqual(matches[0]["name"], "finance-overview")
        self.assertGreater(matches[0]["score"], 100)

    def test_multiple_terms_find_the_non_finance_vertical_slice(self):
        matches = search_items(self.installer, "nutrition dashboard", kind="block")

        self.assertEqual([match["name"] for match in matches], ["nutrition-overview"])

    def test_platform_versions_are_compared_semantically(self):
        matches = search_items(
            self.installer,
            "finance-overview",
            platform="iOS",
            target_version="26",
        )

        self.assertEqual(matches[0]["name"], "finance-overview")

    def test_platform_floor_excludes_incompatible_items(self):
        matches = search_items(
            self.installer,
            "finance",
            platform="iOS",
            target_version="25.0",
        )

        self.assertEqual(matches, [])

    def test_cli_emits_machine_readable_dependency_and_accessibility_metadata(self):
        process = subprocess.run(
            [
                sys.executable,
                str(SCRIPTS / "search.py"),
                "finance",
                "--kind",
                "block",
                "--format",
                "json",
            ],
            check=True,
            capture_output=True,
            text=True,
        )
        matches = json.loads(process.stdout)

        self.assertEqual([match["name"] for match in matches], ["finance-overview"])
        self.assertEqual(
            matches[0]["registryDependencies"],
            ["metric-card", "transaction-row", "empty"],
        )
        self.assertTrue(matches[0]["accessibility"])


if __name__ == "__main__":
    unittest.main()
