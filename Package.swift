// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "Macodoro",
    platforms: [.macOS(.v14)],
    targets: [
        .target(
            name: "MacodoroCore",
            path: "Sources/MacodoroCore"
        ),
        .executableTarget(
            name: "Macodoro",
            dependencies: ["MacodoroCore"],
            path: "Sources/Macodoro"
        ),
        .testTarget(
            name: "MacodoroTests",
            dependencies: ["MacodoroCore"],
            path: "Tests/MacodoroTests"
        ),
    ]
)
