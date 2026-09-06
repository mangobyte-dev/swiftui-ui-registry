# Handoff: Swift CLI rewrite, Phase D

Read [AGENTS.md](AGENTS.md), [philosophy](docs/philosophy.md), [architecture](docs/architecture.md), and the full [registry specification](docs/registry-spec.md), in that order. Then read [the roadmap, Stage 6](docs/component-roadmap.md#stage-6-swift-command-line-rewrite) for the checkpoint, commit evidence, next actions, phase gates, and unresolved work. The roadmap is the only home for stage status and plans

Read [the migration contract](docs/cli-migration.md) for package boundaries, compatibility exceptions, effect injection, and the Showcase codec decision. Read [fixture provenance](Tests/RegistryKitTests/Fixtures/README.md) before changing an expectation. The Python oracle is gone since Phase C; the inline snapshots and captured fixtures under `Tests/RegistryKitTests/` are the byte contract, and an unexplained snapshot update is not evidence

## Session instructions

The owner authorized completing all four phases with local commits, without further confirmation. Phases A through C are done. Do not push, tag, deploy, create the tap repository, or replace visual references. Do not inherit the previous Stage 5 session's publishing authorization. Do not use subagents or run remote workflows. Creating the requested release workflow and formula template files is part of the implementation

Use absolute paths in shell commands and set the working directory explicitly. Do not use `cd` in concurrent commands. Write no em dashes or heading-ending periods. Read the actual Swift interface before calling an unfamiliar API. Preserve raw SwiftUI controls, source ownership, and the four document classes in AGENTS.md

Every commit must pass the scope-appropriate verification loop. Record the commit hash and title, command outcomes, decisions, and omissions in the roadmap. End each commit message with:

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

Follow the roadmap's Stage 6 continuation checkpoint and its Phase D paragraphs rather than replaying completed Phases A through C. No chat history is required. Temporary logs are supporting evidence only; committed tests and fixtures reproduce the proof

## Verification commands

Run sequentially from the root, cheapest first. `swift test` needs `git` on PATH for the merge adapter and Node 22 for the website codec check

```sh
swift build --package-path /Users/developer/Projects/swiftui-cn
swift run --package-path /Users/developer/Projects/swiftui-cn swiftui-registry validate --registry /Users/developer/Projects/swiftui-cn
swift run --package-path /Users/developer/Projects/swiftui-cn swiftui-registry generate catalog --registry /Users/developer/Projects/swiftui-cn
swift run --package-path /Users/developer/Projects/swiftui-cn swiftui-registry generate showcase-manifest --registry /Users/developer/Projects/swiftui-cn
swift run --package-path /Users/developer/Projects/swiftui-cn swiftui-registry generate site-data --registry /Users/developer/Projects/swiftui-cn
git -C /Users/developer/Projects/swiftui-cn diff --exit-code -- docs/catalog Examples/Showcase Website/content Website/public/images
swift test --package-path /Users/developer/Projects/swiftui-cn
make -C /Users/developer/Projects/swiftui-cn format-check
git -C /Users/developer/Projects/swiftui-cn diff --check
```

Use `swift build --package-path /Users/developer/Projects/swiftui-cn --show-bin-path` to discover the binary directory rather than assuming an architecture-specific `.build` path. Also build with `-c release` for release changes; `.build/release/swiftui-registry` is the release binary SwiftPM links

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
npm run lint
npm run build
```

## Source navigation

| Concern | Implementation and tests |
|---|---|
| Real argument parsing and output | `Sources/SwiftUIRegistryCLI/Main.swift`, `PresetCommand.swift`, `Generate.swift`, `MCP.swift`; `Tests/RegistryKitTests/CommandSupport.swift` parses and runs the real root command |
| Registry selection and effects | `Sources/RegistryKit/FileSystem.swift` (`LocalRegistrySource` finds `Registry/registry.json` upward from the working directory; Phase D adds the cached release snapshot after the explicit `--registry` path), `Console.swift`, `RegistryInput.swift`; `Tests/RegistryKitTests/InMemoryFileSystem.swift`, `RepositorySupport.swift` |
| Validation and resolution | `Sources/RegistryKit/Validation.swift`, `Registry.swift`; `ValidationTests.swift` with `Fixtures/validation-cases.json`, `RegistryContractTests.swift` |
| Ownership and merge | `Sources/RegistryKit/Installer.swift`, `SourceComparison.swift`; `Commands.swift`, `InstallerSafetyTests.swift` with `Fixtures/diff-cases.json` |
| Search and preset codec | `Sources/RegistryKit/Registry.swift`, `Preset.swift`, `PresetRandom.swift`; `PresetTests.swift`, `PresetCommandSnapshots.swift`, `PresetContractTests.swift`, the Showcase's `ThemePreset.swift` and `ThemePresetTests` |
| MCP wire contract | `Sources/RegistryKit/MCPServer.swift`, `MCPTools.swift`; `MCPTests.swift` (inline wire snapshots), `MCPContractTests.swift` (real catalog) |
| Generator byte contracts | `Sources/RegistryKit/CatalogGenerator.swift`, `ShowcaseManifestGenerator.swift`, `SiteDataGenerator.swift`, `OrderedJSON.swift`; `GeneratorTests.swift` |
| Shared codec vectors | `Registry/preset_vectors.json`; `Tests/RegistryKitTests/Fixtures/preset_vectors.json` (byte copy), `Fixtures/preset-vectors-check.ts` (website codec under Node), `Website/lib/preset.ts` |
| Captures | `Scripts/capture_previews.py`, the one remaining Python script, which lists items and checks a preset code through the built tool (`--tool`) |
| Release reference | `pointfreeco/pfw` commit `854b491`: `Sources/pfw/Main.swift`, `Install.swift`, `Dependencies/FileSystem.swift`, `Tests/pfwTests/InstallTests.swift`, `Tests/pfwTests/Internal/AssertComand.swift`, `.github/workflows/release.yml` |

The Python originals and the 1,184-comparison parity oracle are in git history at `41c2bd8` if a byte question needs the source. The reference checkout used during implementation is `/tmp/swiftui-registry-stage6-pfw`; recreate it from `https://github.com/pointfreeco/pfw` at the pinned commit if absent. Treat it as a design reference, not a runtime dependency. Its central store, symlinks, login, redirect server, and ZIP dependency do not belong in this source-copying registry
