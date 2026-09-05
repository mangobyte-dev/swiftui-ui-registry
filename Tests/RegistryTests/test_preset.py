"""Preset codes are the handoff artifact between the website, the Showcase,
and the installer, so every implementation must reproduce the same codes.

The pinned vectors (`preset_vectors.json`) are checked here against the
Python reference in both directions and against the website's TypeScript
codec through Node's type stripping (the Showcase's Swift codec runs the same
vectors in its own unit test). The CLI is exercised as a real subprocess:
`apply` writes a theme file a consumer owns, `resolve` reads it back, and an
edited file is not silently replaced.
"""

import json
import subprocess
import sys
import tempfile
import unittest
from pathlib import Path

REPOSITORY_ROOT = Path(__file__).resolve().parents[2]
sys.path.insert(0, str(REPOSITORY_ROOT / "Scripts"))

import preset  # noqa: E402

VECTORS = json.loads((REPOSITORY_ROOT / "Tests" / "RegistryTests" / "preset_vectors.json").read_text(encoding="utf-8"))
CLI = REPOSITORY_ROOT / "Scripts" / "preset.py"


class CodecTests(unittest.TestCase):
    def test_every_vector_encodes_and_decodes_to_its_pinned_code(self):
        for vector in VECTORS["vectors"]:
            with self.subTest(vector["name"]):
                self.assertEqual(preset.encode(vector["tuning"]), vector["code"])
                self.assertEqual(preset.decode(vector["code"]), vector["tuning"])

    def test_the_table_still_fits_the_documented_budget(self):
        # A resized or reordered field is a format change; the vectors would
        # break first, this names the reason.
        self.assertEqual(sum(field["bits"] for field in preset.FIELDS), 61)
        self.assertEqual(VECTORS["alphabet"], preset.ALPHABET)
        self.assertEqual(VECTORS["version"], preset.VERSION)
        self.assertEqual(VECTORS["maxLength"], preset.MAX_LENGTH)
        for field in preset.FIELDS:
            count = len(field["values"]) if "values" in field else field["count"]
            self.assertLessEqual(count, 2 ** field["bits"], field["key"])
        self.assertEqual(preset.encode(preset.DEFAULT_TUNING), VECTORS["vectors"][0]["code"])

    def test_values_off_the_slider_grid_snap_and_clamp(self):
        tuning = {**preset.DEFAULT_TUNING, "cardRadius": 18.3, "surfaceOpacity": 0.9, "compactSpacing": 1}
        decoded = preset.decode(preset.encode(tuning))
        self.assertEqual(decoded["cardRadius"], 18.0)
        self.assertEqual(decoded["surfaceOpacity"], 0.2)
        self.assertEqual(decoded["compactSpacing"], 4.0)
        # A named accent carries no custom color, and a custom accent needs one.
        self.assertNotIn("customAccent", preset.decode(preset.encode({**preset.DEFAULT_TUNING, "accent": "teal"})))
        with self.assertRaises(preset.PresetError):
            preset.encode({**preset.DEFAULT_TUNING, "accent": "custom"})
        with self.assertRaises(preset.PresetError):
            preset.encode({**preset.DEFAULT_TUNING, "accent": "magenta"})

    def test_invalid_codes_are_refused_not_guessed(self):
        for code in ("", "a", "b13GkaOXWwIC", "a13GkaOXWwI-", "a" + "z" * 22, "aF"):
            with self.subTest(code=code):
                self.assertIsNone(preset.decode(code))
        # aF: accent index 15 has no value, so the code is invalid rather than clamped.
        self.assertFalse(preset.is_preset_code("aF") and preset.decode("aF") is not None)
        self.assertEqual(preset.preset_code_in("--preset a13GkaOXWwIC"), "a13GkaOXWwIC")
        self.assertEqual(preset.preset_code_in("  a13GkaOXWwIC \n"), "a13GkaOXWwIC")
        self.assertIsNone(preset.preset_code_in("zz"))

    def test_random_codes_round_trip(self):
        import random
        generator = random.Random(7)
        for _ in range(200):
            tuning = preset.random_tuning(generator)
            self.assertEqual(preset.decode(preset.encode(tuning)), tuning)

    def test_the_website_codec_reproduces_every_vector(self):
        process = subprocess.run(
            ["node", "--experimental-strip-types", str(REPOSITORY_ROOT / "Tests" / "RegistryTests" / "preset_vectors_check.ts"),
             str(REPOSITORY_ROOT / "Tests" / "RegistryTests" / "preset_vectors.json")],
            capture_output=True, text=True, check=True,
        )
        results = json.loads(process.stdout)
        for vector, result in zip(VECTORS["vectors"], results):
            with self.subTest(vector["name"]):
                self.assertEqual(result["encoded"], vector["code"])
                self.assertEqual(result["decoded"], vector["tuning"])
                self.assertEqual(result["swift"], preset.swift_source(vector["tuning"]))
        self.assertEqual(len(results), len(VECTORS["vectors"]) + 1)
        self.assertEqual(results[-1]["rejected"], [True] * 6)
        self.assertEqual(results[-1]["isCode"], ["a0", "a13GkaOXWwIC", "a13GkaOXWwIC", None])
        self.assertTrue(results[-1]["bareIsCode"])


