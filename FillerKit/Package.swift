// swift-tools-version: 5.6

import PackageDescription

let package = Package(
    name: "FillerKit",
    products: [
        .library(
            name: "FillerKit",
            targets: ["FillerKit"]
        ),
    ],
    dependencies: [],
    targets: [
        .target(
            name: "FillerKit"
        ),
        .testTarget(
            name: "FillerKitTests",
            dependencies: ["FillerKit"]
        ),
    ]
)
