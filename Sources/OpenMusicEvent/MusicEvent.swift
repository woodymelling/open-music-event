//
//  MusicEvent.swift
//  open-music-event
//
//  Created by Woodrow Melling on 4/30/25.
//


import Foundation

public struct OpenMusicEventID<T>: Hashable, Sendable, ExpressibleByIntegerLiteral, RawRepresentable {
    public let rawValue: Int
    public init(_ intValue: Int) {
        self.rawValue = intValue
    }

    public init(rawValue: Int) {
        self.rawValue = rawValue
    }

    public init(integerLiteral value: IntegerLiteralType) {
        self.rawValue = value
    }
}

// @Table
public struct Organization: Equatable {
    public typealias ID = OpenMusicEventID<Organization>

    public var id: ID

    public var name: String
    public var imageURL: URL?
    public var address: String?
    public var timeZone: String?
    public var siteMapImageURL: URL?
}

//@Table
public struct MusicEvent: Equatable, Identifiable, Sendable {
    public typealias ID = OpenMusicEventID<MusicEvent>

    public let id: MusicEvent.ID
    public let name: String  //
    //        public var timeZone: TimeZone

    public let organizationID: Organization.ID

    public let imageURL: URL?
    public let siteMapImageURL: URL?

//    @Column(as: JSONRepresentation<Location>?.self)
    public let location: Location?

//    @Column(as: JSONRepresentation<[ContactNumber]>.self)
    public let contactNumbers: [ContactNumber]

    public struct ContactNumber: Equatable, Sendable, Codable {
        public let phoneNumber: String
        public let title: String
        public let description: String?
    }

    public struct Location: Equatable, Hashable, Sendable, Codable {
        public let address: String?
        public let directions: String?
        public let coordinates: Coordinates?

        public struct Coordinates: Hashable, Sendable, Codable {
            public let latitude: Double
            public let longitude: Double
        }
    }

    public init(
        id: MusicEvent.ID,
        name: String,
        organizationID: Organization.ID,
        imageURL: URL?,
        siteMapImageURL: URL?,
        location: Location?,
        contactNumbers: [ContactNumber]
    ) {
        self.id = id
        self.name = name
        self.organizationID = organizationID
        self.imageURL = imageURL
        self.siteMapImageURL = siteMapImageURL
        self.location = location
        self.contactNumbers = contactNumbers
    }
}


// MARK: Artist
// @Table
public struct Artist: Identifiable, Equatable, Sendable {
    public typealias ID = OpenMusicEventID<Artist>
    public let id: ID
    public let eventID: MusicEvent.ID

    public let name: String
    public let bio: String?
    public let imageURL: URL?
    public let links: [Link]


    public struct Link: Equatable, Hashable, Sendable {
        public var url: URL
        public var label: String? = nil

        public init(url: URL, label: String? = nil) {
            self.url = url
            self.label = label
        }
    }

    public init(
        id: ID,
        eventID: MusicEvent.ID,
        name: String,
        bio: String? = nil,
        imageURL: URL? = nil,
        links: [Link]
    ) {
        self.id = id
        self.eventID = eventID

        self.name = name
        self.bio = bio
        self.imageURL = imageURL
        self.links = links
    }
}

// MARK: Stage
public struct Stage: Identifiable, Equatable, Sendable {
    public typealias ID = OpenMusicEventID<Stage>
    public let id: ID
    public let name: String
    public let iconImageURL: URL?

    public init(id: ID, name: String, iconImageURL: URL? = nil) {
        self.id = id
        self.name = name
        self.iconImageURL = iconImageURL
    }
}

// MARK: Schedule
//@Table
public struct Schedule: Identifiable, Equatable, Sendable {
    public typealias ID = OpenMusicEventID<Schedule>
    public let id: ID
    public let eventID: MusicEvent.ID

//    @Column(as: Date.JulianDayRepresentation?.self)
    public let date: Date?

    public let customTitle: String?
}


//@Table
public struct Performance: Identifiable, Equatable, Sendable, TimelineRepresentable {
    public typealias ID = OpenMusicEventID<Performance>
    public var id: ID

    public var scheduleID: Schedule.ID
    public var customTitle: String?

//    @Column(as: Date.ISO8601Representation.self)
    public var startTime: Date

//    @Column(as: Date.ISO8601Representation.self)
    public var endTime: Date

    public var stageID: Stage.ID

//    @Table
    // A join table for the many-to-many relationship of Performance -> Artist
    public struct PerformanceArtist: Equatable, Sendable {
//        public var performanceID: Performance.ID
        public var artistID: Artist.ID?
        public var anonymousArtistName: String?
    }
}

public protocol TimelineRepresentable {
    var startTime: Date { get }
    var endTime: Date { get }
}

