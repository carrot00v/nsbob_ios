// swift-tools-version: 6.1
import PackageDescription

let package = Package(
    name: "CombineMVVMApp",
    platforms: [
        .iOS(.v15)
    ],
    products: [
        .executable(name: "CombineMVVMApp", targets: ["CombineMVVMApp"])
    ],
    targets: [
        .executableTarget(
            name: "CombineMVVMApp",
            path: "Sources/CombineMVVMApp"
        )
    ]
)
