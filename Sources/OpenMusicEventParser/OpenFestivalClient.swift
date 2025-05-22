////
////  File.swift
////  
////
////  Created by Woodrow Melling on 6/28/24.
////
//
//import Foundation
//import Dependencies
//import DependenciesMacros
//
//import Yams
//
//
//public extension URL {
//    static var organizers: URL {
//        let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
//
//        return documentsDirectory.appendingPathComponent("openfestival-organizers")
//    }
//
//    func relativePath(from base: URL) -> String? {
//        let baseComponents = base.pathComponents
//        var selfComponents = self.pathComponents
//
//        for component in baseComponents {
//            if component == selfComponents.first {
//                selfComponents.removeFirst()
//            }
//        }
//
//        return selfComponents.joined(separator: "/")
//    }
//}
//
//public struct OrganizerReference {
//    public var url: URL
//    public var info: Organizer.Info
//    public var events: [Event]
//
//    public struct Event: Codable {
//        public var url: URL
//        public var name: String
//    }
//}
//
//@DependencyClient
//public struct OpenFestivalClient: Sendable {
//    public var fetchMyOrganizerURLs: @Sendable () async throws -> [URL]
//    public var fetchOrganizersFromDisk: @Sendable () async throws -> [OrganizerReference]
//    public var loadOrganizerFromGithub: @Sendable (URL) async throws -> Void
//    public var refreshOrganizer: @Sendable (URL) async throws -> Void
//
//    public func refreshOrganizers() async throws -> Void {
//        for orgDirectory in try getOrganizerDirectories() {
//            try await self._refreshOrganizer(orgDirectory)
//        }
//    }
//
//}
//
//private func getOrganizerDirectories() throws -> [URL] {
//    let fileManager = FileManager.default
//    let organizersDirectory = URL.organizers
//
//    try fileManager.ensureDirectoryExists(at: organizersDirectory)
//
//    let organizerDirectories = try fileManager.contentsOfDirectory(at: organizersDirectory, includingPropertiesForKeys: nil, options: .skipsHiddenFiles)
//
//    return organizerDirectories
//}
//
//extension OpenFestivalClient: DependencyKey {
//    public static let liveValue = OpenFestivalClient(
//        fetchMyOrganizerURLs: {
//            try getOrganizerDirectories()
//        },
//        fetchOrganizersFromDisk: {
//            let fileManager = FileManager.default
//
//            var organizers: [OrganizerReference] = []
//
//            for directory in try getOrganizerDirectories() {
//                let infoFile = directory.appendingPathComponent("organizer-info.yaml")
//
//                guard fileManager.fileExists(atPath: infoFile.path) else {
//                    continue
//                }
//
//                let yamlContent = try String(contentsOf: infoFile, encoding: .utf8)
//                if let data = yamlContent.data(using: .utf8) {
//                    let organizer = try YAMLDecoder().decode(Organizer.Info.self, from: data)
//
//                    var events: [OrganizerReference.Event] = []
//                    let eventDirectories = try fileManager.contentsOfDirectory(
//                        at: directory,
//                        includingPropertiesForKeys: nil,
//                        options: .skipsHiddenFiles
//                    ).filter { $0.hasDirectoryPath }
//                    for directory in eventDirectories {
//                        events.append(
//                            .init(
//                                url: directory,
//                                name: directory.lastPathComponent
//                            )
//                        )
//                    }
//                    organizers.append(
//                        OrganizerReference(
//                            url: directory,
//                            info: organizer,
//                            events: events
//                        )
//                    )
//                }
//            }
//
//            return organizers
//        },
//        loadOrganizerFromGithub: { url in
////            let fileManager = FileManager.default
////            let temporaryDirectory = URL.temporaryDirectory.appendingPathComponent(UUID().uuidString)
////
////            print("Ensuring directory exists at path: \(temporaryDirectory.path)")
////
////            try fileManager.ensureDirectoryExists(at: temporaryDirectory)
////
////            print("Directory exists, starting clone operation to: \(temporaryDirectory.path)")
////
////
////            @Dependency(GitClient.self) var gitClient
////            try await gitClient.cloneRepository(
////                from: url,
////                destination: temporaryDirectory
////            )
////
////            @Dependency(OpenFestivalParser.self) var parser
////            let organizer = try await parser.parse(from: temporaryDirectory)
////
////            try fileManager.ensureDirectoryExists(at: .organizers)
////
////            let newDirectoryPath = URL.organizers.appendingPathComponent(organizer.info.name)
////
////            print("Moving directory from \(temporaryDirectory) to \(newDirectoryPath.absoluteString)")
////            // Move the directory to the new path
////            try fileManager.moveItem(at: temporaryDirectory, to: newDirectoryPath)
//        },
//        refreshOrganizer: {
//            @Dependency(GitClient.self) var gitClient
//            try await gitClient.pull(at: $0)
//        }
//    )
//}
//
//extension FileManager {
//    func ensureDirectoryExists(at path: URL) throws {
//        if !fileExists(atPath: path.path) {
//            try createDirectory(at: path, withIntermediateDirectories: true, attributes: nil)
//        }
//    }
//}
