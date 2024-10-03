// swift-tools-version: 5.7

import PackageDescription

let package = Package(
    name: "AmityUIKit",
    defaultLocalization: "en",
    platforms: [.iOS("14.0")],
    products: [
        .library(
            name: "AmityUIKit",
            targets: ["AmityUIKit", "AmitySDK", "Realm", "RealmSwift"]),
    ],
    dependencies: [],
    targets: [
        .target(
            name: "AmityUIKit",
            resources: [.process("Resources")]
        ),
        .binaryTarget(
            name: "AmitySDK",
            url: "https://sdk.amity.co/sdk-release/ios-uikit-frameworks/4.0.0-beta22/AmitySDK.xcframework.zip",
            checksum: "6bcf31f0cfd985c4edd0f127946e780897d9128937c1be9e83e3e78a8dd6822e"
        ),
        .binaryTarget(
            name: "Realm",
            url: "https://sdk.amity.co/sdk-release/ios-uikit-frameworks/4.0.0-beta22/Realm.xcframework.zip",
            checksum: "f20d3f0d637cdc9c6856f3b488d98feffa5e8fbdd33799077040ef94e86ba049"
        ),
        .binaryTarget(
            name: "RealmSwift",
            url: "https://sdk.amity.co/sdk-release/ios-uikit-frameworks/4.0.0-beta22/RealmSwift.xcframework.zip",
            checksum: "8bc02587f2af1160984347574f1b400a89b398ee38e2bc9184a7f1b435450028"
        )
    ]
)
