//
//  DownloadOrganization.swift
//  open-music-event
//
//  Created by Woodrow Melling on 6/9/25.
//

import CoreModels
import Dependencies
import DependenciesMacros
import OSLog


@DependencyClient
public struct OrganizationClient: Sendable {
    public var fetchOrganizer: @Sendable (_ id: CoreModels.Organizer.ID) async throws -> OpenMusicEventParser.OrganizerConfiguration
}

public struct FailedToLoadOrganizerError: Error {}

extension OrganizationClient: DependencyKey {
    public static let liveValue = OrganizationClient { baseURL in
        let unzippedURL = URL.temporaryDirectory
        let targetZipURL = getZipURLForRemoteURL(baseURL)

        logger.info("Fetching organizer from: \(targetZipURL)")

        let fileManager = FileManager.default

        let (downloadURL, response) = try await URLSession.shared.download(from: targetZipURL)
        logger.info("Response: \((response as! HTTPURLResponse).statusCode), to url: \(downloadURL)")


        logger.info("Unzipping from \(downloadURL) to \(unzippedURL)")
        @Dependency(ZipClient.self) var zipClient

        do {
            try fileManager.createDirectory(at: unzippedURL, withIntermediateDirectories: true)
            try zipClient.unzipFile(source: downloadURL, destination: unzippedURL)
        } catch {
            reportIssue("ERROR: \(error)")
        }

        let finalDestination = try getUnzippedDirectory(from: unzippedURL)
        logger.info("Parsing organizer from directory: \(finalDestination)")

        let organizerData = try OrganizerConfiguration.fileTree.read(from: finalDestination)

        logger.info("Clearing temporary directory")
        try FileManager.default.clearDirectory(downloadURL)
        try FileManager.default.clearDirectory(unzippedURL)

        return organizerData
    }
}


@DependencyClient
struct ZipClient: Sendable {
    var unzipFile: @Sendable (_ source: URL, _ destination: URL) throws -> Void
}

extension ZipClient: TestDependencyKey {
    static let testValue = ZipClient()
}

private func getZipURLForRemoteURL(_ remoteURL: URL) -> URL {
    guard remoteURL.absoluteString.contains("github")
    else { return remoteURL }

    return remoteURL.appendingPathComponent("archive/refs/heads/main.zip")
}


private func getUnzippedDirectory(from zipURL: URL) throws -> URL {
    let fileURLs = try FileManager.default.contentsOfDirectory(
        at: zipURL,
        includingPropertiesForKeys: [.isDirectoryKey],
        options: .skipsHiddenFiles
    )

    guard let directoryURL = fileURLs.first(where: { url in
        (try? url.resourceValues(forKeys: [.isDirectoryKey]).isDirectory) == true
    }) else {
        throw NSError(domain: "UnzipError", code: 1, userInfo: [NSLocalizedDescriptionKey: "No directory found in unzipped contents."])
    }

    return directoryURL
}

private let logger = Logger(subsystem: "open-music-event.event-viewer", category: "OrganizerLoader")

extension FileManager {
    func clearDirectory(_ url: URL) throws {
        let contents = try contentsOfDirectory(atPath: url.path())
        try contents.forEach { file in
            let fileUrl = url.appendingPathComponent(file)
            try removeItem(atPath: fileUrl.path)
        }
    }
}
