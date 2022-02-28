// swift-tools-version:5.3
import PackageDescription

let package = Package(
    name: "Guard",
    defaultLocalization: "en",
    platforms: [
        .macOS(.v10_14), .iOS(.v13), .tvOS(.v13)
    ],
    products: [
        .library(
            name: "Guard",
            targets: ["Guard"])
    ],
    dependencies: [
    ],
    targets: [
        .target(
            name: "Guard",
            path: "Guard",
            cSettings: [
                .headerSearchPath("Guard/Library"),
                .headerSearchPath("Guard/Frameworks/Headers")
            ]
        )
    ]
)
