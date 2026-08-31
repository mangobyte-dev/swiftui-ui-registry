#!/usr/bin/env python3
"""Single structural validator for the SwiftUI registry catalog.

This module is the one place registry structure is enforced. The installer
validates the full registry through it before resolving, search loads items
through the same validated path, `Scripts/validate.py` exposes it as a CLI,
and `Tests/RegistryTests` exercises it directly. It mirrors the canonical
constraints in `Registry/schema.json` and reads that file for required keys,
allowed fields, enums, and patterns so the schema stays canonical.
"""

from __future__ import annotations

import json
import re
from dataclasses import dataclass, field
from pathlib import Path


@dataclass(frozen=True)
class ValidationIssue:
    """One structural defect, addressed by file location for actionable reports."""

    location: str
    message: str

    def __str__(self) -> str:
        return f"{self.location}: {self.message}"


# Platform floors are compared numerically by search; enforce 1 to 3 dot-separated
# non-negative integer parts so every declared floor is comparable.
_PLATFORM_FLOOR = re.compile(r"^[0-9]+(\.[0-9]+){0,2}$")


@dataclass
class _Catalog:
    repository_root: Path
    registry_root: Path
    schema: dict
    items: dict[str, dict] = field(default_factory=dict)
    locations: dict[str, str] = field(default_factory=dict)


def validate_registry(root: Path) -> list[ValidationIssue]:
    """Validate the whole catalog under ``root`` (the repository root)."""
    catalog, issues = _load_catalog(root)
    if catalog is None:
        return issues
    for name in catalog.items:
        issues.extend(_item_issues(catalog, name))
    issues.extend(_graph_issues(catalog, list(catalog.items)))
    return issues


def validate_item(root: Path, name: str) -> list[ValidationIssue]:
    """Validate one item and its dependency closure lazily."""
    catalog, issues = _load_catalog(root)
    if catalog is None or issues:
        return issues
    if name not in catalog.items:
        return [ValidationIssue("Registry/registry.json", f"unknown registry item: {name}")]
    closure = _closure(catalog, name)
    for member in closure:
        issues.extend(_item_issues(catalog, member))
    issues.extend(_graph_issues(catalog, closure))
    return issues


def _load_catalog(root: Path) -> tuple[_Catalog | None, list[ValidationIssue]]:
    issues: list[ValidationIssue] = []
    repository_root = Path(root).resolve()
    registry_root = repository_root / "Registry"
    schema = _read_json(registry_root / "schema.json", "Registry/schema.json", issues)
    index = _read_json(registry_root / "registry.json", "Registry/registry.json", issues)
    if schema is None or index is None:
        return None, issues

    location = "Registry/registry.json"
    if index.get("schemaVersion") != 1:
        issues.append(ValidationIssue(location, "schemaVersion must be 1"))
    if not isinstance(index.get("name"), str) or not index.get("name"):
        issues.append(ValidationIssue(location, "name must be a non-empty string"))
    listed = index.get("items")
    if not isinstance(listed, list) or not all(isinstance(entry, str) for entry in listed):
        issues.append(ValidationIssue(location, "items must be an array of relative item paths"))
        return None, issues

    catalog = _Catalog(repository_root, registry_root, schema)
    listed_paths: set[Path] = set()
    seen_entries: set[str] = set()
    for relative in listed:
        if relative in seen_entries:
            issues.append(ValidationIssue(location, f"item file listed more than once: {relative}"))
            continue
        seen_entries.add(relative)
        item_location = f"Registry/{relative}"
        path = _safe_join(registry_root, relative)
        if path is None:
            issues.append(ValidationIssue(location, f"unsafe item path: {relative}"))
            continue
        if not path.is_file():
            issues.append(ValidationIssue(location, f"listed item file does not exist: {relative}"))
            continue
        listed_paths.add(path)
        item = _read_json(path, item_location, issues)
        if item is None:
            continue
        name = item.get("name")
        if not isinstance(name, str) or not name:
            issues.append(ValidationIssue(item_location, "item document has no usable name"))
            continue
        if name in catalog.items:
            issues.append(ValidationIssue(item_location, f"duplicate registry item name: {name}"))
            continue
        catalog.items[name] = item
        catalog.locations[name] = item_location

    items_directory = registry_root / "items"
    if items_directory.is_dir():
        for path in sorted(items_directory.glob("*.json")):
            if path.resolve() not in listed_paths:
                issues.append(ValidationIssue(
                    f"Registry/items/{path.name}",
                    "item file exists but is not listed in registry.json",
                ))
    return catalog, issues


