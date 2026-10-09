// swift-tools-version: 6.4
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "NotificationRequest",
    defaultLocalization: "en",
    platforms: [.iOS(.v26), .macOS(.v26)],
    products: [
        .library(
            name: "NotificationRequestUI",
            targets: ["NotificationRequestUI"]
        ),
        .library(
            name: "NotificationRequest",
            targets: ["NotificationRequest"]
        ),
    ],
    targets: [
        .target(
            name: "NotificationRequestUI",
            resources: [
                .process("Resources")
            ],
            swiftSettings: [
                .enableUpcomingFeature("ApproachableConcurrency"),
            ],
        ),
        .target(
            name: "NotificationRequest",
            swiftSettings: [
                .enableUpcomingFeature("ApproachableConcurrency"),
            ],
        ),
        .testTarget(
            name: "NotificationRequestTests",
            dependencies: ["NotificationRequest"],
            swiftSettings: [
                .enableUpcomingFeature("ApproachableConcurrency"),
            ],
        ),
    ]
)
