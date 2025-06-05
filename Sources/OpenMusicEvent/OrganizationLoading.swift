////
////  DataFetchingClient.swift
////  open-music-event
////
////  Created by Woodrow Melling on 6/5/25.
////
//
//
//import OpenMusicEventParser
//import Dependencies
//import DependenciesMacros
//import ZIPFoundation
//import SwiftUI
//import OMECoreModels
//
//@DependencyClient
//struct DataFetchingClient {
//    var fetchOrganizer: @Sendable (_ id: OMECoreModels.Organizer.ID) async throws -> OpenMusicEventParser.OrganizerConfiguration
//}
//
//struct FailedToLoadOrganizerError: Error {}
//
//extension DataFetchingClient: DependencyKey {
//    static let liveValue = DataFetchingClient { baseURL in
//        let unzippedURL = URL.temporaryDirectory
//
//        let targetZipURL = getZipURLForRemoteURL(baseURL)
//        logger.info("Fetching organizer from: \(targetZipURL)")
//
//        try FileManager.default.clearDirectory(URL.temporaryDirectory)
//
//        let fileManager = FileManager.default
//
//        let (downloadURL, response) = try await URLSession.shared.download(from: targetZipURL)
//        logger.info("Response: \((response as! HTTPURLResponse).statusCode), to url: \(downloadURL)")
//        
//        logger.info("Unzipping from \(downloadURL) to \(unzippedURL)")
//
//        do {
//            try fileManager.createDirectory(at: unzippedURL, withIntermediateDirectories: true)
//            try fileManager.unzipItem(at: downloadURL, to: unzippedURL)
//        } catch {
//            reportIssue("ERROR: \(error)")
//        }
//
//        let finalDestination = try getUnzippedDirectory(from: unzippedURL)
//        logger.info("Parsing organizer from directory: \(finalDestination)")
//
//        let organizerData = try OrganizerConfiguration.fileTree.read(from: finalDestination)
//
//        logger.info("Clearing temporary directory")
//        try FileManager.default.clearDirectory(unzippedURL)
//
//        return organizerData
//    }
//}
//
//private func getUnzippedDirectory(from zipURL: URL) throws -> URL {
//    let fileURLs = try FileManager.default.contentsOfDirectory(
//        at: zipURL,
//        includingPropertiesForKeys: [.isDirectoryKey],
//        options: .skipsHiddenFiles
//    )
//
//    guard let directoryURL = fileURLs.first(where: { url in
//        (try? url.resourceValues(forKeys: [.isDirectoryKey]).isDirectory) == true
//    }) else {
//        throw NSError(domain: "UnzipError", code: 1, userInfo: [NSLocalizedDescriptionKey: "No directory found in unzipped contents."])
//    }
//
//    return directoryURL
//}
//
//extension FileManager {
//    func clearDirectory(_ url: URL) throws {
//        let contents = try contentsOfDirectory(atPath: url.path())
//        try contents.forEach { file in
//            let fileUrl = url.appendingPathComponent(file)
//            try removeItem(atPath: fileUrl.path)
//        }
//    }
//}
//
//private func getZipURLForRemoteURL(_ remoteURL: URL) -> URL {
//    guard remoteURL.absoluteString.contains("github")
//    else { return remoteURL }
//
//    return remoteURL.appendingPathComponent("archive/refs/heads/main.zip")
//}
//
//import OSLog
//import GRDB
//
//private let logger = Logger(subsystem: "open-music-event.event-viewer", category: "OrganizerLoader")
//
//
//extension String {
//    var stableHash: Int {
//        var result = UInt64 (5381)
//        let buf = [UInt8](self.utf8)
//        for b in buf {
//            result = 127 * (result & 0x00ffffffffffffff) + UInt64(b)
//        }
//        return Int(result)
//    }
//}
//
//extension OmeID where RawValue == Int {
//    public init(stabilizedBy values: String...) {
//        self.init(rawValue: values.joined(separator: "-").stableHash)
//    }
//}
//
//func downloadAndStoreOrganizer(id: OMECoreModels.Organizer.ID) async throws {
//    @Dependency(DataFetchingClient.self) var dataFetchingClient
//    @Dependency(\.defaultDatabase) var database
//
//    let organizer = try await dataFetchingClient.fetchOrganizer(id: id)
//
//    let organizerDraft = Organizer.Draft(
//        url: id,
//        name: organizer.info.name,
//        imageURL: organizer.info.imageURL
//    )
//
//    let organizerURL: URL = id
//
//    try await database.write { db in
//        try Organizer.find(organizerURL)
//            .delete()
//            .execute(db)
//
//        try Organizer.upsert(organizerDraft)
//            .execute(db)
//
//        for event in organizer.events {
//
//            let eventDraft = MusicEvent.Draft(
//                id: MusicEvent.ID(stabilizedBy: id.absoluteString, event.info.name),
//                organizerURL: organizerURL,
//                name: event.info.name,
//                timeZone: event.info.timeZone,
//                startTime: event.info.startTime,
//                endTime: event.info.endTime,
//                imageURL: event.info.imageURL,
//                siteMapImageURL: event.info.siteMapImageURL,
//                location: event.info.location,
//                contactNumbers: event.info.contactNumbers
//            )
//
//            let eventID = try MusicEvent.insert(eventDraft)
//                .returning(\.id)
//                .fetchOne(db)!
//
//            var stageNameIDMapping: [String: Stage.ID] = [:]
//            var artistNameIDMapping: [String: Artist.ID] = [:]
//
//            for stage in event.stages {
//                let stage = Stage.Draft(
//                    id: Stage.ID(rawValue: (String(eventID.rawValue) + stage.name).stableHash),
//                    musicEventID: eventID,
//                    name: stage.name,
//                    iconImageURL: stage.iconImageURL,
//                    imageURL: stage.imageURL,
//                    color: stage.color
//                )
//
//                let stageID = try Stage.upsert(stage)
//                    .returning(\.id)
//                    .fetchOne(db)!
//
//                stageNameIDMapping[stage.name] = stageID
//            }
//
//            for artist in event.artists {
//                let artistDraft = Artist.Draft(
//                    id: OmeID(stabilizedBy: String(eventID.rawValue), artist.name),
//                    musicEventID: eventID,
//                    name: artist.name,
//                    bio: artist.bio,
//                    imageURL: artist.imageURL,
//                    links: artist.links
//                )
//
//                let artistID = try Artist.upsert(artistDraft)
//                    .returning(\.id)
//                    .fetchOne(db)!
//
//                artistNameIDMapping[artist.name] = artistID
//            }
//
//            for schedule in event.schedule {
//                let draft = Schedule.Draft(
//                    id: .init(
//                        stabilizedBy: String(eventID.rawValue),
//                        (schedule.metadata.customTitle ?? schedule.metadata.startTime?.description ?? UUID().uuidString)
//                    ),
//                    musicEventID: eventID,
//                    startTime: schedule.metadata.startTime,
//                    endTime: schedule.metadata.endTime,
//                    customTitle: schedule.metadata.customTitle
//                )
//
//                let scheduleID = try Schedule.upsert(draft)
//                    .returning(\.id)
//                    .fetchOne(db)!
//
//                for stageSchedule in schedule.stageSchedules {
//
//                    for performance in stageSchedule.value {
//                        let draft = Performance.Draft(
//                            // Stable for each performance **BUT*** will fail if an artist has two performances on the same stage on the same day
//                            // Maybe we increment a counter if there are multiple?
//                            id: .init(stabilizedBy: String(scheduleID.rawValue), stageSchedule.key, performance.title),
//                            stageID: stageNameIDMapping[stageSchedule.key]!,
//                            scheduleID: scheduleID,
//                            startTime: performance.startTime,
//                            endTime: performance.endTime,
//                            title: performance.title,
//                            description: nil
//                        )
//
//                        let performanceID = try Performance.upsert(draft)
//                            .returning(\.id)
//                            .fetchOne(db)!
//
//                        for artistName in performance.artistNames {
//                            let artistID = artistNameIDMapping[artistName]
//
//                            let draft = Performance.Artists.Draft(
//                                performanceID: performanceID,
//                                artistID: artistID,
//                                anonymousArtistName: artistID == nil ? artistName : nil
//                            )
//
//                            try Performance.Artists.insert(draft)
//                                .execute(db)
//                        }
//                    }
//                }
//            }
//        }
//    }
//}
