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
//    static var organizations: URL {
//        let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
//
//        return documentsDirectory.appendingPathComponent("openfestival-organizations")
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
//public struct OrganizationReference {
//    public var url: URL
//    public var info: Organization.Info
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
//    public var fetchMyOrganizationURLs: @Sendable () async throws -> [URL]
//    public var fetchOrganizationsFromDisk: @Sendable () async throws -> [OrganizationReference]
//    public var loadOrganizationFromGithub: @Sendable (URL) async throws -> Void
//    public var refreshOrganization: @Sendable (URL) async throws -> Void
//
//    public func refreshOrganizations() async throws -> Void {
//        for orgDirectory in try getOrganizationDirectories() {
//            try await self._refreshOrganization(orgDirectory)
//        }
//    }
//
//}
//
//private func getOrganizationDirectories() throws -> [URL] {
//    let fileManager = FileManager.default
//    let organizationsDirectory = URL.organizations
//
//    try fileManager.ensureDirectoryExists(at: organizationsDirectory)
//
//    let organizationDirectories = try fileManager.contentsOfDirectory(at: organizationsDirectory, includingPropertiesForKeys: nil, options: .skipsHiddenFiles)
//
//    return organizationDirectories
//}
//
//extension OpenFestivalClient: DependencyKey {
//    public static let liveValue = OpenFestivalClient(
//        fetchMyOrganizationURLs: {
//            try getOrganizationDirectories()
//        },
//        fetchOrganizationsFromDisk: {
//            let fileManager = FileManager.default
//
//            var organizations: [OrganizationReference] = []
//
//            for directory in try getOrganizationDirectories() {
//                let infoFile = directory.appendingPathComponent("organization-info.yaml")
//
//                guard fileManager.fileExists(atPath: infoFile.path) else {
//                    continue
//                }
//
//                let yamlContent = try String(contentsOf: infoFile, encoding: .utf8)
//                if let data = yamlContent.data(using: .utf8) {
//                    let organization = try YAMLDecoder().decode(Organization.Info.self, from: data)
//
//                    var events: [OrganizationReference.Event] = []
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
//                    organizations.append(
//                        OrganizationReference(
//                            url: directory,
//                            info: organization,
//                            events: events
//                        )
//                    )
//                }
//            }
//
//            return organizations
//        },
//        loadOrganizationFromGithub: { url in
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
////            let organization = try await parser.parse(from: temporaryDirectory)
////
////            try fileManager.ensureDirectoryExists(at: .organizations)
////
////            let newDirectoryPath = URL.organizations.appendingPathComponent(organization.info.name)
////
////            print("Moving directory from \(temporaryDirectory) to \(newDirectoryPath.absoluteString)")
////            // Move the directory to the new path
////            try fileManager.moveItem(at: temporaryDirectory, to: newDirectoryPath)
//        },
//        refreshOrganization: {
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
