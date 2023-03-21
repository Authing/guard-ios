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
            url: "https://github.com/Authing/guard-ios/releases/download/1.4.3/Guard.xcframework.zip",
            checksum: "5379a9be48ad7a57c2713d4dad3a3011e245f08db295c7a3a088a99eb8e22849"
        )
    ]
)
