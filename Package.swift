// swift-tools-version: 6.1
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
        .package(url: "https://github.com/pointfreeco/swift-composable-architecture", from: "1.17.0"),
        .package(url: "https://github.com/pointfreeco/swift-custom-dump", from: "1.3.3"),
        .package(url: "https://github.com/pointfreeco/swift-dependencies", from: "1.4.1"),
        .package(url: "https://github.com/pointfreeco/swift-identified-collections", from: "1.0.0"),
        .package(url: "https://github.com/pointfreeco/swift-tagged", from: "0.10.0"),
        .package(url: "https://github.com/pointfreeco/swift-validated", from: "0.2.0"),
        .package(url: "https://github.com/pointfreeco/swift-prelude", branch: "main"),
        .package(url: "https://github.com/woodymelling/swift-parsing", from: "0.1.0"),
        .package(url: "https://github.com/pointfreeco/swift-navigation", from: "2.3.0"),

        .package(url: "https://github.com/apple/swift-collections", from: "1.0.4"),

        .package(url: "https://github.com/pointfreeco/sharing-grdb", from: "0.2.0"),
        .package(url: "https://github.com/woodymelling/swift-image-caching", branch: "trunk"),
        .package(url: "https://github.com/woodymelling/swift-file-tree", from: "0.2.0"),
        .package(url: "https://github.com/woodymelling/swift-frontmatter-parsing", from: "0.1.0"),
        .package(url: "https://github.com/weichsel/ZIPFoundation", from: "0.9.0"),
        .package(url: "https://github.com/jpsim/Yams.git", from: "5.0.0"),

        .package(url: "https://github.com/woodymelling/swiftui-customizable-tab-view", branch: "main"),
    ],
    targets: [
        .target(
            name: "OpenMusicEvent",
            dependencies: [
                .product(name: "SharingGRDB", package: "sharing-grdb"),
                .product(name: "ZIPFoundation", package: "ZIPFoundation"),
                .product(name: "FileTree", package: "swift-file-tree"),
                .product(name: "ImageCaching", package: "swift-image-caching"),
                .product(name: "Yams", package: "Yams"),
                .product(name: "SwiftUINavigation", package: "swift-navigation"),
                .product(name: "DependenciesMacros", package: "swift-dependencies"),
                "OpenMusicEventParser",
                .product(name: "CustomizableTabView", package: "swiftui-customizable-tab-view"),
            ],
            plugins: [
//                .plugin(name: "skipstone", package: "skip")
            ]
        ),
        .target(
            name: "OpenMusicEventParser",
            dependencies: [
                "Yams",
                .product(name: "FileTree", package: "swift-file-tree"),
                .product(name: "Dependencies", package: "swift-dependencies"),
                .product(name: "DependenciesMacros", package: "swift-dependencies"),
                .product(name: "CustomDump", package: "swift-custom-dump"),
                .product(name: "Validated", package: "swift-validated"),
                .product(name: "Prelude", package: "swift-prelude"),
                .product(name: "Parsing", package: "swift-parsing"),
                .product(name: "Conversions", package: "swift-parsing"),

                .product(name: "IdentifiedCollections", package: "swift-identified-collections"),
                .product(name: "CustomDump", package: "swift-custom-dump"),
                .product(name: "Collections", package: "swift-collections"),
                .product(name: "Dependencies", package: "swift-dependencies"),
                .product(name: "Tagged", package: "swift-tagged"),

            ]
        ),
        .testTarget(
            name: "OpenMusicEventParserTests",
            dependencies: [
                 "OpenMusicEventParser",
                 "Yams",
                 .product(name: "CustomDump", package: "swift-custom-dump"),
                 .product(name: "DependenciesTestSupport", package: "swift-dependencies")
            ],
            resources: [
                .copy("ExampleFestivals")
            ]
        ),
    ]
)
