#!/usr/bin/env python3
"""A Model Context Protocol server over the registry, with no dependencies.

Exposes the same deterministic operations the scripts offer (search, describe,
plan, diff, install) as MCP tools over the stdio transport, so an agent working
inside a consuming app can discover and install items without leaving its
editor. It is a thin adapter: every tool calls the Installer and search code
the CLI uses, so behavior cannot diverge.

Configure it in an MCP client, from any directory:

    {
      "mcpServers": {
        "swiftui-registry": {
          "command": "python3",
          "args": ["/path/to/swiftui-cn/Scripts/mcp_server.py"]
        }
      }
    }

Protocol: JSON-RPC 2.0, newline-delimited UTF-8 on stdin and stdout, per the
MCP specification (2025-06-18, stdio transport). Logs go to stderr only.
"""

from __future__ import annotations

import json
import sys
from pathlib import Path

_SCRIPTS = Path(__file__).resolve().parent
if str(_SCRIPTS) not in sys.path:
    sys.path.insert(0, str(_SCRIPTS))

from install import Installer, RecipeGuidance, RegistryError
from preset import PresetError, apply as apply_preset, describe as describe_preset, preset_code_in
from search import search_items

PROTOCOL_VERSIONS = ("2025-06-18", "2025-03-26", "2024-11-05")
SERVER_INFO = {"name": "swiftui-registry", "title": "SwiftUI Registry", "version": "0.1.0"}
INSTRUCTIONS = (
    "Search the registry, describe an item to read its usage snippet and source, plan an"
    " install to see the dependency closure and target writes, then install. Installs copy"
    " Swift source into the destination and write a receipt; they never edit project files."
    " Recipes are native guidance and install nothing. A preset code from the website's"
    " /create page or the Showcase's tuning panel describes a RegistryTheme; apply_preset"
    " writes it as RegistryTheme+App.swift next to the installed items."
)

_DESTINATION = {
    "type": "string",
    "description": "Folder inside the consuming target's sources, absolute or relative to the client's working directory",
}

TOOLS = [
    {
        "name": "search_items",
        "title": "Search registry items",
        "description": "Find components, blocks, and recipes by name, alias, tag, or description. Every query term must match.",
        "inputSchema": {
            "type": "object",
            "properties": {
                "query": {"type": "string", "description": "Space-separated terms; empty lists everything"},
                "kind": {"type": "string", "enum": ["component", "block", "flow", "recipe"]},
                "platform": {"type": "string", "description": "Platform name such as iOS"},
                "targetVersion": {"type": "string", "description": "Deployment target such as 26.0"},
            },
        },
        "annotations": {"readOnlyHint": True, "idempotentHint": True},
    },
    {
        "name": "describe_item",
        "title": "Describe an item",
        "description": "Metadata, the call-site usage snippet, native guidance for recipes, the dependency closure, package requirements, and the canonical Swift source.",
        "inputSchema": {
            "type": "object",
            "properties": {"name": {"type": "string"}},
            "required": ["name"],
        },
        "annotations": {"readOnlyHint": True, "idempotentHint": True},
    },
    {
        "name": "plan_install",
        "title": "Plan an install",
        "description": "Resolve like a real install and report every target write with its status (new, up-to-date, modified-would-require-force, would-merge) plus package requirements. Writes nothing.",
        "inputSchema": {
            "type": "object",
            "properties": {"name": {"type": "string"}, "destination": _DESTINATION},
            "required": ["name", "destination"],
        },
        "annotations": {"readOnlyHint": True, "idempotentHint": True},
    },
    {
        "name": "diff_item",
        "title": "Diff owned source",
        "description": "Unified diff of each receipt-backed owned file against the canonical registry source. Requires an existing installation receipt.",
        "inputSchema": {
            "type": "object",
            "properties": {"name": {"type": "string"}, "destination": _DESTINATION},
            "required": ["name", "destination"],
        },
        "annotations": {"readOnlyHint": True, "idempotentHint": True},
    },
    {
        "name": "install_item",
        "title": "Install an item",
        "description": "Copy the item and its dependency closure into the destination and write the receipt. Refuses to overwrite modified owned source unless force is true. Never edits project files.",
        "inputSchema": {
            "type": "object",
            "properties": {
                "name": {"type": "string"},
                "destination": _DESTINATION,
                "force": {"type": "boolean", "default": False},
            },
            "required": ["name", "destination"],
        },
        "annotations": {"readOnlyHint": False, "destructiveHint": True, "idempotentHint": True},
    },
    {
        "name": "describe_preset",
        "title": "Describe a preset code",
        "description": "Decode a preset code into its theme knobs, the RegistryTheme Swift it stands for, and its website URL.",
        "inputSchema": {
            "type": "object",
            "properties": {"code": {"type": "string", "description": "A preset code such as a13GkaOXWwIF, with or without a --preset prefix"}},
            "required": ["code"],
        },
        "annotations": {"readOnlyHint": True, "idempotentHint": True},
    },
    {
        "name": "apply_preset",
        "title": "Apply a preset code",
        "description": "Write RegistryTheme+App.swift for the code into the destination, declaring RegistryTheme.app to apply once at the scene root. Refuses to replace a theme file edited by hand unless force is true.",
        "inputSchema": {
            "type": "object",
            "properties": {
                "code": {"type": "string"},
                "destination": _DESTINATION,
                "force": {"type": "boolean", "default": False},
            },
            "required": ["code", "destination"],
        },
        "annotations": {"readOnlyHint": False, "destructiveHint": True, "idempotentHint": True},
    },
]


