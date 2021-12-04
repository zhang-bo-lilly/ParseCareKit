// swift-tools-version:5.5
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "ParseCareKit",
    platforms: [.iOS(.v15), .watchOS(.v8), .macOS(.v12), .tvOS(.v15)],
    products: [
        .library(
            name: "ParseCareKit",
            targets: ["ParseCareKit"])
    ],
    dependencies: [
        // Dependencies declare other packages that this package depends on.
        .package(name: "CareKit", url: "https://github.com/cbaker6/CareKit.git",
                 .revision("52f6b4e6734d49124db54c83f552a6a1c3e26469")),
        .package(name: "ParseSwift", url: "https://github.com/parse-community/Parse-Swift", from: "2.3.1")
    ],
    targets: [
        .target(
            name: "ParseCareKit",
            dependencies: ["ParseSwift", .product(name: "CareKitStore", package: "CareKit")]),
        .testTarget(
            name: "ParseCareKitTests",
            dependencies: ["ParseCareKit"])
    ]
)
