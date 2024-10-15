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
            url: "https://sdk.amity.co/sdk-release/ios-uikit-frameworks/4.0.0-beta25/AmitySDK.xcframework.zip",
            checksum: "63d0b5f205d90478a621c00449fadbf821afdc5b6b4d29ced5fae633e327face"
        ),
        .binaryTarget(
            name: "Realm",
            url: "https://sdk.amity.co/sdk-release/ios-uikit-frameworks/4.0.0-beta25/Realm.xcframework.zip",
            checksum: "1e5c3b81e229b47751f00e501c54a84d1ef445607ed5c4af7dc6dbc459f3fa01"
        ),
        .binaryTarget(
            name: "RealmSwift",
            url: "https://sdk.amity.co/sdk-release/ios-uikit-frameworks/4.0.0-beta25/RealmSwift.xcframework.zip",
            checksum: "12acc2b0e8e9e2999d6bb459e41eaf9e04131b4ab8e2cb68ea33a547dfc16035"
        )
    ]
)
