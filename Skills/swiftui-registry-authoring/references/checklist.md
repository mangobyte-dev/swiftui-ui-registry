<!-- Reference for the swiftui-registry-authoring skill. The commands and scoping rules are quoted from AGENTS.md, "Verification". Run from the repository root, cheapest first. Do not hand-edit; AGENTS.md governs. -->

# Authoring verification checklist

Quoted from `AGENTS.md`, "Verification". Run from the repository root, cheapest
first, so a defect fails the run before the expensive steps. Scope the run to the
change (see "Scoping" below).

## Commands

- [ ] `swift build`
- [ ] `swift run swiftui-registry validate`
- [ ] `swift run swiftui-registry generate catalog`
- [ ] `swift run swiftui-registry generate showcase-manifest`
- [ ] `swift run swiftui-registry generate site-data`
- [ ] `swift run swiftui-registry generate item-tokens`
- [ ] `git diff --exit-code -- docs/catalog Examples/Showcase Website/content Sources/SwiftUIRegistryDesignSurface/RegistryItemTokens.swift`
- [ ] `swift test`
- [ ] `make format-check`
- [ ] `swift run swiftui-registry search nutrition dashboard --kind block --platform iOS --target-version 26.0`
- [ ] `swift run swiftui-registry install finance-overview --destination Examples/Showcase/SwiftUIRegistryShowcasePackage/Sources/SwiftUIRegistryShowcaseFeature/Installed --force`
- [ ] `swift run swiftui-registry install nutrition-overview --destination Examples/Showcase/SwiftUIRegistryShowcasePackage/Sources/SwiftUIRegistryShowcaseFeature/Installed`
- [ ] `xcodebuildmcp simulator build --workspace-path Examples/Showcase/SwiftUIRegistryShowcase.xcworkspace --scheme SwiftUIRegistryShowcase --simulator-name 'iPhone 17'`
- [ ] `xcodebuildmcp simulator test --workspace-path Examples/Showcase/SwiftUIRegistryShowcase.xcworkspace --scheme SwiftUIRegistryShowcase --simulator-id 1807166B-C557-4F6B-B177-D5F3F701CBD7`
- [ ] `(cd Website && npm ci && npm run typecheck && npm run build)`

## Captures (a visible change to an item)

- [ ] `python3 Scripts/capture_previews.py <item>` on the pinned simulator, then regenerate the four generators above

## Scoping (quoted from AGENTS.md)

- A metadata-only change stops after `make format-check`.
- A registry source change needs the install and compile steps.
- Only a visible UI change needs the simulator test.
- A change under `Website/` needs the typecheck and build.
- `swift test` needs `git` and Node 22 on PATH (the merge adapter shells out to
  `git merge-file`; the website codec check runs `Website/lib/preset.ts` under
  `node --experimental-strip-types`).

A change is incomplete if generated consumer sources differ from registry sources
or any executed command fails; a skipped step is named in the done-claim.
