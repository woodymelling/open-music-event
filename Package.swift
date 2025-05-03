// swift-tools-version: 6.0
// This is a Skip (https://skip.tools) package.
import PackageDescription

let package = Package(
    name: "open-music-event",
    defaultLocalization: "en",
    platforms: [.iOS(.v18)],
    products: [
        .library(name: "OpenMusicEvent", type: .dynamic, targets: ["OpenMusicEvent"]),
    ],
    dependencies: [
        .package(url: "https://source.skip.tools/skip.git", from: "1.5.0"),
        .package(url: "https://source.skip.tools/skip-fuse-ui.git", "0.0.0"..<"2.0.0")
    ],
    targets: [
        .target(
            name: "OpenMusicEvent",
            dependencies: [
                "OpenMusicEventModels",
                .product(name: "SkipFuseUI", package: "skip-fuse-ui")
            ],
            plugins: [
                .plugin(name: "skipstone", package: "skip")
            ]
        ),
        .target(name: "OpenMusicEventModels"),
    ]
)
