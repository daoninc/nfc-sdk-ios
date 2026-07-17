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
            url: "https://github.com/daoninc/nfc-sdk-ios/releases/download/1.4.11/DaonNFCSDK.xcframework.zip",
            checksum: "0ed3b8a914ab67b9b83a5abc97f20a75b728a2b7ab488782d93d748b9ce557aa"
         ),
    ]
)