def _item_issues(catalog: _Catalog, name: str) -> list[ValidationIssue]:
    issues: list[ValidationIssue] = []
    item = catalog.items[name]
    location = catalog.locations[name]
    _check_shape(item, catalog.schema, location, issues)
    _check_declared_paths(item, catalog, location, issues)
    return issues


def _check_shape(item: dict, schema: dict, location: str, issues: list[ValidationIssue]) -> None:
    properties = schema["properties"]

    missing = sorted(set(schema["required"]) - item.keys())
    if missing:
        issues.append(ValidationIssue(location, f"missing required keys: {', '.join(missing)}"))
    undeclared = sorted(item.keys() - properties.keys())
    if undeclared:
        issues.append(ValidationIssue(location, f"undeclared keys: {', '.join(undeclared)}"))

    if "schemaVersion" in item and item["schemaVersion"] != properties["schemaVersion"]["const"]:
        issues.append(ValidationIssue(location, "schemaVersion must be 1"))
    _check_pattern(item, "version", properties["version"]["pattern"], location, issues)
    _check_pattern(item, "name", properties["name"]["pattern"], location, issues)

    kinds = properties["kind"]["enum"]
    kind = item.get("kind")
    if "kind" in item and kind not in kinds:
        issues.append(ValidationIssue(location, f"kind must be one of: {', '.join(kinds)}"))

    for key in ("description", "docs"):
        if key in item and (not isinstance(item[key], str) or not item[key].strip()):
            issues.append(ValidationIssue(location, f"{key} must be a non-empty string"))

    # Catalog gate: every item documents its public API at a call site. The
    # schema keeps `usage` an additive optional field within schema version 1;
    # this registry refuses to publish an item without it.
    usage = item.get("usage")
    if not isinstance(usage, str) or not usage.strip():
        issues.append(ValidationIssue(
            location, "every item requires a non-empty usage snippet"
        ))

    _check_object_array(
        item, "files", properties["files"]["items"], location, issues
    )
    _check_string_array(item, "registryDependencies", location, issues, unique=True)
    _check_object_array(
        item, "packageDependencies", properties["packageDependencies"]["items"], location, issues
    )
    _check_package_dependencies(
        item, properties["packageDependencies"]["items"], location, issues
    )
    _check_platforms(item, properties["platforms"], location, issues)
    _check_string_array(item, "tags", location, issues, unique=True)
    _check_string_array(item, "accessibility", location, issues, unique=False)
    _check_preview_shape(item, properties["preview"], location, issues)

    if kind == "recipe":
        docs = item.get("docs")
        if not isinstance(docs, str) or not docs.strip():
            issues.append(ValidationIssue(location, "recipe items require non-empty docs"))
        if item.get("files"):
            issues.append(ValidationIssue(location, "recipe items must declare empty files"))
    elif kind in kinds:
        if "preview" not in item:
            issues.append(ValidationIssue(location, "installable items require a preview"))
        files = item.get("files")
        if isinstance(files, list) and not files:
            issues.append(ValidationIssue(location, "installable items require at least one entry in files"))


def _check_pattern(
    item: dict, key: str, pattern: str, location: str, issues: list[ValidationIssue]
) -> None:
    if key not in item:
        return
    value = item[key]
    if not isinstance(value, str) or re.fullmatch(pattern, value) is None:
        issues.append(ValidationIssue(location, f"{key} must match {pattern}"))


def _check_string_array(
    item: dict, key: str, location: str, issues: list[ValidationIssue], *, unique: bool
) -> None:
    if key not in item:
        return
    value = item[key]
    if not isinstance(value, list) or not all(isinstance(entry, str) for entry in value):
        issues.append(ValidationIssue(location, f"{key} must be an array of strings"))
        return
    if unique and len(set(value)) != len(value):
        issues.append(ValidationIssue(location, f"{key} entries must be unique"))


def _check_object_array(
    item: dict, key: str, entry_schema: dict, location: str, issues: list[ValidationIssue]
) -> None:
    if key not in item:
        return
    value = item[key]
    if not isinstance(value, list):
        issues.append(ValidationIssue(location, f"{key} must be an array"))
        return
    for index, entry in enumerate(value):
        entry_location = f"{location} ({key}[{index}])"
        _check_object(entry, entry_schema, entry_location, issues)


