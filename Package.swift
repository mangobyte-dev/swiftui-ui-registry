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
        .package(url: "https://github.com/pointfreeco/swift-dependencies", from: "1.0.0"),
        .package(url: "https://github.com/pointfreeco/swift-sharing", from: "2.10.1"),
        .package(url: "https://github.com/pointfreeco/swift-snapshot-testing", from: "1.18.9"),
    ],
    targets: [
        .target(
            name: "RegistryKit",
            dependencies: [.product(name: "Dependencies", package: "swift-dependencies")],
            swiftSettings: [.enableUpcomingFeature("NonisolatedNonsendingByDefault")]
        ),
        .executableTarget(
            name: "SwiftUIRegistryCLI",
            dependencies: ["RegistryKit", .product(name: "ArgumentParser", package: "swift-argument-parser")],
            swiftSettings: [.enableUpcomingFeature("NonisolatedNonsendingByDefault")]
        ),
        .testTarget(
            name: "RegistryKitTests",
            dependencies: ["RegistryKit", "SwiftUIRegistryCLI", .product(name: "InlineSnapshotTesting", package: "swift-snapshot-testing")],
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
