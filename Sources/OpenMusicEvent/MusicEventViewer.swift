import SwiftUI
import SharingGRDB
import CoreModels

enum ContentTab: String, Hashable {
    case welcome, home, settings
}

struct MusicEventViewer: View {
    var id: MusicEvent.ID

    @State
    var eventFeatures: MusicEventFeatures?

    var isLoading: Bool { eventFeatures == nil }

    @State
    var error: LocalizedStringKey?

    @Environment(\.exitEvent) var dismiss

    var body: some View {
        ZStack {
            AnimatedMeshView()
                .ignoresSafeArea()

            if let eventFeatures {
                MusicEventFeaturesView(store: eventFeatures)
            }
        }
        .animation(.default, value: isLoading)
        .task(id: id) {
            @Dependency(\.defaultDatabase)
            var database

            self.eventFeatures = nil
            await withErrorReporting {
                @FetchOne(MusicEvent?.find(id))
                var musicEvent: MusicEvent? = nil

                try await $musicEvent.sharedReader.load()
//                try await Task.sleep(for: .seconds(1))

                if let event = musicEvent {
                    try await withDependencies {
                        $0.musicEventID = self.id
                    } operation: { @MainActor in
                        @FetchAll(Current.artists) var artists
                        @FetchAll(Current.stages) var stages
                        @FetchAll(Current.schedules) var schedules

                        try await withThrowingTaskGroup {
                            $0.addTask { try await FetchAll(Current.stages).load() }
                            $0.addTask { try await FetchAll(Current.artists).load() }
                            $0.addTask { try await FetchAll(Current.schedules) .load() }
                            $0.addTask { await prefetchStageImages() }

                            try await $0.waitForAll()
                        }

                        self.eventFeatures = MusicEventFeatures(
                            event,
                            artists: artists,
                            stages: stages,
                            schedules: schedules
                        )
                    }
                } else {
                    dismiss()
                }
            }
        }

    }
}


import ImageCaching
private func prefetchStageImages() async {
    @FetchAll(Current.stages) var stages
    try? await $stages.sharedReader.load()

    await withTaskGroup {
        for stage in stages {
            if let imageURL = stage.iconImageURL {
                $0.addTask {
                    await withErrorReporting {
                        _ = try await ImagePipeline.images.image(for: imageURL)
                    }
                }
            }
        }

        await $0.waitForAll()
    }
}

private func prefetchArtistImages() async {
    @FetchAll(Current.artists) var artists
    try? await $artists.sharedReader.load()
    
    await withTaskGroup {
        for artist in artists {
            if let imageURL = artist.imageURL {
                $0.addTask {
                    await withErrorReporting {
                        _ = try await ImagePipeline.images.image(for: imageURL)
                    }
                }
            }
        }
    }
}

enum MusicEventIDDependencyKey: DependencyKey {
    static let liveValue: MusicEvent.ID = .init(-1)
}

extension DependencyValues {
    var musicEventID: MusicEvent.ID {
        get {
            self[MusicEventIDDependencyKey.self]
        }
        set { self[MusicEventIDDependencyKey.self] = newValue }
    }
}

@MainActor
@Observable
public class MusicEventFeatures: Identifiable {
    public enum Feature: String, Hashable, Codable, Sendable {
        case schedule, artists, contactInfo, siteMap, location, explore, workshops, notifications, more
    }

    public init(
        _ event: MusicEvent,
        artists: [Artist],
        stages: [Stage],
        schedules: [Schedule]
    ) {

        self.artists = ArtistsList()
        self.more = MoreTabFeature()

        self.shouldShowArtistImages = !artists.compactMap { $0.imageURL }.isEmpty

        if !schedules.isEmpty {
            self.schedule = ScheduleFeature()
        }

        if !event.contactNumbers.isEmpty {
            self.contactInfo = ContactInfoFeature()
        }

        if let location = event.location {
            self.location = LocationFeature(location: location)
        }

        self._event = FetchOne(wrappedValue: event)
    }


    @ObservationIgnored
    @FetchOne
    var event: MusicEvent

//    public var orgLoader = OrganizerLoader()

//    @SharedReader(.appStorage("selectedFeature"))
    public var selectedFeature: Feature = .schedule

    public var schedule: ScheduleFeature?
    public var artists: ArtistsList
    public var location: LocationFeature?
    public var contactInfo: ContactInfoFeature?
    var more: MoreTabFeature


    var shouldShowArtistImages: Bool = true
}

public struct MusicEventFeaturesView: View {
    public init(store: MusicEventFeatures) {
        self.store = store
    }

    @Bindable var store: MusicEventFeatures

    public var body: some View {
        TabView(selection: $store.selectedFeature) {
            if let schedule = store.schedule {
                NavigationStack {
                    ScheduleView(store: schedule)
                }
                .tabItem { Label("Schedule", systemImage: "calendar") }
                .tag(MusicEventFeatures.Feature.schedule)
            }

            NavigationSplitView {
                ArtistsListView(store: store.artists)
            } detail: {
                Text("Select an Artist")
            }
            .tabItem { Label("Artists", systemImage: "person.3") }
            .tag(MusicEventFeatures.Feature.artists)

            if let contactInfo = store.contactInfo {
                NavigationStack {
                    ContactInfoView(store: contactInfo)
                }
                .tabItem { Label("Contact Info", systemImage: "phone") }
                .tag(MusicEventFeatures.Feature.contactInfo)
            }

            if let location = store.location {
                NavigationStack {
                    LocationView(store: location)
                }
                #if os(iOS)
                .tabItem { Label("Location", systemImage: "mappin") }
                #elseif os(Android)
                .tabItem { Label("Location", systemImage: "mappin.circle")}
                #endif
                .tag(MusicEventFeatures.Feature.location)
            }

            NavigationStack {
                MoreView(store: store.more)
            }
            .tabItem { Label("More", systemImage: "ellipsis") }
            .tag(MusicEventFeatures.Feature.more)

//            if let workshops = store.workshops {
//                NavigationStack {
//                    Text("TODO: Workshops")
//                }
//                .tabItem { Label("Workshops", systemImage: "figure.mind.and.body") }
//                .tag(MusicEventFeatures.Feature.workshops)
//            }
//
//            if let siteMap = store.siteMap {
//                NavigationStack {
//                    Text("TODO: Site Map")
//                }
//                .tabItem { Label("Site Map", systemImage: "map") }
//                .tag(MusicEventFeatures.Feature.siteMap)
//            }

//
//            NavigationStack {
//                Text("TODO: Notifications")
//            }
//            .tabItem { Label("Notifications", systemImage: Icons.notifications) }
//            .tag(MusicEventFeatures.Feature.notifications)
        }
        .environment(\.showArtistImages, store.shouldShowArtistImages)
    }
}
