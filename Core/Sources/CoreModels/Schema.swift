//
//  MusicEvent.swift
//  open-music-event
//
//  Created by Woodrow Melling on 4/30/25.
//


import Foundation
@_exported import Tagged

public typealias OmeID<T> = Tagged<T, Int>

public enum OrganizationReference: Hashable, Codable, Sendable, LosslessStringConvertible {
    case repository(Repository)
    case url(URL)

    public struct Repository: Hashable, Codable, Sendable {
        public init(baseURL: URL, version: Version) {
            self.baseURL = baseURL
            self.version = version
        }

        var baseURL: URL
        var version: Version

        public enum Version: Hashable, Codable, Sendable {
            case branch(String)
            case version(SemanticVersion)
        }

        public var zipURL: URL {
            switch version {
            case .branch(let name):
                return baseURL.appendingPathComponent("archive/refs/heads/\(name).zip")
            case .version(let version):
                return baseURL.appendingPathComponent("archive/refs/tags/\(version).zip")
            }
        }
    }

    public var zipURL: URL {
        switch self {
        case .repository(let repository):
            return repository.zipURL
        case .url(let url):
            return url
        }
    }

    public init?(_ description: String) {
        guard let url = URL(string: description)
        else { return nil }

        let components = url.pathComponents
                let baseURL = URL(string: "https://\(url.host!)\(components[0...2].joined(separator: "/"))")!
        let refType = components[safe: 4]
        let refName = components[safe: 5]?.replacingOccurrences(of: ".zip", with: "")

        switch refType {
        case "heads":
            guard let branch = refName else { return nil }
            self = .repository(.init(baseURL: baseURL, version: .branch(branch)))
        case "tags":
            guard let tag = refName, let version = SemanticVersion(tag) else { return nil }
            self = .repository(.init(baseURL: baseURL, version: .version(version)))
        default:
            return nil
        }

        return nil
    }

    public var description: String {
        switch self {
        case .repository(let repo):
            return repo.zipURL.absoluteString
        case .url(let url):
            return url.absoluteString
        }
    }
}

extension Collection {
    subscript(safe index: Index) -> Element? {
        return indices.contains(index) ? self[index] : nil
    }
}

// MARK: Organizer
//@Table
public struct Organizer: Equatable, Identifiable, Sendable, Codable {
//    @Column(primaryKey: true)
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
// @Table
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

//    @Column(as: Location.JSONRepresentation?.self)
    public let location: Location?

//    @Column(as: [ContactNumber].JSONRepresentation.self)
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
// @Table
public struct Artist: Identifiable, Equatable, Sendable, Codable {
    public typealias ID = OmeID<Artist>
    public var id: ID
    public var musicEventID: MusicEvent.ID?

    public typealias Name = String
    public let name: Name
    public let bio: String?
    public let imageURL: URL?

//    @Column(as: [Link].JSONRepresentation.self)
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
//@Table
public struct Stage: Identifiable, Equatable, Sendable, Codable {
    public typealias ID = OmeID<Stage>
    public var id: ID
    public let musicEventID: MusicEvent.ID?

    public typealias Name = String
    public let name: Name

    public var sortIndex: Int?

    public let color: OMEColor

    public var iconImageURL: URL?
    public var imageURL: URL?
    public var posterImageURL: URL?

//    @Column(as: [Artist.ID]?.JSONRepresentation.self)
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
//    @Table
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
//@Table
public struct Schedule: Identifiable, Equatable, Sendable, Codable {
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
//@Table
public struct Performance: Identifiable, Equatable, Sendable, TimelineRepresentable, Codable {
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
//    @Table("performanceArtists")
    public struct Artists: Equatable, Sendable, Identifiable, Codable {
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
//extension Performance.StageOnly.Draft: Codable, Sendable, Equatable {}

public protocol TimelineRepresentable {
    var startTime: Date { get }
    var endTime: Date { get }
}


//extension Color.HexRepresentation: Codable { }
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
#endif

// MARK: DRAFT
extension Organizer {
    public static let tableName = "organizers"
    public struct Draft {
        public typealias PrimaryTable = Organizer
        public var url: URL?
        public var name: String
        public var iconImageURL: URL?
        public var imageURL: URL?

        public static let tableName = Organizer.tableName

        public init(_ other: Organizer) {
            self.url = other.url
            self.name = other.name
            self.imageURL = other.imageURL
            self.iconImageURL = other.iconImageURL
        }

        public init(
            url: URL? = nil,
            name: String,
            imageURL: URL?,
            iconImageURL: URL?
        ) {
            self.url = url
            self.name = name
            self.imageURL = imageURL
            self.iconImageURL = iconImageURL
        }
    }
}


extension MusicEvent {
    public static let tableName = "musicEvents"

    public struct Draft {
        public typealias PrimaryTable = MusicEvent

        public var id: MusicEvent.ID?
        public var organizerURL: Organizer.ID?
        public var name: String
        public var timeZone: TimeZone
        public var startTime: Date?
        public var endTime: Date?
        public let iconImageURL: URL?
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
            self.iconImageURL = other.iconImageURL
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
            iconImageURL: URL? = nil,
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
            self.iconImageURL = iconImageURL
            self.imageURL = imageURL
            self.siteMapImageURL = siteMapImageURL
            self.location = location
            self.contactNumbers = contactNumbers
        }
    }
}

extension Artist {
    public static let tableName = "artists"

    public struct Draft {
        public typealias PrimaryTable = Artist

        public var id: ID?
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

        public var id: ID?
        public let musicEventID: MusicEvent.ID?
        public let name: String
        public var sortIndex: Int?
        public var iconImageURL: URL?
        public var imageURL: URL?
        public let color: OMEColor
        public var posterImageURL: URL?
        public var lineup: [Artist.ID]?

        public static let tableName = Stage.tableName

        public init(_ other: Stage) {
            self.id = other.id
            self.musicEventID = other.musicEventID
            self.name = other.name
            self.iconImageURL = other.iconImageURL
            self.imageURL = other.imageURL
            self.color = other.color
            self.lineup = other.lineup
            self.posterImageURL = other.posterImageURL
            self.sortIndex = other.sortIndex
        }

        public init(
            id: ID? = nil,
            musicEventID: MusicEvent.ID? = nil,
            name: String,
            sortIndex: Int?,
            iconImageURL: URL? = nil,
            imageURL: URL? = nil,
            posterImageURL: URL? = nil,
            color: OMEColor,
            lineup: [Artist.ID]? = nil
        ) {
            self.id = id
            self.musicEventID = musicEventID
            self.name = name
            self.iconImageURL = iconImageURL
            self.sortIndex = sortIndex
            self.imageURL = imageURL
            self.color = color
            self.posterImageURL = posterImageURL
            self.lineup = lineup
        }
    }
}

extension Schedule {
    public static let tableName = "schedules"

    public struct Draft {
        public typealias PrimaryTable = Schedule

        public var id: ID?
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

        public var id: ID?
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

        public var id: OmeID<Performance.Artists>?
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
