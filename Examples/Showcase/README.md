# Showcase sample app

This universal iOS app is the compile, integration, and visual consumer for the registry proof

The feature package depends only on `SwiftUIRegistryFoundations`. Product components and blocks under `Sources/SwiftUIRegistryShowcaseFeature/Installed/` are copied from the registry by `Scripts/install.py`

Regenerate installed source from the repository root:

```sh
DEST=Examples/Showcase/SwiftUIRegistryShowcasePackage/Sources/SwiftUIRegistryShowcaseFeature/Installed
python3 Scripts/install.py finance-overview --destination "$DEST" --force
python3 Scripts/install.py nutrition-overview --destination "$DEST"
```

The destination also contains a receipt and non-Swift base snapshots under `.swiftui-registry/`. These files prove provenance and updates without adding declarations to the feature target

Build with the shared `SwiftUIRegistryShowcase` scheme in `SwiftUIRegistryShowcase.xcworkspace`. Run the UI suite on an iPhone 16 Pro with iOS 18.0 for the pinned visual contract. Current iPhone and iPad runtimes remain manual adaptation checks
