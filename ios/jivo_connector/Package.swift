// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "jivo_connector",
    platforms: [
        // JivoSDK's own package asks for 15.
        .iOS("15.0")
    ],
    products: [
        .library(name: "jivo-connector", targets: ["jivo_connector"])
    ],
    dependencies: [
        .package(url: "https://github.com/JivoChat/JivoSDK-iOS.git", .upToNextMinor(from: "5.3.2"))
    ],
    targets: [
        .target(
            name: "jivo_connector",
            dependencies: [
                .product(name: "JivoSDK", package: "JivoSDK-iOS")
            ]
        )
    ]
)
