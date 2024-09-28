// swift-tools-version: 6.0
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

private let packageName = "SwiftyReceiptValidator"

let package = Package(
    name: packageName,
    platforms: [.iOS(.v13), .tvOS(.v13), .macOS(.v10_15)],
    products: [.library(name: packageName, targets: [packageName])],
    targets: [
        .target(name: packageName, path: "Sources"),
        .testTarget(name: packageName + "Tests", dependencies: ["SwiftyReceiptValidator"], path: "Tests", resources: [.process("TestHelpers/Resources")])
    ],
    swiftLanguageModes: [.v5, .v6]
)
