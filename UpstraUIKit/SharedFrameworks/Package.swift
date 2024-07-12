// swift-tools-version: 5.7
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "SharedFrameworks",
    products: [
        .library(
            name: "SharedFrameworks",
            targets: [
                "SharedFrameworks",
                "AmitySDK",
                "Realm",
                "RealmSwift"
            ]
        ),
    ],
    dependencies: [],
    targets: [
        .target(
            name: "SharedFrameworks",
            dependencies: []),
        .binaryTarget(
                    name: "AmitySDK",
                    url: "https://sdk.amity.co/sdk-release/ios-uikit-frameworks/3.20.7/AmitySDK.xcframework.zip",
                    checksum: "64fa391f50185357e99f2a7808e293638a34f4d729defc7eba669b66c0da8fcd"
                ),
        .binaryTarget(
                    name: "Realm",
                    url: "https://sdk.amity.co/sdk-release/ios-uikit-frameworks/3.20.7/Realm.xcframework.zip",
                    checksum: "576831b9099d51f3f1f74fb32846e98aebb56bdc473bee29a54feaf6a51ade9a"
                ),
         .binaryTarget(
                    name: "RealmSwift",
                    url: "https://sdk.amity.co/sdk-release/ios-uikit-frameworks/3.20.7/RealmSwift.xcframework.zip",
                    checksum: "0452dea625e0d6b3e674ae28cff5ab7fcf4442bfd5cb796190fd05b4f42ecb5e"
                )
    ]
)

