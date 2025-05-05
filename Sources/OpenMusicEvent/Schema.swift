//
//  MusicEvent.swift
//  open-music-event
//
//  Created by Woodrow Melling on 4/30/25.
//


import Foundation
import StructuredQueries

public struct OmeID<T>: Hashable, Sendable, ExpressibleByIntegerLiteral, RawRepresentable, QueryBindable {
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

@Table
public struct Organization: Equatable {
    public typealias ID = OmeID<Organization>

    public var id: ID

    public var name: String
    public var imageURL: URL?
}

// MARK: Music Event
@Table
public struct MusicEvent: Equatable, Identifiable, Sendable {
    public typealias ID = OmeID<MusicEvent>
    
    public let id: MusicEvent.ID
    public let organizationID: Organization.ID?
    
    public let name: String  //
    
    public var timeZone: TimeZone
    
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
    }
    
    public struct Location: Equatable, Sendable, Codable {
        public let address: String?
        public let directions: String?
        public let coordinates: Coordinates?
        
        public struct Coordinates: Equatable, Sendable, Codable {
            public let latitude: Double
            public let longitude: Double
        }
    }
}

// MARK: Artist
@Table
public struct Artist: Identifiable, Equatable, Sendable {
    public typealias ID = OmeID<Artist>
    public let id: ID
    public let eventID: MusicEvent.ID?

    public let name: String
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
}

// MARK: Stage
@Table
public struct Stage: Identifiable, Equatable, Sendable {
    public typealias ID = OmeID<Stage>
    public let id: ID
    public let eventID: MusicEvent.ID?
    public let name: String
    public let iconImageURL: URL?
}

// MARK: Schedule
@Table
public struct Schedule: Identifiable, Equatable, Sendable {
    public typealias ID = OmeID<Schedule>
    public let id: ID
    public let eventID: MusicEvent.ID

    @Column(as: Date.ISO8601Representation?.self)
    public let startTime: Date?

    @Column(as: Date.ISO8601Representation?.self)
    public let endTime: Date?

    public let customTitle: String?
}

@Table
public struct Performance: Identifiable, Equatable, Sendable, TimelineRepresentable {
    public typealias ID = OmeID<Performance>
    public let id: ID
    public let stageID: Stage.ID
    public let scheduleID: Schedule.ID?

    @Column(as: Date.ISO8601Representation.self)
    public let startTime: Date

    @Column(as: Date.ISO8601Representation.self)
    public let endTime: Date

    public let customTitle: String?
    public let description: String?


    // A join table for the many-to-many relationship of Performance -> Artist
    @Table("performanceArtists")
    public struct Artists: Equatable, Sendable {
        public let performanceID: Performance.ID
        public let artistID: Artist.ID?
        public let anonymousArtistName: String?
    }
}

public protocol TimelineRepresentable {
    var startTime: Date { get }
    var endTime: Date { get }
}


extension TimeZone: @retroactive QueryBindable {
    public var queryBinding: StructuredQueriesCore.QueryBinding {
        .text(identifier)
    }
    
    public init(decoder: inout some StructuredQueriesCore.QueryDecoder) throws {
        guard let timeZone = Self(identifier: try String(decoder: &decoder)) else {
            throw InvalidTimeZone()
        }

        self = timeZone
    }
}

private struct InvalidTimeZone: Error {}