def _check_object(entry: object, entry_schema: dict, location: str, issues: list[ValidationIssue]) -> None:
    if not isinstance(entry, dict):
        issues.append(ValidationIssue(location, "entry must be an object"))
        return
    missing = sorted(set(entry_schema["required"]) - entry.keys())
    if missing:
        issues.append(ValidationIssue(location, f"missing required keys: {', '.join(missing)}"))
    allowed = entry_schema["properties"].keys()
    undeclared = sorted(entry.keys() - allowed)
    if undeclared:
        issues.append(ValidationIssue(location, f"undeclared keys: {', '.join(undeclared)}"))
    for key in entry.keys() & allowed:
        declared = entry_schema["properties"][key]
        if declared.get("type") == "string" and not isinstance(entry[key], str):
            issues.append(ValidationIssue(location, f"{key} must be a string"))


def _check_package_dependencies(
    item: dict, entry_schema: dict, location: str, issues: list[ValidationIssue]
) -> None:
    """Enforce the actionable SwiftPM shape beyond the generic object check.

    An entry that carries a version requirement must also carry the
    machine-resolvable ``swiftPM`` rule so a consumer can act on the metadata
    instead of interpreting prose.
    """
    entries = item.get("packageDependencies")
    if not isinstance(entries, list):
        return
    swiftpm_schema = entry_schema["properties"]["swiftPM"]
    kinds = swiftpm_schema["properties"]["kind"]["enum"]
    version_pattern = swiftpm_schema["properties"]["minimumVersion"]["pattern"]
    for index, entry in enumerate(entries):
        if not isinstance(entry, dict):
            continue
        entry_location = f"{location} (packageDependencies[{index}])"
        source_url = entry.get("sourceURL")
        if source_url is not None and (not isinstance(source_url, str) or not source_url.strip()):
            issues.append(ValidationIssue(entry_location, "sourceURL must be a non-empty string"))
        requirement = entry.get("requirement")
        rule = entry.get("swiftPM")
        if isinstance(requirement, str) and requirement.strip() and rule is None:
            issues.append(ValidationIssue(
                entry_location,
                "a version requirement needs a machine-resolvable swiftPM rule",
            ))
        if rule is None:
            continue
        _check_object(rule, swiftpm_schema, entry_location, issues)
        if not isinstance(rule, dict):
            continue
        kind = rule.get("kind")
        if "kind" in rule and kind not in kinds:
            issues.append(ValidationIssue(
                entry_location, f"swiftPM kind must be one of: {', '.join(kinds)}"
            ))
        for key in ("minimumVersion", "maximumVersionExclusive"):
            value = rule.get(key)
            if isinstance(value, str) and re.fullmatch(version_pattern, value) is None:
                issues.append(ValidationIssue(
                    entry_location, f"swiftPM {key} must match {version_pattern}"
                ))
        if kind == "range" and "maximumVersionExclusive" not in rule:
            issues.append(ValidationIssue(
                entry_location, "swiftPM range requires maximumVersionExclusive"
            ))
        if kind in kinds and kind != "range" and "maximumVersionExclusive" in rule:
            issues.append(ValidationIssue(
                entry_location,
                f"swiftPM {kind} derives its upper bound; maximumVersionExclusive is only for range",
            ))


def _check_platforms(
    item: dict, platforms_schema: dict, location: str, issues: list[ValidationIssue]
) -> None:
    if "platforms" not in item:
        return
    platforms = item["platforms"]
    if not isinstance(platforms, list):
        issues.append(ValidationIssue(location, "platforms must be an array"))
        return
    if len(platforms) < platforms_schema["minItems"]:
        issues.append(ValidationIssue(location, "platforms must declare at least one platform"))
    names = platforms_schema["items"]["properties"]["name"]["enum"]
    for index, entry in enumerate(platforms):
        entry_location = f"{location} (platforms[{index}])"
        _check_object(entry, platforms_schema["items"], entry_location, issues)
        if not isinstance(entry, dict):
            continue
        if "name" in entry and entry["name"] not in names:
            issues.append(ValidationIssue(entry_location, f"name must be one of: {', '.join(names)}"))
        floor = entry.get("minimumVersion")
        if isinstance(floor, str) and _PLATFORM_FLOOR.fullmatch(floor) is None:
            issues.append(ValidationIssue(
                entry_location,
                f"minimumVersion must be 1 to 3 dot-separated numbers, got: {floor}",
            ))


def _check_preview_shape(
    item: dict, preview_schema: dict, location: str, issues: list[ValidationIssue]
) -> None:
    if "preview" not in item:
        return
    preview = item["preview"]
    preview_location = f"{location} (preview)"
    _check_object(preview, preview_schema, preview_location, issues)
    if not isinstance(preview, dict):
        return
    screenshots = preview.get("screenshots")
    if screenshots is None:
        return
    if not isinstance(screenshots, list) or not all(isinstance(entry, str) for entry in screenshots):
        issues.append(ValidationIssue(preview_location, "screenshots must be an array of strings"))
        return
    if len(set(screenshots)) != len(screenshots):
        issues.append(ValidationIssue(preview_location, "screenshots entries must be unique"))


