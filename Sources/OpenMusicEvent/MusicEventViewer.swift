import SwiftUI
import SharingGRDB

enum ContentTab: String, Hashable {
    case welcome, home, settings
}


struct MusicEventViewer: View {
    var id: MusicEvent.ID

    @State
    var eventFeatures: MusicEventFeatures?

    @State
    var error: LocalizedStringKey?

    @Environment(\.exitEvent) var dismiss

    var body: some View {
        Group {
            if let eventFeatures {
                MusicEventFeaturesView(store: eventFeatures)
            } else {
                ProgressView()
            }
        }
        .task {
            @Dependency(\.defaultDatabase)
            var database

            do {
                @FetchOne(MusicEvent?.find(id))
                var musicEvent: MusicEvent? = nil

                try await $musicEvent.sharedReader.load()

                if let event = musicEvent {
                    withDependencies {
                        $0.musicEventID = self.id
                    } operation: {
                        self.eventFeatures = MusicEventFeatures(event)
                    }
                } else {
                    dismiss()
                }
            } catch {
                dismiss()
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
    public enum Feature: String, Hashable, Codable {
        case schedule, artists, contactInfo, siteMap, location, explore, workshops, notifications, more
    }

    public init(_ event: MusicEvent) {

        self.artists = ArtistsList()
        self.schedule = ScheduleFeature()
        self.notifications = Notifications()
        self.more = MoreTabFeature()


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

//    public var orgLoader = OrganizationLoader()

    public var selectedFeature: Feature = .schedule

    public var schedule: ScheduleFeature
    public var artists: ArtistsList
    public var workshops: Workshops?
    public var siteMap: SiteMap?
    public var location: LocationFeature?
    public var contactInfo: ContactInfoFeature?
    public var notifications: Notifications
    var more: MoreTabFeature

    @Observable
    public class Schedule {
        // State
        public var selectedStage: Stage.ID = 0

        public init() { }

        // Data
//        public var event: MusicEvent

        @ObservationIgnored
        @FetchAll(Current.stages)
        public var stages: [Stage] = []

        public func performances(for stageID: Stage.ID) -> [Performance] {
            return []
        }
    }

    @Observable
    public class Workshops {}

    @Observable
    public class SiteMap {}

    @Observable
    public class Notifications {}

}



public struct MusicEventFeaturesView: View {
    public init(store: MusicEventFeatures) {
        self.store = store
    }

    @Bindable var store: MusicEventFeatures
    

    public var body: some View {
        TabView(selection: $store.selectedFeature) {
            NavigationStack {
                ScheduleView(store: store.schedule)
            }
            .tabItem { Label("Schedule", systemImage: "calendar") }
            .tag(MusicEventFeatures.Feature.schedule)

            NavigationStack {
                ArtistsListView(store: store.artists)
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
    }
}
