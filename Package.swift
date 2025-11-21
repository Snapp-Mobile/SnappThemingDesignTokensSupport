// swift-tools-version: 6.2

import PackageDescription

let package = Package(
    name: "SnappThemingDesignTokensSupport",
    platforms: [
        .iOS(.v16),
        .macOS(.v13),
    ],
    products: [
        .library(
            name: "SnappThemingDesignTokensSupport",
            targets: ["SnappThemingDesignTokensSupport"]
        ),
    ],
    targets: [
        .target(
            name: "SnappThemingDesignTokensSupport"
        ),
        .testTarget(
            name: "SnappThemingDesignTokensSupportTests",
            dependencies: ["SnappThemingDesignTokensSupport"]
        ),
    ]
)
