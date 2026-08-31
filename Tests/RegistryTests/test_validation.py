"""The shared validator is the single structural gate for the catalog.

Install, search, the validate CLI, and CI all trust Scripts/registry_validation.py
to reject malformed metadata. Every negative case below encodes a defect class a
consumer must never receive silently; if a check is weakened, the matching test
fails because the mutated fixture would validate.
"""

import importlib.util
import json
import shutil
import sys
import tempfile
import unittest
from pathlib import Path


REPOSITORY_ROOT = Path(__file__).resolve().parents[2]
SPEC = importlib.util.spec_from_file_location(
    "registry_validation", REPOSITORY_ROOT / "Scripts" / "registry_validation.py"
)
VALIDATION_MODULE = importlib.util.module_from_spec(SPEC)
assert SPEC.loader is not None
sys.modules[SPEC.name] = VALIDATION_MODULE
SPEC.loader.exec_module(VALIDATION_MODULE)
validate_registry = VALIDATION_MODULE.validate_registry
validate_item = VALIDATION_MODULE.validate_item


class ValidationTests(unittest.TestCase):
    def setUp(self):
        self._directory = tempfile.TemporaryDirectory()
        self.addCleanup(self._directory.cleanup)
        self.repository = Path(self._directory.name)
        self.make_registry(self.repository)

    def test_real_registry_and_valid_fixture_pass(self):
        self.assertEqual(validate_registry(REPOSITORY_ROOT), [])
        self.assertEqual(validate_registry(self.repository), [])

    def test_missing_required_key_is_rejected(self):
        item = self.load_item("example")
        del item["tags"]
        self.save_item("example", item)

        self.assert_rejects("missing required keys: tags")

    def test_undeclared_key_is_rejected(self):
        item = self.load_item("example")
        item["surprise"] = True
        self.save_item("example", item)

        self.assert_rejects("undeclared keys: surprise")

    def test_wrong_schema_version_is_rejected(self):
        item = self.load_item("example")
        item["schemaVersion"] = 2
        self.save_item("example", item)

        self.assert_rejects("schemaVersion must be 1")

    def test_malformed_version_and_name_are_rejected(self):
        item = self.load_item("example")
        item["version"] = "1.0"
        self.save_item("example", item)
        self.assert_rejects("version must match")

        item["version"] = "0.1.0"
        item["name"] = "example"
        self.save_item("example", item)
        helper = self.load_item("helper")
        helper["name"] = "Bad Name"
        self.save_item("helper", helper)
        self.assert_rejects("name must match")

    def test_unknown_kind_is_rejected(self):
        item = self.load_item("example")
        item["kind"] = "widget"
        self.save_item("example", item)

        self.assert_rejects("kind must be one of")

    def test_recipe_with_files_is_rejected(self):
        # A recipe is native guidance; installing files from one would break the
        # item value gate.
        item = self.load_item("guide")
        item["files"] = [{"source": "sources/Example.swift", "target": "Example.swift"}]
        self.save_item("guide", item)

        self.assert_rejects("recipe items must declare empty files")

    def test_recipe_with_blank_docs_is_rejected(self):
        item = self.load_item("guide")
        item["docs"] = "   "
        self.save_item("guide", item)

        self.assert_rejects("docs must be a non-empty string")
        self.assert_rejects("recipe items require non-empty docs")

    def test_missing_or_blank_usage_is_rejected(self):
        # The catalog gate: an item without a call-site usage snippet cannot be
        # documented, so the validator refuses it for every kind.
        item = self.load_item("example")
        del item["usage"]
        self.save_item("example", item)
        self.assert_rejects("every item requires a non-empty usage snippet")

        item["usage"] = "   "
        self.save_item("example", item)
        self.assert_rejects("every item requires a non-empty usage snippet")

        guide = self.load_item("guide")
        del guide["usage"]
        self.save_item("guide", guide)
        self.assert_rejects("every item requires a non-empty usage snippet")

    def test_installable_item_without_preview_is_rejected(self):
        # Previews are the visual contract; an installable item without one
        # cannot prove its variants.
        item = self.load_item("example")
        del item["preview"]
        self.save_item("example", item)

        self.assert_rejects("installable items require a preview")

    def test_installable_item_with_empty_files_is_rejected(self):
        item = self.load_item("example")
        item["files"] = []
        self.save_item("example", item)

        self.assert_rejects("installable items require at least one entry in files")

    def test_missing_declared_source_file_is_rejected(self):
        item = self.load_item("example")
        item["files"][0]["source"] = "sources/Ghost.swift"
        self.save_item("example", item)

        self.assert_rejects("declared source file does not exist: sources/Ghost.swift")

    def test_missing_preview_source_and_screenshot_are_rejected(self):
        item = self.load_item("example")
        item["preview"]["source"] = "sources/Ghost.swift"
        item["preview"]["screenshots"] = ["docs/images/ghost.png"]
        self.save_item("example", item)

        self.assert_rejects("preview source file does not exist")
        self.assert_rejects("preview screenshot does not exist: docs/images/ghost.png")

    def test_unknown_dependency_is_rejected(self):
        item = self.load_item("example")
        item["registryDependencies"] = ["missing-item"]
        self.save_item("example", item)

        self.assert_rejects("unknown registry dependency: missing-item")

    def test_dependency_cycle_is_rejected(self):
        item = self.load_item("example")
        item["registryDependencies"] = ["helper"]
        self.save_item("example", item)
        helper = self.load_item("helper")
        helper["registryDependencies"] = ["example"]
        self.save_item("helper", helper)

        self.assert_rejects("dependency cycle")

    def test_recipe_as_dependency_is_rejected(self):
        # Installable items cannot depend on non-installing recipes.
        item = self.load_item("example")
        item["registryDependencies"] = ["guide"]
        self.save_item("example", item)

        self.assert_rejects("depends on recipe guide")

    def test_platform_floor_format_is_enforced(self):
        item = self.load_item("example")
        item["platforms"] = [{"name": "iOS", "minimumVersion": "18.beta"}]
        self.save_item("example", item)
        self.assert_rejects("minimumVersion must be 1 to 3 dot-separated numbers")

        item["platforms"] = [{"name": "macOS", "minimumVersion": "15.0"}]
        self.save_item("example", item)
        self.assert_rejects("name must be one of")

        item["platforms"] = []
        self.save_item("example", item)
        self.assert_rejects("platforms must declare at least one platform")

    def test_package_dependency_shape_is_enforced(self):
        item = self.load_item("example")
        item["packageDependencies"] = [{"package": "SwiftUIRegistry", "product": "Foundations"}]
        self.save_item("example", item)
        self.assert_rejects("missing required keys: requirement")

        item["packageDependencies"] = [
            {
                "package": "SwiftUIRegistry",
                "product": "Foundations",
                "requirement": "0.x",
                "branch": "main",
            }
        ]
        self.save_item("example", item)
        self.assert_rejects("undeclared keys: branch")

    def test_actionable_package_dependency_passes(self):
        item = self.load_item("example")
        item["packageDependencies"] = [self.foundation_dependency()]
        self.save_item("example", item)

        self.assertEqual(validate_registry(self.repository), [])

    def test_version_requirement_without_swiftpm_rule_is_rejected(self):
        # A prose-only requirement is not actionable; a consumer cannot resolve
        # "0.x" mechanically.
        dependency = self.foundation_dependency()
        del dependency["swiftPM"]
        item = self.load_item("example")
        item["packageDependencies"] = [dependency]
        self.save_item("example", item)

        self.assert_rejects("a version requirement needs a machine-resolvable swiftPM rule")

    def test_malformed_swiftpm_rule_is_rejected(self):
        item = self.load_item("example")
        dependency = self.foundation_dependency()
        dependency["swiftPM"] = {"kind": "branch", "minimumVersion": "0.1.0"}
        item["packageDependencies"] = [dependency]
        self.save_item("example", item)
        self.assert_rejects("swiftPM kind must be one of")

        dependency["swiftPM"] = {"kind": "upToNextMinor", "minimumVersion": "0.x"}
        self.save_item("example", item)
        self.assert_rejects("swiftPM minimumVersion must match")

        dependency["swiftPM"] = {"kind": "upToNextMinor"}
        self.save_item("example", item)
        self.assert_rejects("missing required keys: minimumVersion")

        dependency["sourceURL"] = "   "
        dependency["swiftPM"] = {"kind": "upToNextMinor", "minimumVersion": "0.1.0"}
        self.save_item("example", item)
        self.assert_rejects("sourceURL must be a non-empty string")

    def test_swiftpm_range_bounds_are_enforced(self):
        item = self.load_item("example")
        dependency = self.foundation_dependency()
        dependency["swiftPM"] = {"kind": "range", "minimumVersion": "0.1.0"}
        item["packageDependencies"] = [dependency]
        self.save_item("example", item)
        self.assert_rejects("swiftPM range requires maximumVersionExclusive")

        dependency["swiftPM"] = {
            "kind": "upToNextMinor",
            "minimumVersion": "0.1.0",
            "maximumVersionExclusive": "0.2.0",
        }
        self.save_item("example", item)
        self.assert_rejects("maximumVersionExclusive is only for range")

        dependency["swiftPM"] = {
            "kind": "range",
            "minimumVersion": "0.1.0",
            "maximumVersionExclusive": "0.2.0",
        }
        self.save_item("example", item)
        self.assertEqual(validate_registry(self.repository), [])

    def test_index_listing_a_missing_item_file_is_rejected(self):
        index_path = self.repository / "Registry" / "registry.json"
        index = json.loads(index_path.read_text())
        index["items"].append("items/ghost.json")
        index_path.write_text(json.dumps(index))

        self.assert_rejects("listed item file does not exist: items/ghost.json")

    def test_unlisted_item_file_is_rejected(self):
        # Every item file must be indexed so no orphan metadata drifts silently.
        source = self.repository / "Registry" / "items" / "example.json"
        shutil.copyfile(source, source.with_name("orphan.json"))

        self.assert_rejects("item file exists but is not listed in registry.json")

    def test_duplicate_item_name_is_rejected(self):
        item = self.load_item("helper")
        item["name"] = "example"
        self.save_item("helper", item)

        self.assert_rejects("duplicate registry item name: example")

    def test_validate_item_scopes_to_the_dependency_closure(self):
        # Lazy validation lets search or install of one item skip unrelated
        # defects while the full-catalog pass still fails.
        guide = self.load_item("guide")
        guide["docs"] = "   "
        self.save_item("guide", guide)

        self.assertEqual(validate_item(self.repository, "example"), [])
        self.assertTrue(validate_registry(self.repository))

    def test_validate_item_rejects_unknown_names(self):
        issues = validate_item(self.repository, "missing-item")

        self.assertEqual(len(issues), 1)
        self.assertIn("unknown registry item: missing-item", str(issues[0]))

    def assert_rejects(self, fragment: str):
        issues = validate_registry(self.repository)
        self.assertTrue(issues, "expected the validator to report issues")
        rendered = [str(issue) for issue in issues]
        self.assertTrue(
            any(fragment in line for line in rendered),
            f"no issue mentions {fragment!r}; got:\n" + "\n".join(rendered),
        )

    def make_registry(self, repository: Path) -> None:
        sources = repository / "Registry" / "sources"
        sources.mkdir(parents=True)
        (sources / "Example.swift").write_text("// example\n")
        (sources / "Helper.swift").write_text("// helper\n")
        schema = (REPOSITORY_ROOT / "Registry" / "schema.json").read_text()
        (repository / "Registry" / "schema.json").write_text(schema)

        items = repository / "Registry" / "items"
        items.mkdir()
        self.write_item(repository, self.component("example", "Example"))
        self.write_item(repository, self.component("helper", "Helper"))
        self.write_item(repository, {
            "schemaVersion": 1,
            "version": "0.1.0",
            "name": "guide",
            "kind": "recipe",
            "description": "Test recipe.",
            "usage": "NativeControl()",
            "docs": "Use the native control directly.",
            "files": [],
            "registryDependencies": [],
            "packageDependencies": [],
            "platforms": [{"name": "iOS", "minimumVersion": "26.0"}],
            "tags": ["guide"],
            "accessibility": [],
        })
        (repository / "Registry" / "registry.json").write_text(json.dumps({
            "schemaVersion": 1,
            "name": "TestRegistry",
            "items": ["items/example.json", "items/helper.json", "items/guide.json"],
        }))

    @staticmethod
    def foundation_dependency() -> dict:
        return {
            "package": "SwiftUIRegistry",
            "product": "SwiftUIRegistryFoundations",
            "requirement": "0.x",
            "sourceURL": "https://github.com/mangobyte-dev/swiftui-ui-registry.git",
            "swiftPM": {"kind": "upToNextMinor", "minimumVersion": "0.1.0"},
        }

    @staticmethod
    def component(name: str, source: str) -> dict:
        return {
            "schemaVersion": 1,
            "version": "0.1.0",
            "name": name,
            "kind": "component",
            "description": "Test item.",
            "usage": f"{source}()",
            "files": [{"source": f"sources/{source}.swift", "target": f"{source}.swift"}],
            "registryDependencies": [],
            "packageDependencies": [],
            "platforms": [{"name": "iOS", "minimumVersion": "26.0"}],
            "tags": [name],
            "accessibility": [],
            "preview": {"source": f"sources/{source}.swift", "name": source},
        }

    def write_item(self, repository: Path, item: dict) -> None:
        path = repository / "Registry" / "items" / f"{item['name']}.json"
        path.write_text(json.dumps(item))

    def load_item(self, name: str) -> dict:
        path = self.repository / "Registry" / "items" / f"{name}.json"
        return json.loads(path.read_text())

    def save_item(self, name: str, item: dict) -> None:
        path = self.repository / "Registry" / "items" / f"{name}.json"
        path.write_text(json.dumps(item))


if __name__ == "__main__":
    unittest.main()
