// swift-tools-version: 5.7
import PackageDescription

let package = Package(
    name: "DMSLNetworkModule",
    platforms: [
        .iOS(.v14) // Update the platform version if needed
    ],
    products: [
        .library(
            name: "DMSLNetworkModule",
            targets: ["DMSLNetworkModule"]
        ),
    ],
    dependencies: [
        // Add Alamofire as a dependency
        .package(url: "https://github.com/Alamofire/Alamofire.git", from: "5.6.0"),
    ],
    targets: [
        .target(
            name: "DMSLNetworkModule",
            dependencies: ["Alamofire"]
        ),
        .testTarget(
            name: "DMSLNetworkModuleTests",
            dependencies: ["DMSLNetworkModule"]
        ),
    ]
)
