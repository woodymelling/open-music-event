//
//  OrganizationDetails.swift
//  event-viewer
//
//  Created by Woodrow Melling on 3/25/25.
//

import Foundation
import Observation
import SwiftUI
import Zip
import Dependencies
import OSLog
import ImageCaching
import SharingGRDB
import OpenMusicEventParser

@Observable
@MainActor
public class OrganizationDetail {
    let logger = Logger(subsystem: "open-music-event.event-viewer", category: "OrganizationDetails")

    public init(url: URL) {
        self.url = url

        _organization = FetchOne(wrappedValue: nil, Organization?.find(url))
        _events =  FetchAll(MusicEvent.where { $0.organizationID == url })
    }

    public let url: URL

    @ObservationIgnored
    @FetchOne
    public var organization: Organization?

    @ObservationIgnored
    @FetchAll
    var events: [MusicEvent] = []


    public var currentEvent: EventFeatures?

    public func onAppear() async {
        logger.log("Fetching: \(String(describing: self.url))")

        do {
            try await loadAndStoreOrganizationInfo(from: url)
        } catch {
            logger.error("Error: \(error.localizedDescription)")
        }
    }

    public func didTapEvent(id: MusicEvent.ID) {
        self.currentEvent = EventFeatures()
    }
}

struct OrganizationDetailView: View {
    @State var store = OrganizationDetail(url: URL(string: "https://github.com/woodymelling/wicked-woods/archive/refs/heads/main.zip")!)

    var body: some View {
        Group {
            if let organization = store.organization {
                StretchyHeaderList(
                    title: Text(organization.name),
                    stretchyContent: {
                        OrganizationImage(organization: organization)
                    },
                    listContent: {
                        Section("Events") {
                            EventsListView(events: store.events) { eventID in
                                store.didTapEvent(id: eventID)
                            }
                        }
                    }
                )
                .listStyle(.plain)
            } else if let error = store.$organization.loadError {
                Text("Error: \(error)").foregroundStyle(.red)
            } else {
                ProgressView("Loading Organization...")
            }
        }
        .task { await store.onAppear() }
        .fullScreenCover(item: $store.currentEvent) {
            EventFeaturesView(store: $0)
        }
    }

    struct EventsListView: View {

        var events: [MusicEvent]

        var onTapEvent: (MusicEvent.ID) -> Void

        var body: some View {
            ForEach(events) { event in
                Button(action: { onTapEvent(event.id) }) {
                    EventRow(event: event)
                }
                .buttonStyle(.plain)
            }
        }
    }

    struct OrganizationImage: View {
        let organization: Organization

        var body: some View {
//            CachedAsyncImage(
//                requests: [
//                    ImageRequest(
//                        url: organization.imageURL,
//                        processors: [.resize(width: 440)]
//                    ).withPipeline(.organization)
//                ]
//            ) {
//                $0.resizable()
//            } placeholder: {
//                #if !SKIP
//                AnimatedMeshView()
//                    .overlay(Material.thinMaterial)
//                    .opacity(0.25)
//                #else
//                ProgressView().frame(square: 440)
//                #endif
//
//            }
//            .frame(maxWidth: .infinity)
        }
    }

    struct EventRow: View {
        var event: MusicEvent

        var body: some View {
            HStack(spacing: 10) {
                EventImageView(eventInfo: event)

                Text(event.name)
                    .lineLimit(1)
            }
        }

        struct EventImageView: View {
            var eventInfo: MusicEvent

            var body: some View {
                CachedAsyncImage(
                    requests: [
                        ImageRequest(
                            url: eventInfo.imageURL,
                            processors: [
                                .resize(size: CGSize(width: 60, height: 60))
                            ]
                        )
                        .withPipeline(.images)
                    ]
                ) {
                    $0.resizable()
                        .aspectRatio(contentMode: .fill)
                } placeholder: {
                    ProgressView()
                }
                .frame(width: 60, height: 60)
                .clipped()
            }
        }
    }
}


import OSLog
private let logger = Logger(subsystem: "open-music-event.event-viewer", category: "OrganizationDetails")
func loadAndStoreOrganizationInfo(from url: URL) async throws {
    let (zipData, response) = try await URLSession.shared.data(from: url)
    logger.log("Response: \((response as! HTTPURLResponse).statusCode), data: \(zipData)")

    let baseURL = URL.cachesDirectory.appending(path: "organizations")
    logger.log("Creating Directory at: \(baseURL)")

    let zipDestination = baseURL.appendingPathComponent("wicked-woods.zip")
    let unzipped = baseURL.appendingPathComponent("wicked-woods")

    logger.log("Creating Directory at: \(baseURL)")
    try FileManager.default.createDirectory(at: baseURL, withIntermediateDirectories: true)

    logger.log("Writing data to: \(zipDestination)")
    try zipData.write(to: zipDestination, options: [.noFileProtection])

    if FileManager.default.isDeletableFile(atPath: unzipped.absoluteString) {
        logger.log("Clearing \(unzipped)")
        try FileManager.default.removeItem(at: unzipped)
    }

    logger.log("Unzipping from \(zipDestination) to \(unzipped)")
    try Zip.unzipFile(zipDestination, destination: unzipped)

    let finalDestination = unzipped.appendingPathComponent("wicked-woods-main")

    let contents = try FileManager.default.contentsOfDirectory(
        at: finalDestination,
        includingPropertiesForKeys: nil
    )

    logger.log("Reading from: \(finalDestination): Contents \(contents.map { $0.lastPathComponent })")

//    var organization = try OpenMusicEventParser.Organization.fileTree.read(from: url)
//    organization.url = url
//
//    @dependency(\.defaultdatabase) var database
//
//    try await database.write { [organization] db in
//        let url = try organization.upsert(organization).returning(\.url).fetchone(db)!
//    }

//    let organization = try OpenMusicEventParser.Organization.fileTree.read(from: finalDestination)

//
//    let organizationID = upsertOrganization(draft: organization.draft(url: url))
//
//    for event in organization.events {
//        let draft = event.draft(organizationID: organizationID)
//        let id = upsertEvent(draft: draft)
//
//        for artist in event.artists {
////                _ = upsertEventArtist(draft: artist.0.description, eventID: id)
//        }
//    }
//



    //        let (organization, events) = try Organization.fileTree.read(from: finalDestination)
    //
    //        self.organization = organization
    //        self.currentEvent = currentEvent
}

import Sharing
extension SharedKey where Self == AppStorageKey<MusicEvent.ID?> {
    static var eventID: Self {
        .appStorage("OME.eventID")
    }
}

//extension FileExtension {
//    static let yaml: Self = "yml"
//}
import FileTree



extension ImagePipeline {
    static let images: ImagePipeline = {

        var configuration = ImagePipeline.Configuration()

        var dataCache = try? DataCache(name: "com.open-music-event.images")
        dataCache?.sizeLimit = 1024 * 1024 * 150

        configuration.dataCache = dataCache
        configuration.imageCache = ImageCache()

        return ImagePipeline(configuration: configuration)
    }()
    
}
