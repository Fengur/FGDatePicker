// swift-tools-version: 5.9
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "FGDatePicker",
    platforms: [
        .iOS(.v16)
    ],
    products: [
        .library(
            name: "FGDatePicker",
            targets: ["FGDatePicker"]
        )
    ],
    targets: [
        .target(
            name: "FGDatePicker",
            path: "Sources/FGDatePicker"
        ),
        .testTarget(
            name: "FGDatePickerTests",
            dependencies: ["FGDatePicker"],
            path: "Tests/FGDatePickerTests"
        )
    ]
)
