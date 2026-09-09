<!-- Checklist for `swiftui-registry-authoring`; from `AGENTS.md` Verification, do not edit. -->

# Authoring verification checklist

Repo root, cheapest first; scope to change (Scoping).

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

## Captures

- [ ] visible item change: `python3 Scripts/capture_previews.py <item>` on pinned simulator, rerun the four generators above

## Scoping

- metadata-only: stop after `make format-check`
- registry source: + install, compile
- visible UI: + simulator test
- `Website/`: + typecheck, build
- `swift test` needs `git`, `node` 22 on PATH: `git merge-file`; `Website/lib/preset.ts` under `node --experimental-strip-types`

Incomplete if generated differs from registry, or any command fails; name skipped steps.
