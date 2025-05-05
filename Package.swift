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
//        .package(url: "https://source.skip.tools/skip.git", from: "1.5.0"),
//        .package(url: "https://source.skip.tools/skip-fuse-ui.git", "0.0.0"..<"2.0.0"),
        .package(url: "https://github.com/kean/Nuke", from: "12.8.0"),
        .package(url: "https://github.com/pointfreeco/sharing-grdb", from: "0.2.0")
    ],
    targets: [
        .target(
            name: "OpenMusicEvent",
            dependencies: [
                .product(name: "Nuke", package: "Nuke"),
                .product(name: "SharingGRDB", package: "sharing-grdb")
            ],
            plugins: [
//                .plugin(name: "skipstone", package: "skip")
            ]
        ),
    ]
)
