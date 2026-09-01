"""The generated catalog can never drift from registry metadata.

docs/catalog is a build product of Scripts/generate_catalog.py. This gate
regenerates the catalog into a temporary directory and asserts byte equality
with the checked-in pages, so an item edit without a regeneration run, a
hand-edited page, or a stale orphan page fails loudly.
"""

import importlib.util
import json
import sys
import tempfile
import unittest
from pathlib import Path


REPOSITORY_ROOT = Path(__file__).resolve().parents[2]
SPEC = importlib.util.spec_from_file_location(
    "generate_catalog", REPOSITORY_ROOT / "Scripts" / "generate_catalog.py"
)
CATALOG_MODULE = importlib.util.module_from_spec(SPEC)
assert SPEC.loader is not None
sys.modules[SPEC.name] = CATALOG_MODULE
SPEC.loader.exec_module(CATALOG_MODULE)
generate = CATALOG_MODULE.generate


def _write_single_item_registry(repository: Path, item_name: str) -> None:
    """A minimal valid registry holding one installable component."""
    source = repository / "Registry" / "sources" / "Item.swift"
    source.parent.mkdir(parents=True)
    source.write_text("source\n")
    (repository / "Registry" / "schema.json").write_text(
        (REPOSITORY_ROOT / "Registry" / "schema.json").read_text()
    )
    item = {
        "schemaVersion": 1,
        "version": "0.1.0",
        "name": item_name,
        "kind": "component",
        "description": "Test item.",
        "usage": "Item()",
        "files": [{"source": "sources/Item.swift", "target": "Item.swift"}],
        "registryDependencies": [],
        "packageDependencies": [],
        "platforms": [{"name": "iOS", "minimumVersion": "26.0"}],
        "tags": ["test"],
        "accessibility": [],
        "preview": {"source": "sources/Item.swift", "name": "Item"},
    }
    items = repository / "Registry" / "items"
    items.mkdir()
    (items / f"{item_name}.json").write_text(json.dumps(item))
    (repository / "Registry" / "registry.json").write_text(json.dumps({
        "schemaVersion": 1,
        "name": "TestRegistry",
        "items": [f"items/{item_name}.json"],
    }))


class CatalogFreshnessTests(unittest.TestCase):
    def test_checked_in_catalog_matches_regenerated_output(self):
        checked_in = REPOSITORY_ROOT / "docs" / "catalog"
        with tempfile.TemporaryDirectory() as directory:
            regenerated = Path(directory) / "catalog"
            written = generate(REPOSITORY_ROOT, regenerated)

            checked_in_names = sorted(path.name for path in checked_in.glob("*.md"))
            self.assertEqual(
                checked_in_names,
                sorted(written),
                "docs/catalog page set differs from generated output;"
                " run python3 Scripts/generate_catalog.py",
            )
            for name in written:
                self.assertEqual(
                    (checked_in / name).read_bytes(),
                    (regenerated / name).read_bytes(),
                    f"docs/catalog/{name} is stale;"
                    " run python3 Scripts/generate_catalog.py",
                )

    def test_item_named_index_is_rejected_before_overwriting_the_catalog_index(self):
        # An item validly named 'index' would have its page written to index.md,
        # then silently clobbered by the catalog index at the same path. The
        # generator must refuse it instead of losing the item's documentation.
        with tempfile.TemporaryDirectory() as repository, tempfile.TemporaryDirectory() as output:
            _write_single_item_registry(Path(repository), "index")
            with self.assertRaises(CATALOG_MODULE.RegistryError):
                generate(Path(repository), Path(output) / "catalog")

    def test_generation_is_deterministic(self):
        # Byte-stable output is what makes the freshness gate meaningful.
        with tempfile.TemporaryDirectory() as directory:
            first = Path(directory) / "first"
            second = Path(directory) / "second"
            names = generate(REPOSITORY_ROOT, first)
            self.assertEqual(names, generate(REPOSITORY_ROOT, second))
            for name in names:
                self.assertEqual(
                    (first / name).read_bytes(),
                    (second / name).read_bytes(),
                    f"{name} differs between two generation runs",
                )


if __name__ == "__main__":
    unittest.main()
