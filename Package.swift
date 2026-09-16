// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "LockIn",
    platforms: [
        .macOS(.v14)
    ],
    products: [
        .executable(name: "LockIn", targets: ["LockIn"])
    ],
    targets: [
        .executableTarget(
            name: "LockIn",
            path: "Sources/LockIn"
        )
    ]
)
