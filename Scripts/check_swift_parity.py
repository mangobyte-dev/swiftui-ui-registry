#!/usr/bin/env python3
"""Temporary Phase A/B oracle: compare real commands and every destination byte.

Run after swift build. Python remains authoritative until this proof and the
Swift tests pass. Paths alone are normalized, because the two tools must write
separate destinations. No source, receipt, base, or conflict bytes are normalized.
"""
import argparse
import json
import shutil
import subprocess
import sys
import tempfile
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
sys.path.insert(0, str(ROOT / "Scripts"))
sys.path.insert(0, str(ROOT / "Tests" / "RegistryTests"))
from test_installer import InstallerTests


def tree(path):
    return {str(p.relative_to(path)): p.read_bytes() if p.is_file() else None
            for p in sorted(path.rglob("*"))}


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--binary", type=Path)
    args = parser.parse_args()
    binary = args.binary or Path(subprocess.check_output(
        ["swift", "build", "--package-path", str(ROOT), "--show-bin-path"], text=True).strip()) / "swiftui-registry"
    count = 0
    with tempfile.TemporaryDirectory(prefix="registry-parity-") as temporary:
        scratch = Path(temporary).resolve()
        registry = scratch / "clone"
        shutil.copytree(ROOT / "Registry", registry / "Registry")
        shutil.copytree(ROOT / "docs" / "images", registry / "docs" / "images")
        shutil.copytree(ROOT / "Scripts", registry / "Scripts")
        py_dest, swift_dest = scratch / "python", scratch / "swift"

        def compare(command, *arguments, root=registry, files=False):
            nonlocal count
            py_args = [str(py_dest) if x == "{destination}" else x for x in arguments]
            sw_args = [str(swift_dest) if x == "{destination}" else x for x in arguments]
            first = subprocess.run([sys.executable, str(root / "Scripts" / (command + ".py")), *py_args], capture_output=True)
            second = subprocess.run([str(binary), command, *sw_args,
                *(["--registry", str(root)] if command != "preset" else [])], capture_output=True)
            normalize = lambda b: b.replace(str(py_dest.resolve()).encode(), b"DESTINATION").replace(str(swift_dest.resolve()).encode(), b"DESTINATION")
            assert first.returncode == second.returncode, (command, arguments, first.returncode, second.returncode, second.stderr)
            assert normalize(first.stdout) == normalize(second.stdout), (command, arguments, "stdout", first.stdout[:2000], second.stdout[:2000])
            assert normalize(first.stderr) == normalize(second.stderr), (command, arguments, "stderr", first.stderr[:2000], second.stderr[:2000])
            if files:
                left, right = tree(py_dest), tree(swift_dest)
                assert left == right, (command, arguments, "tree", [k for k in left.keys() | right.keys() if left.get(k) != right.get(k)])
            count += 1
            if count % 100 == 0:
                print(f"Compared {count} command pairs", flush=True)

        compare("validate")
        index = json.loads((registry / "Registry" / "registry.json").read_text())
        items = [json.loads((registry / "Registry" / path).read_text()) for path in index["items"]]
        for item in items:
            name = item["name"]
            compare("validate", name)
            compare("search", name)
            compare("search", name, "--format", "names")
            compare("install", name, "--destination", "{destination}", "--plan", files=True)
            compare("install", name, "--destination", "{destination}", files=True)
            if item["kind"] != "recipe":
                compare("install", name, "--destination", "{destination}", files=True)
                compare("install", name, "--destination", "{destination}", "--diff", files=True)
                compare("install", name, "--destination", "{destination}", "--update", files=True)
                compare("install", name, "--destination", "{destination}", "--force", files=True)
        for query in [[], ["nutrition", "dashboard"], ["dropdown"], ["shimmer"], ["does-not-exist"]]:
            for kind in ["component", "block", "flow", "recipe"]:
                for version in ["25.0", "26", "26.0.0", "27.0"]:
                    compare("search", *query, "--kind", kind, "--platform", "iOS", "--target-version", version)
        for vector in json.loads((ROOT / "Tests" / "RegistryTests" / "preset_vectors.json").read_text())["vectors"]:
            code = vector["code"]
            compare("preset", "decode", code)
            compare("preset", "decode", code, "--json")
            compare("preset", "url", code)
            compare("preset", "apply", code, "--destination", "{destination}", "--force", files=True)
            compare("preset", "resolve", "{destination}", "--json")
        for seed in [*range(-10, 100), 2**128, -(2**129 + 31)]:
            compare("preset", "random", "--seed", str(seed))
        for code in ["", "a", "b13GkaOXWwIC", "a13GkaOXWwI-", "a" + "z" * 22, "aF", "a" + "z" * 21]:
            compare("preset", "decode", code)
        for mode in [[], ["--force"], ["--plan"], ["--update"], ["--diff"]]:
            compare("install", "missing-item", "--destination", "{destination}", *mode, files=True)

        # Bidirectional interoperability, clean merge, conflict preflight, and recovery.
        fixture = scratch / "fixture"
        base = "consumer = false\nline2\nline3\nline4\nline5\nregistry = false\n"
        source = InstallerTests.make_registry(fixture, base)
        shutil.copytree(ROOT / "Scripts", fixture / "Scripts")
        for initial in ["python", "swift"]:
            for path in [py_dest, swift_dest]:
                shutil.rmtree(path)
            source.write_text(base)
            # Both tools update a receipt written by the other implementation.
            initial_command = [sys.executable, str(fixture / "Scripts" / "install.py")] if initial == "python" else [str(binary), "install", "--registry", str(fixture)]
            subprocess.run([*initial_command, "example", "--destination", str(py_dest)], check=True, capture_output=True)
            shutil.copytree(py_dest, swift_dest)
            compare("install", "example", "--destination", "{destination}", "--diff", root=fixture, files=True)
            for path in [py_dest, swift_dest]:
                (path / "Example.swift").write_text(base.replace("consumer = false", "consumer = true"))
            compare("install", "example", "--destination", "{destination}", root=fixture, files=True)
            compare("install", "example", "--destination", "{destination}", "--plan", root=fixture, files=True)
            compare("install", "example", "--destination", "{destination}", "--diff", root=fixture, files=True)
            source.write_text(base.replace("registry = false", "registry = true"))
            compare("install", "example", "--destination", "{destination}", "--update", root=fixture, files=True)
            compare("install", "example", "--destination", "{destination}", root=fixture, files=True)
            for path in [py_dest, swift_dest]:
                (path / "Example.swift").write_text("value = consumer\n")
            source.write_text("value = registry\n")
            compare("install", "example", "--destination", "{destination}", "--update", root=fixture, files=True)
            compare("install", "example", "--destination", "{destination}", "--force", root=fixture, files=True)
            compare("install", "example", "--destination", "{destination}", "--update", root=fixture, files=True)
        print(f"Parity passed: {count} command pairs; stdout, stderr, exit status, complete file trees, receipts, bases, and merge artifacts")


if __name__ == "__main__":
    main()
