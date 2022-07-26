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
        .package(url: "https://github.com/ajamaica/Solana.swift", revision: "f487b25"),
        .package(
                url: "https://github.com/Flight-School/AnyCodable",
                from: "0.6.0"
            ),
//        .package(name: "OpenAPIClient", path: "../Kinetic/Sources/OpenAPIClient"),
    ],
    targets: [
        .target(
            name: "Kinetic",
            dependencies: [
                .product(name: "Solana", package: "Solana.swift"),
                .product(name: "AnyCodable", package: "AnyCodable")
//                .product(name: "OpenAPIClient", package: "OpenAPIClient")
            ],
            path: "Kinetic/Sources/Kinetic",
    ),
        .testTarget(
            name: "KineticTests",
            dependencies: ["Kinetic"]),
    ]
)
