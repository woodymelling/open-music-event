//
//  FileTree.swift
//  OpenFestival
//
//  Created by Woodrow Melling on 9/30/24.
//

@preconcurrency import FileTree

import Yams
import IssueReporting
import Collections
import Conversions
import Foundation


public func read(from url: URL) throws -> Organization {
    try Organization.fileTree.read(from: url)
}


extension Organization {
    static var fileTree: some FileTreeViewable<Organization> {
        FileTree {
            Organization.Info.file

                Directory.Many {
                    EventFileTree()
                }
        }
        .convert(fileConversion)
    }

    static var fileConversion: some Conversion<(Organization.Info, [DirectoryContent<Event>]), Organization> {
        Convert {
            Organization.init(
                id: .init(),
                info: $0.0,
                events: $0.1.map(\.components)
            )

        } unapply: {
            (
                $0.info,
                $0.events.map { DirectoryContent(directoryName: $0.info.name, components: $0)}
            )
        }
    }
}

// MARK: Organization
extension Organization.Info {
    static var file: some FileTreeViewable<Organization.Info> {
        File("organization-info", .yaml)
            .convert {
                Conversions.YamlConversion<Self.YamlRepresentation>()

                Convert {
                    Organization.Info(
                        name: $0.name,
                        imageURL: $0.imageURL
                    )
                } unapply: { 
                    YamlRepresentation(
                        name: $0.name,
                        imageURL: $0.imageURL,
                        address: nil,
                        timeZone: nil,
                        siteMapImageURL: nil,
                        colorScheme: nil
                    )
                }
            }
    }

    struct YamlRepresentation: Codable, Equatable {
        var name: String
        var imageURL: URL?
        var address: String?
        var timeZone: String?
        var siteMapImageURL: URL?
        var colorScheme: ColorScheme?
    }
}

extension Event.Info {
    static var file: some FileTreeViewable<Event.Info.YamlRepresentation> {
        File("event-info", .yaml)
            .convert(Conversions.YamlConversion(Event.Info.YamlRepresentation.self))
    }
}

typealias Convert = AnyConversion


// MARK: Event
public struct EventFileTree: FileTreeViewable {
    public init() {}

    public var body: some FileTreeComponent<Event> & FileTreeViewable {
        FileTree {
            Event.Info.file

            File("stages", .yaml)
                .convert(StagesConversion())

            Directory("schedules") {
                File.Many(withExtension: .yaml)
                    .map(ScheduleConversion())
            }

            Directory("artists") {
                File.Many(withExtension: "md")
                    .map(ArtistConversion())
            }
        }
        .convert(EventConversion())
    }

    struct ScheduleConversion: Conversion {
        var body: some Conversion<FileContent<Data>, StringlyTyped.Schedule> {
            FileContentConversion {
                Conversions.YamlConversion(DTOs.Event.DaySchedule.self)
            }

            ScheduleDayConversion()
        }
    }

    struct EventConversion: Conversion {
        typealias Input = (Event.Info.YamlRepresentation, [Event.Stage], [StringlyTyped.Schedule], [Event.Artist])
        typealias Output = Event

        func apply(_ input: Input) throws -> Event {
            let artists = input.3
            let stages = input.1


            return Event(
                name: input.0.name ?? "",
                // TODO?
                timeZone: try TimeZoneConversion().apply(input.0.timeZone) ?? TimeZone.current,
                imageURL: input.0.imageURL.map { Event.ImageURL($0) },
                siteMapImageURL: input.0.siteMapImageURL.map { Event.SiteMapImageURL($0) },
                location: Event.Location(
                    address: input.0.address
                    // TODO: More here
                ),
                contactNumbers: (input.0.contactNumbers ?? []).map {
                    .init(
                        id: .init(),
                        title: $0.title,
                        phoneNumber: $0.phoneNumber,
                        description: $0.description
                    )
                },
                artists: artists,
                stages: input.1,
                schedule: [],
                colorScheme: nil // TODO:
            )
        }

