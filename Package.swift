// swift-tools-version: 6.0
// This is a Skip (https://skip.tools) package.
import PackageDescription

let package = Package(
    name: "open-music-event",
    defaultLocalization: "en",
    platforms: [.iOS(.v17), .macOS(.v14), .tvOS(.v17), .watchOS(.v10), .macCatalyst(.v17)],
    products: [
        .library(name: "OpenMusicEvent", type: .dynamic, targets: ["OpenMusicEvent"]),
    ],
    dependencies: [
        .package(url: "https://github.com/woodymelling/swift-file-tree", branch: "android-support"),
        .package(url: "https://github.com/woodymelling/swift-frontmatter-parsing", from: "0.1.0"),

        .package(url: "https://source.skip.tools/skip.git", from: "1.5.18"),
        .package(url: "https://source.skip.tools/skip-fuse-ui.git", "0.0.0"..<"2.0.0"),
        .package(url: "https://github.com/swift-everywhere/grdb-sqlcipher.git", from: "7.5.0"),

        .package(url: "https://github.com/pointfreeco/swift-tagged", from: "0.10.0"),
        .package(url: "https://github.com/pointfreeco/swift-case-paths", from: "1.0.0"),
        .package(url: "https://github.com/pointfreeco/swift-dependencies", from: "1.4.1"),
        .package(url: "https://github.com/pointfreeco/swift-custom-dump", from: "1.3.3"),
        .package(url: "https://github.com/pointfreeco/swift-snapshot-testing", from: "1.18.0"),

        .package(url: "https://github.com/woodymelling/swift-parsing", from: "0.1.0"),

        .package(url: "https://github.com/apple/swift-collections", from: "1.0.4"),

        .package(url: "https://github.com/weichsel/ZIPFoundation", from: "0.9.0"),
        .package(url: "https://github.com/jpsim/Yams.git", from: "5.0.0"),
    ],
    targets: [
        .target(
            name: "OpenMusicEvent",
            dependencies: [
                "OMECoreModels",
                "OpenMusicEventParser",
                .product(name: "SkipFuseUI", package: "skip-fuse-ui"),
                .product(name: "GRDB", package: "grdb-sqlcipher"),
                .product(name: "Dependencies", package: "swift-dependencies"),
                .product(name: "CasePaths", package: "swift-case-paths"),
//                .product(name: "ZIPFoundation", package: "ZIPFoundation"),
            ],
            plugins: [.plugin(name: "skipstone", package: "skip")]
        ),
        .target(
            name: "OMECoreModels",
            dependencies: [
                .product(name: "Tagged", package: "swift-tagged"),
//                .product(name: "StructuredQueries", package: "swift-structured-queries")
            ]
        ),
        .target(
            name: "OpenMusicEventParser",
            dependencies: [
                "Yams",
                "OMECoreModels",
                .product(name: "FileTree", package: "swift-file-tree"),
                .product(name: "Dependencies", package: "swift-dependencies"),
                .product(name: "DependenciesMacros", package: "swift-dependencies"),
                .product(name: "CustomDump", package: "swift-custom-dump"),
                .product(name: "Parsing", package: "swift-parsing"),
                .product(name: "Conversions", package: "swift-parsing"),
                .product(name: "Collections", package: "swift-collections"),
                .product(name: "Tagged", package: "swift-tagged"),

            ]
        ),
        .testTarget(
            name: "OpenMusicEventParserTests",
            dependencies: [
                 "OpenMusicEventParser",
                 "Yams",
                 .product(name: "CustomDump", package: "swift-custom-dump"),
                 .product(name: "DependenciesTestSupport", package: "swift-dependencies"),
                 .product(name: "InlineSnapshotTesting", package: "swift-snapshot-testing"),
                 .product(name: "SnapshotTestingCustomDump", package: "swift-snapshot-testing"),
            ],
            resources: [
                .copy("ExampleFestivals")
            ]
        ),
    ]
)
