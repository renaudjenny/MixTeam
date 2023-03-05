// swift-tools-version: 5.7
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "MixTeam",
    platforms: [.iOS(.v15), .macOS(.v12)],
    products: [
        .library(name: "Assets", targets: ["Assets"]),
        .library(name: "ImagePicker", targets: ["ImagePicker"]),
        .library(name: "LoaderCore", targets: ["LoaderCore"]),
        .library(name: "StyleCore", targets: ["StyleCore"]),
    ],
    dependencies: [
        .package(url: "https://github.com/pointfreeco/swift-composable-architecture", from: "0.51.0")
    ],
    targets: [
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
        .target(name: "StyleCore", dependencies: ["Assets"])
    ]
)
