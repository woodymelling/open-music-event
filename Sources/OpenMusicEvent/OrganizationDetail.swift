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
            _events = FetchAll(MusicEvent.where { $0.organizationURL == id })
        }

        public let id: Organization.ID

        @ObservationIgnored
        @FetchOne
        public var organization: Organization?

        @ObservationIgnored
        @FetchAll
        var events: [MusicEvent] = []


        public var currentEvent: EventFeatures?

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
            self.currentEvent = EventFeatures()
        }

        @ObservationIgnored
        @Dependency(DataFetchingClient.self)
        var dataFetchingClient

        public func onPullToRefresh() async  {
            do {
                _ = try await dataFetchingClient.fetchOrganization(id: self.id)
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
            EventFeaturesView(store: $0)
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

