import Validated
import Foundation
import Collections


protocol EquatableError: Equatable, Error {}

extension Validation.ScheduleError {
    enum PerformanceError: Error, CustomStringConvertible, Equatable {
        case invalidStartTime(ScheduleTimeDecodingError)
        case invalidEndTime(String)
        case artistAndArtists
        case noArtistsOrTitle
        case emptyArtist
        case emptyArtists
        case unknownError

        var description: String {
            switch self {
            case .invalidStartTime(let time): "Unable to parse start time: \(time)"
            case .invalidEndTime(let time): "Unable to parse end time: \(time)"
            case .artistAndArtists: "Cannot have both artist and artists for a performance"
            case .noArtistsOrTitle: "You must provide at least one artist or a title for each set"
            case .emptyArtist: "artist field must have an artist"
            case .emptyArtists: "artists field must have at least one artist"
            case .unknownError: "Failed to parse performance"
            }
        }
    }
}

struct TimelessStagelessPerformance: Equatable, Sendable {
    var startTime: ScheduleTime
    var endTime: ScheduleTime?
    var customTitle: String?
    var artistNames: OrderedSet<String>
}


import Parsing
import FileTree

extension ScheduleDayConversion {
    struct TimelessStagelessPerformanceConversion: Conversion {
        typealias Input = PerformanceDTO
        typealias Output = TimelessStagelessPerformance

        func apply(_ input: PerformanceDTO) throws -> TimelessStagelessPerformance {
            let startTime = try ScheduleTimeConversion().apply(input.time)
            let endTime = try input.endTime.map(ScheduleTimeConversion().apply(_:))
            let artistNames = try getArtists(artist: input.artist, artists: input.artists)

            guard !(input.title == nil && artistNames.isEmpty)
            else { throw PerformanceError.noArtistsOrTitle }

            return TimelessStagelessPerformance(
                startTime: startTime,
                endTime: endTime,
                customTitle: input.title,
                artistNames: artistNames
            )
        }

        func unapply(_ output: TimelessStagelessPerformance) throws -> PerformanceDTO {
            return PerformanceDTO(
                title: output.customTitle,
                artist: output.artistNames.count == 1 ? output.artistNames.first : nil,
                artists: output.artistNames.count > 1 ? Array(output.artistNames) : nil,
                time: try ScheduleTimeConversion().unapply(output.startTime),
                endTime: try output.endTime.map(ScheduleTimeConversion().unapply(_:))
            )
        }


        typealias PerformanceError = Validation.ScheduleError.PerformanceError

        func getArtists(artist: String?, artists: [String]?) throws -> OrderedSet<String> {
            switch (artist, artists) {
            case (.none, .none): return []
            case (.some, .some): throw PerformanceError.artistAndArtists
            case (.some(let artistName), .none):
                guard artistName.hasElements
                else { throw PerformanceError.emptyArtist }

                return OrderedSet([artistName])

            case (.none, .some(let artists)):
                guard artists.hasElements
                else { throw PerformanceError.emptyArtists  }

                return OrderedSet(artists)
            }
        }
    }

}


import Parsing