class Server:
    def __init__(self, repository_root: Path) -> None:
        self.repository_root = repository_root
        self._installer: Installer | None = None

    @property
    def installer(self) -> Installer:
        # Loaded lazily and re-read per call so a metadata edit is picked up
        # without restarting the server; validation runs on every load.
        self._installer = Installer(self.repository_root)
        return self._installer

    # MARK: JSON-RPC

    def serve(self) -> None:
        for line in sys.stdin.buffer:
            line = line.strip()
            if not line:
                continue
            try:
                message = json.loads(line.decode("utf-8"))
            except (UnicodeDecodeError, json.JSONDecodeError):
                self._send({"jsonrpc": "2.0", "id": None, "error": {"code": -32700, "message": "Parse error"}})
                continue
            response = self.handle(message)
            if response is not None:
                self._send(response)

    def handle(self, message: dict) -> dict | None:
        method = message.get("method")
        identifier = message.get("id")
        params = message.get("params") or {}
        if method is None:
            return None  # a response to a server request; this server sends none
        try:
            if method == "initialize":
                result = self._initialize(params)
            elif method == "ping":
                result = {}
            elif method == "tools/list":
                result = {"tools": TOOLS}
            elif method == "tools/call":
                result = self._call(params)
            elif method.startswith("notifications/"):
                return None
            else:
                return self._error(identifier, -32601, f"Method not found: {method}")
        except _InvalidParams as error:
            return self._error(identifier, -32602, str(error))
        if identifier is None:
            return None
        return {"jsonrpc": "2.0", "id": identifier, "result": result}

    def _initialize(self, params: dict) -> dict:
        requested = params.get("protocolVersion")
        version = requested if requested in PROTOCOL_VERSIONS else PROTOCOL_VERSIONS[0]
        return {
            "protocolVersion": version,
            "capabilities": {"tools": {"listChanged": False}},
            "serverInfo": SERVER_INFO,
            "instructions": INSTRUCTIONS,
        }

    def _call(self, params: dict) -> dict:
        name = params.get("name")
        arguments = params.get("arguments") or {}
        if not isinstance(arguments, dict):
            raise _InvalidParams("arguments must be an object")
        handler = {
            "search_items": self._search,
            "describe_item": self._describe,
            "plan_install": self._plan,
            "diff_item": self._diff,
            "install_item": self._install,
            "describe_preset": self._describe_preset,
            "apply_preset": self._apply_preset,
        }.get(name)
        if handler is None:
            raise _InvalidParams(f"Unknown tool: {name}")
        try:
            structured = handler(arguments)
        except RecipeGuidance as guidance:
            structured = {
                "item": guidance.name,
                "kind": "recipe",
                "installs": False,
                "guidance": guidance.guidance,
            }
        except (RegistryError, PresetError) as error:
            return _tool_error(str(error))
        except (TypeError, ValueError) as error:
            return _tool_error(f"Invalid arguments: {error}")
        return {
            "content": [{"type": "text", "text": json.dumps(structured, indent=2)}],
            "structuredContent": structured,
            "isError": False,
        }

    # MARK: Tools

    def _search(self, arguments: dict) -> dict:
        matches = search_items(
            self.installer,
            _string(arguments, "query", ""),
            kind=_optional_string(arguments, "kind"),
            platform=_optional_string(arguments, "platform"),
            target_version=_optional_string(arguments, "targetVersion"),
        )
        return {"items": [
            {key: match[key] for key in ("name", "kind", "version", "description", "score", "registryDependencies", "tags", "aliases")}
            for match in matches
        ]}

    def _describe(self, arguments: dict) -> dict:
        installer = self.installer
        name = _string(arguments, "name")
        item = installer.items.get(name)
        if item is None:
            raise RegistryError(f"Unknown registry item: {name}")
        described = {
            key: item.get(key)
            for key in ("name", "kind", "version", "description", "usage", "docs", "tags", "aliases", "platforms", "accessibility", "registryDependencies")
        }
        if item["kind"] == "recipe":
            described["installs"] = False
            return described
        described["installs"] = True
        described["installOrder"] = installer.resolve(name)
        described["packageRequirements"] = [
            {
                "instruction": Installer.dependency_instruction(entry),
                "manifest": "\n".join(Installer.dependency_manifest_snippet(entry)),
                "xcode": Installer.dependency_xcode_instruction(entry),
            }
            for entry in installer.package_requirements(name)
        ]
        described["files"] = [
            {
                "source": file["source"],
                "target": file["target"],
                "content": (installer.registry_root / file["source"]).read_text(encoding="utf-8"),
            }
            for file in item["files"]
        ]
        return described

    def _plan(self, arguments: dict) -> dict:
        installer = self.installer
        name = _string(arguments, "name")
        destination = _destination(arguments)
        entries = installer.inspect_plan(name, destination)
        return {
            "item": name,
            "destination": str(destination.resolve()),
            "closure": [
                {"name": member, "version": installer.items[member]["version"], "kind": installer.items[member]["kind"]}
                for member in installer.resolve(name)
            ],
            "files": [
                {"item": entry.file.item, "target": str(entry.file.target), "status": entry.status}
                for entry in entries
            ],
            "packageRequirements": [
                Installer.dependency_instruction(entry) for entry in installer.package_requirements(name)
            ],
            "collisions": [str(entry.file.target) for entry in entries if entry.status == "modified-would-require-force"],
            "stale": [str(entry.file.target) for entry in entries if entry.status == "would-merge"],
            "nextSteps": [
                "Add each package requirement to the consuming project; the installer never edits project files",
                "Ensure the destination folder is a member of the consuming build target",
                f"Call install_item with name {name} and this destination",
            ],
        }

    def _diff(self, arguments: dict) -> dict:
        name = _string(arguments, "name")
        entries = self.installer.diff(name, _destination(arguments))
        return {
            "item": name,
            "identical": all(not entry.diff for entry in entries),
            "files": [
                {"item": entry.file.item, "target": str(entry.file.target), "diff": entry.diff}
                for entry in entries
            ],
        }

    def _install(self, arguments: dict) -> dict:
        installer = self.installer
        name = _string(arguments, "name")
        force = arguments.get("force", False)
        if not isinstance(force, bool):
            raise ValueError("force must be a boolean")
        installed = installer.install(name, _destination(arguments), force=force)
        return {
            "item": name,
            "installed": [{"item": file.item, "target": str(file.target)} for file in installed],
            "upToDate": not installed,
            "packageRequirements": [
                {
                    "instruction": Installer.dependency_instruction(entry),
                    "manifest": "\n".join(Installer.dependency_manifest_snippet(entry)),
                    "xcode": Installer.dependency_xcode_instruction(entry),
                }
                for entry in installer.package_requirements(name)
            ],
        }

    def _describe_preset(self, arguments: dict) -> dict:
        return describe_preset(_preset_code(arguments))

    def _apply_preset(self, arguments: dict) -> dict:
        code = _preset_code(arguments)
        force = arguments.get("force", False)
        if not isinstance(force, bool):
            raise ValueError("force must be a boolean")
        target = apply_preset(code, _destination(arguments), force=force)
        return {
            "code": code,
            "file": str(target),
            "nextSteps": [
                "Ensure the destination folder is a member of the consuming build target",
                "Apply the theme once at the scene root: ContentView().registryTheme(.app)",
            ],
        }

    # MARK: Transport

    @staticmethod
    def _send(message: dict) -> None:
        sys.stdout.write(json.dumps(message, separators=(",", ":")) + "\n")
        sys.stdout.flush()

    @staticmethod
    def _error(identifier, code: int, message: str) -> dict:
        return {"jsonrpc": "2.0", "id": identifier, "error": {"code": code, "message": message}}


class _InvalidParams(ValueError):
    pass


def _tool_error(message: str) -> dict:
    return {"content": [{"type": "text", "text": message}], "isError": True}


def _string(arguments: dict, key: str, default: str | None = None) -> str:
    value = arguments.get(key, default)
    if not isinstance(value, str):
        raise ValueError(f"{key} must be a string")
    return value


def _optional_string(arguments: dict, key: str) -> str | None:
    value = arguments.get(key)
    if value is None:
        return None
    if not isinstance(value, str):
        raise ValueError(f"{key} must be a string")
    return value


def _destination(arguments: dict) -> Path:
    return Path(_string(arguments, "destination")).expanduser()


def _preset_code(arguments: dict) -> str:
    code = preset_code_in(_string(arguments, "code"))
    if code is None:
        raise PresetError(f"invalid preset code: {arguments.get('code')!r}")
    return code


def main() -> int:
    Server(Path(__file__).resolve().parents[1]).serve()
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
