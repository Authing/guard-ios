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
            url: "https://github.com/Authing/guard-ios/releases/download/1.4.0/Guard.xcframework.zip",
            checksum: "bdd7edf1270daa4b8cbb1c7f552b63f41c65b9243dd711c2baeff3f1f6617bf2"
        )
    ]
)
