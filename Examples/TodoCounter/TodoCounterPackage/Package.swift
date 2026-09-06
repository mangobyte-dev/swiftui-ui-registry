// swift-tools-version: 6.2

import PackageDescription

// A consumer outside the Showcase: the published registry package by URL at its 0.1.0 tag,
// the Composable Architecture for the feature logic, and registry items copied into
// Sources/TodoCounterFeature/Registry by `swiftui-registry install`.
let package = Package(
    name: "TodoCounterFeature",
    platforms: [.iOS(.v26)],
    products: [
        .library(
            name: "TodoCounterFeature",
            targets: ["TodoCounterFeature"]
        )
    ],
    dependencies: [
        .package(url: "https://github.com/mangobyte-dev/swiftui-ui-registry.git", .upToNextMinor(from: "0.1.0")),
        .package(url: "https://github.com/pointfreeco/swift-composable-architecture", from: "1.26.2"),
    ],
    targets: [
        .target(
            name: "TodoCounterFeature",
            dependencies: [
                .product(name: "SwiftUIRegistryFoundations", package: "swiftui-ui-registry"),
                .product(name: "ComposableArchitecture", package: "swift-composable-architecture"),
            ]
        ),
        .testTarget(
            name: "TodoCounterFeatureTests",
            dependencies: [
                "TodoCounterFeature",
                .product(name: "ComposableArchitecture", package: "swift-composable-architecture"),
            ]
        ),
    ]
)
