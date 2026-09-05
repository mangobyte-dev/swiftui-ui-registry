// swift-tools-version: 6.2

import PackageDescription

let package = Package(
    name: "SwiftUIRegistryShowcaseFeature",
    platforms: [
        .iOS(.v26)
    ],
    products: [
        .library(
            name: "SwiftUIRegistryShowcaseFeature",
            targets: ["SwiftUIRegistryShowcaseFeature"]
        )
    ],
    dependencies: [
        .package(name: "SwiftUIRegistry", path: "../../..")
    ],
    targets: [
        .target(
            name: "SwiftUIRegistryShowcaseFeature",
            dependencies: [
                .product(
                    name: "SwiftUIRegistryFoundations",
                    package: "SwiftUIRegistry"
                )
            ]
        ),
        .testTarget(
            name: "SwiftUIRegistryShowcaseFeatureTests",
            dependencies: ["SwiftUIRegistryShowcaseFeature"]
        )
    ]
)
