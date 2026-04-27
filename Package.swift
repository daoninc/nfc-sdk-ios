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
            url: "https://github.com/daoninc/nfc-sdk-ios/releases/download/1.4.8/DaonNFCSDK.xcframework.zip",
            checksum: "677d1a3a432d0c9d2ac498895006dc88d154b9ac21a4efa88c2b56890b9c02ed"
         ),
    ]
)
