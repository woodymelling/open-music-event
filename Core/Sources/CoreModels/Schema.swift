//
//  MusicEvent.swift
//  open-music-event
//
//  Created by Woodrow Melling on 4/30/25.
//

import Foundation
import StructuredQueries
@_exported import Tagged

#if canImport(SwiftUI)
import SwiftUI
#endif





public typealias OmeID<T> = Tagged<T, Int>


extension Collection {
    subscript(safe index: Index) -> Element? {
        return indices.contains(index) ? self[index] : nil
    }
}

// MARK: Organizer
@Table
public struct Organizer: Equatable, Identifiable, Sendable, Codable {
    @Column(primaryKey: true)
    public var url: URL

    public var id: ID {
        get { self.url }
        set { self.url = newValue }
    }

    public typealias ID = URL

    public var name: String
    public var imageURL: URL?
    public var iconImageURL: URL?

    public init(
        url: Organizer.ID,
        name: String,
        imageURL: URL? = nil,
        iconImageURL: URL? = nil
    ) {
        self.url = url
        self.name = name
        self.imageURL = imageURL
        self.iconImageURL = iconImageURL
    }
}


extension Organizer.Draft: Identifiable, Equatable, Codable, Sendable {
    public var id: URL? {
        get { self.url }
        set { self.url = newValue }
    }
}

// MARK: Music Event
@Table
public struct MusicEvent: Equatable, Identifiable, Sendable, Codable {
    public typealias ID = OmeID<MusicEvent>

    public var id: MusicEvent.ID
    public var organizerURL: Organizer.ID?

    public let name: String  //

    public var timeZone: TimeZone

    public var startTime: Date?

    public var endTime: Date?

    public let iconImageURL: URL?
    public let imageURL: URL?
    public let siteMapImageURL: URL?

    @Column(as: Location.JSONRepresentation?.self)
    public let location: Location?

    @Column(as: [ContactNumber].JSONRepresentation.self)
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

    public init(
        id: MusicEvent.ID,
        organizerURL: Organizer.ID?,
        name: String,
        timeZone: TimeZone,
        startTime: Date? = nil,
        endTime: Date? = nil,
        imageURL: URL?,
        iconImageURL: URL?,
        siteMapImageURL: URL?,
        location: Location?,
        contactNumbers: [ContactNumber]
    ) {
        self.id = id
        self.organizerURL = organizerURL
        self.name = name
        self.timeZone = timeZone
        self.startTime = startTime
        self.endTime = endTime
        self.imageURL = imageURL
        self.iconImageURL = iconImageURL
        self.siteMapImageURL = siteMapImageURL
        self.location = location
        self.contactNumbers = contactNumbers
    }
}

extension MusicEvent.Draft: Codable, Equatable, Sendable {}

// MARK: Artist
@Table
public struct Artist: Identifiable, Equatable, Sendable {
    public typealias ID = OmeID<Artist>
    public var id: ID
    public var musicEventID: MusicEvent.ID?

    public typealias Name = String
    public let name: Name
    public let bio: String?
    public let imageURL: URL?

    @Column(as: [Link].JSONRepresentation.self)
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
@Table
public struct Stage: Identifiable, Equatable, Sendable, Codable {
    public typealias ID = OmeID<Stage>
    public var id: ID
    public let musicEventID: MusicEvent.ID?

    public typealias Name = String
    public let name: Name

    public var sortIndex: Int?

    public var iconImageURL: URL?
    public var imageURL: URL?

    public let color: OMEColor

    public var posterImageURL: URL?

    @Column(as: [Artist.ID]?.JSONRepresentation.self)
    public var lineup: [Artist.ID]?

    public init(
        id: ID,
        musicEventID: MusicEvent.ID? = nil,
        sortIndex: Int? = nil,
        name: String,
        iconImageURL: URL? = nil,
        imageURL: URL? = nil,
        color: OMEColor,
        posterImageURL: URL? = nil,
        lineup: [Artist.ID]? = []
    ) {
        self.id = id
        self.musicEventID = musicEventID
        self.name = name
        self.sortIndex = sortIndex
        self.iconImageURL = iconImageURL
        self.posterImageURL = posterImageURL
        self.imageURL = imageURL
        self.color = color
        self.lineup = lineup
    }
}

extension Stage.Draft: Codable, Sendable, Equatable {}

public extension Performance {
    @Table
    struct StageOnly: Identifiable, Equatable, Sendable {
        public var id: OmeID<Performance.StageOnly>
        public var artistID: Artist.ID
        public var stage: Stage.ID

