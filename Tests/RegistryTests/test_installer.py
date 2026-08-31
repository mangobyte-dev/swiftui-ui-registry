import importlib.util
import json
import re
import subprocess
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
RecipeGuidance = INSTALLER_MODULE.RecipeGuidance

RECIPE_NAMES = {
    "aspect-ratio",
    "direction",
    "native-select",
    "radio-group",
    "slider",
    "switch",
    "tabs",
}


class InstallerTests(unittest.TestCase):
    def setUp(self):
        self.installer = Installer(REPOSITORY_ROOT)

    def test_button_installs_a_native_style_instead_of_a_wrapper_control(self):
        self.assertEqual(self.installer.resolve("button"), ["button"])

        with tempfile.TemporaryDirectory() as directory:
            destination = Path(directory)
            installed = self.installer.install("button", destination)
            source = (destination / "RegistryButtonStyle.swift").read_text()

            self.assertEqual(len(installed), 1)
            self.assertIn("public struct RegistryButtonStyle: ButtonStyle", source)
            self.assertNotIn("struct RegistryButton: View", source)

    def test_badge_installs_a_modifier_that_preserves_native_content(self):
        self.assertEqual(self.installer.resolve("badge"), ["badge"])

        with tempfile.TemporaryDirectory() as directory:
            destination = Path(directory)
            installed = self.installer.install("badge", destination)
            source = (destination / "RegistryBadge.swift").read_text()

            self.assertEqual(len(installed), 1)
            self.assertIn("func registryBadge(", source)
            self.assertNotIn("struct RegistryBadge: View", source)

    def test_button_group_installs_its_native_button_style_dependency_first(self):
        self.assertEqual(
            self.installer.resolve("button-group"),
            ["button", "button-group"],
        )

        with tempfile.TemporaryDirectory() as directory:
            destination = Path(directory)
            installed = self.installer.install("button-group", destination)
            source = (destination / "RegistryButtonGroupStyle.swift").read_text()

            self.assertEqual(len(installed), 2)
            self.assertIn("public struct RegistryButtonGroupStyle: ControlGroupStyle", source)
            self.assertIn("ControlGroup(configuration)", source)
            self.assertNotIn("struct RegistryButtonGroup: View", source)

    def test_card_installs_a_group_box_style_instead_of_a_wrapper_view(self):
        self.assertEqual(self.installer.resolve("card"), ["card"])

        with tempfile.TemporaryDirectory() as directory:
            destination = Path(directory)
            installed = self.installer.install("card", destination)
            source = (destination / "RegistryCardStyle.swift").read_text()

            self.assertEqual(len(installed), 1)
            self.assertIn("public struct RegistryCardStyle: GroupBoxStyle", source)
            self.assertNotIn("struct RegistryCard: View", source)

    def test_schema_declares_every_top_level_item_field(self):
        schema = json.loads(
            (REPOSITORY_ROOT / "Registry" / "schema.json").read_text()
        )
        declared_fields = set(schema["properties"])

        for item_path in (REPOSITORY_ROOT / "Registry" / "items").glob("*.json"):
            with self.subTest(item=item_path.name):
                item_fields = set(json.loads(item_path.read_text()))
                self.assertEqual(
                    item_fields - declared_fields,
                    set(),
                    "The canonical schema forbids undeclared item fields.",
                )

    def test_preview_metadata_resolves_to_declared_source_and_screenshots(self):
        for item in self.installer.items.values():
            if item["kind"] == "recipe":
                continue
            with self.subTest(item=item["name"]):
                preview = item["preview"]
                source = REPOSITORY_ROOT / "Registry" / preview["source"]
                self.assertIn(
                    f'#Preview("{preview["name"]}")',
                    source.read_text(),
                )
                # Screenshot and preview path existence is enforced on every
                # load by the shared validator; see test_validation.py.

    def test_every_stage_one_roadmap_item_is_registered_with_its_native_seam(self):
        roadmap = (REPOSITORY_ROOT / "docs" / "component-roadmap.md").read_text()
        stage_one = roadmap.split("### Stage 1 mapping (built)", 1)[1].split(
            "### Forms and data entry candidates", 1
        )[0]
        names = re.findall(r"\| `([^`]+)` \|", stage_one)
        expected_markers = {
            "aspect-ratio": ".aspectRatio(",
            "badge": "func registryBadge(",
            "button": "ButtonStyle",
            "button-group": "ControlGroupStyle",
            "card": "GroupBoxStyle",
            "checkbox": "ToggleStyle",
            "input": "TextFieldStyle",
            "label": "LabelStyle",
            "progress": "ProgressViewStyle",
            "radio-group": ".pickerStyle(.inline)",
            "select": ".pickerStyle(.menu)",
            "separator": "func registrySeparator(",
            "slider": ".controlSize(",
            "spinner": "ProgressViewStyle",
            "switch": ".toggleStyle(.switch)",
            "tabs": ".pickerStyle(.segmented)",
            "textarea": "func registryTextArea(",
            "toggle": "ToggleStyle",
            "toggle-group": "func registryToggleGroup(",
            "native-select": ".pickerStyle(.menu)",
            "direction": "layoutDirection",
        }

        self.assertEqual(set(names), set(expected_markers))
        for name in names:
            with self.subTest(item=name):
                item = self.installer.items[name]
                if item["kind"] == "recipe":
                    # A recipe's guidance is the snippet plus the prose that
                    # explains it, exactly what install.py prints and what the
                    # catalog page shows; the snippet lives in `usage` only.
                    evidence = f"{item['usage']}\n\n{item['docs']}"
                else:
                    evidence = (
                        REPOSITORY_ROOT / "Registry" / item["preview"]["source"]
                    ).read_text()
                self.assertIn(expected_markers[name], evidence)
                self.assertNotRegex(evidence, r"public struct \w+: View")

    def test_item_value_gate_separates_recipes_from_installable_items(self):
        kinds = {name: item["kind"] for name, item in self.installer.items.items()}

        self.assertEqual(
            {name for name, kind in kinds.items() if kind == "recipe"},
            RECIPE_NAMES,
        )
        self.assertEqual(len([kind for kind in kinds.values() if kind == "component"]), 17)
        self.assertEqual(len([kind for kind in kinds.values() if kind == "block"]), 2)
        # The per-item gate (a recipe is docs-only guidance with no files; an
        # installable item ships files plus a preview and never depends on a
        # recipe) is enforced on every registry load by the shared validator;
        # test_validation.py proves each violation is rejected.

    def test_recipe_resolution_fails_loudly_with_its_guidance(self):
        with self.assertRaises(RecipeGuidance) as caught:
            self.installer.resolve("tabs")
        self.assertIn(".pickerStyle(.segmented)", caught.exception.docs)

        with tempfile.TemporaryDirectory() as directory:
            with self.assertRaises(RecipeGuidance):
                self.installer.install("tabs", Path(directory))
            self.assertFalse(list(Path(directory).iterdir()))

    def test_recipe_install_command_prints_guidance_and_exits_with_code_two(self):
        with tempfile.TemporaryDirectory() as directory:
            process = subprocess.run(
                [
                    sys.executable,
                    str(REPOSITORY_ROOT / "Scripts" / "install.py"),
                    "switch",
                    "--destination",
                    directory,
                ],
                check=False,
                capture_output=True,
                text=True,
            )

            self.assertEqual(process.returncode, 2)
            self.assertIn(".toggleStyle(.switch)", process.stdout)
            self.assertIn(
                "recipe items are native guidance; nothing to install",
                process.stderr,
            )
            self.assertFalse(list(Path(directory).iterdir()))

    def test_textarea_requires_and_applies_its_accessibility_label(self):
        item = self.installer.items["textarea"]
        source = (
            REPOSITORY_ROOT / "Registry" / item["preview"]["source"]
        ).read_text()

        self.assertIn("accessibilityLabel: Text", source)
        self.assertIn(".accessibilityLabel(accessibilityLabel)", source)

    def test_aspect_ratio_guidance_labels_media_and_hides_decorative_symbols(self):
        guidance = self._recipe_guidance("aspect-ratio")

        self.assertIn(".accessibilityHidden(true)", guidance)
        self.assertIn('.accessibilityLabel("Video placeholder")', guidance)
        self.assertIn('.accessibilityLabel("Avatar placeholder")', guidance)

    def test_slider_guidance_keeps_native_control_and_hides_decorative_symbols(self):
        guidance = self._recipe_guidance("slider")

        self.assertIn(".tint(_:)", guidance)
        self.assertIn(".controlSize(_:)", guidance)
        self.assertEqual(guidance.count(".accessibilityHidden(true)"), 2)
        self.assertNotIn("registrySlider", guidance)

    def _recipe_guidance(self, name: str) -> str:
        """What a caller receives for a recipe: the snippet plus its prose.

        The snippet is carried once, in `usage`; `docs` explains why the native
        API is the whole treatment. install.py prints both and the catalog page
        renders both, so both together are the guidance under test.
        """
        item = self.installer.items[name]
        return f"{item['usage']}\n\n{item['docs']}"

    def test_invalid_previews_reuse_the_negative_theme_color(self):
        for name in ["input", "textarea"]:
            with self.subTest(item=name):
                item = self.installer.items[name]
                source = (
                    REPOSITORY_ROOT / "Registry" / item["preview"]["source"]
                ).read_text()
                self.assertIn(".foregroundStyle(theme.negative)", source)
                self.assertNotIn(".foregroundStyle(.red)", source)

    def test_every_foundation_token_has_two_semantic_registry_consumers(self):
        consumer_contract = {
            "surface": ("theme.surface", ["badge", "input"]),
            "border": ("theme.border", ["badge", "separator"]),
            "positive": ("theme.positive", ["badge", "progress"]),
            "negative": ("theme.negative", ["badge", "button"]),
            "disabledOpacity": (
                "theme.disabledOpacity",
                ["button", "checkbox", "input", "select", "textarea"],
            ),
            "compactSpacing": (
                "theme.metrics.compactSpacing",
                ["badge", "label"],
            ),
            "standardSpacing": (
                "theme.metrics.standardSpacing",
                ["card", "metric-card"],
            ),
            "sectionSpacing": (
                "theme.metrics.sectionSpacing",
                ["finance-overview", "nutrition-overview"],
            ),
            "controlHorizontalPadding": (
                "theme.metrics.controlHorizontalPadding",
                ["input", "select"],
            ),
            "borderWidth": (
                "theme.metrics.borderWidth",
                ["badge", "button", "checkbox", "input", "select", "textarea"],
            ),
            "emphasizedBorderWidth": (
                "theme.metrics.emphasizedBorderWidth",
                ["input", "textarea"],
            ),
            "controlRadius": (
                "theme.metrics.controlRadius",
                ["button", "input", "select", "textarea"],
            ),
            "cardRadius": (".registrySurface()", ["card", "metric-card"]),
            "minimumHitSize": (
                "RegistryMetrics.minimumHitSize",
                ["button", "checkbox", "select"],
            ),
        }
        foundations = (
            REPOSITORY_ROOT
            / "Sources"
            / "SwiftUIRegistryFoundations"
            / "RegistryTheme.swift"
        ).read_text()
        foundation_tokens = set(
            re.findall(r"public (?:var|static let) (\w+):", foundations)
        ) - {"metrics"}

        self.assertEqual(set(consumer_contract), foundation_tokens)
        for token, (marker, names) in consumer_contract.items():
            self.assertGreaterEqual(len(names), 2)
            for name in names:
                with self.subTest(token=token, item=name):
                    item = self.installer.items[name]
                    source = (
                        REPOSITORY_ROOT / "Registry" / item["preview"]["source"]
                    ).read_text()
                    self.assertIn(marker, source)

    def test_every_stage_one_preview_covers_adaptive_environments(self):
        roadmap = (REPOSITORY_ROOT / "docs" / "component-roadmap.md").read_text()
        stage_one = roadmap.split("### Stage 1 mapping (built)", 1)[1].split(
            "### Forms and data entry candidates", 1
        )[0]
        names = re.findall(r"\| `([^`]+)` \|", stage_one)

        for name in names:
            item = self.installer.items[name]
            if item["kind"] == "recipe":
                continue
            with self.subTest(item=name):
                source = (
                    REPOSITORY_ROOT / "Registry" / item["preview"]["source"]
                ).read_text()
                self.assertIn("preferredColorScheme(.dark)", source)
                self.assertIn("layoutDirection", source)
                self.assertIn("dynamicTypeSize(.accessibility", source)

    def test_stage_one_interaction_states_are_explicit_and_cannot_regress_silently(self):
        required_state_evidence = {
            "enabled": ("button", "isEnabled"),
            "pressed": ("button", "configuration.isPressed"),
            "focused": ("input", "isFocused"),
            "selected": ("checkbox", "isSelected"),
            "disabled": ("button", ".disabled(true)"),
            "invalid": ("input", "isInvalid"),
        }

        for state, (name, marker) in required_state_evidence.items():
            with self.subTest(state=state, item=name):
                item = self.installer.items[name]
                source = (
                    REPOSITORY_ROOT / "Registry" / item["preview"]["source"]
                ).read_text()
                self.assertIn(marker, source)

    def test_showcase_installs_exact_canonical_sources_for_every_indexed_item(self):
        destination = (
            REPOSITORY_ROOT
            / "Examples"
            / "Showcase"
            / "SwiftUIRegistryShowcasePackage"
            / "Sources"
            / "SwiftUIRegistryShowcaseFeature"
            / "Installed"
        )

        for item in self.installer.items.values():
            for file in item["files"]:
                with self.subTest(item=item["name"], target=file["target"]):
                    source = REPOSITORY_ROOT / "Registry" / file["source"]
                    target = destination / file["target"]
                    self.assertTrue(target.is_file())
                    self.assertEqual(target.read_bytes(), source.read_bytes())

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
            self.assertEqual(receipt["items"]["finance-overview"]["version"], "0.2.1")
            self.assertEqual(
                receipt["items"]["finance-overview"]["packageDependencies"],
                [
                    {
                        "package": "SwiftUIRegistry",
                        "product": "SwiftUIRegistryFoundations",
                        "requirement": "0.x",
                        "sourceURL": "https://github.com/mangobyte-dev/swiftui-ui-registry.git",
                        "swiftPM": {"kind": "upToNextMinor", "minimumVersion": "0.1.0"},
                    }
                ],
            )
            self.assertEqual(set(receipt["files"]), {
                "MetricCard.swift",
                "TransactionRow.swift",
                "FinanceOverview.swift",
            })
            self.assertFalse(list((destination / ".swiftui-registry").rglob("*.swift")))

    def test_install_prints_the_actionable_package_instruction(self):
        # The consumer must receive the package URL, resolvable requirement, and
        # product, not only the prose requirement string.
        with tempfile.TemporaryDirectory() as directory:
            process = subprocess.run(
                [
                    sys.executable,
                    str(REPOSITORY_ROOT / "Scripts" / "install.py"),
                    "button",
                    "--destination",
                    directory,
                ],
                check=False,
                capture_output=True,
                text=True,
            )

            self.assertEqual(process.returncode, 0)
            self.assertIn(
                "requires: add package "
                "https://github.com/mangobyte-dev/swiftui-ui-registry.git "
                "(from 0.1.0 up to the next minor version) "
                "and link product SwiftUIRegistryFoundations",
                process.stdout,
            )

    def test_receipt_never_invents_a_package_requirement(self):
        # An item that declares no package dependencies must record an empty
        # list, so a receipt audit distinguishes "none required" from "unknown".
        with tempfile.TemporaryDirectory() as repository, tempfile.TemporaryDirectory() as output:
            self.make_registry(Path(repository), "source\n")
            destination = Path(output)
            Installer(Path(repository)).install("example", destination)

            receipt = json.loads(
                (destination / ".swiftui-registry" / "receipt.json").read_text()
            )
            self.assertEqual(receipt["items"]["example"]["packageDependencies"], [])

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

    def test_plan_for_block_prints_closure_statuses_and_package_lines(self):
        with tempfile.TemporaryDirectory() as directory:
            destination = Path(directory).resolve()
            process = subprocess.run(
                [
                    sys.executable,
                    str(REPOSITORY_ROOT / "Scripts" / "install.py"),
                    "finance-overview",
                    "--plan",
                    "--destination",
                    directory,
                ],
                check=False,
                capture_output=True,
                text=True,
            )

            self.assertEqual(process.returncode, 0)
            self.assertIn(
                "closure:\n"
                "  metric-card 0.1.1 (component)\n"
                "  transaction-row 0.3.0 (component)\n"
                "  finance-overview 0.2.1 (block)\n",
                process.stdout,
            )
            self.assertIn(
                "files:\n"
                f"  new metric-card: {destination / 'MetricCard.swift'}\n"
                f"  new transaction-row: {destination / 'TransactionRow.swift'}\n"
                f"  new finance-overview: {destination / 'FinanceOverview.swift'}\n",
                process.stdout,
            )
            self.assertIn(
                "  requires: add package "
                "https://github.com/mangobyte-dev/swiftui-ui-registry.git "
                "(from 0.1.0 up to the next minor version) "
                "and link product SwiftUIRegistryFoundations",
                process.stdout,
            )
            self.assertIn("  ok: no collisions", process.stdout)
            self.assertIn("next steps:", process.stdout)
            self.assertIn("plan only: nothing was written", process.stdout)
            self.assertFalse(list(Path(directory).iterdir()))

    def test_plan_statuses_track_receipt_and_registry_state(self):
        with tempfile.TemporaryDirectory() as repository, tempfile.TemporaryDirectory() as output:
            source = self.make_registry(Path(repository), "base\n")
            installer = Installer(Path(repository))
            destination = Path(output)
            installer.install("example", destination)

            self.assertEqual(
                [entry.status for entry in installer.inspect_plan("example", destination)],
                ["up-to-date"],
            )

            (destination / "Example.swift").write_text("consumer\n")
            self.assertEqual(
                [entry.status for entry in installer.inspect_plan("example", destination)],
                ["modified-would-require-force"],
            )

            (destination / "Example.swift").write_text("base\n")
            source.write_text("registry\n")
            self.assertEqual(
                [entry.status for entry in installer.inspect_plan("example", destination)],
                ["would-merge"],
            )

    def test_plan_for_recipe_prints_guidance_and_installs_nothing(self):
        with tempfile.TemporaryDirectory() as directory:
            process = subprocess.run(
                [
                    sys.executable,
                    str(REPOSITORY_ROOT / "Scripts" / "install.py"),
                    "switch",
                    "--plan",
                    "--destination",
                    directory,
                ],
                check=False,
                capture_output=True,
                text=True,
            )

            self.assertEqual(process.returncode, 0)
            self.assertIn(".toggleStyle(.switch)", process.stdout)
            self.assertIn(
                "plan: switch is a recipe; native guidance only; nothing installs",
                process.stdout,
            )
            self.assertFalse(list(Path(directory).iterdir()))

    def test_diff_exits_zero_when_installed_source_matches_canonical(self):
        with tempfile.TemporaryDirectory() as directory:
            destination = Path(directory).resolve()
            self.installer.install("metric-card", destination)

            process = subprocess.run(
                [
                    sys.executable,
                    str(REPOSITORY_ROOT / "Scripts" / "install.py"),
                    "metric-card",
                    "--diff",
                    "--destination",
                    directory,
                ],
                check=False,
                capture_output=True,
                text=True,
            )

            self.assertEqual(process.returncode, 0)
            self.assertIn(
                f"identical metric-card: {destination / 'MetricCard.swift'}",
                process.stdout,
            )

    def test_diff_reports_local_modification_with_the_changed_hunk(self):
        with tempfile.TemporaryDirectory() as directory:
            destination = Path(directory).resolve()
            self.installer.install("metric-card", destination)
            owned = destination / "MetricCard.swift"
            owned.write_text(owned.read_text() + "// consumer edit\n")

            process = subprocess.run(
                [
                    sys.executable,
                    str(REPOSITORY_ROOT / "Scripts" / "install.py"),
                    "metric-card",
                    "--diff",
                    "--destination",
                    directory,
                ],
                check=False,
                capture_output=True,
                text=True,
            )

            self.assertEqual(process.returncode, 1)
            self.assertIn("--- owned/MetricCard.swift", process.stdout)
            self.assertIn(
                "+++ incoming/sources/components/MetricCard.swift",
                process.stdout,
            )
            self.assertIn("@@", process.stdout)
            self.assertIn("-// consumer edit", process.stdout)

    def test_diff_fails_loudly_without_an_installation_receipt(self):
        with tempfile.TemporaryDirectory() as directory:
            process = subprocess.run(
                [
                    sys.executable,
                    str(REPOSITORY_ROOT / "Scripts" / "install.py"),
                    "metric-card",
                    "--diff",
                    "--destination",
                    directory,
                ],
                check=False,
                capture_output=True,
                text=True,
            )

            self.assertEqual(process.returncode, 2)
            self.assertIn("Installation receipt is missing", process.stderr)
            self.assertFalse(list(Path(directory).iterdir()))

    def test_plan_and_diff_write_nothing_to_an_installed_destination(self):
        def snapshot(root: Path) -> dict:
            return {
                str(path.relative_to(root)): (
                    path.read_bytes() if path.is_file() else "dir"
                )
                for path in sorted(root.rglob("*"))
            }

        with tempfile.TemporaryDirectory() as directory:
            destination = Path(directory).resolve()
            self.installer.install("finance-overview", destination)
            (destination / "MetricCard.swift").write_text("// consumer edit\n")
            before = snapshot(destination)

            for flag in ["--plan", "--diff"]:
                subprocess.run(
                    [
                        sys.executable,
                        str(REPOSITORY_ROOT / "Scripts" / "install.py"),
                        "finance-overview",
                        flag,
                        "--destination",
                        directory,
                    ],
                    check=False,
                    capture_output=True,
                    text=True,
                )
            self.installer.inspect_plan("finance-overview", destination)
            self.installer.diff("finance-overview", destination)

            self.assertEqual(snapshot(destination), before)

    @staticmethod
    def make_registry(repository: Path, source_content: str) -> Path:
        source = repository / "Registry" / "sources" / "Example.swift"
        source.parent.mkdir(parents=True)
        source.write_text(source_content)
        (repository / "Registry" / "schema.json").write_text(
            (REPOSITORY_ROOT / "Registry" / "schema.json").read_text()
        )
        item = {
            "schemaVersion": 1,
            "version": "0.1.0",
            "name": "example",
            "kind": "component",
            "description": "Test item.",
            "usage": "Example()",
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