        func unapply(_ output: Event) throws -> Input {
//            let schedules = output.schedule.map {
//
//                StringlyTyped.Schedule(
//                    metadata: $0.metadata,
//                    stageSchedules: Dictionary(
//                        uniqueKeysWithValues: $0.stageSchedules.map { stageID, performances in
//                            guard let stageName = output.stages[id: stageID]?.name else {
//                                fatalError("Missing stage name for \(stageID)")
//                            }
//                            let stringlyTypedPerformances = performances.map { performance in
//                                StringlyTyped.Schedule.Performance(
//                                    artistNames: OrderedSet(performance.artistIDs.compactMap {
//                                        switch $0 {
//                                        case .known(let artistID):
//                                            output.artists[id: artistID]?.name
//                                        case .anonymous(let artistName):
//                                            artistName
//                                        }
//                                    }),
//                                    startTime: performance.startTime,
//                                    endTime: performance.endTime,
//                                    stageName: stageName
//                                )
//                            }
//                            .sorted(by: { $0.startTime < $1.startTime })
//
//
//                            return (stageName, stringlyTypedPerformances)
//                        })
//                )
//            }

            return (
                Event.Info.YamlRepresentation(
                    name: output.info.name,
                    address: output.info.location?.address,
                    timeZone: output.info.timeZone.identifier,
                    imageURL: output.info.imageURL?.rawValue,
                    siteMapImageURL: output.info.siteMapImageURL?.rawValue,
                    colorScheme: nil,
                    contactNumbers: output.info.contactNumbers.map {
                        .init(phoneNumber: $0.phoneNumber, title: $0.title, description: $0.description)
                    }
                ),
                Array(output.stages),
                [],
                Array(output.artists)
            )
        }

        struct TimeZoneConversion: Conversion {
            typealias Input = String?
            typealias Output = TimeZone?

            func apply(_ input: String?) throws -> TimeZone? {
                input.flatMap(TimeZone.init(identifier:)) ?? input.flatMap(TimeZone.init(abbreviation:))
            }

            func unapply(_ output: TimeZone?) throws -> String? {
                output.map { $0.identifier }
            }
        }
    }


    struct StagesConversion: Conversion {
        var body: some Conversion<Data, [Event.Stage]> {
            Conversions.YamlConversion([StageDTO].self)
                .mapValues {
                    Event.Stage(
                        name: $0.name,
                        iconImageURL: $0.imageURL
                    )
                } unapply: {
                    StageDTO(
                        name: $0.name,
                        color: nil, // Needs to get set from the Event Color Scheme?
                        imageURL: $0.iconImageURL
                    )
                }
        }
    }

    struct ContactInfoConversion: Conversion {
        typealias Input = Data
        typealias Output = [Event.ContactNumber]

        var body: some Conversion<Data, [Event.ContactNumber]> {
            Conversions.YamlConversion([ContactInfoDTO].self)
            Conversions.MapValues(ContactNumberDTOConversion())
        }


        struct ContactNumberDTOConversion: Conversion {
            typealias Input = ContactInfoDTO
            typealias Output = Event.ContactNumber
            func apply(_ input: Input) throws -> Output {
                Event.ContactNumber(
                    id: .init(),
                    title: input.title,
                    phoneNumber: input.phoneNumber,
                    description: input.description
                )
            }

            func unapply(_ output: Output) throws -> Input {
                ContactInfoDTO(
                    phoneNumber: output.phoneNumber,
                    title: output.title,
                    description: output.description
                )
            }
        }
    }
}

extension Event {
    
}


extension Dictionary {
    func mapValuesWithKeys<NewValue>(_ transform: (Key, Value) -> NewValue) -> [Key: NewValue] {
        Dictionary<Key, NewValue>(uniqueKeysWithValues: self.map { ($0, transform($0, $1))})
    }
}

extension Tagged {
    struct Conversion: Parsing.Conversion {
        typealias Input = RawValue
        typealias Output = Tagged<Tag, RawValue>

