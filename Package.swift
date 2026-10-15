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
            url: "https://github.com/daoninc/nfc-sdk-ios/releases/download/1.4.15/DaonNFCSDK.xcframework.zip",
            checksum: "82f87b2f0020398eecef27f2240ec365cc9276bfbf4aa92c84173f32824c2b06"
         ),
    ]
)
