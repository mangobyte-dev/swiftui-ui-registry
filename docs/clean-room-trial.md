# Clean-room adoption trial

Date: 2026-08-31
Role: an independent iOS developer who has never seen this repository, working only from README.md and the generated catalog in `docs/catalog/`
Working area: a scratch directory outside the repository containing a minimal iOS SwiftPM package (`AdopterApp`, swift-tools-version 6.2, platforms iOS 18)
Registry dependency: a local path dependency to this repository stood in for the published URL `https://github.com/mangobyte-dev/swiftui-ui-registry.git` printed by the installer; the published URL itself was not exercised
Effort metric: tool-call counts (each shell command, file read, or file edit is one call). 16 calls total including scratch-directory setup

## Protocol

1. Discover: from README, find how to search; search for a finance dashboard block
2. Inspect: read its catalog page; run the documented plan command against a fresh destination
3. Install: create a minimal iOS SwiftPM package; install `finance-overview` per the docs; add the foundations dependency the way the install output instructs
4. Compile: build the package for iOS Simulator with xcodebuild
5. Customize: edit one copied file, rebuild, run the documented diff command, then re-run install without `--force`
6. Verdicts against the docs alone, with a shadcn comparison

## Step outcomes

### Step 1 Discover (3 calls: README read, 2 searches)

Outcome: pass. README's "Use one item in minutes" gives `python3 Scripts/search.py finance --kind block --format names`, which returned `finance-overview`. The richer Discover query (`finance dashboard --kind block --platform iOS --target-version 18.0`) returned full JSON with dependencies, package requirement, platforms, accessibility notes, and preview paths, exactly as README describes.

Friction:

- Every documented command is `python3 Scripts/...` run from the registry checkout root, but README never says "clone this repository first". A newcomer landing on the catalog page or a copied snippet has no statement of the precondition that the whole registry repo must exist locally and be the working directory. I inferred it; the docs did not say it
- No stated Python version requirement anywhere in README Requirements (Swift, iOS, Xcode, Git are listed; Python is not, despite every entry-point command being Python)

### Step 2 Inspect (2 calls: catalog page read, plan)

Outcome: pass. `docs/catalog/finance-overview.md` leads with preview, install command, and a usage snippet as README promises. `--plan` against a fresh destination printed the ordered closure (metric-card 0.1.1, transaction-row 0.3.0, finance-overview 0.2.1), each target write as `new`, the package requirement, a preflight ok, and manual next steps, then confirmed nothing was written. Verified read-only: the destination did not exist afterward.

Friction:

- The catalog install command uses the placeholder `<your-target-dir>` with no guidance on what a good destination is inside a SwiftPM package or app target (for example `Sources/<Target>/Components`). README uses `path/to/YourTarget/Components`, which hints at it, but neither states that the destination must live inside an existing build target's source folder

### Step 3 Install (2 calls: write Package.swift, install)

Outcome: pass. Install copied the three files in dependency order and printed the package requirement line again. Wiring the dependency required writing this by hand in `Package.swift`:

```swift
.package(path: "/Users/developer/Projects/swiftui-cn")
// stand-in for: .package(url: "https://github.com/mangobyte-dev/swiftui-ui-registry.git", .upToNextMinor(from: "0.1.0"))
.product(name: "SwiftUIRegistryFoundations", package: "swiftui-cn")
```

Friction, the largest gap found:

- The install output and both doc pages say "add package `<URL>` (from 0.1.0 up to the next minor version) and link product SwiftUIRegistryFoundations" but never show the actual `Package.swift` or Xcode syntax. shadcn's equivalent (`npx shadcn add`) wires dependencies itself; here even the manual step lacks a copyable snippet
- The `package:` argument of `.product(name:package:)` is nowhere documented. Search JSON says `"package": "SwiftUIRegistry"`, the URL implies identity `swiftui-ui-registry`, and my path stand-in needed `swiftui-cn`. SwiftPM accepted the path-derived identity; which value a URL consumer must write is left for the adopter to know. For an Xcode-app consumer this is moot (Xcode wires it), but the docs never separate the two consumer types
- The published URL could not be verified from the clean room; README's Status section itself lists "no external adoption evidence" and no hosted registry, so this is a known boundary, recorded here for completeness

### Step 4 Compile for iOS (3 calls: failed build, scheme list, successful build)

Outcome: pass. `xcodebuild -scheme AdopterApp -destination 'generic/platform=iOS Simulator' build` ended in `BUILD SUCCEEDED` with target triples `arm64-apple-ios18.0-simulator` and `x86_64-apple-ios18.0-simulator` against the iPhoneSimulator 27.0 SDK, no warnings or errors in the filtered log. One failed call was my own scheme-name guess (`AdopterFeature` instead of `AdopterApp`), not a product defect.

