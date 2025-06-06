//
//  MusicEvent.swift
//  open-music-event
//
//  Created by Woodrow Melling on 4/30/25.
//


import Foundation
//import StructuredQueries

#if canImport(SwiftUI)
import SwiftUI
#endif

import Tagged
public typealias OmeID<T> = Tagged<T, Int>

// MARK: Organizer
// @Table
public struct Organizer: Equatable, Identifiable, Sendable, Codable {
    // @Column(primaryKey: true)
    public let url: URL

    public var id: URL {
        self.url
    }

    public var name: String
    public var imageURL: URL?

    public init(url: URL, name: String, imageURL: URL? = nil) {
        self.url = url
        self.name = name
        self.imageURL = imageURL
    }
}

extension Organizer.Draft: Equatable, Codable, Sendable {}

// MARK: Music Event
// @Table
public struct MusicEvent: Equatable, Identifiable, Sendable, Codable {
    public typealias ID = OmeID<MusicEvent>
    
    public let id: MusicEvent.ID
    public let organizerURL: Organizer.ID?
    
    public let name: String  //
    
    public var timeZone: TimeZone
    
    public var startTime: Date?
    
    public var endTime: Date?
    
    public let imageURL: URL?
    public let siteMapImageURL: URL?
    
    // @Column(as: Location.JSONRepresentation?.self)
    public let location: Location?
    
    // @Column(as: [ContactNumber].JSONRepresentation.self)
    public let contactNumbers: [ContactNumber]
    
    public struct ContactNumber: Equatable, Sendable, Codable {
        public let phoneNumber: String
        public let title: String
        public let description: String?

        public init(phoneNumber: String, title: String, description: String?) {
            self.phoneNumber = phoneNumber
            self.title = title
            self.description = description
        }
    }
    
    public struct Location: Equatable, Sendable, Codable {
        public let address: String?
        public let directions: String?
        public let coordinates: Coordinates?

        public struct Coordinates: Equatable, Sendable, Codable {
            public let latitude: Double
            public let longitude: Double

            public init(latitude: Double, longitude: Double) {
                self.latitude = latitude
                self.longitude = longitude
            }
        }

        public init(address: String?, directions: String?, coordinates: Coordinates?) {
            self.address = address
            self.directions = directions
            self.coordinates = coordinates
        }
    }

    public init(id: MusicEvent.ID, organizerURL: Organizer.ID?, name: String, timeZone: TimeZone, startTime: Date? = nil, endTime: Date? = nil, imageURL: URL?, siteMapImageURL: URL?, location: Location?, contactNumbers: [ContactNumber]) {
        self.id = id
        self.organizerURL = organizerURL
        self.name = name
        self.timeZone = timeZone
        self.startTime = startTime
        self.endTime = endTime
        self.imageURL = imageURL
        self.siteMapImageURL = siteMapImageURL
        self.location = location
        self.contactNumbers = contactNumbers
    }

}

extension MusicEvent.Draft: Codable, Equatable, Sendable {}

// MARK: Artist
// @Table
public struct Artist: Identifiable, Equatable, Sendable {
    public typealias ID = OmeID<Artist>
    public let id: ID
    public let musicEventID: MusicEvent.ID?

    public let name: String
    public let bio: String?
    public let imageURL: URL?

    // @Column(as: [Link].JSONRepresentation.self)
    public let links: [Link]

    public struct Link: Equatable, Codable, Sendable {
        public var url: URL
        public var label: String? = nil

        public init(url: URL, label: String? = nil) {
            self.url = url
            self.label = label
        }
    }

    public init(id: OmeID<Artist>, musicEventID: MusicEvent.ID?, name: String, bio: String?, imageURL: URL?, links: [Link]) {
        self.id = id
        self.musicEventID = musicEventID
        self.name = name
        self.bio = bio
        self.imageURL = imageURL
        self.links = links
    }
}

extension Artist.Draft: Equatable, Sendable, Codable {}

// MARK: Stage
// @Table
public struct Stage: Identifiable, Equatable, Sendable, Codable {
    public typealias ID = OmeID<Stage>
    public let id: ID
    public let musicEventID: MusicEvent.ID?
    public let name: String
    public var iconImageURL: URL?
    public var imageURL: URL?

    public let color: Color
    public typealias Color = Int


    public init(
        id: ID,
        musicEventID: MusicEvent.ID? = nil,
        name: String,
        iconImageURL: URL? = nil,
        imageURL: URL? = nil,
        color: Color
    ) {
        self.id = id
        self.musicEventID = musicEventID
        self.name = name
        self.iconImageURL = iconImageURL
        self.imageURL = imageURL
        self.color = color
    }
}

