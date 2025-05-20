//
//  OrganizationDetails.swift
//  event-viewer
//
//  Created by Woodrow Melling on 3/25/25.
//

import Foundation
import Observation
import SwiftUI
import Dependencies
import OSLog
import ImageCaching
import SharingGRDB

public struct OrganizationDetailView: View {
    public init(url: Organization.ID) {
        self.store = ViewModel(url: url)
    }

    public init(store: ViewModel) {
        self.store = store
    }
    
    @Observable
    @MainActor
    public class ViewModel {
        let logger = Logger(subsystem: "open-music-event.event-viewer", category: "OrganizationDetails")

        public init(url: Organization.ID) {
            self.id = url

            _organization = FetchOne(wrappedValue: nil, Organization?.find(id))
            _events = FetchAll(
                MusicEvent
                    .where { $0.organizationURL == id }
                    .order { $0.startTime.desc(nulls: .last)  }
            )
        }

        public let id: Organization.ID

        @ObservationIgnored
        @FetchOne
        public var organization: Organization?

        @ObservationIgnored
        @FetchAll
        var events: [MusicEvent]

        @ObservationIgnored
        @Shared(Current.musicEventID)
        public var currentEvent


        public func didTapEvent(id: MusicEvent.ID) {
            logger.info("didTapEvent: \(id)")
            self.$currentEvent.withLock { $0 = id}
        }

        public func onPullToRefresh() async  {
            await withErrorReporting {
                try await downloadAndStoreOrganization(id: self.id)
            }
        }

        public func onAppear() async {
            await withErrorReporting {
                try await downloadAndStoreOrganization(id: self.id)
            }
        }
    }

    @Bindable var store: ViewModel

    public var body: some View {
        Group {
            if let organization = store.organization {
                StretchyHeaderList(
                    title: Text(organization.name),
                    stretchyContent: {
                        Organization.ImageView(organization: organization)
                    },
                    listContent: {
                        Section("Events") {
                            EventsListView(events: store.events) { eventID in
                                store.didTapEvent(id: eventID)
                            }
                        }
                    }
                )
                .refreshable { await store.onPullToRefresh() }
                .listStyle(.plain)
            } else if let error = store.$organization.loadError {
                Text("Error: \(error)").foregroundStyle(.red)
            } else {
                ProgressView("Loading Organization...")
            }
        }
        .task { await store.onAppear() }

    }

    struct EventsListView: View {

        var events: [MusicEvent]

        var onTapEvent: (MusicEvent.ID) -> Void

        var body: some View {
            ForEach(events) { event in
                Button(action: { onTapEvent(event.id) }) {
                    EventRowView(event: event)
                }
                .buttonStyle(.navigationLink)
            }
        }
    }


    struct EventRowView: View {
        var event: MusicEvent

        static let intervalFormatter = {
            let f = DateIntervalFormatter()
            f.dateStyle = .short
            f.timeStyle = .none
            return f
        }()

        var eventDateString: String? {
            if let startTime = event.startTime, let endTime = event.endTime {
                guard startTime <= endTime
                else {
                    reportIssue("Start time (\(String(describing: startTime))) is after end time (\(String(describing: endTime)))")
                    return nil
                }

                return Self.intervalFormatter.string(from: startTime, to: endTime)
            } else if let startTime = event.startTime {
                return startTime.formatted()
            } else {
                return nil
            }
        }

        var body: some View {
            HStack(spacing: 10) {

                MusicEvent.ImageView(event: event)
                    .frame(width: 60, height: 60)
//                    .foregroundColor(.label)
//                .invertForLightMode()

                VStack(alignment: .leading) {
                    Text(event.name)
                    if let eventDateString {
                        Text(eventDateString)
                            .lineLimit(1)
                            .font(.caption2)
                    }
                    Text(String(event.id))
                        .font(.caption2)
                        .foregroundStyle(.tertiary)
                }

                Spacer()
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

enum Current {
    static var musicEventID: AppStorageKey<MusicEvent.ID?> {
        .appStorage("OME-eventID")
    }


    static var musicEvent: Where<MusicEvent> {
        @Dependency(\.musicEventID) var musicEventID
        return MusicEvent.find(musicEventID)
    }

    static var artists: Where<Artist> {
        @Dependency(\.musicEventID) var eventID
        return Artist.where {
            eventID == $0.musicEventID
        }
    }

    static var stages: Where<Stage> {
        Stage.where {
            @Dependency(\.musicEventID) var eventID
            eventID == $0.musicEventID
        }
    }

    static var schedules: Where<Schedule> {
        Schedule.where {
            @Dependency(\.musicEventID) var eventID
            eventID == $0.musicEventID
        }
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

let intervalFormatter = DateIntervalFormatter()


