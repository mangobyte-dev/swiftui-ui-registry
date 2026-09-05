"""The MCP adapter exposes the same registry operations the scripts do.

Spawns Scripts/mcp_server.py as a real subprocess over the stdio transport and
drives it with JSON-RPC, so the test proves the wire shape, not only the
Python functions: initialize negotiates a version, tools/list names every tool,
a search finds items by alias, a plan writes nothing, an install writes the
closure and the receipt, and a recipe reports that it installs nothing.
"""

import json
import subprocess
import sys
import tempfile
import unittest
from pathlib import Path

REPOSITORY_ROOT = Path(__file__).resolve().parents[2]
SERVER = REPOSITORY_ROOT / "Scripts" / "mcp_server.py"


class McpServerTests(unittest.TestCase):
    def run_session(self, messages):
        payload = "".join(json.dumps(message) + "\n" for message in messages)
        process = subprocess.run(
            [sys.executable, str(SERVER)],
            input=payload,
            capture_output=True,
            text=True,
            check=True,
        )
        responses = [json.loads(line) for line in process.stdout.splitlines() if line.strip()]
        return {response["id"]: response for response in responses if "id" in response}

    @staticmethod
    def call(identifier, tool, **arguments):
        return {"jsonrpc": "2.0", "id": identifier, "method": "tools/call",
                "params": {"name": tool, "arguments": arguments}}

    def test_initialize_lists_tools_and_answers_search_by_alias(self):
        responses = self.run_session([
            {"jsonrpc": "2.0", "id": 1, "method": "initialize",
             "params": {"protocolVersion": "2025-06-18", "capabilities": {}, "clientInfo": {"name": "test", "version": "0"}}},
            {"jsonrpc": "2.0", "method": "notifications/initialized"},
            {"jsonrpc": "2.0", "id": 2, "method": "tools/list"},
            self.call(3, "search_items", query="dropdown"),
            {"jsonrpc": "2.0", "id": 4, "method": "initialize",
             "params": {"protocolVersion": "1999-01-01", "capabilities": {}, "clientInfo": {"name": "old", "version": "0"}}},
            {"jsonrpc": "2.0", "id": 5, "method": "no/such/method"},
        ])
        self.assertEqual(responses[1]["result"]["protocolVersion"], "2025-06-18")
        self.assertIn("tools", responses[1]["result"]["capabilities"])
        names = {tool["name"] for tool in responses[2]["result"]["tools"]}
        self.assertEqual(names, {
            "search_items", "describe_item", "plan_install", "diff_item", "install_item",
            "describe_preset", "apply_preset",
        })
        for tool in responses[2]["result"]["tools"]:
            self.assertEqual(tool["inputSchema"]["type"], "object")
        search = responses[3]["result"]
        self.assertFalse(search["isError"])
        self.assertEqual(search["structuredContent"]["items"][0]["name"], "dropdown-menu")
        # An unsupported client version gets the server's latest, never an echo.
        self.assertEqual(responses[4]["result"]["protocolVersion"], "2025-06-18")
        self.assertEqual(responses[5]["error"]["code"], -32601)

    def test_plan_writes_nothing_and_install_writes_the_closure(self):
        with tempfile.TemporaryDirectory() as directory:
            destination = Path(directory) / "Components"
            responses = self.run_session([
                self.call(1, "plan_install", name="finance-overview", destination=str(destination)),
                self.call(2, "describe_item", name="finance-overview"),
            ])
            plan = responses[1]["result"]["structuredContent"]
            self.assertEqual([m["name"] for m in plan["closure"]], ["metric-card", "transaction-row", "empty", "finance-overview"])
            self.assertTrue(all(f["status"] == "new" for f in plan["files"]))
            self.assertFalse(destination.exists(), "plan_install must not create the destination")
            described = responses[2]["result"]["structuredContent"]
            self.assertTrue(described["installs"])
            self.assertIn("public struct FinanceOverview", described["files"][0]["content"])

            responses = self.run_session([
                self.call(1, "install_item", name="finance-overview", destination=str(destination)),
                self.call(2, "install_item", name="finance-overview", destination=str(destination)),
                self.call(3, "diff_item", name="finance-overview", destination=str(destination)),
            ])
            installed = responses[1]["result"]["structuredContent"]
            self.assertEqual(len(installed["installed"]), 4)
            self.assertTrue((destination / ".swiftui-registry" / "receipt.json").is_file())
            self.assertTrue(responses[2]["result"]["structuredContent"]["upToDate"])
            self.assertTrue(responses[3]["result"]["structuredContent"]["identical"])

            (destination / "MetricCard.swift").write_text("// edited\n")
            responses = self.run_session([
                self.call(1, "install_item", name="finance-overview", destination=str(destination)),
            ])
            refused = responses[1]["result"]
            self.assertTrue(refused["isError"], "modified owned source must be refused without force")
            self.assertIn("Refusing to overwrite owned source", refused["content"][0]["text"])

    def test_recipe_reports_native_guidance_instead_of_installing(self):
        with tempfile.TemporaryDirectory() as directory:
            responses = self.run_session([
                self.call(1, "install_item", name="tabs", destination=directory),
                self.call(2, "describe_item", name="tabs"),
                self.call(3, "describe_item", name="no-such-item"),
            ])
            guidance = responses[1]["result"]["structuredContent"]
            self.assertFalse(guidance["installs"])
            self.assertIn(".pickerStyle(.segmented)", guidance["guidance"])
            self.assertFalse(any(Path(directory).iterdir()), "a recipe must write nothing")
            self.assertFalse(responses[2]["result"]["structuredContent"]["installs"])
            self.assertTrue(responses[3]["result"]["isError"])


    def test_preset_tools_decode_and_write_the_theme_file(self):
        with tempfile.TemporaryDirectory() as directory:
            destination = str(Path(directory) / "Components")
            responses = self.run_session([
                self.call(1, "describe_preset", code="--preset a13GkaOXWwIa"),
                self.call(2, "apply_preset", code="a13GkaOXWwIa", destination=destination),
                self.call(3, "describe_preset", code="not a code"),
                self.call(4, "apply_preset", code="a13GkaOXWwIF", destination=destination, force="yes"),
            ])
            described = responses[1]["result"]["structuredContent"]
            self.assertFalse(responses[1]["result"]["isError"])
            self.assertEqual(described["code"], "a13GkaOXWwIa")
            self.assertEqual(described["tuning"]["accent"], "yellow")
            self.assertTrue(described["tuning"]["darkLabelOnAccent"])
            self.assertIn("accent: .yellow,", described["swift"])
            self.assertTrue(described["url"].endswith("/create?preset=a13GkaOXWwIa"))

            applied = responses[2]["result"]["structuredContent"]
            self.assertFalse(responses[2]["result"]["isError"])
            theme_file = Path(applied["file"])
            self.assertEqual(theme_file, Path(destination) / "RegistryTheme+App.swift")
            self.assertIn("static let app = RegistryTheme(", theme_file.read_text(encoding="utf-8"))
            self.assertIn(".registryTheme(.app)", applied["nextSteps"][1])

            self.assertTrue(responses[3]["result"]["isError"])
            self.assertIn("invalid preset code", responses[3]["result"]["content"][0]["text"])
            self.assertTrue(responses[4]["result"]["isError"])
            self.assertIn("force must be a boolean", responses[4]["result"]["content"][0]["text"])


if __name__ == "__main__":
    unittest.main()
