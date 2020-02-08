// swift-tools-version:5.1
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "SwiftyReceiptValidator",
    platforms: [.iOS(.v11)],
    products: [.library(name: "SwiftyReceiptValidator", targets: ["SwiftyReceiptValidator"])],
    targets: [.target(name: "SwiftyReceiptValidator", path: "Sources")],
    swiftLanguageVersions: [.v5]
)