        public init(id: OmeID<StageOnly>, artistID: Artist.ID, stage: Stage.ID) {
            self.id = id
            self.artistID = artistID
            self.stage = stage
        }
    }
}

// MARK: Schedule
@Table
public struct Schedule: Identifiable, Equatable, Sendable {
    public typealias ID = OmeID<Schedule>
    public var id: ID
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

extension Schedule.Draft: Codable, Sendable, Equatable {}

// MARK: Performance
@Table
public struct Performance: Identifiable, Equatable, Sendable, TimelineRepresentable {
    public typealias ID = OmeID<Performance>
    public var id: ID
    public let stageID: Stage.ID
    public let scheduleID: Schedule.ID?

    public let startTime: Date
    public let endTime: Date

    public let title: String
//    public let subtitle: String?

    public let description: String?

    // A join table for the many-to-many relationship of Performance -> Artist
    @Table("performanceArtists")
    public struct Artists: Equatable, Sendable, Identifiable {
        public var id: OmeID<Performance.Artists>
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

extension Performance.Draft: Codable, Sendable, Equatable {}
extension Performance.Artists.Draft: Codable, Sendable, Equatable {}
extension Performance.StageOnly.Draft: Codable, Sendable, Equatable {}

public protocol TimelineRepresentable {
    var startTime: Date { get }
    var endTime: Date { get }
}

// MARK: TimeZone
extension TimeZone: @retroactive QueryBindable {

    public var queryBinding: StructuredQueriesCore.QueryBinding {
        .text(identifier)
    }

    struct InvalidTimeZone: Error {}
    public init(decoder: inout some StructuredQueriesCore.QueryDecoder) throws {
        let id = try String(decoder: &decoder)

        guard let timeZone = Self(identifier: id) else {
            throw InvalidTimeZone()
        }

        self = timeZone
    }
}

import GRDB

extension TimeZone: DatabaseValueConvertible {
    public var databaseValue: DatabaseValue {
        identifier.databaseValue
    }

    public static func fromDatabaseValue(_ dbValue: DatabaseValue) -> TimeZone? {
        guard let identifier = String.fromDatabaseValue(dbValue) else {
            return nil
        }
        return TimeZone(identifier: identifier)
    }
}

public enum _ColorTag {}
public typealias OMEColor = Tagged<_ColorTag, Int>
// MARK: Color HexRepresentation
#if canImport(SwiftUI)
import SwiftUI
import CustomDump

public extension OMEColor {
    var swiftUIColor: SwiftUI.Color {
        return Color(hex: self.rawValue)
    }
}

public extension Color {
    init(hex: Int, opacity: Double = 1.0) {
        self.init(
            red: Double((hex >> 16) & 0xFF) / 255.0,
            green: Double((hex >> 8) & 0xFF) / 255.0,
            blue: Double(hex & 0xFF) / 255.0,
            opacity: opacity
        )
    }


    #if canImport(UIKit)
    var hex: Int {
        get throws {
            guard let components = UIColor(self).cgColor.components,
                  components.count >= 3 else {
                struct InvalidColor: Error {}
                throw InvalidColor()
            }
            let r = Int(components[0] * 255.0) << 16
            let g = Int(components[1] * 255.0) << 8
            let b = Int(components[2] * 255.0)
            return r | g | b
        }
    }
    #elseif canImport(AppKit)
    var hex: Int {
        get throws {
            guard let components = NSColor(self).cgColor.components,
                  components.count >= 3 else {
                struct InvalidColor: Error {}
                throw InvalidColor()
            }
            let r = Int(components[0] * 255.0) << 16
            let g = Int(components[1] * 255.0) << 8
            let b = Int(components[2] * 255.0)
            return r | g | b
        }
    }

    #endif
}
#else

#endif

// MARK: Queries

