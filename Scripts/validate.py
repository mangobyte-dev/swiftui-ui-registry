#!/usr/bin/env python3
"""Validate the registry catalog through the single shared validator."""

from __future__ import annotations

import argparse
import sys
from pathlib import Path

_SCRIPTS = Path(__file__).resolve().parent
if str(_SCRIPTS) not in sys.path:
    sys.path.insert(0, str(_SCRIPTS))

from registry_validation import validate_item, validate_registry


def main() -> int:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument(
        "items",
        nargs="*",
        help="Validate only these items and their dependency closures; default is the whole catalog",
    )
    arguments = parser.parse_args()

    repository_root = Path(__file__).resolve().parents[1]
    if arguments.items:
        issues = []
        for name in arguments.items:
            issues.extend(validate_item(repository_root, name))
    else:
        issues = validate_registry(repository_root)

    if issues:
        print(f"Registry validation failed with {len(issues)} issue(s):", file=sys.stderr)
        for issue in issues:
            print(f"- {issue}", file=sys.stderr)
        return 1
    scope = ", ".join(arguments.items) if arguments.items else "full catalog"
    print(f"Registry validation passed: {scope}")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
