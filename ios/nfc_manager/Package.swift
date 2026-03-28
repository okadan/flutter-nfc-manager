// swift-tools-version: 5.9
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "nfc_manager",
    platforms: [
        .iOS("13.0")
    ],
    products: [
        .library(name: "nfc-manager", targets: ["nfc_manager"])
    ],
    dependencies: [],
    targets: [
        .target(
            name: "nfc_manager",
            dependencies: [],
            resources: []
        )
    ]
)
