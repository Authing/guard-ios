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
            url: "https://github.com/Authing/guard-ios/releases/download/1.4.8/Guard.xcframework.zip",
            checksum: "f6cef2a784cbd2a6791d30b3d9fd146be4f2e5cc610a768b6a7eaf54319fd3ab"
        )
    ]
)
