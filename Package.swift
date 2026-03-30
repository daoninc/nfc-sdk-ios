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
            url: "https://github.com/daoninc/nfc-sdk-ios/releases/download/1.3.12/DaonNFCSDK.xcframework.zip",
            checksum: "eaf98e5c573b105791c3368e08076f3849f3c33401578ebaae8f96b4f62d608b"
         ),
    ]
)
