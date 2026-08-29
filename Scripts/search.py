#!/usr/bin/env python3
"""Search SwiftUI registry metadata with deterministic JSON output."""

from __future__ import annotations

import argparse
import json
import re
from pathlib import Path

from install import Installer, RegistryError


def search_items(
    installer: Installer,
    query: str = "",
    *,
    kind: str | None = None,
    platform: str | None = None,
    target_version: str | None = None,
) -> list[dict]:
    query_terms = _terms(query)
    matches: list[dict] = []

    for item in installer.items.values():
        if kind is not None and item["kind"] != kind:
            continue
        compatible_platforms = _compatible_platforms(item, platform, target_version)
        if platform is not None and not compatible_platforms:
            continue

        name_terms = _terms(item["name"])
        tag_terms = {term for tag in item["tags"] for term in _terms(tag)}
        description_terms = _terms(item["description"])
        searchable = name_terms | tag_terms | description_terms | {item["kind"]}
        if not query_terms.issubset(searchable):
            continue

        score = sum(
            30 if term in name_terms else 20 if term in tag_terms else 5
            for term in query_terms
        )
        if query.strip().lower() == item["name"]:
            score += 100

        matches.append({
            "name": item["name"],
            "version": item["version"],
            "kind": item["kind"],
            "description": item["description"],
            "score": score,
            "registryDependencies": item["registryDependencies"],
            "packageDependencies": item["packageDependencies"],
            "platforms": compatible_platforms,
            "tags": item["tags"],
            "accessibility": item["accessibility"],
            "preview": item["preview"],
        })

    return sorted(matches, key=lambda result: (-result["score"], result["name"]))


def _compatible_platforms(item: dict, platform: str | None, target_version: str | None) -> list[dict]:
    platforms = item["platforms"]
    if platform is None:
        return platforms

    requested = platform.casefold()
    target = _version(target_version) if target_version is not None else None
    return [
        candidate
        for candidate in platforms
        if candidate["name"].casefold() == requested
        and (target is None or _version(candidate["minimumVersion"]) <= target)
    ]


def _terms(value: str) -> set[str]:
    return set(re.findall(r"[a-z0-9]+", value.lower()))


def _version(value: str) -> tuple[int, ...]:
    try:
        parts = [int(part) for part in value.split(".")]
    except ValueError as error:
        raise RegistryError(f"Invalid platform version: {value}") from error
    if not parts or len(parts) > 3 or any(part < 0 for part in parts):
        raise RegistryError(f"Invalid platform version: {value}")
    return tuple(parts + [0] * (3 - len(parts)))


def main() -> int:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("query", nargs="*", help="Terms that must all match metadata")
    parser.add_argument("--kind", choices=["component", "block", "flow"])
    parser.add_argument("--platform")
    parser.add_argument("--target-version")
    parser.add_argument("--format", choices=["json", "names"], default="json")
    arguments = parser.parse_args()

    repository_root = Path(__file__).resolve().parents[1]
    try:
        matches = search_items(
            Installer(repository_root),
            " ".join(arguments.query),
            kind=arguments.kind,
            platform=arguments.platform,
            target_version=arguments.target_version,
        )
    except RegistryError as error:
        parser.error(str(error))

    if arguments.format == "names":
        for match in matches:
            print(match["name"])
    else:
        print(json.dumps(matches, indent=2, sort_keys=True))
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
