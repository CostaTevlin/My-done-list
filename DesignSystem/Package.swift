// swift-tools-version: 6.0
// DesignSystem — local Swift package shared by app + widget.
// Hosts color asset catalog + typography scale + spacing/radius/motion tokens.
//
// See: design-system/Tokens.md  ·  design-system/Components.md

import PackageDescription

let package = Package(
    name: "DesignSystem",
    platforms: [
        .iOS(.v18),
        .macOS(.v14)   // host-builds only; app ships iOS-only
    ],
    products: [
        .library(name: "DesignSystem", targets: ["DesignSystem"])
    ],
    targets: [
        .target(
            name: "DesignSystem",
            path: "Sources/DesignSystem",
            resources: [
                .process("Resources")
            ]
        ),
        .testTarget(
            name: "DesignSystemTests",
            dependencies: ["DesignSystem"],
            path: "Tests/DesignSystemTests"
        )
    ]
)
