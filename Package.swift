// swift-tools-version: 5.9

import PackageDescription

let package = Package(
    name: "Shiso8211",
    platforms: [
        .iOS(.v14), .macOS(.v11), .macCatalyst(.v14)
    ],
    products: [
        .library(name: "Shiso8211", targets: ["Shiso8211"]),
    ],
    dependencies: [],
    targets: [
        .target(name: "Shiso8211", dependencies: []),
    ]
)