class SwiftTests(unittest.TestCase):
    def test_swift_source_parses_back_for_every_vector(self):
        for vector in VECTORS["vectors"]:
            with self.subTest(vector["name"]):
                parsed = preset.parse_swift(preset.swift_source(vector["tuning"]))
                self.assertEqual(preset.encode(parsed), vector["code"])
                parsed = preset.parse_swift(preset.theme_file(vector["tuning"], vector["code"]))
                self.assertEqual(preset.encode(parsed), vector["code"])

    def test_swift_spells_each_accent_the_way_the_tune_tab_exports_it(self):
        by_name = {vector["name"].split(":")[0]: vector["tuning"] for vector in VECTORS["vectors"]}
        graphite = preset.swift_source(by_name["Graphite"])
        self.assertIn("accent: .primary,", graphite)
        self.assertIn("onAccent: Color(uiColor: .systemBackground),", graphite)
        self.assertIn("surface: .primary.opacity(0.050),", graphite)
        amber = preset.swift_source(by_name["Amber"])
        self.assertIn("accent: .yellow,", amber)
        self.assertIn("onAccent: .black,", amber)
        system = preset.swift_source(by_name["System"])
        self.assertNotIn("accent:", system.split("onAccent")[0])
        self.assertIn("onAccent: .white,", system)
        tuned = preset.swift_source(by_name["Tuned metrics off the defaults"])
        self.assertIn("borderWidth: 1.5,", tuned)
        self.assertIn("emphasizedBorderWidth: 3,", tuned)
        self.assertIn("disabledOpacity: 0.350,", tuned)
        self.assertIn("border: .primary.opacity(0.160),", tuned)
        custom = preset.swift_source(by_name["Custom accent without a dark accent"])
        self.assertIn("accent: Color(red: 0.349, green: 0.341, blue: 0.839),", custom)
        self.assertTrue(system.endswith("ContentView()\n    .registryTheme(theme)"))

    def test_dual_custom_accent_keeps_light_and_dark_apart(self):
        tuning = {**preset.DEFAULT_TUNING, "accent": "custom", "customAccent": "#112233", "customAccentDark": "#AABBCC"}
        parsed = preset.parse_swift(preset.swift_source(tuning))
        self.assertEqual(parsed["customAccent"], "#112233")
        self.assertEqual(parsed["customAccentDark"], "#AABBCC")

    def test_a_labeled_subset_keeps_the_base_and_preset_words_map_to_colors(self):
        parsed = preset.parse_swift("RegistryTheme(accent: .rose, disabledOpacity: 0.3, metrics: RegistryMetrics(cardRadius: 20))")
        self.assertEqual(parsed["accent"], "pink")
        self.assertEqual(parsed["disabledOpacity"], 0.3)
        self.assertEqual(parsed["cardRadius"], 20.0)
        self.assertEqual(parsed["standardSpacing"], 16.0)
        self.assertEqual(preset.parse_swift("RegistryTheme(onAccent: .white)")["accent"], "system")
        with self.assertRaises(preset.PresetError):
            preset.parse_swift("nothing here")
        with self.assertRaises(preset.PresetError):
            preset.parse_swift("RegistryTheme(accent: .magenta)")

    def test_theme_file_imports_uikit_only_when_the_swift_needs_it(self):
        self.assertNotIn("import UIKit", preset.theme_file(preset.DEFAULT_TUNING, "a0"))
        ink = {**preset.DEFAULT_TUNING, "accent": "ink"}
        self.assertIn("import UIKit", preset.theme_file(ink, "a0"))
        self.assertIn("static let app = RegistryTheme(", preset.theme_file(ink, "a0"))