        func apply(_ input: RawValue) throws -> Tagged<Tag, RawValue> {
            Tagged(input)
        }

        func unapply(_ output: Tagged<Tag, RawValue>) throws -> RawValue {
            output.rawValue
        }
    }
}


typealias Identity = Conversions.Identity

extension DTOs.Event.DaySchedule {
    struct TupleConversion: Conversion {
        typealias Input = DTOs.Event.DaySchedule
        typealias Output = (String?, CalendarDate?, [String: [PerformanceDTO]])

        func apply(_ input: Input) throws -> Output {
            (input.customTitle, input.date, input.performances)
        }

        func unapply(_ output: Output) throws -> Input {
            .init(
                customTitle: output.0,
                date: output.1,
                performances: output.2
            )
        }
    }
}

extension Conversions {
    struct FatalError<Input, Output>: Conversion {
        func apply(_ input: Input) throws -> Output {
            fatalError()
        }

        func unapply(_ output: Output) throws -> Input {
            fatalError()
        }
    }
}

extension Conversion {
    func mapValues<OutputElement: Sendable, NewOutput: Sendable>(
        apply: @Sendable @escaping (OutputElement) throws -> NewOutput,
        unapply: @Sendable @escaping (NewOutput) throws -> OutputElement
    ) -> some Conversion<Input, [NewOutput]> where Output == [OutputElement] {
        self.map(Conversions.MapValues(AnyConversion(apply: apply, unapply: unapply)))
    }

    func mapValues<OutputElement: Sendable, NewOutput: Sendable, C>(
        _ conversion: some Conversion<OutputElement, NewOutput>
    ) -> some Conversion<Input, [NewOutput]>
    where Output == [OutputElement] {
        self.map(Conversions.MapValues(conversion))
    }

    func mapValues<OutputElement: Sendable, NewOutput: Sendable, C>(
        @ConversionBuilder _ conversion: () -> some Conversion<OutputElement, NewOutput>
    ) -> some Conversion<Input, [NewOutput]>
    where Output == [OutputElement] {
        self.map(Conversions.MapValues(conversion))
    }
}


extension FileExtension {
    static let markdown: FileExtension = "md"
}

struct ArtistConversion: Conversion {
    var body: some Conversion<FileContent<Data>, Event.Artist> {
        FileContentConversion {
            Conversions.DataToString()
            MarkdownWithFrontMatterConversion<ArtistInfoFrontMatter>()
        }

        FileToArtistConversion()
    }

    struct FileToArtistConversion: Conversion {
        typealias Input = FileContent<MarkdownWithFrontMatter<ArtistInfoFrontMatter>>
        typealias Output = Event.Artist

        func apply(_ input: Input) throws -> Output {
            Event.Artist(
                name: input.fileName,
                bio: input.data.body,
                imageURL: input.data.frontMatter?.imageURL,
                links: (input.data.frontMatter?.links ?? []).map { .init(url: $0.url, label: $0.label )}
            )
        }

        func unapply(_ output: Output) throws -> Input {
            FileContent(
                fileName: output.name,
                data: MarkdownWithFrontMatter(
                    frontMatter: ArtistInfoFrontMatter(
                        imageURL: output.imageURL,
                        links: output.links.map { .init(url: $0.url, label: $0.label )}
                    ).nilIfEmpty,
                    body: output.bio?.nilIfEmpty
                )
            )
        }
    }
}



import Foundation

import Parsing
import Conversions



struct OpenFestivalDecoder {
    public func decode(from url: URL) throws -> Event {
        return try EventFileTree().read(from: url)
    }

}


extension Collection {
    var nilIfEmpty: Self? {
        self.isEmpty ? nil : self
    }
}

extension ArtistInfoFrontMatter {
    var nilIfEmpty: Self? {
        if self.imageURL == nil && self.links.isEmpty {
            return nil
        } else {
            return self
        }
    }
}