extension Stage.Draft: Codable, Sendable, Equatable {}


// MARK: Schedule
// @Table
public struct Schedule: Identifiable, Equatable, Sendable {
    public typealias ID = OmeID<Schedule>
    public let id: ID
    public let musicEventID: MusicEvent.ID?

    public let startTime: Date?
    public let endTime: Date?

    public let customTitle: String?

    public init(id: ID, musicEventID: MusicEvent.ID?, startTime: Date?, endTime: Date?, customTitle: String?) {
        self.id = id
        self.musicEventID = musicEventID
        self.startTime = startTime
        self.endTime = endTime
        self.customTitle = customTitle
    }
}

// MARK: Performance
// @Table
public struct Performance: Identifiable, Equatable, Sendable, TimelineRepresentable {
    public typealias ID = OmeID<Performance>
    public let id: ID
    public let stageID: Stage.ID
    public let scheduleID: Schedule.ID?

    public let startTime: Date
    public let endTime: Date

    public let title: String
//    public let subtitle: String?

    public let description: String?

    // A join table for the many-to-many relationship of Performance -> Artist
    // @Table("performanceArtists")
    public struct Artists: Equatable, Sendable, Identifiable {
        public let id: OmeID<Performance.Artists>
        public let performanceID: Performance.ID
        public let artistID: Artist.ID?
        public let anonymousArtistName: String?

        public init(id: OmeID<Performance.Artists>, performanceID: Performance.ID, artistID: Artist.ID?, anonymousArtistName: String?) {
            self.id = id
            self.performanceID = performanceID
            self.artistID = artistID
            self.anonymousArtistName = anonymousArtistName
        }
    }

    public init(id: ID, stageID: Stage.ID, scheduleID: Schedule.ID?, startTime: Date, endTime: Date, title: String, description: String?) {
        self.id = id
        self.stageID = stageID
        self.scheduleID = scheduleID
        self.startTime = startTime
        self.endTime = endTime
        self.title = title
        self.description = description
    }

}

public protocol TimelineRepresentable {
    var startTime: Date { get }
    var endTime: Date { get }
}

extension Organizer {
    public static let tableName = "organizers"
    public struct Draft {
        public typealias PrimaryTable = Organizer
        public let url: URL?
        public var name: String
        public var imageURL: URL?

        public static let tableName = Organizer.tableName

        public init(_ other: Organizer) {
            self.url = other.url
            self.name = other.name
            self.imageURL = other.imageURL
        }

        public init(
            url: URL? = nil,
            name: String,
            imageURL: URL? = nil
        ) {
            self.url = url
            self.name = name
            self.imageURL = imageURL
        }
    }
}
extension MusicEvent {
    public static let tableName = "musicEvents"

    public struct Draft {
        public typealias PrimaryTable = MusicEvent

        public let id: MusicEvent.ID?
        public let organizerURL: Organizer.ID?
        public let name: String
        public var timeZone: TimeZone
        public var startTime: Date?
        public var endTime: Date?
        public let imageURL: URL?
        public let siteMapImageURL: URL?
        public let location: Location?
        public let contactNumbers: [ContactNumber]

        public static let tableName = MusicEvent.tableName

        public init(_ other: MusicEvent) {
            self.id = other.id
            self.organizerURL = other.organizerURL
            self.name = other.name
            self.timeZone = other.timeZone
            self.startTime = other.startTime
            self.endTime = other.endTime
            self.imageURL = other.imageURL
            self.siteMapImageURL = other.siteMapImageURL
            self.location = other.location
            self.contactNumbers = other.contactNumbers
        }
        public init(
            id: MusicEvent.ID? = nil,
            organizerURL: Organizer.ID? = nil,
            name: String,
            timeZone: TimeZone,
            startTime: Date? = nil,
            endTime: Date? = nil,
            imageURL: URL? = nil,
            siteMapImageURL: URL? = nil,
            location: Location? = nil,
            contactNumbers: [ContactNumber]
        ) {
            self.id = id
            self.organizerURL = organizerURL
            self.name = name
            self.timeZone = timeZone
            self.startTime = startTime
            self.endTime = endTime
            self.imageURL = imageURL
            self.siteMapImageURL = siteMapImageURL
            self.location = location
            self.contactNumbers = contactNumbers
        }
    }
}

extension Artist {
    static let tableName = "artists"

    public struct Draft {
        public typealias PrimaryTable = Artist