def _check_declared_paths(
    item: dict, catalog: _Catalog, location: str, issues: list[ValidationIssue]
) -> None:
    files = item.get("files")
    if isinstance(files, list):
        for entry in files:
            if not isinstance(entry, dict):
                continue
            source = entry.get("source")
            if not isinstance(source, str):
                continue
            path = _safe_join(catalog.registry_root, source)
            if path is None:
                issues.append(ValidationIssue(location, f"unsafe source path: {source}"))
            elif not path.is_file():
                issues.append(ValidationIssue(location, f"declared source file does not exist: {source}"))

    preview = item.get("preview")
    if not isinstance(preview, dict):
        return
    source = preview.get("source")
    if isinstance(source, str):
        path = _safe_join(catalog.registry_root, source)
        if path is None:
            issues.append(ValidationIssue(location, f"unsafe preview source path: {source}"))
        elif not path.is_file():
            issues.append(ValidationIssue(location, f"preview source file does not exist: {source}"))
    screenshots = preview.get("screenshots")
    if not isinstance(screenshots, list):
        return
    for screenshot in screenshots:
        if not isinstance(screenshot, str):
            continue
        path = _safe_join(catalog.repository_root, screenshot)
        if path is None:
            issues.append(ValidationIssue(location, f"unsafe screenshot path: {screenshot}"))
        elif not path.is_file():
            issues.append(ValidationIssue(location, f"preview screenshot does not exist: {screenshot}"))


def _graph_issues(catalog: _Catalog, names: list[str]) -> list[ValidationIssue]:
    issues: list[ValidationIssue] = []
    for name in names:
        dependencies = catalog.items[name].get("registryDependencies")
        if not isinstance(dependencies, list):
            continue
        for dependency in dependencies:
            if not isinstance(dependency, str):
                continue
            target = catalog.items.get(dependency)
            if target is None:
                issues.append(ValidationIssue(
                    catalog.locations[name], f"unknown registry dependency: {dependency}"
                ))
            elif target.get("kind") == "recipe":
                issues.append(ValidationIssue(
                    catalog.locations[name],
                    f"depends on recipe {dependency}; recipes install nothing and cannot be dependencies",
                ))
    issues.extend(_cycle_issues(catalog, names))
    return issues


def _cycle_issues(catalog: _Catalog, names: list[str]) -> list[ValidationIssue]:
    issues: list[ValidationIssue] = []
    state: dict[str, int] = {}

    def visit(current: str, trail: list[str]) -> None:
        if state.get(current) == 2:
            return
        if state.get(current) == 1:
            cycle = trail[trail.index(current):] + [current]
            issues.append(ValidationIssue(
                catalog.locations[current], "dependency cycle: " + " -> ".join(cycle)
            ))
            return
        state[current] = 1
        dependencies = catalog.items[current].get("registryDependencies")
        if isinstance(dependencies, list):
            for dependency in dependencies:
                if isinstance(dependency, str) and dependency in catalog.items:
                    visit(dependency, trail + [current])
        state[current] = 2

    for name in names:
        visit(name, [])
    return issues


def _closure(catalog: _Catalog, name: str) -> list[str]:
    ordered: list[str] = []
    seen: set[str] = set()
    stack = [name]
    while stack:
        current = stack.pop()
        if current in seen:
            continue
        seen.add(current)
        ordered.append(current)
        dependencies = catalog.items[current].get("registryDependencies")
        if isinstance(dependencies, list):
            for dependency in dependencies:
                if isinstance(dependency, str) and dependency in catalog.items:
                    stack.append(dependency)
    return ordered


def _read_json(path: Path, location: str, issues: list[ValidationIssue]) -> dict | None:
    try:
        value = json.loads(path.read_text(encoding="utf-8"))
    except (OSError, json.JSONDecodeError) as error:
        issues.append(ValidationIssue(location, f"cannot read JSON: {error}"))
        return None
    if not isinstance(value, dict):
        issues.append(ValidationIssue(location, "expected a JSON object"))
        return None
    return value


def _safe_join(root: Path, value: str) -> Path | None:
    if not isinstance(value, str) or not value:
        return None
    relative = Path(value)
    if relative == Path(".") or relative.is_absolute() or ".." in relative.parts:
        return None
    candidate = (root / relative).resolve(strict=False)
    try:
        candidate.relative_to(root.resolve())
    except ValueError:
        return None
    return candidate
