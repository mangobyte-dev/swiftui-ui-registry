// swift-tools-version: 6.2

import PackageDescription

let package = Package(
    name: "SwiftUIRegistry",
    platforms: [
        .iOS(.v18)
    ],
    products: [
        .library(
            name: "SwiftUIRegistryFoundations",
            targets: ["SwiftUIRegistryFoundations"]
        )
    ],
    targets: [
        .target(name: "SwiftUIRegistryFoundations"),
        .testTarget(
            name: "SwiftUIRegistryFoundationsTests",
            dependencies: ["SwiftUIRegistryFoundations"]
        )
    ]
)
