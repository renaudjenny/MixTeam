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
        .library(name: "PersistenceCore", targets: ["PersistenceCore"]),
        .library(name: "PlayersCore", targets: ["PlayersCore"]),
        .library(name: "ScoresCore", targets: ["ScoresCore"]),
        .library(name: "StyleCore", targets: ["StyleCore"]),
        .library(name: "TeamsCore", targets: ["TeamsCore"]),
    ],
    dependencies: [
        .package(url: "https://github.com/pointfreeco/swift-composable-architecture", from: "0.51.0")
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
        .target(
            name: "PersistenceCore",
            dependencies: [
                .product(name: "ComposableArchitecture", package: "swift-composable-architecture"),
            ]
        ),
        .target(
            name: "PlayersCore",
            dependencies: [
                "Assets",
                .product(name: "ComposableArchitecture", package: "swift-composable-architecture"),
                "ImagePicker",
                "PersistenceCore",
            ]
        ),
        .target(
            name: "ScoresCore",
            dependencies: [
                .product(name: "ComposableArchitecture", package: "swift-composable-architecture"),
                "PersistenceCore",
            ]
        ),
        .target(name: "StyleCore", dependencies: ["Assets"]),
        .target(
            name: "TeamsCore",
            dependencies: [
                "Assets",
                .product(name: "ComposableArchitecture", package: "swift-composable-architecture"),
                "ImagePicker",
                "PlayersCore",
                "PersistenceCore",
            ]
        ),
    ]
)
