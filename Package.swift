// swift-tools-version: 5.7
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "MixTeam",
    platforms: [.iOS(.v15), .macOS(.v12)],
    products: [
        .library(name: "ArchivesFeature", targets: ["ArchivesFeature"]),
        .library(name: "Assets", targets: ["Assets"]),
        .library(name: "ImagePicker", targets: ["ImagePicker"]),
        .library(name: "LoaderCore", targets: ["LoaderCore"]),
        .library(name: "Models", targets: ["Models"]),
        .library(name: "PersistenceCore", targets: ["PersistenceCore"]),
        .library(name: "PlayersFeature", targets: ["PlayersFeature"]),
        .library(name: "ScoresFeature", targets: ["ScoresFeature"]),
        .library(name: "StyleCore", targets: ["StyleCore"]),
        .library(name: "TeamsCore", targets: ["TeamsCore"]),
    ],
    dependencies: [
        .package(url: "https://github.com/pointfreeco/swift-composable-architecture", from: "0.51.0"),
        .package(url: "https://github.com/pointfreeco/swiftui-navigation", from: "0.6.1"),
    ],
    targets: [
        .target(
            name: "ArchivesFeature",
            dependencies: [
                .product(name: "ComposableArchitecture", package: "swift-composable-architecture"),
                "LoaderCore",
                "TeamsCore",
            ]
        ),
        .testTarget(name: "ArchivesFeatureTests", dependencies: ["ArchivesFeature"]),
        .target(name: "Assets", dependencies: [], resources: [.process("Illustrations.xcassets")]),
        .target(
            name: "ImagePicker",
            dependencies: [
                "Assets",
                .product(name: "ComposableArchitecture", package: "swift-composable-architecture"),
            ]
        ),
        .testTarget(name: "ImagePickerTests", dependencies: ["ImagePicker"]),
        .target(
            name: "LoaderCore",
            dependencies: [
                "Assets",
                .product(name: "ComposableArchitecture", package: "swift-composable-architecture"),
                "StyleCore"
            ]
        ),
        .target(name: "Models", dependencies: ["Assets"]),
        .target(
            name: "PersistenceCore",
            dependencies: [
                .product(name: "ComposableArchitecture", package: "swift-composable-architecture"),
                "Models",
            ]
        ),
        .target(
            name: "PlayersFeature",
            dependencies: [
                "Assets",
                .product(name: "ComposableArchitecture", package: "swift-composable-architecture"),
                "ImagePicker",
                "PersistenceCore",
            ]
        ),
        .testTarget(name: "PlayersFeatureTests", dependencies: ["PlayersFeature"]),
        .target(
            name: "ScoresFeature",
            dependencies: [
                .product(name: "ComposableArchitecture", package: "swift-composable-architecture"),
                "PersistenceCore",
                .product(name: "SwiftUINavigation", package: "swiftui-navigation"),
                "TeamsCore",
            ]
        ),
        .testTarget(name: "ScoresFeatureTests", dependencies: ["ScoresFeature"]),
        .target(name: "StyleCore", dependencies: ["Assets"]),
        .target(
            name: "TeamsCore",
            dependencies: [
                "Assets",
                .product(name: "ComposableArchitecture", package: "swift-composable-architecture"),
                "ImagePicker",
                "PlayersFeature",
                "PersistenceCore",
            ]
        ),
    ]
)
