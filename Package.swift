// swift-tools-version:5.5
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "Kinetic",
    platforms: [
        .iOS(.v13),
        .macOS(.v10_12)
    ],
    products: [
        .library(
            name: "Kinetic",
            targets: ["Kinetic"]),
    ],
    dependencies: [
        .package(url: "https://github.com/metaplex-foundation/Solana.swift", from: "2.0.1"),
        .package(
                url: "https://github.com/Flight-School/AnyCodable",
                from: "0.6.0"
            ),
    ],
    targets: [
        .target(
            name: "Kinetic",
            dependencies: [
                .product(name: "Solana", package: "Solana.swift"),
                .product(name: "AnyCodable", package: "AnyCodable")
            ]),
        .testTarget(
            name: "KineticTests",
            dependencies: ["Kinetic"]),
    ]
)
