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

        let organizationData = try OpenMusicEventParser.read(from: finalDestination)

        logger.info("Clearing temporary directory")
        try FileManager.default.clearDirectory(unzippedURL)

        return organizationData
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

extension FileManager {
    func clearDirectory(_ url: URL) throws {
        let contents = try contentsOfDirectory(atPath: url.path())
        try contents.forEach { file in
            let fileUrl = url.appendingPathComponent(file)
            try removeItem(atPath: fileUrl.path)
        }
    }
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


func downloadAndStoreOrganization(id: Organization.ID) async throws {
    @Dependency(DataFetchingClient.self) var dataFetchingClient
    @Dependency(\.defaultDatabase) var database

    let organization = try await dataFetchingClient.fetchOrganization(id: id)

    let organizationDraft = Organization.Draft(
        url: id,
        name: organization.info.name,
        imageURL: organization.info.imageURL
    )

    let organizationURL: URL = id

    try await database.write { db in
        try Organization.find(organizationURL)
            .delete()
            .execute(db)

        try Organization.upsert(organizationDraft)
            .execute(db)

        for event in organization.events {
            let eventDraft = MusicEvent.Draft(
                // Make a stable identifier for events that don't change their name
                id: .init((organizationURL.absoluteString + event.info.name).hashValue),
                organizationURL: organizationURL,
                name: event.info.name,
                timeZone: event.info.timeZone,
                startTime: event.info.startTime,
                endTime: event.info.endTime,
                imageURL: event.info.imageURL?.rawValue,
                siteMapImageURL: event.info.siteMapImageURL?.rawValue,
                location: event.info.location?.draft,
                contactNumbers: event.info.contactNumbers.map { $0.draft }
            )

            let eventID = try MusicEvent.insert(eventDraft)
                .returning(\.id)
                .fetchOne(db)!

            var stageNameIDMapping: [String: Stage.ID] = [:]
            var artistNameIDMapping: [String: Artist.ID] = [:]

            for stage in event.stages {
                let stageDraft = Stage.Draft(
                    musicEventID: eventID,
                    name: stage.name,
                    iconImageURL: stage.imageURL,
                    color: stage.color
                )

                let stageID = try Stage.insert(stageDraft)
                    .returning(\.id)
                    .fetchOne(db)!

                stageNameIDMapping[stage.name] = stageID
            }

            for artist in event.artists {
                let artistDraft = Artist.Draft(
                    musicEventID: eventID,
                    name: artist.name,
                    bio: artist.bio,
                    imageURL: artist.imageURL,
                    links: artist.links.map { $0.draft }
                )

                let artistID = try Artist.insert(artistDraft)
                    .returning(\.id)
                    .fetchOne(db)!

                artistNameIDMapping[artist.name] = artistID
            }

            for schedule in event.schedule {
                let draft = Schedule.Draft(
                    musicEventID: eventID,
                    startTime: schedule.metadata.startTime,
                    endTime: schedule.metadata.endTime,
                    customTitle: schedule.metadata.customTitle
                )

                let scheduleID = try Schedule.insert(draft)
                    .returning(\.id)
                    .fetchOne(db)!
            }
        }
    }
}

import OpenMusicEventParser

extension OpenMusicEventParser.Event.Location {
    var draft: MusicEvent.Location {
        let location = if let latitude, let longitude {
            MusicEvent.Location.Coordinates(latitude: latitude, longitude: longitude)
        } else {
            MusicEvent.Location.Coordinates?.none
        }

        return .init(
            address: self.address,
            directions: self.directions,
            coordinates: location
        )
    }
}

extension OpenMusicEventParser.Event.ContactNumber {
    var draft: MusicEvent.ContactNumber {
        .init(phoneNumber: self.phoneNumber, title: self.title, description: self.description)
    }
}

extension OpenMusicEventParser.Event.Artist.Link {
    var draft: Artist.Link {
        .init(url: self.url, label: self.label)
    }
}
