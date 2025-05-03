import SwiftUI

enum ContentTab: String, Hashable {
    case welcome, home, settings
}

@Observable
public class EventFeatures: Identifiable {
    public enum Feature: String, Hashable, Codable {
        case schedule, artists, contactInfo, siteMap, location, explore, workshops, notifications
    }

    public init() {

        self.artists = ArtistsList()
        self.schedule = Schedule()
        self.notifications = Notifications()


        let event: MusicEvent = .testival

        if !event.contactNumbers.isEmpty {
            self.contactInfo = ContactInfo(contactNumbers: event.contactNumbers)
        }

        if let location = event.location {
            self.location = Location(location: location)
        }
    }


//    public var orgLoader = OrganizationLoader()

    public var selectedFeature: Feature = .artists

    public var schedule: Schedule
    public var artists: ArtistsList
    public var workshops: Workshops?
    public var siteMap: SiteMap?
    public var location: Location?
    public var contactInfo: ContactInfo?
    public var notifications: Notifications

    @Observable
    public class Schedule {
        // State
        public var selectedStage: Stage.ID = 0

        public init() { }

        // Data
        public var event: MusicEvent = .previewValue
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
    public class Location {
        public var location: MusicEvent.Location

        public init(location: MusicEvent.Location) {
            self.location = location
        }
    }

    @Observable
    public class ContactInfo {
        public init(contactNumbers: [MusicEvent.ContactNumber]) {
            self.contactNumbers = contactNumbers
        }

        public var contactNumbers: [MusicEvent.ContactNumber]
    }

    @Observable
    public class Notifications {}

}



public struct EventFeaturesView: View {
    public init(store: EventFeatures) {
        self.store = store
    }

    @Bindable var store: EventFeatures

    public var body: some View {
        TabView(selection: $store.selectedFeature) {
//            NavigationStack {
//                ScheduleView(store: store.schedule)
//            }
//            .tabItem { Label("Schedule", systemImage: "calendar") }
//            .tag(EventFeatures.Feature.schedule)

            NavigationStack {
                ArtistsListView(store: store.artists)
            }
            .tabItem { Label("Artists", systemImage: "person.3") }
            .tag(EventFeatures.Feature.artists)

//            if let contactInfo = store.contactInfo {
//                NavigationStack {
//                    ContactInfoView(store: contactInfo)
//                }
//                .tabItem { Label("Contact Info", systemImage: "phone") }
//                .tag(EventFeatures.Feature.contactInfo)
//            }

//            if let location = store.location {
//                NavigationStack {
//                    LocationView(store: location)
//                }
//                #if os(iOS)
//                .tabItem { Label("Location", systemImage: "mappin") }
//                #elseif os(Android)
//                .tabItem { Label("Location", systemImage: "mappin.circle")}
//                #endif
//                .tag(EventFeatures.Feature.location)
//            }

//            if let workshops = store.workshops {
//                NavigationStack {
//                    Text("TODO: Workshops")
//                }
//                .tabItem { Label("Workshops", systemImage: "figure.mind.and.body") }
//                .tag(EventFeatures.Feature.workshops)
//            }
//
//            if let siteMap = store.siteMap {
//                NavigationStack {
//                    Text("TODO: Site Map")
//                }
//                .tabItem { Label("Site Map", systemImage: "map") }
//                .tag(EventFeatures.Feature.siteMap)
//            }

//
//            NavigationStack {
//                Text("TODO: Notifications")
//            }
//            .tabItem { Label("Notifications", systemImage: Icons.notifications) }
//            .tag(EventFeatures.Feature.notifications)
        }
    }
}
