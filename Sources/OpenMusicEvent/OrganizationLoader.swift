//
//  OrganizationLoader.swift
//  open-music-event
//
//  Created by Woodrow Melling on 5/7/25.
//

import OpenMusicEventParser
import Dependencies
import DependenciesMacros
import Zip

@DependencyClient
struct DataFetchingClient {
    var fetchOrganization: @Sendable (_ id: Organization.ID) async throws -> OpenMusicEventParser.Organization
}

struct FailedToLoadOrganizationError: Error {}

extension DataFetchingClient: DependencyKey {
    static let liveValue = DataFetchingClient { baseURL in

        let targetZipURL = getZipURLForRemoteURL(baseURL)
        
        logger.info("Fetching organization from: \(targetZipURL)")

        let (downloadURL, response) = try await URLSession.shared.download(from: targetZipURL)
        logger.info("Response: \((response as! HTTPURLResponse).statusCode), to url: \(downloadURL)")
        let unzippedURL = URL.temporaryDirectory

        logger.info("Unzipping from \(downloadURL) to \(unzippedURL)")

        try Zip.unzipFile(downloadURL, destination: unzippedURL, customFileExtension: "tmp")

        let finalDestination = try getUnzippedDirectory(from: unzippedURL)
        logger.info("Parsing organization from directory: \(finalDestination)")

        return try OpenMusicEventParser.read(from: finalDestination)
    }
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



extension Zip {
    static func unzipFile(_ fileURL: URL, destination: URL, customFileExtension: String) throws {
        Zip.addCustomFileExtension(customFileExtension)
        try Zip.unzipFile(fileURL, destination: destination)
        Zip.removeCustomFileExtension(customFileExtension)
    }
}

private func getZipURLForRemoteURL(_ remoteURL: URL) -> URL {
    guard remoteURL.absoluteString.contains("github")
    else { return remoteURL }

    return remoteURL.appendingPathComponent("archive/refs/heads/main.zip")
}

import OSLog
import GRDB

private let logger = Logger(subsystem: "open-music-event.event-viewer", category: "OrganizationLoader")

