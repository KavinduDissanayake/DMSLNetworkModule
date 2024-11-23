// swift-tools-version: 5.7
import PackageDescription

let package = Package(
    name: "DMSLSwiftPackages",
    platforms: [
        .iOS(.v15)
    ],
    products: [
        //NetworkModule
        .library(
            name: "NetworkModule",
            targets: ["NetworkModule"]
        ),
        
        //AnalyticsModule
        .library(
            name: "AnalyticsModule",
            targets: ["AnalyticsModule"]
        ),
        
        //LocalizeModule
        .library(
            name: "LocalizeModule",
            targets: ["LocalizeModule"]
        ),
        
        //LoggerModule
        .library(
            name: "LoggerModule",
            targets: ["LoggerModule"]
        ),
        
    ],
    dependencies: [
        .package(url: "https://github.com/Alamofire/Alamofire", from: "5.4.0"),
        .package(url: "https://github.com/CleverTap/clevertap-ios-sdk", from: "6.2.1"),
        .package(url: "https://github.com/lokalise/lokalise-ios-framework.git", from: "1.0.2"),
    ],
    targets: [
        
        //NetworkModule
        .target(
            name: "NetworkModule",
            dependencies: [
                "LoggerModule",
                .product(name: "Alamofire", package: "Alamofire")
            ],
            path: "Sources/NetworkModule"
        ),
        .testTarget(
            name: "NetworkModuleTests",
            dependencies: ["NetworkModule"],
            path: "Tests/NetworkModuleTests"
        ),
        
        //AnalyticsModule
        .target(
            name: "AnalyticsModule",
            dependencies: [
                .product(name: "CleverTapSDK", package: "clevertap-ios-sdk")
            ],
            path: "Sources/AnalyticsModule"
        ),
        .testTarget(
            name: "AnalyticsModuleTests",
            dependencies: ["AnalyticsModule"],
            path: "Tests/AnalyticsModuleTests"
        ),
                
        // LocalizeModule
        .target(
            name: "LocalizeModule",
            dependencies: [
                "LoggerModule",
                .product(name: "Lokalise", package: "lokalise-ios-framework")  // Dependency on Lokalise
            ],
            path: "Sources/LocalizeModule"
        ),
        .testTarget(
            name: "LocalizeModuleTests",
            dependencies: ["LocalizeModule"],
            path: "Tests/LocalizeModuleTests"
        ),
        
        
        // LoggerModule
        .target(
            name: "LoggerModule",
            dependencies: [],
            path: "Sources/LoggerModule"
        ),
        .testTarget(
            name: "LoggerModuleTests",
            dependencies: ["LoggerModule"],
            path: "Tests/LoggerModuleTests"
        ),
    ]
)
