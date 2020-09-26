// swift-tools-version:5.3
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

private let packageName = "SwiftyReceiptValidator"

let package = Package(
    name: packageName,
    defaultLocalization: "en",
    platforms: [.iOS(.v11), .tvOS(.v11)],
    products: [.library(name: packageName, targets: [packageName])],
    targets: [
        .target(
            name: packageName,
            path: "Sources",
            resources: [.process("Resources")]
        )
    ],
    swiftLanguageVersions: [.v5]
)
