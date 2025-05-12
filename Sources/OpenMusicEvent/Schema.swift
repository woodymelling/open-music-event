//
//  MusicEvent.swift
//  open-music-event
//
//  Created by Woodrow Melling on 4/30/25.
//


import Foundation
import StructuredQueries
import Dependencies

#if canImport(SwiftUI)
import SwiftUI
#endif

public typealias OmeID<T> = Int
//public struct OmeID<T>: Hashable, Sendable, ExpressibleByIntegerLiteral, RawRepresentable, QueryBindable, Codable {
//    public let rawValue: Int
//    public init(_ intValue: Int) {
//        self.rawValue = intValue
//    }
//
//    public init(rawValue: Int) {
//        self.rawValue = rawValue
//    }
//
//    public init(integerLiteral value: IntegerLiteralType) {
//        self.rawValue = value
//    }
//}
//
//import Tagged
//
//extension OmeID: _OptionalPromotable {}
//extension OmeID: QueryDecodable {}
//extension OmeID: QueryExpression {}
//extension OmeID: QueryRepresentable {}
//extension OmeID: SQLiteType {
//  public static var typeAffinity: SQLiteTypeAffinity {
//      .integer
//  }
//}

// MARK: Organization
@Table
public struct Organization: Equatable, Identifiable, Sendable {
    @Column(primaryKey: true)
    public var url: URL

    public var id: URL {
        self.url
    }

    public var name: String
    public var imageURL: URL?
}

extension Organization.Draft: Equatable {}
extension Organization.Draft: Sendable {}

// MARK: Music Event
@Table
public struct MusicEvent: Equatable, Identifiable, Sendable, Codable {
    public typealias ID = OmeID<MusicEvent>
    
    public let id: MusicEvent.ID
    public let organizationURL: Organization.ID?
    
    public let name: String  //
    
    public var timeZone: TimeZone
    
    @Column(as: Date?.ISO8601Representation.self)
    public var startTime: Date?
    
    @Column(as: Date?.ISO8601Representation.self)
    public var endTime: Date?
    
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

extension MusicEvent.Draft: Codable {}
extension MusicEvent.Draft: Equatable {}

// MARK: Artist
@Table
public struct Artist: Identifiable, Equatable, Sendable {
    public let id: Int
    public let musicEventID: MusicEvent.ID?

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
    public var musicEventID: MusicEvent.ID?
    public var name: String
    public var iconImageURL: URL?

    public var color: Color
}




// MARK: Schedule
@Table
public struct Schedule: Identifiable, Equatable, Sendable {
    public typealias ID = OmeID<Schedule>
    public let id: ID


    public let musicEventID: MusicEvent.ID?

    @Column(as: Date.ISO8601Representation?.self)
    public let startTime: Date?

    @Column(as: Date.ISO8601Representation?.self)
    public let endTime: Date?

    public let customTitle: String?
}

// MARK: Performance
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
    public struct Artists: Equatable, Sendable, Identifiable {
        public let id: OmeID<Performance.Artists>
        public let performanceID: Performance.ID
        public let artistID: Artist.ID?
        public let anonymousArtistName: String?
    }

}

public protocol TimelineRepresentable {
    var startTime: Date { get }
    var endTime: Date { get }
}

// MARK: TimeZone
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
private struct InvalidColor: Error {}

extension Color: QueryBindable {
    public var queryBinding: StructuredQueriesCore.QueryBinding {
        do {
            return try .int(Int64(self.hex))
        } catch {
            return .invalid((error))
        }
    }
    
    public init(decoder: inout some StructuredQueriesCore.QueryDecoder) throws {
        let int = try Int(decoder: &decoder)
        let color = Color(hex: int)
        self = color
    }
    

}

// MARK: Color HexRepresentation
#if canImport(SwiftUI)
import SwiftUI
extension Color {
  public struct HexRepresentation: QueryBindable, QueryRepresentable {
    public var queryOutput: Color
    public var queryBinding: QueryBinding {
        do {
            return try .int(Int64(queryOutput.hex))
        } catch {
            return .invalid(error)
        }

    }
    public init(queryOutput: Color) {
      self.queryOutput = queryOutput
    }
      public init(_ int: Int)  {
          self.queryOutput = Color(hex: int)
      }
    public init(decoder: inout some QueryDecoder) throws {
      let hex = try Int(decoder: &decoder)
      self.init(
        queryOutput: Color(hex: hex)
      )
    }
  }
}

extension Color: Codable {
    public init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        let hexInt = try container.decode(Int.self)
        self = Color(hex: hexInt)
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        try container.encode(self.hex)
    }
}

extension Color.HexRepresentation: Codable { }


extension Color {
    init(hex: Int) {
        self.init(
          red: Double((hex >> 24) & 0xFF) / 0xFF,
          green: Double((hex >> 16) & 0xFF) / 0xFF,
          blue: Double((hex >> 8) & 0xFF) / 0xFF,
          opacity: Double(hex & 0xFF) / 0xFF
        )
    }

    var hex: Int {
        get throws {
            guard let components = UIColor(self).cgColor.components
            else {
              struct InvalidColor: Error {}
              throw InvalidColor()
            }
            let r = Int64(components[0] * 0xFF) << 24
            let g = Int64(components[1] * 0xFF) << 16
            let b = Int64(components[2] * 0xFF) << 8
            let a = Int64((components.indices.contains(3) ? components[3] : 1) * 0xFF)
            return Int(r | g | b | a)
        }
    }
}
#endif

// MARK: Queries

extension Performance {
    static let withStage = Self.all.join(Stage.all) { $0.stageID.eq($1.id) }
    static let withColor = Self.withStage.select { ($0, $1.color) }


    static let performances = { @Sendable (artistID: Artist.ID) in
        Performance.Artists
            .where { $0.artistID == artistID }
            .join(Performance.all) { $0.performanceID == $1.id }
            .select { $1 }
    }

    static let performanceDetails = Performance
        .withStage
        .select {
            ArtistDetail.ArtistPerformance.Columns(
                id: $0.id,
                stageID: $1.id,
                startTime: $0.startTime,
                endTime: $0.endTime,
                customTitle: $0.customTitle,
                stageColor: $1.color
            )
        }
}


extension ArtistsList {
    static let rowsQuery = Current.artists
        .group(by: \.id)
        .rightJoin(Performance.Artists.all) { $1.artistID.eq($0.id) }
        .join(Performance.all) { $1.performanceID.eq($2.id) }
        .join(Stage.all) { $2.stageID.eq($3.id) }
        .select {
            ArtistRow.Columns(
                id: $0.id,
                name: $0.name,
                imageURL: $0.imageURL,
                performanceColors: $3.color.jsonGroupArray()
            )
        }
}


@Selection
struct ArtistRow: Identifiable {
    var id: Artist.ID?
    var name: String?
    var imageURL: URL?

    @Column(as: [Color].JSONRepresentation.self)
    var performanceColors: [Color]
}
