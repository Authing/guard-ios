// swift-tools-version:5.3
import PackageDescription

let package = Package(
    name: "Guard",
    defaultLocalization: "en",
    platforms: [
        .macOS(.v10_14), .iOS(.v10), .tvOS(.v13)
    ],
    products: [
        .library(
            name: "Guard",
            type: .dynamic,
            targets: ["Guard"])
    ],
    dependencies: [
    ],
    targets: [
        .target(
            name: "Guard",
            path: "Guard/Guard"
        )
    ]
)