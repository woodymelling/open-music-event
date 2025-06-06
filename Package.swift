// swift-tools-version: 6.1
// This is a Skip (https://skip.tools) package.
import PackageDescription

let package = Package(
    name: "open-music-event",
    defaultLocalization: "en",
    platforms: [.iOS(.v17), .macOS(.v15)],
    products: [
        .library(name: "OpenMusicEvent", targets: ["OpenMusicEvent"]),
        .library(name: "OpenMusicEventParser", targets: ["OpenMusicEventParser"]),
        .library(name: "CoreModels", targets: ["CoreModels"])
    ],
    dependencies: [
        .package(url: "https://github.com/apple/swift-collections", from: "1.0.4"),

        .package(url: "https://github.com/pointfreeco/swift-custom-dump", from: "1.3.3"),
        .package(url: "https://github.com/pointfreeco/swift-dependencies", from: "1.4.1"),
        .package(url: "https://github.com/pointfreeco/swift-identified-collections", from: "1.0.0"),
        .package(url: "https://github.com/pointfreeco/swift-tagged", from: "0.10.0"),
        .package(url: "https://github.com/pointfreeco/swift-validated", from: "0.2.0"),
        .package(url: "https://github.com/pointfreeco/swift-navigation", from: "2.3.0"),
        .package(url: "https://github.com/pointfreeco/swift-snapshot-testing", from: "1.18.0"),
        .package(url: "https://github.com/pointfreeco/sharing-grdb", from: "0.4.0"),
        .package(url: "https://github.com/pointfreeco/swift-structured-queries", from: "0.4.0"),

        .package(url: "https://github.com/woodymelling/swift-parsing", from: "0.1.0"),

        .package(url: "https://github.com/woodymelling/skip-image-caching", branch: "main"),
        .package(url: "https://github.com/woodymelling/swift-file-tree", branch: "android-support"),
        .package(url: "https://github.com/woodymelling/swift-frontmatter-parsing", from: "0.1.0"),
        .package(url: "https://github.com/weichsel/ZIPFoundation", from: "0.9.0"),
        .package(url: "https://github.com/jpsim/Yams.git", from: "5.0.0"),

//        .package(url: "https://github.com/woodymelling/swiftui-customizable-tab-view", branch: "main"),
    ],
    targets: [
        .target(
            name: "OpenMusicEvent",
            dependencies: [
                .product(name: "SharingGRDB", package: "sharing-grdb"),
                .product(name: "ZIPFoundation", package: "ZIPFoundation"),
                .product(name: "FileTree", package: "swift-file-tree"),
                .product(name: "ImageCaching", package: "skip-image-caching"),
                .product(name: "Yams", package: "Yams"),
                .product(name: "SwiftUINavigation", package: "swift-navigation"),
                .product(name: "DependenciesMacros", package: "swift-dependencies"),
                "OpenMusicEventParser",
                "CoreModels"
//                .product(name: "CustomizableTabView", package: "swiftui-customizable-tab-view"),
            ],
            resources: [.process("Resources")],
//            plugins: [
//                .plugin(name: "skipstone", package: "skip")
//            ]
        ),
        .target(
            name: "CoreModels",
            dependencies: [
                .product(name: "StructuredQueries", package: "swift-structured-queries")
            ],
        ),

        .target(
            name: "OpenMusicEventParser",
            dependencies: [
                "Yams",
                "CoreModels",
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
    ]
)