class CliTests(unittest.TestCase):
    @staticmethod
    def run_cli(*arguments):
        return subprocess.run([sys.executable, str(CLI), *arguments], capture_output=True, text=True)

    def test_apply_writes_a_theme_file_that_resolves_back_and_refuses_to_clobber_edits(self):
        code = VECTORS["vectors"][5]["code"]  # Amber
        with tempfile.TemporaryDirectory() as directory:
            destination = Path(directory) / "Components"
            applied = self.run_cli("apply", code, "--destination", str(destination))
            self.assertEqual(applied.returncode, 0, applied.stderr)
            target = destination / preset.THEME_FILE
            self.assertTrue(target.is_file())
            text = target.read_text(encoding="utf-8")
            self.assertIn(f"// swiftui-registry preset {code}", text)
            self.assertIn("accent: .yellow,", text)
            self.assertIn("onAccent: .black,", text)
            self.assertIn(".registryTheme(.app)", text)

            resolved = self.run_cli("resolve", str(destination), "--json")
            self.assertEqual(resolved.returncode, 0, resolved.stderr)
            self.assertEqual(json.loads(resolved.stdout)["code"], code)

            # Untouched: a second apply replaces it with another code.
            other = VECTORS["vectors"][2]["code"]  # Indigo
            self.assertEqual(self.run_cli("apply", other, "--destination", str(destination)).returncode, 0)
            self.assertEqual(json.loads(self.run_cli("resolve", str(destination), "--json").stdout)["code"], other)

            # Edited by hand: refused without --force, and the edit is what resolves.
            target.write_text(text.replace("cardRadius: 16", "cardRadius: 20"), encoding="utf-8")
            refused = self.run_cli("apply", other, "--destination", str(destination))
            self.assertEqual(refused.returncode, 2)
            self.assertIn("edited since it was written", refused.stderr)
            self.assertIn("cardRadius: 20", target.read_text(encoding="utf-8"))
            self.assertNotEqual(json.loads(self.run_cli("resolve", str(destination), "--json").stdout)["code"], code)
            forced = self.run_cli("apply", other, "--destination", str(destination), "--force")
            self.assertEqual(forced.returncode, 0, forced.stderr)
            self.assertIn("accent: .indigo,", target.read_text(encoding="utf-8"))

    def test_decode_url_and_random_speak_the_same_code(self):
        code = VECTORS["vectors"][9]["code"]  # dual custom accent
        decoded = self.run_cli("decode", code)
        self.assertEqual(decoded.returncode, 0, decoded.stderr)
        self.assertIn("customAccentDark", decoded.stdout)
        self.assertIn("UIColor { traits in", decoded.stdout)
        self.assertIn(f"{preset.SITE_URL}/create?preset={code}", decoded.stdout)
        as_json = json.loads(self.run_cli("decode", code, "--json").stdout)
        self.assertEqual(as_json["tuning"], VECTORS["vectors"][9]["tuning"])
        self.assertEqual(self.run_cli("url", code).stdout.strip(), preset.preset_url(code))
        invalid = self.run_cli("decode", "nope")
        self.assertEqual(invalid.returncode, 2)
        self.assertIn("invalid preset code", invalid.stderr)
        first = self.run_cli("random", "--seed", "3").stdout.strip()
        self.assertEqual(first, self.run_cli("random", "--seed", "3").stdout.strip())
        self.assertIsNotNone(preset.decode(first))


if __name__ == "__main__":
    unittest.main()
