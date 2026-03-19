// swift-tools-version:6.0
import PackageDescription

let package = Package(
    name: "LocalizeWiz",
    platforms: [
        .iOS(.v17),
        .tvOS(.v17),
        .macOS(.v14),
    ],
    products: [
        .library(
            name: "LocalizeWiz",
            targets: ["LocalizeWiz"]),
    ],
    dependencies: [],
    targets: [
        .target(
            name: "LocalizeWiz",
            dependencies: [],
            swiftSettings: [
                .swiftLanguageMode(.v6),
            ]
        ),
        .testTarget(
            name: "LocalizeWizTests",
            dependencies: ["LocalizeWiz"]),
    ]
)

