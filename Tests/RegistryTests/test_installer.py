import importlib.util
import json
import sys
import tempfile
import unittest
from pathlib import Path


REPOSITORY_ROOT = Path(__file__).resolve().parents[2]
SPEC = importlib.util.spec_from_file_location(
    "registry_installer", REPOSITORY_ROOT / "Scripts" / "install.py"
)
INSTALLER_MODULE = importlib.util.module_from_spec(SPEC)
assert SPEC.loader is not None
sys.modules[SPEC.name] = INSTALLER_MODULE
SPEC.loader.exec_module(INSTALLER_MODULE)
Installer = INSTALLER_MODULE.Installer
RegistryError = INSTALLER_MODULE.RegistryError


class InstallerTests(unittest.TestCase):
    def setUp(self):
        self.installer = Installer(REPOSITORY_ROOT)

    def test_block_resolves_components_before_the_block(self):
        self.assertEqual(
            self.installer.resolve("finance-overview"),
            ["metric-card", "transaction-row", "finance-overview"],
        )

    def test_non_finance_block_reuses_foundation_components(self):
        self.assertEqual(
            self.installer.resolve("nutrition-overview"),
            ["metric-card", "macro-progress", "nutrition-overview"],
        )

    def test_install_copies_sources_and_records_exact_provenance(self):
        with tempfile.TemporaryDirectory() as directory:
            destination = Path(directory)
            installed = self.installer.install("finance-overview", destination)

            self.assertEqual(len(installed), 3)
            for planned in installed:
                self.assertEqual(planned.target.read_bytes(), planned.source.read_bytes())

            receipt = json.loads(
                (destination / ".swiftui-registry" / "receipt.json").read_text()
            )
            self.assertEqual(receipt["schemaVersion"], 1)
            self.assertEqual(receipt["items"]["finance-overview"]["version"], "0.2.0")
            self.assertEqual(set(receipt["files"]), {
                "MetricCard.swift",
                "TransactionRow.swift",
                "FinanceOverview.swift",
            })
            self.assertFalse(list((destination / ".swiftui-registry").rglob("*.swift")))

    def test_repeated_install_is_safe_but_modified_owned_source_is_refused(self):
        with tempfile.TemporaryDirectory() as directory:
            destination = Path(directory)
            self.installer.install("metric-card", destination)
            self.assertEqual(self.installer.install("metric-card", destination), [])
            (destination / "MetricCard.swift").write_text("// consumer edit\n")

            with self.assertRaisesRegex(RegistryError, "Refusing to overwrite owned source"):
                self.installer.install("metric-card", destination)

    def test_install_rejects_target_that_escapes_through_symbolic_link(self):
        with tempfile.TemporaryDirectory() as repository, \
             tempfile.TemporaryDirectory() as output, \
             tempfile.TemporaryDirectory() as outside:
            self.make_registry(Path(repository), "source\n")
            item_path = Path(repository) / "Registry" / "items" / "example.json"
            item = json.loads(item_path.read_text())
            item["files"][0]["target"] = "linked/Example.swift"
            item_path.write_text(json.dumps(item))
            destination = Path(output)
            (destination / "linked").symlink_to(Path(outside), target_is_directory=True)

            with self.assertRaisesRegex(RegistryError, "escapes through a symbolic link"):
                Installer(Path(repository)).install("example", destination)

    def test_update_replaces_unmodified_source(self):
        with tempfile.TemporaryDirectory() as repository, tempfile.TemporaryDirectory() as output:
            source = self.make_registry(Path(repository), "old\n")
            installer = Installer(Path(repository))
            destination = Path(output)
            installer.install("example", destination)
            source.write_text("new\n")

            results = installer.update("example", destination)

            self.assertEqual(results[0].status, "updated")
            self.assertEqual((destination / "Example.swift").read_text(), "new\n")

    def test_update_preserves_local_only_edits(self):
        with tempfile.TemporaryDirectory() as repository, tempfile.TemporaryDirectory() as output:
            self.make_registry(Path(repository), "base\n")
            installer = Installer(Path(repository))
            destination = Path(output)
            installer.install("example", destination)
            owned = destination / "Example.swift"
            owned.write_text("consumer\n")

            results = installer.update("example", destination)

            self.assertEqual(results[0].status, "locally-modified")
            self.assertEqual(owned.read_text(), "consumer\n")

    def test_update_three_way_merges_disjoint_registry_and_consumer_edits(self):
        base = "consumer = false\nline2\nline3\nline4\nline5\nregistry = false\n"
        with tempfile.TemporaryDirectory() as repository, tempfile.TemporaryDirectory() as output:
            source = self.make_registry(Path(repository), base)
            installer = Installer(Path(repository))
            destination = Path(output)
            installer.install("example", destination)
            (destination / "Example.swift").write_text(base.replace("consumer = false", "consumer = true"))
            source.write_text(base.replace("registry = false", "registry = true"))

            results = installer.update("example", destination)

            merged = (destination / "Example.swift").read_text()
            self.assertEqual(results[0].status, "merged")
            self.assertIn("consumer = true", merged)
            self.assertIn("registry = true", merged)

    def test_conflict_preflight_prevents_partial_dependency_update(self):
        with tempfile.TemporaryDirectory() as repository, tempfile.TemporaryDirectory() as output:
            source = self.make_registry(Path(repository), "value = base\n")
            other_source = Path(repository) / "Registry" / "sources" / "Other.swift"
            other_source.write_text("other = base\n")
            item_path = Path(repository) / "Registry" / "items" / "example.json"
            item = json.loads(item_path.read_text())
            item["files"].append({
                "source": "sources/Other.swift",
                "target": "Other.swift",
            })
            item_path.write_text(json.dumps(item))
            installer = Installer(Path(repository))
            destination = Path(output)
            installer.install("example", destination)
            (destination / "Example.swift").write_text("value = consumer\n")
            source.write_text("value = registry\n")
            other_source.write_text("other = registry\n")

            with self.assertRaisesRegex(RegistryError, "owned source was not changed"):
                installer.update("example", destination)

            self.assertEqual((destination / "Other.swift").read_text(), "other = base\n")

    def test_update_stops_on_conflict_and_preserves_owned_source(self):
        with tempfile.TemporaryDirectory() as repository, tempfile.TemporaryDirectory() as output:
            source = self.make_registry(Path(repository), "value = base\n")
            installer = Installer(Path(repository))
            destination = Path(output)
            installer.install("example", destination)
            owned = destination / "Example.swift"
            owned.write_text("value = consumer\n")
            source.write_text("value = registry\n")

            with self.assertRaisesRegex(RegistryError, "owned source was not changed"):
                installer.update("example", destination)

            self.assertEqual(owned.read_text(), "value = consumer\n")
            artifacts = list(
                (destination / ".swiftui-registry" / "conflicts").glob("*.merge")
            )
            self.assertEqual(len(artifacts), 1)
            self.assertIn("<<<<<<< Example.swift", artifacts[0].read_text())

    @staticmethod
    def make_registry(repository: Path, source_content: str) -> Path:
        source = repository / "Registry" / "sources" / "Example.swift"
        source.parent.mkdir(parents=True)
        source.write_text(source_content)
        item = {
            "schemaVersion": 1,
            "version": "0.1.0",
            "name": "example",
            "kind": "component",
            "description": "Test item.",
            "files": [{"source": "sources/Example.swift", "target": "Example.swift"}],
            "registryDependencies": [],
            "packageDependencies": [],
            "platforms": [{"name": "iOS", "minimumVersion": "18.0"}],
            "tags": ["test"],
            "accessibility": [],
            "preview": {"source": "sources/Example.swift", "name": "Example"},
        }
        items = repository / "Registry" / "items"
        items.mkdir()
        (items / "example.json").write_text(json.dumps(item))
        (repository / "Registry" / "registry.json").write_text(json.dumps({
            "schemaVersion": 1,
            "name": "TestRegistry",
            "items": ["items/example.json"],
        }))
        return source


if __name__ == "__main__":
    unittest.main()
