// swift-tools-version:5.1
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

private let packageName = "SwiftyReceiptValidator"

let package = Package(
    name: packageName,
    platforms: [.iOS(.v11)],
    products: [.library(name: packageName, targets: [packageName])],
    targets: [.target(name: packageName, path: packageName)],
    swiftLanguageVersions: [.v5]
)
