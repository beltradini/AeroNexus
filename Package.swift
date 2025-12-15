// swift-tools-version:6.0
import PackageDescription

let package = Package(
    name: "AeroNexus",
    platforms: [
        .macOS(.v14),
        .iOS(.v17)
    ],
    products: [
        .executable(name: "AeroNexusAPI", targets: ["AeroNexusAPI"]),
        .executable(name: "AeroNexusCLI", targets: ["AeroNexusCLI"]),
        .library(name: "AeroNexusCore", targets: ["AeroNexusCore"])
    ],
    dependencies: [
        .package(url: "https://github.com/vapor/vapor.git", from: "4.115.0"),
        .package(url: "https://github.com/vapor/fluent.git", from: "4.9.0"),
        .package(url: "https://github.com/vapor/fluent-sqlite-driver.git", from: "4.0.0"),
        .package(url: "https://github.com/vapor/fluent-postgres-driver.git", from: "2.0.0"),
        .package(url: "https://github.com/swift-server/RediStack.git", from: "1.0.0"),
        .package(url: "https://github.com/apple/swift-nio.git", from: "2.65.0"),
        .package(url: "https://github.com/apple/swift-argument-parser.git", from: "1.2.0"),
        .package(url: "https://github.com/apple/swift-log.git", from: "1.5.0")
    ],
    targets: [
        // Core Module - Business logic and models
        .target(
            name: "AeroNexusCore",
            dependencies: [
                .product(name: "Fluent", package: "fluent"),
                .product(name: "FluentSQLiteDriver", package: "fluent-sqlite-driver"),
                .product(name: "FluentPostgresDriver", package: "fluent-postgres-driver"),
                .product(name: "RediStack", package: "RediStack"),
                .product(name: "Logging", package: "swift-log")
            ],
            path: "Sources/AeroNexusCore",
            swiftSettings: swiftSettings
        ),
        
        // API Module - Vapor web services
        .executableTarget(
            name: "AeroNexusAPI",
            dependencies: [
                .target(name: "AeroNexusCore"),
                .product(name: "Vapor", package: "vapor"),
                .product(name: "RediStack", package: "RediStack"),
                .product(name: "NIOCore", package: "swift-nio"),
                .product(name: "NIOPosix", package: "swift-nio")
            ],
            path: "Sources/AeroNexusAPI",
            swiftSettings: swiftSettings
        ),
        
        // CLI Module - Command line interface
        .executableTarget(
            name: "AeroNexusCLI",
            dependencies: [
                .target(name: "AeroNexusCore"),
                .product(name: "ArgumentParser", package: "swift-argument-parser"),
                .product(name: "Logging", package: "swift-log")
            ],
            path: "Sources/AeroNexusCLI",
            swiftSettings: swiftSettings
        ),
        
        // Test Targets
        .testTarget(
            name: "AeroNexusCoreTests",
            dependencies: [
                .target(name: "AeroNexusCore"),
                .product(name: "XCTVapor", package: "vapor"),
                .product(name: "VaporTesting", package: "vapor")
            ],
            path: "Tests/AeroNexusCoreTests",
            swiftSettings: swiftSettings
        ),
        
        .testTarget(
            name: "AeroNexusAPITests",
            dependencies: [
                .target(name: "AeroNexusAPI"),
                .product(name: "XCTVapor", package: "vapor"),
                .product(name: "VaporTesting", package: "vapor")
            ],
            path: "Tests/AeroNexusAPITests",
            swiftSettings: swiftSettings
        )
    ]
)

var swiftSettings: [SwiftSetting] { [
    .enableUpcomingFeature("ExistentialAny"),
    .enableExperimentalFeature("StrictConcurrency")
] }
