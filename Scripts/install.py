#!/usr/bin/env python3
"""Install and update source-owned SwiftUI registry items."""

from __future__ import annotations

import argparse
import hashlib
import json
import shutil
import subprocess
import tempfile
from dataclasses import dataclass
from pathlib import Path


class RegistryError(RuntimeError):
    pass


@dataclass(frozen=True)
class PlannedFile:
    item: str
    source: Path
    target: Path


@dataclass(frozen=True)
class UpdateResult:
    file: PlannedFile
    status: str


@dataclass(frozen=True)
class _UpdateDecision:
    file: PlannedFile
    target_content: bytes
    base_content: bytes
    status: str


class Installer:
    receipt_schema_version = 1

    def __init__(self, repository_root: Path) -> None:
        self.repository_root = repository_root.resolve()
        self.registry_root = self.repository_root / "Registry"
        index = self._read_json(self.registry_root / "registry.json")
        if index.get("schemaVersion") != 1:
            raise RegistryError("Unsupported registry schema version")

        self.registry_name = index.get("name", "unknown")
        self.items: dict[str, dict] = {}
        for relative_path in index.get("items", []):
            item_path = self._safe_join(self.registry_root, relative_path)
            item = self._read_json(item_path)
            self._validate_item(item, item_path)
            self._validate_preview_files(item, item_path)
            name = item["name"]
            if name in self.items:
                raise RegistryError(f"Duplicate registry item: {name}")
            self.items[name] = item

    def resolve(self, name: str) -> list[str]:
        ordered: list[str] = []
        visiting: set[str] = set()
        visited: set[str] = set()

        def visit(current: str) -> None:
            if current in visited:
                return
            if current in visiting:
                raise RegistryError(f"Registry dependency cycle at {current}")
            item = self.items.get(current)
            if item is None:
                raise RegistryError(f"Unknown registry item: {current}")

            visiting.add(current)
            for dependency in item["registryDependencies"]:
                visit(dependency)
            visiting.remove(current)
            visited.add(current)
            ordered.append(current)

        visit(name)
        return ordered

    def plan(self, name: str, destination: Path) -> list[PlannedFile]:
        destination = destination.resolve()
        planned: list[PlannedFile] = []
        targets: set[Path] = set()

        for item_name in self.resolve(name):
            for file in self.items[item_name]["files"]:
                source = self._safe_join(self.registry_root, file["source"])
                target = self._safe_join(destination, file["target"])
                if not source.is_file():
                    raise RegistryError(f"Missing source file: {source}")
                if target in targets:
                    raise RegistryError(f"Multiple files target {target}")
                targets.add(target)
                planned.append(PlannedFile(item_name, source, target))

        return planned

    def install(self, name: str, destination: Path, force: bool = False) -> list[PlannedFile]:
        destination = destination.resolve()
        planned = self.plan(name, destination)
        receipt = self._read_receipt(destination)
        receipt_files = receipt["files"]

        conflicts: list[Path] = []
        for file in planned:
            if not file.target.exists() or force:
                continue
            target = self._target_key(file.target, destination)
            record = receipt_files.get(target)
            if not self._matches_receipt(file, record, destination):
                conflicts.append(file.target)

        if conflicts:
            joined = "\n".join(str(path) for path in conflicts)
            raise RegistryError(f"Refusing to overwrite owned source:\n{joined}")

        installed: list[PlannedFile] = []
        for file in planned:
            content = file.source.read_bytes()
            if not file.target.exists() or force:
                file.target.parent.mkdir(parents=True, exist_ok=True)
                file.target.write_bytes(content)
                installed.append(file)
            self._record_file(receipt, file, destination, content, content)

        self._record_items(receipt, name)
        self._write_receipt(destination, receipt)
        return installed

    def update(self, name: str, destination: Path) -> list[UpdateResult]:
        destination = destination.resolve()
        planned = self.plan(name, destination)
        receipt = self._read_receipt(destination, require_existing=True)
        decisions: list[_UpdateDecision] = []
        conflicts: list[tuple[PlannedFile, bytes]] = []

        for file in planned:
            target_key = self._target_key(file.target, destination)
            record = receipt["files"].get(target_key)
            if not isinstance(record, dict):
                raise RegistryError(f"No valid receipt entry for {file.target}; install it first")
            if not file.target.is_file():
                raise RegistryError(f"Installed source is missing: {file.target}")
            base_value = record.get("base")
            if not isinstance(base_value, str):
                raise RegistryError(f"Invalid receipt base for {file.target}")

            base_path = self._safe_join(self._metadata_root(destination), base_value)
            if not base_path.is_file():
                raise RegistryError(f"Receipt base is missing: {base_path}")

            current = file.target.read_bytes()
            base = base_path.read_bytes()
            incoming = file.source.read_bytes()
            if self._digest(base) != record.get("sourceDigest"):
                raise RegistryError(f"Receipt base digest mismatch for {file.target}")

            if current == base:
                status = "unchanged" if incoming == base else "updated"
                decisions.append(_UpdateDecision(file, incoming, incoming, status))
            elif incoming == base:
                decisions.append(_UpdateDecision(file, current, base, "locally-modified"))
            else:
                merged, has_conflict = self._merge(current, base, incoming, target_key)
                if has_conflict:
                    conflicts.append((file, merged))
                else:
                    decisions.append(_UpdateDecision(file, merged, incoming, "merged"))

        if conflicts:
            conflict_root = self._metadata_root(destination) / "conflicts"
            conflict_root.mkdir(parents=True, exist_ok=True)
            artifacts: list[Path] = []
            for file, merged in conflicts:
                target_key = self._target_key(file.target, destination)
                artifact = conflict_root / f"{self._target_identifier(target_key)}.merge"
                artifact.write_bytes(merged)
                artifacts.append(artifact)
            joined = "\n".join(str(path) for path in artifacts)
            raise RegistryError(f"Update has merge conflicts; owned source was not changed:\n{joined}")

        for decision in decisions:
            decision.file.target.write_bytes(decision.target_content)
            self._record_file(
                receipt,
                decision.file,
                destination,
                decision.base_content,
                decision.target_content,
            )
            target_key = self._target_key(decision.file.target, destination)
            conflict = self._metadata_root(destination) / "conflicts" / (
                f"{self._target_identifier(target_key)}.merge"
            )
            conflict.unlink(missing_ok=True)

        self._record_items(receipt, name)
        self._write_receipt(destination, receipt)
        return [UpdateResult(decision.file, decision.status) for decision in decisions]

    def _matches_receipt(
        self,
        file: PlannedFile,
        record: dict | None,
        destination: Path,
    ) -> bool:
        if not isinstance(record, dict) or not file.target.is_file():
            return False
        base_value = record.get("base")
        if not isinstance(base_value, str):
            return False
        source = file.source.read_bytes()
        current = file.target.read_bytes()
        base_path = self._safe_join(self._metadata_root(destination), base_value)
        return (
            base_path.is_file()
            and self._digest(source) == record.get("sourceDigest")
            and self._digest(current) == record.get("installedDigest")
            and base_path.read_bytes() == source
        )

    def _record_items(self, receipt: dict, requested_name: str) -> None:
        for item_name in self.resolve(requested_name):
            item = self.items[item_name]
            receipt["items"][item_name] = {
                "version": item["version"],
                "registryDependencies": item["registryDependencies"],
            }

    def _record_file(
        self,
        receipt: dict,
        file: PlannedFile,
        destination: Path,
        base_content: bytes,
        installed_content: bytes,
    ) -> None:
        target_key = self._target_key(file.target, destination)
        base_relative = Path("bases") / f"{self._target_identifier(target_key)}.base"
        base_path = self._metadata_root(destination) / base_relative
        base_path.parent.mkdir(parents=True, exist_ok=True)
        base_path.write_bytes(base_content)
        receipt["files"][target_key] = {
            "item": file.item,
            "version": self.items[file.item]["version"],
            "sourceDigest": self._digest(base_content),
            "installedDigest": self._digest(installed_content),
            "base": base_relative.as_posix(),
        }

    def _read_receipt(self, destination: Path, require_existing: bool = False) -> dict:
        path = self._metadata_root(destination) / "receipt.json"
        if not path.exists():
            if require_existing:
                raise RegistryError(f"Installation receipt is missing: {path}")
            return {
                "schemaVersion": self.receipt_schema_version,
                "registry": self.registry_name,
                "items": {},
                "files": {},
            }

        receipt = self._read_json(path)
        if receipt.get("schemaVersion") != self.receipt_schema_version:
            raise RegistryError(f"Unsupported receipt schema version in {path}")
        if receipt.get("registry") != self.registry_name:
            raise RegistryError(f"Receipt belongs to another registry: {path}")
        if not isinstance(receipt.get("items"), dict) or not isinstance(receipt.get("files"), dict):
            raise RegistryError(f"Invalid receipt structure in {path}")
        return receipt

    def _write_receipt(self, destination: Path, receipt: dict) -> None:
        metadata_root = self._metadata_root(destination)
        metadata_root.mkdir(parents=True, exist_ok=True)
        path = metadata_root / "receipt.json"
        temporary = metadata_root / "receipt.json.tmp"
        temporary.write_text(json.dumps(receipt, indent=2, sort_keys=True) + "\n", encoding="utf-8")
        temporary.replace(path)

    @staticmethod
    def _merge(current: bytes, base: bytes, incoming: bytes, target: str) -> tuple[bytes, bool]:
        if shutil.which("git") is None:
            raise RegistryError("git is required to merge concurrent source changes")

        with tempfile.TemporaryDirectory() as directory:
            root = Path(directory)
            current_path = root / "current"
            base_path = root / "base"
            incoming_path = root / "incoming"
            current_path.write_bytes(current)
            base_path.write_bytes(base)
            incoming_path.write_bytes(incoming)
            process = subprocess.run(
                [
                    "git",
                    "merge-file",
                    "-p",
                    "-L",
                    target,
                    "-L",
                    "registry base",
                    "-L",
                    "registry incoming",
                    str(current_path),
                    str(base_path),
                    str(incoming_path),
                ],
                check=False,
                capture_output=True,
            )

        if process.returncode not in {0, 1}:
            message = process.stderr.decode("utf-8", errors="replace").strip()
            raise RegistryError(f"git merge-file failed for {target}: {message}")
        return process.stdout, process.returncode == 1

    @staticmethod
    def _metadata_root(destination: Path) -> Path:
        return destination / ".swiftui-registry"

    @staticmethod
    def _target_key(target: Path, destination: Path) -> str:
        try:
            return target.relative_to(destination).as_posix()
        except ValueError as error:
            raise RegistryError(f"Target escapes destination: {target}") from error

    @classmethod
    def _target_identifier(cls, target: str) -> str:
        return hashlib.sha256(target.encode("utf-8")).hexdigest()

    @staticmethod
    def _digest(content: bytes) -> str:
        return f"sha256:{hashlib.sha256(content).hexdigest()}"

    @staticmethod
    def _read_json(path: Path) -> dict:
        try:
            value = json.loads(path.read_text(encoding="utf-8"))
        except (OSError, json.JSONDecodeError) as error:
            raise RegistryError(f"Cannot read {path}: {error}") from error
        if not isinstance(value, dict):
            raise RegistryError(f"Expected a JSON object in {path}")
        return value

    @staticmethod
    def _safe_relative(value: str) -> Path:
        if not isinstance(value, str) or not value:
            raise RegistryError(f"Unsafe registry path: {value}")
        path = Path(value)
        if path == Path(".") or path.is_absolute() or ".." in path.parts:
            raise RegistryError(f"Unsafe registry path: {value}")
        return path

    @classmethod
    def _safe_join(cls, root: Path, value: str) -> Path:
        root = root.resolve()
        candidate = (root / cls._safe_relative(value)).resolve(strict=False)
        try:
            candidate.relative_to(root)
        except ValueError as error:
            raise RegistryError(f"Registry path escapes through a symbolic link: {value}") from error
        return candidate

    def _validate_preview_files(self, item: dict, item_path: Path) -> None:
        preview = item["preview"]
        source = self._safe_join(self.registry_root, preview["source"])
        if not source.is_file():
            raise RegistryError(f"Missing preview source in {item_path}: {source}")

        for screenshot in preview.get("screenshots", []):
            path = self._safe_join(self.repository_root, screenshot)
            if not path.is_file():
                raise RegistryError(f"Missing preview screenshot in {item_path}: {path}")

    @staticmethod
    def _validate_item(item: dict, path: Path) -> None:
        required = {
            "schemaVersion",
            "version",
            "name",
            "kind",
            "description",
            "files",
            "registryDependencies",
            "packageDependencies",
            "platforms",
            "tags",
            "accessibility",
            "preview",
        }
        missing = required - item.keys()
        if missing:
            raise RegistryError(f"{path} is missing: {', '.join(sorted(missing))}")
        if item["schemaVersion"] != 1:
            raise RegistryError(f"Unsupported item schema version in {path}")
        if item["kind"] not in {"component", "block", "flow"}:
            raise RegistryError(f"Unsupported item kind in {path}")


def main() -> int:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("item", help="Registry item name")
    parser.add_argument("--destination", required=True, type=Path)
    mode = parser.add_mutually_exclusive_group()
    mode.add_argument("--force", action="store_true")
    mode.add_argument("--update", action="store_true")
    arguments = parser.parse_args()

    repository_root = Path(__file__).resolve().parents[1]
    installer = Installer(repository_root)
    try:
        if arguments.update:
            results = installer.update(arguments.item, arguments.destination)
            for result in results:
                print(f"{result.status} {result.file.item}: {result.file.target}")
        else:
            files = installer.install(arguments.item, arguments.destination, arguments.force)
            for file in files:
                print(f"installed {file.item}: {file.target}")
            if not files:
                print(f"up-to-date: {arguments.item}")
    except RegistryError as error:
        parser.error(str(error))
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
