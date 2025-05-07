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

struct OrganizationDetailView: View {
    @Observable
    @MainActor
    public class ViewModel {
        let logger = Logger(subsystem: "open-music-event.event-viewer", category: "OrganizationDetails")

        public init(id: Organization.ID) {
            self.id = id

            _organization = FetchOne(wrappedValue: nil, Organization?.find(id))
            _events = FetchAll(
                MusicEvent
                    .where { $0.organizationURL == id }
            )
        }

        public let id: Organization.ID

        @ObservationIgnored
        @FetchOne
        public var organization: Organization?

        @ObservationIgnored
        @FetchAll
        var events: [MusicEvent] = []


        public var currentEvent: MusicEventFeatures?

        public func onAppear() async {
//            logger.log("Fetching: \(String(describing: self.url))")
//
//            do {
//                try await loadAndStoreOrganizationInfo(from: url)
//            } catch {
//                logger.error("Error: \(error.localizedDescription)")
//            }
        }

        public func didTapEvent(id: MusicEvent.ID) {
            withDependencies(from: self) {
                $0.musicEventID = id
            } operation: {
                self.currentEvent = MusicEventFeatures()
            }
        }

        @ObservationIgnored
        @Dependency(DataFetchingClient.self)
        var dataFetchingClient

        public func onPullToRefresh() async  {
            do {
                try await downloadAndStoreOrganization(id: self.id)

            } catch {
                logger.error("\(error.localizedDescription)")
            }
        }
    }

    @Bindable var store: ViewModel

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
        .fullScreenCover(item: $store.currentEvent) {
            MusicEventFeaturesView(store: $0)
        }
        .refreshable { await store.onPullToRefresh() }
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
            CachedAsyncImage(
                requests: [
                    ImageRequest(
                        url: organization.imageURL,
                        processors: [.resize(width: 440)]
                    ).withPipeline(.images)
                ]
            ) {
                $0.resizable()
            } placeholder: {
                #if !SKIP
                AnimatedMeshView()
                    .overlay(Material.thinMaterial)
                    .opacity(0.25)
                #else
                ProgressView().frame(square: 440)
                #endif

            }
            .frame(maxWidth: .infinity)
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


import Sharing
extension SharedKey where Self == AppStorageKey<MusicEvent.ID?> {
    static var eventID: Self {
        .appStorage("OME-eventID")
    }
}


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

extension MusicEvent.ID: TestDependencyKey {
    public static let testValue: OmeID<MusicEvent> = .init(rawValue: 0)
}

extension DependencyValues {
    var musicEventID: MusicEvent.ID {
        get { self[MusicEvent.ID.self] }
        set { self[MusicEvent.ID.self] = newValue }
    }
}

private func downloadAndStoreOrganization(id: Organization.ID) async throws {
    @Dependency(DataFetchingClient.self) var dataFetchingClient
    @Dependency(\.defaultDatabase) var database

    let organization = try await dataFetchingClient.fetchOrganization(id: id)

    let organizationDraft = Organization.Draft(
        url: id,
        name: organization.info.name,
        imageURL: organization.info.imageURL
    )

    let organizationURL = id

    try await database.write { db in
        try Organization
            .where { $0.url == organizationURL }
            .delete()
            .execute(db)

        try Organization.upsert(organizationDraft)
            .execute(db)

        for event in organization.events {
            let eventDraft = MusicEvent.Draft(
                organizationURL: organizationURL,
                name: event.info.name,
                timeZone: event.info.timeZone,
                imageURL: event.info.imageURL?.rawValue,
                siteMapImageURL: event.info.siteMapImageURL?.rawValue,
                location: event.info.location?.draft,
                contactNumbers: event.info.contactNumbers.map { $0.draft }
            )

            let eventID = try MusicEvent.insert(eventDraft)
                .returning(\.id)
                .fetchOne(db)!

            for artist in event.artists {
                let artistDraft = Artist.Draft(
                    musicEventID: eventID,
                    name: artist.name,
                    bio: artist.bio,
                    imageURL: artist.imageURL,
                    links: artist.links.map { $0.draft }
                )

                try Artist.insert(artistDraft)
                    .execute(db)
//
//                for performance in artist.performances {
//                    let stageDraft = Stage.Draft(
//                        eventID: eventID,
//                        name: performance.stage.name,
//                        iconImageURL: performance.stage.iconImageURL
//                    )
//
//                    let stageID = try Stage.upsert(stageDraft)
//                        .returning(\.id)
//                        .fetchOne(db)!
//
//                    let scheduleDraft = Schedule.Draft(
//                        eventID: eventID,
//                        startTime: performance.schedule?.startTime,
//                        endTime: performance.schedule?.endTime,
//                        customTitle: performance.schedule?.customTitle
//                    )
//
//                    let scheduleID = try Schedule.insert(scheduleDraft)
//                        .returning(\.id)
//                        .fetchOne(db)
//
//                    let performanceDraft = Performance.Draft(
//                        stageID: stageID,
//                        scheduleID: scheduleID,
//                        startTime: performance.startTime,
//                        endTime: performance.endTime,
//                        customTitle: performance.customTitle,
//                        description: performance.description
//                    )
//
//                    let performanceID = try Performance.insert(performanceDraft)
//                        .returning(\.id)
//                        .fetchOne(db)!
//
//                    let artistLinkDraft = Performance.Artists(
//                        performanceID: performanceID,
//                        artistID: artistID,
//                        anonymousArtistName: nil
//                    )
//
//                    try Performance.Artists.insert(artistLinkDraft)
//                        .execute(db)
//                }
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
