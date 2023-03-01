// swift-tools-version: 5.7
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "MixTeam",
    platforms: [.iOS(.v15)],
    products: [
        .library(name: "ImagePicker", targets: ["ImagePicker"]),
    ],
    dependencies: [
    ],
    targets: [
        .target(name: "ImagePicker", dependencies: []),
    ]
)
