import ArgumentParser
import Dependencies
import Foundation
import RegistryKit
import Synchronization
import Testing

@testable import SwiftUIRegistryCLI

struct CommandOutput: Equatable {
  var stdout: String
  var stderr: String
  var code: Int32
}

// Parse and run the real root. Capturing the output dependency keeps unrelated
// Swift Testing reports out of command snapshots, including during failures.
func command(_ arguments: [String]) throws -> CommandOutput {
  let output = Mutex(CommandOutput(stdout: "", stderr: "", code: 0))
  return withDependencies {
    $0.registryConsole = RegistryConsole(
      stdout: { text in output.withLock { $0.stdout += text } },
      stderr: { text in output.withLock { $0.stderr += text } }
    )
  } operation: {
    do {
      var parsed = try SwiftUIRegistry.parseAsRoot(arguments)
      try parsed.run()
    } catch let exit as ExitCode { output.withLock { $0.code = exit.rawValue } } catch {
      output.withLock {
        $0.code = SwiftUIRegistry.exitCode(for: error).rawValue
        $0.stderr += SwiftUIRegistry.message(for: error)
      }
    }
    return output.withLock { $0 }
  }
}

let example: JSON = [
  "schemaVersion": 1, "name": "example", "version": "0.1.0", "kind": "component",
  "description": "Test item.", "usage": "Example()",
  "files": [["source": "sources/Example.swift", "target": "Example.swift"]],
  "registryDependencies": [], "packageDependencies": [],
  "platforms": [["name": "iOS", "minimumVersion": "26.0"]],
  "tags": ["test"], "accessibility": [],
  "preview": ["source": "sources/Example.swift", "name": "Example"],
]

func fixture(_ content: String = "source\n") throws -> InMemoryFileSystem {
  let fs = InMemoryFileSystem()
  let schema = try String(
    contentsOf: Bundle.module.url(
      forResource: "schema", withExtension: "json", subdirectory: "Fixtures")!, encoding: .utf8)
  try fs.put("/registry/Registry/schema.json", schema)
  try fs.put("/registry/Registry/items/example.json", example.rendered())
  try fs.put(
    "/registry/Registry/registry.json",
    JSON.object(["schemaVersion": 1, "name": "TestRegistry", "items": ["items/example.json"]])
      .rendered())
  try fs.put("/registry/Registry/sources/Example.swift", content)
  return fs
}

func withFixture<R>(_ fs: InMemoryFileSystem, _ body: () throws -> R) rethrows -> R {
  try withDependencies {
    $0.registryFileSystem = fs
    $0.registrySource = InMemoryRegistrySource()
    $0.registrySourceMerger = .git
    $0.uuid = .incrementing
  } operation: {
    try body()
  }
}
