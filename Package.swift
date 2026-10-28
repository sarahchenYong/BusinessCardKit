// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "BusinessCardKit",
    defaultLocalization: "en",
    platforms: [
        .iOS(.v16)
    ],
    products: [
        .library(name: "BusinessCardKit", targets: ["BusinessCardKit"])
    ],
    targets: [
        .target(
            name: "BusinessCardKit",
            resources: [
                // Client-editable Interface Builder layouts for the card faces.
                .process("Resources")
            ]
        ),
        .testTarget(name: "BusinessCardKitTests", dependencies: ["BusinessCardKit"])
    ]
)
