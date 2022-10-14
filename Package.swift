// swift-tools-version:5.3
import PackageDescription

let package = Package(
    name: "Guard",
    defaultLocalization: "en",
    platforms: [
        .macOS(.v10_14), .iOS(.v11), .tvOS(.v13)
    ],
    products: [
        .library(
            name: "Guard",
            targets: ["Guard"])
    ],
    dependencies: [
    ],
    targets: [
        .binaryTarget(
            name: "Guard",
            url: "https://github.com/Authing/guard-ios/releases/download/1.3.3/Guard.xcframework.zip",
            checksum: "6b65212e983eb4252c93aefe6e5cd94e5d8ae5f98a08aa1136db5ac6fde37de6"
        )
    ]
)
