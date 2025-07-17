// swift-tools-version:5.5
import PackageDescription

let package = Package(
    name: "AurumFinance",
    platforms: [
        .iOS(.v15),
        .macOS(.v12)
    ],
    products: [
        .library(
            name: "AurumFinance",
            targets: ["AurumFinance"]),
    ],
    dependencies: [
        .package(url: "https://github.com/firebase/firebase-ios-sdk.git", from: "10.0.0"),
    ],
    targets: [
        .target(
            name: "AurumFinance",
            dependencies: [
                .product(name: "FirebaseAuth", package: "firebase-ios-sdk"),
                .product(name: "FirebaseFirestore", package: "firebase-ios-sdk")
            ]),
        .testTarget(
            name: "AurumFinanceTests",
            dependencies: ["AurumFinance"]),
    ]
) 