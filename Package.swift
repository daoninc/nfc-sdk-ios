// swift-tools-version:5.4
import PackageDescription

let package = Package(
    name: "DaonNFCSDK",
    platforms: [
        .iOS(.v13)
    ],
    products: [
        .library(
            name: "DaonNFCSDK",
            targets: [
                "DaonNFCSDK"
            ]
        ),
    ],
    targets: [
         .binaryTarget(
            name: "DaonNFCSDK",
            url: "https://github.com/daoninc/nfc-sdk-ios/releases/download/1.4.6/DaonNFCSDK.xcframework.zip",
            checksum: "bdf3de22930683dca126b37a25baf540cde2fbf7ac15e3d87838561e30c67005"
         ),
    ]
)
