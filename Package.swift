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
            url: "https://sdk.amity.co/sdk-release/ios-uikit-frameworks/4.0.0-beta29/AmitySDK.xcframework.zip",
            checksum: "59e9996a707e3ba630e53265157795b4f486b382ccfbcd833fd3cb2574310051"
        ),
        .binaryTarget(
            name: "Realm",
            url: "https://sdk.amity.co/sdk-release/ios-uikit-frameworks/4.0.0-beta29/Realm.xcframework.zip",
            checksum: "8c2b1e560b094f2d538f8a1ae59515a0137f34aade896bb81dca797633828c14"
        ),
        .binaryTarget(
            name: "RealmSwift",
            url: "https://sdk.amity.co/sdk-release/ios-uikit-frameworks/4.0.0-beta29/RealmSwift.xcframework.zip",
            checksum: "19eccbecdbed93e800539fd8f45cc1526fe9642440728b87990a8c0e4cbd2517"
        )
    ]
)
