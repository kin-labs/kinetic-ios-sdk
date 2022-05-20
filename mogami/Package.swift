// swift-tools-version:5.5
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "Mogami",
    platforms: [
        .iOS(.v11),
        .macOS(.v10_12)
    ],
    products: [
        .library(
            name: "Mogami",
            targets: ["Mogami"]),
    ],
    dependencies: [
         .package(url: "https://github.com/ajamaica/Solana.swift", from: "1.1.0"),
         .package(name: "OpenAPIClient", path: "../OpenAPIClient"),
    ],
    targets: [
        .target(
            name: "Mogami",
            dependencies: [
                .product(name: "Solana", package: "Solana.swift"),
                .product(name: "OpenAPIClient", package: "OpenAPIClient")
            ]),
        .testTarget(
            name: "MogamiTests",
            dependencies: ["Mogami"]),
    ]
)
