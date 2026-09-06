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



def phase_b(binary, scratch, registry):
    from unittest import TestLoader, TextTestRunner
    from unittest.mock import patch
    import test_mcp_server
    count = 0
    py_dest, swift_dest = scratch / "b-python", scratch / "b-swift"
    names_path = registry / "Examples/Showcase/SwiftUIRegistryShowcaseUITests/RegistryItemNames.swift"
    names_path.parent.mkdir(parents=True, exist_ok=True)
    normalize = lambda data: data.replace(str(py_dest).encode(), b"DESTINATION").replace(str(swift_dest).encode(), b"DESTINATION")
    for generator in ["catalog", "showcase-manifest", "site-data"]:
        folder = generator == "catalog"
        suffix = generator if folder else generator + ".out"
        outputs = []
        names = []
        for python, destination in [(True, py_dest), (False, swift_dest)]:
            output = destination / suffix
            command = [sys.executable, str(registry / "Scripts" / ("generate_" + generator.replace("-", "_") + ".py"))] if python else [str(binary), "generate", generator, "--registry", str(registry)]
            command += ["--output", str(output)]
            if generator == "site-data":
                command += ["--images", str(destination / "images")]
            if folder:
                output.mkdir(parents=True)
                (output / "stale.md").write_text("stale")
                (output / "keep.txt").write_text("keep")
            result = subprocess.run(command, capture_output=True)
            assert result.returncode == 0, (generator, result.stderr)
            outputs.append(result)
            if generator == "showcase-manifest":
                names.append(names_path.read_bytes())
        assert normalize(outputs[0].stdout) == normalize(outputs[1].stdout), generator
        assert outputs[0].stderr == outputs[1].stderr, generator
        assert tree(py_dest) == tree(swift_dest), generator
        if names:
            assert names[0] == names[1], "Showcase item names"
        count += 1
    print("Compared all three generators, both manifests, catalog cleanup, website JSON, and copied image bytes", flush=True)

    messages = []
    def call(tool, **arguments):
        messages.append({"jsonrpc": "2.0", "id": len(messages) + 1, "method": "tools/call", "params": {"name": tool, "arguments": arguments}})
    for version in ["2025-06-18", "2025-03-26", "2024-11-05", "1999-01-01"]:
        messages.append({"jsonrpc": "2.0", "id": len(messages) + 1, "method": "initialize", "params": {"protocolVersion": version}})
    for method in ["notifications/initialized", "ping", "tools/list", "no/such/method"]:
        messages.append({"jsonrpc": "2.0", "id": len(messages) + 1, "method": method})
    for query in ["", "dropdown", "nutrition dashboard", "no-such-item"]:
        call("search_items", query=query)
    call("search_items", query="", kind="block", platform="iOS", targetVersion="26.0")
    call("search_items", query="", platform="iOS", targetVersion="26.beta")
    index = json.loads((registry / "Registry/registry.json").read_text())
    for path in index["items"]:
        item = json.loads((registry / "Registry" / path).read_text())
        call("describe_item", name=item["name"])
        for tool in ["plan_install", "install_item", "install_item", "diff_item"]:
            call(tool, name=item["name"], destination="{destination}")
    for vector in json.loads((ROOT / "Tests/RegistryTests/preset_vectors.json").read_text())["vectors"]:
        call("describe_preset", code="--preset " + vector["code"])
        call("apply_preset", code=vector["code"], destination="{destination}", force=True)
    for tool in ["describe_item", "plan_install", "install_item", "diff_item"]:
        call(tool, name="no-such-item", destination="{destination}")
        call(tool, name=13, destination="{destination}")
    for code in ["not a code", "a", "a\\'", "a\n", "a" + "z" * 22]:
        call("describe_preset", code=code)
    call("apply_preset", code="a13GkaOXWwIF", destination="{destination}", force="yes")
    call("install_item", name="button", destination="{destination}", force=1)
    call("install_item", name="button", destination=13)
    call("search_items", query=3)
    call("search_items", kind=3)
    call("search_items", platform=3)
    call("search_items", targetVersion=3)
    call("unknown_tool")
    messages.append({"id": 10001, "method": "tools/call", "params": {"name": "search_items", "arguments": "invalid"}})
    messages.append({"id": 10002, "method": "tools/call", "params": {"name": "search_items", "arguments": []}})
    messages.append({"method": "ping"})
    def session(sequence):
        outputs = []
        for python, destination in [(True, py_dest), (False, swift_dest)]:
            command = [sys.executable, str(registry / "Scripts/mcp_server.py")] if python else [str(binary), "mcp", "--registry", str(registry)]
            payload = "\n".join(json.dumps(message).replace("{destination}", str(destination)) for message in sequence).encode() + b"\nnot json\n\xff\n\n"
            result = subprocess.run(command, input=payload, capture_output=True)
            assert result.returncode == 0, ("MCP exit", result.stderr)
            outputs.append(result)
        first, second = outputs
        if normalize(first.stdout) != normalize(second.stdout):
            left = normalize(first.stdout).splitlines()
            right = normalize(second.stdout).splitlines()
            for i, (a, b) in enumerate(zip(left, right)):
                if a != b:
                    raise AssertionError(("MCP wire", i, a[:2000], b[:2000]))
            raise AssertionError(("MCP line count", len(left), len(right)))
        assert first.stderr == second.stderr
        assert tree(py_dest) == tree(swift_dest), "MCP filesystem"
        return len(sequence) + 2
    count += session(messages)
    for destination in [py_dest, swift_dest]:
        (destination / "RegistryButtonStyle.swift").write_text("// edited\n")
        (destination / "RegistryTheme+App.swift").write_text("// edited theme\n")
    messages = []
    for tool in ["plan_install", "diff_item", "install_item"]:
        call(tool, name="button", destination="{destination}")
    call("apply_preset", code="a13GkaOXWwIF", destination="{destination}")
    call("install_item", name="button", destination="{destination}", force=True)
    call("apply_preset", code="a13GkaOXWwIF", destination="{destination}", force=True)
    count += session(messages)

    # Keep both stdin pipes open: prove replies do not wait for EOF, and metadata reloads.
    import select
    commands = [[sys.executable, str(registry / "Scripts/mcp_server.py")], [str(binary), "mcp", "--registry", str(registry)]]
    processes = [subprocess.Popen(command, stdin=subprocess.PIPE, stdout=subprocess.PIPE, stderr=subprocess.PIPE) for command in commands]
    metadata = registry / "Registry/items/button.json"
    original_metadata = metadata.read_bytes()
    try:
        for revision in ["First live edit.", "Second live edit."]:
            edited = json.loads(original_metadata)
            edited["description"] = revision
            metadata.write_text(json.dumps(edited))
            message = {"id": 20001, "method": "tools/call", "params": {"name": "describe_item", "arguments": {"name": "button"}}}
            replies = []
            for process in processes:
                process.stdin.write(json.dumps(message).encode() + b"\n")
                process.stdin.flush()
                assert select.select([process.stdout], [], [], 10)[0], "MCP did not respond before EOF"
                replies.append(process.stdout.readline())
            assert replies[0] == replies[1], "Persistent MCP wire"
            assert json.loads(replies[1])["result"]["structuredContent"]["description"] == revision
            count += 1
    finally:
        metadata.write_bytes(original_metadata)
        for process in processes:
            process.stdin.close()
            try:
                process.wait(timeout=10)
            except subprocess.TimeoutExpired:
                process.kill()
                process.wait()
            process.stdout.close()
            process.stderr.close()

    # The original test module and all its assertions remain unchanged.
    original_run = subprocess.run
    def swift_launch(command, *args, **kwargs):
        if command == [sys.executable, str(test_mcp_server.SERVER)]:
            command = [str(binary), "mcp", "--registry", str(ROOT)]
        return original_run(command, *args, **kwargs)
    with patch("subprocess.run", swift_launch):
        result = TextTestRunner(verbosity=1).run(TestLoader().loadTestsFromModule(test_mcp_server))
        assert result.wasSuccessful(), "Unchanged MCP tests failed against Swift"
    print(f"Compared {count} Phase B outputs; unchanged MCP tests passed against the Swift subprocess", flush=True)
    return count


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--binary", type=Path)
    parser.add_argument("--phase-b-only", action="store_true")
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
        if args.phase_b_only:
            total = phase_b(binary, scratch, registry)
            print(f"Phase B parity passed: {total} comparisons; MCP wire, generator bytes, images, and unchanged MCP assertions")
            return
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
        count += phase_b(binary, scratch, registry)
        print(f"Parity passed: {count} command pairs; stdout, stderr, exit status, complete file trees, receipts, bases, and merge artifacts")


if __name__ == "__main__":
    main()
