# Handoff: Swift CLI rewrite

Read [AGENTS.md](AGENTS.md), [philosophy](docs/philosophy.md), [architecture](docs/architecture.md), and the full [registry specification](docs/registry-spec.md), in that order. Then read [the roadmap, Stage 6](docs/component-roadmap.md#stage-6-swift-command-line-rewrite) for the checkpoint, commit evidence, next actions, phase gates, and unresolved work. The roadmap is the only home for stage status and plans

Read [the migration contract](docs/cli-migration.md) for package boundaries, compatibility exceptions, effect injection, and the Showcase codec decision. Read [fixture provenance](Tests/RegistryKitTests/Fixtures/README.md) before changing an expectation. Python is the byte oracle during the overlap; an unexplained snapshot update is not parity evidence

## Session instructions

The owner authorized completing all four phases with local commits, without further confirmation. Do not push, tag, deploy, create the tap repository, or replace visual references. Do not inherit the previous Stage 5 session's publishing authorization. Do not use subagents or run remote workflows. Creating the requested CI and release workflow files is part of the implementation

Use absolute paths in shell commands and set the working directory explicitly. Do not use `cd` in concurrent commands. Write no em dashes or heading-ending periods. Read the actual Swift interface or the mirrored Python source before calling an unfamiliar API. Preserve raw SwiftUI controls, source ownership, and the four document classes in AGENTS.md

Every commit must pass the scope-appropriate verification loop. Record the commit hash and title, command outcomes, exact parity coverage, decisions, and omissions in the roadmap. End each commit message with:

```text
Co-Authored-By: Claude Fable 5.1 <noreply@anthropic.com>
Claude-Session: https://claude.ai/code/session_01HsHG4U7cjKDqu9oTQY139e
```

The local commit-msg hook appends `By specifier.`; leave the hook alone

## Restart procedure

Use `/Users/developer/Projects/swiftui-cn` as the working directory. Inspect the branch, recent commits, and working tree before editing; do not reset another session's work

```sh
git -C /Users/developer/Projects/swiftui-cn status --short --branch
git -C /Users/developer/Projects/swiftui-cn log -5 --oneline
git -C /Users/developer/Projects/swiftui-cn diff --stat
```

Follow the roadmap's Stage 6 continuation checkpoint rather than replaying completed Phases A and B. No chat history is required. Temporary logs are supporting evidence only; committed tests, fixtures, and the parity script reproduce the proof

## Verification commands

Run sequentially from the root, cheapest first. Keep the Python checks until Phase C removes that path. Run the Swift generators as well and compare their bytes before changing generated command examples

```sh
swift build --package-path /Users/developer/Projects/swiftui-cn
swift test --package-path /Users/developer/Projects/swiftui-cn --filter RegistryKitTests
python3 -m unittest discover -s /Users/developer/Projects/swiftui-cn/Tests/RegistryTests
python3 /Users/developer/Projects/swiftui-cn/Scripts/validate.py
swift run --package-path /Users/developer/Projects/swiftui-cn swiftui-registry validate --registry /Users/developer/Projects/swiftui-cn
python3 /Users/developer/Projects/swiftui-cn/Scripts/generate_catalog.py
python3 /Users/developer/Projects/swiftui-cn/Scripts/generate_showcase_manifest.py
python3 /Users/developer/Projects/swiftui-cn/Scripts/generate_site_data.py
swift run --package-path /Users/developer/Projects/swiftui-cn swiftui-registry generate catalog --registry /Users/developer/Projects/swiftui-cn
swift run --package-path /Users/developer/Projects/swiftui-cn swiftui-registry generate showcase-manifest --registry /Users/developer/Projects/swiftui-cn
swift run --package-path /Users/developer/Projects/swiftui-cn swiftui-registry generate site-data --registry /Users/developer/Projects/swiftui-cn
git -C /Users/developer/Projects/swiftui-cn diff --exit-code -- docs/catalog Examples/Showcase Website/content Website/public/images
python3 /Users/developer/Projects/swiftui-cn/Scripts/check_swift_parity.py
make -C /Users/developer/Projects/swiftui-cn format-check
git -C /Users/developer/Projects/swiftui-cn diff --check
```

Use `swift build --package-path /Users/developer/Projects/swiftui-cn --show-bin-path` to discover the binary directory rather than assuming an architecture-specific `.build` path. Also build with `-c release` for release changes

After touching Showcase, build it on the pinned simulator:

```sh
xcodebuildmcp simulator build --workspace-path /Users/developer/Projects/swiftui-cn/Examples/Showcase/SwiftUIRegistryShowcase.xcworkspace --scheme SwiftUIRegistryShowcase --simulator-id 1807166B-C557-4F6B-B177-D5F3F701CBD7
```

If Showcase sources change, run its UI suite once with the explicit destination, retain the result bundle, and report the known reference failures separately:

```sh
xcodebuild test -workspace /Users/developer/Projects/swiftui-cn/Examples/Showcase/SwiftUIRegistryShowcase.xcworkspace -scheme SwiftUIRegistryShowcase -destination 'platform=iOS Simulator,id=1807166B-C557-4F6B-B177-D5F3F701CBD7' -resultBundlePath /tmp/swiftui-registry-stage6-showcase-tests.xcresult
```

Choose a fresh result bundle path if that one exists. The suite takes about 27 minutes; inspect its log while it runs. See the roadmap and [visual testing contract](docs/visual-testing.md) for the pre-existing `auth-light` and `nutrition-light` differences. Never write into `ReferenceImages/`

Read `Website/AGENTS.md` before changing website files. After touching Website, run these commands with working directory `/Users/developer/Projects/swiftui-cn/Website`:

```sh
npm run typecheck
npm run build
```

## Source navigation

| Concern | Implementation and oracle |
|---|---|
| Real argument parsing and output | `Sources/SwiftUIRegistryCLI/Main.swift`, `PresetCommand.swift`; `Tests/RegistryKitTests/CommandSupport.swift` parses and runs the real root command |
| Validation and resolution | `Sources/RegistryKit/Validation.swift`, `Registry.swift`; `Scripts/registry_validation.py`, `Tests/RegistryTests/test_validation.py` |
| Ownership and merge | `Sources/RegistryKit/Installer.swift`, `SourceComparison.swift`; `Scripts/install.py`, `Tests/RegistryTests/test_installer.py` |
| Effects | `Sources/RegistryKit/FileSystem.swift`, `Console.swift`; `Tests/RegistryKitTests/InMemoryFileSystem.swift` |
| Search and preset codec | `Sources/RegistryKit/Registry.swift`, `Preset.swift`, `PresetRandom.swift`; `Scripts/search.py`, `preset.py` and their Python tests |
| MCP wire contract | `Sources/RegistryKit/MCPServer.swift`, `MCPTools.swift`, `RegistryInput.swift`; `Scripts/mcp_server.py`, `Tests/RegistryTests/test_mcp_server.py`, `Tests/RegistryKitTests/MCPTests.swift` |
| Generator byte contracts | `Sources/RegistryKit/CatalogGenerator.swift`, `ShowcaseManifestGenerator.swift`, `SiteDataGenerator.swift`, `OrderedJSON.swift`; the three Python generators and `Tests/RegistryKitTests/GeneratorTests.swift` |
| Shared codec vectors | `Tests/RegistryTests/preset_vectors.json`, `preset_vectors_check.ts`, `Tests/RegistryKitTests/Fixtures/preset_vectors.json`, Showcase `ThemePreset.swift` |
| Release reference | `pointfreeco/pfw` commit `854b491`: `Sources/pfw/Main.swift`, `Install.swift`, `Dependencies/FileSystem.swift`, `Tests/pfwTests/InstallTests.swift`, `Tests/pfwTests/Internal/AssertComand.swift`, `.github/workflows/release.yml` |

The reference checkout used during implementation is `/tmp/swiftui-registry-stage6-pfw`; recreate it from `https://github.com/pointfreeco/pfw` at the pinned commit if absent. Treat it as a design reference, not a runtime dependency. Its central store, symlinks, login, redirect server, and ZIP dependency do not belong in this source-copying registry