Friction:

- The docs never describe how a package-only consumer verifies the copied source builds for iOS; the Verify section covers only this repository's own test suites. A one-line "build your consuming target for an iOS Simulator destination" note would close the loop the trial had to invent

### Step 5 Customize, diff, reinstall (5 calls: read, edit, rebuild, diff, reinstall check)

Outcome: pass on all three sub-checks.

- Customization: restyled the transactions section header in the copied `FinanceOverview.swift` (`.font(.subheadline.weight(.semibold))`, `.textCase(.uppercase)`, `.foregroundStyle(.secondary)` replacing `.font(.headline)`); rebuild stayed green
- `--diff` printed `identical` for the two untouched components and a correct unified diff of exactly the local edit, exit code 1, matching README's documented contract
- Re-running install without `--force` refused with `Refusing to overwrite owned source: .../FinanceOverview.swift`, exit code 2, and the local edit survived (verified by grep). This matches README's "A repeated install is accepted only when the existing source still matches its receipt"

Friction:

- The refusal is routed through argparse, so the message is prefixed by a `usage:` block that makes a correct safety refusal read like a CLI syntax mistake. The error also does not name the recovery options (`--diff` to inspect, `--update` to merge, `--force` to replace); the flags appear only in the usage noise above it

## Verdicts per step

| Step | From docs alone | Notes |
| --- | --- | --- |
| Discover | Yes | Commands worked verbatim; unstated clone-and-cwd precondition |
| Inspect | Yes | Plan output is genuinely read-only and complete |
| Install | Mostly | File copy yes; SwiftPM wiring needed knowledge the docs do not provide |
| Compile | Yes, but self-directed | Docs are silent on consumer-side iOS build verification |
| Customize and update safety | Yes | Diff and no-force refusal behaved exactly as documented |

## Comparison with shadcn's flow

- shadcn: one hosted command (`npx shadcn@latest add <item>`) with no repository clone, automatic dependency wiring via `components.json`, and no project-file steps. This registry: clone the repo, run `python3` scripts from its root, hand-edit `Package.swift` or the Xcode project, ensure target membership. Roughly the same number of conceptual steps but two of them are manual here and the entry cost (full clone) is higher
- Where this registry is ahead of shadcn for its platform: `--plan` and `--diff` are stronger inspection primitives than shadcn offers, the receipt-backed refusal to clobber owned source is stricter than shadcn's overwrite prompt, and the metadata (accessibility contract, platform floor, versioned closure) is richer per item
- Net: the copy-and-own core delivers; the distribution shell (clone precondition, manual SwiftPM wiring) is where the flow is slower than shadcn

## Defects found

1. Unstated precondition that the registry repository must be cloned and be the working directory for every command (README.md "Use one item in minutes", Discover, Install; docs/catalog/finance-overview.md Install)
2. No copyable SwiftPM dependency snippet and no documented value for the `.product(name:package:)` `package:` argument; the "add the printed package requirement" instruction (README.md step 4, install output of Scripts/install.py, docs/catalog/finance-overview.md) assumes the consumer can derive manifest syntax and package identity
3. Python is missing from README.md Requirements although every entry-point command is Python
4. Refusal to overwrite owned source (Scripts/install.py) presents as an argparse usage error and does not name `--diff`, `--update`, or `--force` as next actions in the message body
5. No consumer-side build-verification guidance for package consumers (README.md Verify covers only this repository's own suites)
6. Catalog install placeholder `<your-target-dir>` (docs/catalog/*.md) gives no guidance on choosing a destination inside a build target

## Prioritized fix list

1. Add a copyable `Package.swift` snippet (and the Xcode "Add Package Dependency" equivalent) to the install output, README Install, and the generated catalog Install section, including the exact `package:` identity for the published URL (defect 2)
2. State the clone-and-run-from-root precondition once at the top of README "Use one item in minutes" and in the generated catalog preamble (defect 1)
3. Separate the ownership refusal from argparse usage output and name the three recovery flags in the error message (defect 4)
4. Add Python 3 to README Requirements with the minimum version the scripts need (defect 3)
5. Add a one-line consumer verification note: build the consuming target for an iOS Simulator destination after install (defect 5)
6. Replace `<your-target-dir>` in generated catalog pages with a concrete example path and a sentence on target membership (defect 6)

## Deferrals

- The published GitHub URL and the `0.1.0` tag it advertises were not exercised; a local path dependency stood in as the trial mandated
- `--update` three-way merge behavior was not exercised; the protocol covered plan, install, diff, and the no-force refusal only
- Xcode-project (non-SwiftPM) consumer wiring and target membership were not exercised; the trial consumer was a SwiftPM library package
