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
            url: "https://github.com/daoninc/nfc-sdk-ios/releases/download/1.4.20/DaonNFCSDK.xcframework.zip",
            checksum: "ae6c3cbca467e2e9eddf715bc3fb7e10dd785cac13906e5851f7a871bf297452"
         ),
    ]
)
