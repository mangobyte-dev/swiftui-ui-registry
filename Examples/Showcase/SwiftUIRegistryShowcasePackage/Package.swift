// swift-tools-version: 6.2

import PackageDescription

let package = Package(
    name: "SwiftUIRegistryShowcaseFeature",
    platforms: [
        .iOS(.v18)
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
        )
    ]
)
