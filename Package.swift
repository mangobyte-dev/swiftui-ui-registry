// swift-tools-version: 6.2

import PackageDescription

let package = Package(
    name: "SwiftUIRegistry",
    platforms: [
        .macOS(.v15),
        .iOS(.v26)
    ],
    products: [
        .library(
            name: "SwiftUIRegistryFoundations",
            targets: ["SwiftUIRegistryFoundations"]
        ),
        .library(
            name: "SwiftUIRegistryDesignSurface",
            targets: ["SwiftUIRegistryDesignSurface"]
        ),
        .library(name: "RegistryKit", targets: ["RegistryKit"]),
        .executable(name: "swiftui-registry", targets: ["SwiftUIRegistryCLI"])
    ],
    dependencies: [
        .package(url: "https://github.com/apple/swift-argument-parser", from: "1.5.0"),
        .package(url: "https://github.com/pointfreeco/swift-custom-dump", from: "1.3.0"),
        .package(url: "https://github.com/pointfreeco/swift-dependencies", from: "1.0.0"),
        .package(url: "https://github.com/pointfreeco/xctest-dynamic-overlay", from: "1.4.3"),
        .package(url: "https://github.com/pointfreeco/swift-sharing", "2.9.1"..<"2.10.0", traits: []),
        .package(url: "https://github.com/pointfreeco/swift-snapshot-testing", from: "1.18.9"),
    ],
    targets: [
        .target(
            name: "RegistryKit",
            dependencies: [
                .product(name: "Dependencies", package: "swift-dependencies"),
                .product(name: "IssueReporting", package: "xctest-dynamic-overlay"),
            ],
            swiftSettings: [.enableUpcomingFeature("NonisolatedNonsendingByDefault")]
        ),
        .executableTarget(
            name: "SwiftUIRegistryCLI",
            dependencies: [
                "RegistryKit",
                .product(name: "ArgumentParser", package: "swift-argument-parser"),
                .product(name: "Dependencies", package: "swift-dependencies"),
            ],
            swiftSettings: [.enableUpcomingFeature("NonisolatedNonsendingByDefault")]
        ),
        .testTarget(
            name: "RegistryKitTests",
            dependencies: [
                "RegistryKit",
                "SwiftUIRegistryCLI",
                .product(name: "CustomDump", package: "swift-custom-dump"),
                .product(name: "InlineSnapshotTesting", package: "swift-snapshot-testing"),
                .product(name: "DependenciesTestSupport", package: "swift-dependencies"),
            ],
            resources: [.copy("Fixtures")],
            swiftSettings: [.enableUpcomingFeature("NonisolatedNonsendingByDefault")]
        ),
        .target(name: "SwiftUIRegistryFoundations"),
        .target(
            name: "SwiftUIRegistryDesignSurface",
            dependencies: [
                "SwiftUIRegistryFoundations",
                .product(name: "Sharing", package: "swift-sharing")
            ]
        ),
        .testTarget(
            name: "SwiftUIRegistryFoundationsTests",
            dependencies: ["SwiftUIRegistryFoundations"]
        )
    ],
    swiftLanguageModes: [.v6]
)