        public let id: ID?
        public let musicEventID: MusicEvent.ID?
        public let name: String
        public let bio: String?
        public let imageURL: URL?
        public let links: [Link]

        public static let tableName = Artist.tableName

        public init(_ other: Artist) {
            self.id = other.id
            self.musicEventID = other.musicEventID
            self.name = other.name
            self.bio = other.bio
            self.imageURL = other.imageURL
            self.links = other.links
        }
        public init(
            id: ID? = nil,
            musicEventID: MusicEvent.ID? = nil,
            name: String,
            bio: String? = nil,
            imageURL: URL? = nil,
            links: [Link]
        ) {
            self.id = id
            self.musicEventID = musicEventID
            self.name = name
            self.bio = bio
            self.imageURL = imageURL
            self.links = links
        }
    }
}

extension Stage {
    public static let tableName = "stages"

    public struct Draft {
        public typealias PrimaryTable = Stage

        public let id: ID?
        public let musicEventID: MusicEvent.ID?
        public let name: String
        public var iconImageURL: URL?
        public var imageURL: URL?
        public let color: Color
        public static let tableName = Stage.tableName

        public init(_ other: Stage) {
            self.id = other.id
            self.musicEventID = other.musicEventID
            self.name = other.name
            self.iconImageURL = other.iconImageURL
            self.imageURL = other.imageURL
            self.color = other.color
        }

        public init(
            id: ID? = nil,
            musicEventID: MusicEvent.ID? = nil,
            name: String,
            iconImageURL: URL? = nil,
            imageURL: URL? = nil,
            color: Color
        ) {
            self.id = id
            self.musicEventID = musicEventID
            self.name = name
            self.iconImageURL = iconImageURL
            self.imageURL = imageURL
            self.color = color
        }
    }
}

extension Schedule {
    public static let tableName = "schedules"

    public struct Draft {
        public typealias PrimaryTable = Schedule

        public let id: ID?
        public let musicEventID: MusicEvent.ID?
        public let startTime: Date?
        public let endTime: Date?
        public let customTitle: String?

        public static let tableName = Schedule.tableName

        public init(_ other: Schedule) {
            self.id = other.id
            self.musicEventID = other.musicEventID
            self.startTime = other.startTime
            self.endTime = other.endTime
            self.customTitle = other.customTitle
        }

        public init(
            id: ID? = nil,
            musicEventID: MusicEvent.ID? = nil,
            startTime: Date? = nil,
            endTime: Date? = nil,
            customTitle: String? = nil
        ) {
            self.id = id
            self.musicEventID = musicEventID
            self.startTime = startTime
            self.endTime = endTime
            self.customTitle = customTitle
        }
    }
}

extension Performance {
    public static let tableName = "performances"

    public struct Draft {
        public typealias PrimaryTable = Performance

        public let id: ID?
        public let stageID: Stage.ID
        public let scheduleID: Schedule.ID?
        public let startTime: Date
        public let endTime: Date
        public let title: String
        public let description: String?

        public static let tableName = Performance.tableName

        public init(_ other: Performance) {
            self.id = other.id
            self.stageID = other.stageID
            self.scheduleID = other.scheduleID
            self.startTime = other.startTime
            self.endTime = other.endTime
            self.title = other.title
            self.description = other.description
        }
        public init(
            id: ID? = nil,
            stageID: Stage.ID,
            scheduleID: Schedule.ID? = nil,
            startTime: Date,
            endTime: Date,
            title: String,
            description: String? = nil
        ) {
            self.id = id
            self.stageID = stageID
            self.scheduleID = scheduleID
            self.startTime = startTime
            self.endTime = endTime
            self.title = title
            self.description = description
        }
    }
}

extension Performance.Artists {
    public static let tableName = "performanceArtists"

    public struct Draft {
        public typealias PrimaryTable = Performance.Artists

        public let id: OmeID<Performance.Artists>?
        public let performanceID: Performance.ID
        public let artistID: Artist.ID?
        public let anonymousArtistName: String?

        public static let tableName = Performance.Artists.tableName

        public init(_ other: Performance.Artists) {
            self.id = other.id
            self.performanceID = other.performanceID
            self.artistID = other.artistID
            self.anonymousArtistName = other.anonymousArtistName
        }
        public init(
            id: OmeID<Performance.Artists>? = nil,
            performanceID: Performance.ID,
            artistID: Artist.ID? = nil,
            anonymousArtistName: String? = nil
        ) {
            self.id = id
            self.performanceID = performanceID
            self.artistID = artistID
            self.anonymousArtistName = anonymousArtistName
        }
    }
}
