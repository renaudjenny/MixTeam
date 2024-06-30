// swift-tools-version: 5.10
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "MixTeam",
    platforms: [.iOS(.v17), .macOS(.v14)],
    products: [
        .library(name: "AppFeature", targets: ["AppFeature"]),
        .library(name: "ArchivesFeature", targets: ["ArchivesFeature"]),
        .library(name: "Assets", targets: ["Assets"]),
        .library(name: "CompositionFeature", targets: ["CompositionFeature"]),
        .library(name: "ImagePicker", targets: ["ImagePicker"]),
        .library(name: "LoaderCore", targets: ["LoaderCore"]),
        .library(name: "Models", targets: ["Models"]),
        .library(name: "PersistenceCore", targets: ["PersistenceCore"]),
        .library(name: "PlayersFeature", targets: ["PlayersFeature"]),
        .library(name: "ScoresFeature", targets: ["ScoresFeature"]),
        .library(name: "SettingsFeature", targets: ["SettingsFeature"]),
        .library(name: "StyleCore", targets: ["StyleCore"]),
        .library(name: "TeamsFeature", targets: ["TeamsFeature"]),
    ],
    dependencies: [
        .package(url: "https://github.com/pointfreeco/swift-composable-architecture", from: "1.11.2"),
        .package(url: "https://github.com/renaudjenny/RenaudJennyAboutView", branch: "main"),
    ],
    targets: [
        .target(
            name: "AppFeature",
            dependencies: [
                .product(name: "ComposableArchitecture", package: "swift-composable-architecture"),
                "CompositionFeature",
                "PersistenceCore",
                "ScoresFeature",
                "SettingsFeature",
            ]
        ),
        .testTarget(name: "AppFeatureTests", dependencies: ["AppFeature"]),
        .target(
            name: "ArchivesFeature",
            dependencies: [
                .product(name: "ComposableArchitecture", package: "swift-composable-architecture"),
                "LoaderCore",
                "TeamsFeature",
            ]
        ),
        .testTarget(name: "ArchivesFeatureTests", dependencies: ["ArchivesFeature"]),
        .target(name: "Assets", dependencies: [], resources: [.process("Illustrations.xcassets")]),
        .target(
            name: "CompositionFeature",
            dependencies: [
                .product(name: "ComposableArchitecture", package: "swift-composable-architecture"),
                "LoaderCore",
                "Models",
                "PersistenceCore",
                "PlayersFeature",
                "StyleCore",
                "TeamsFeature",
            ]
        ),
        .testTarget(name: "CompositionFeatureTests", dependencies: ["CompositionFeature"]),
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
                "StyleCore",
            ]
        ),
        .target(name: "Models", dependencies: [        
            .product(name: "ComposableArchitecture", package: "swift-composable-architecture"),
            "Assets",
        ]),
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
                "Models",
                "PersistenceCore",
                "StyleCore",
            ]
        ),
        .testTarget(name: "PlayersFeatureTests", dependencies: ["PlayersFeature"]),
        .target(
            name: "ScoresFeature",
            dependencies: [
                .product(name: "ComposableArchitecture", package: "swift-composable-architecture"),
                "PersistenceCore",
                "TeamsFeature",
            ]
        ),
        .testTarget(name: "ScoresFeatureTests", dependencies: ["ScoresFeature"]),
        .target(
            name: "SettingsFeature",
            dependencies: [
                "ArchivesFeature",
                .product(name: "ComposableArchitecture", package: "swift-composable-architecture"),
                "PersistenceCore",
                .product(name: "RenaudJennyAboutView", package: "RenaudJennyAboutView"),
            ]
        ),
        .testTarget(name: "SettingsFeatureTests", dependencies: ["SettingsFeature"]),
        .target(name: "StyleCore", dependencies: ["Assets"]),
        .target(
            name: "TeamsFeature",
            dependencies: [
                "Assets",
                .product(name: "ComposableArchitecture", package: "swift-composable-architecture"),
                "ImagePicker",
                "PlayersFeature",
                "PersistenceCore",
            ]
        ),
        .testTarget(name: "TeamsFeatureTests", dependencies: ["TeamsFeature"]),
    ]
)
