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
            url: "https://github.com/Authing/guard-ios/releases/download/1.3.4/Guard.xcframework.zip",
            checksum: "6b40e4139a98e37475d9369a8a50169f2d8b9c391b3590c7b93498d8fa446859"
        )
    ]
)
