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
    dependencies: [
        .package(url: "https://github.com/Snapp-Mobile/SnappTheming.git", from: "0.1.3"),
        .package(url: "https://github.com/Snapp-Mobile/SnappDesignTokens.git", from: "0.1.0"),
        .package(url: "https://github.com/Snapp-Mobile/SwiftFormatLintPlugin.git", from: "1.0.4"),
    ],
    targets: [
        .target(
            name: "SnappThemingDesignTokensSupport",
            dependencies: [
                "SnappTheming",
                "SnappDesignTokens",
            ],
            plugins: [
                .plugin(name: "Lint", package: "SwiftFormatLintPlugin")
            ]
        ),
        .testTarget(
            name: "SnappThemingDesignTokensSupportTests",
            dependencies: ["SnappThemingDesignTokensSupport"]
        ),
    ]
)
