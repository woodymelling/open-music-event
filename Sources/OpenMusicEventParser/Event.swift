//
//  File.swift
//
//
//  Created by Woody on 2/10/22.
//

import Foundation
import Tagged
import IdentifiedCollections
import Collections
import CoreModels

public typealias OpenFestivalIDType = UUID

public struct OrganizerConfiguration: Equatable, Identifiable, Sendable {
    public var id: Tagged<Self, OpenFestivalIDType>

    public var info: CoreModels.Organizer
    public var events: [Event]
}

public struct Event: Equatable, Sendable {
    public var info: Info
    public var artists: [Artist]
    public var stages: Stages
    public var schedule: [StringlyTyped.Schedule]
    public var colorScheme: ColorScheme?

    // MARK: TO BE REMOVED
    public struct Info: Equatable, Sendable {
        public var name: String //
        public var timeZone: TimeZone
        public var startTime: Date?
        public var endTime: Date?

        public var imageURL: Event.ImageURL? = nil
        public var siteMapImageURL: SiteMapImageURL? = nil

        public var location: Location?

        public var contactNumbers: [ContactNumber] = []

        public init(
            name: String,
            timeZone: TimeZone,
            startTime: Date?,
            endTime: Date?,
            imageURL: Event.ImageURL? = nil,
            siteMapImageURL: SiteMapImageURL? = nil,
            location: Location? = nil,
            contactNumbers: [ContactNumber]
        ) {
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

    public enum EventImageURLTag {}
    public typealias ImageURL = Tagged<EventImageURLTag, URL>

    public enum SiteMapURLTag {}
    public typealias SiteMapImageURL = Tagged<SiteMapURLTag, URL>

    public init(
        name: String,
        timeZone: TimeZone,
        startTime: Date?,
        endTime: Date?,
        imageURL: ImageURL? = nil,
        siteMapImageURL: SiteMapImageURL? = nil,
        location: Location? = nil,
        contactNumbers: [ContactNumber] = [],
        artists: [Artist],
        stages: Stages,
        schedule: [StringlyTyped.Schedule],
        colorScheme: ColorScheme? = nil
    ) {
        self.info = Info(
            name: name,
            timeZone: timeZone,
            startTime: startTime,
            endTime: endTime,
            imageURL: imageURL,
            siteMapImageURL: siteMapImageURL,
            location: location,
            contactNumbers: contactNumbers
        )
        self.artists = artists
        self.stages = stages
        self.schedule = schedule
        self.colorScheme = colorScheme
    }
}

public extension Event {
    struct ContactNumber: Identifiable, Equatable, Codable, Hashable, Sendable {
        public var id: Tagged<Self, OpenFestivalIDType>
        public var phoneNumber: String
        public var title: String
        public var description: String?

        public init(
            id: Self.ID,
            title: String,
            phoneNumber: String,
            description: String?
        ) {
            self.id = id
            self.title = title
            self.phoneNumber = phoneNumber
            self.description = description
        }
    }
}

public extension Event {
    typealias Stages = [StageDTO]
    typealias Stage = StageDTO
}

public extension Event {
    struct Location: Equatable, Hashable, Sendable {
        public var address: String?
        public var directions: String?
        public var city: String?
        public var country: String?
        public var postalCode: String?
        public var latitude: Double?
        public var longitude: Double?

        public init(address: String? = nil, directions: String? = nil, city: String? = nil, country: String? = nil, postalCode: String? = nil, latitude: Double? = nil, longitude: Double? = nil) {
            self.address = address
            self.directions = directions
            self.city = city
            self.country = country
            self.postalCode = postalCode
            self.latitude = latitude
            self.longitude = longitude
        }
    }
}



#if canImport(SwiftUI)
import SwiftUI
#endif

public extension Event {

    struct Artist: Equatable, Hashable, Sendable {
        public var name: String
        public var bio: String?
        public var imageURL: URL?
        public var links: [Link]

        public init(
            name: String,
            bio: String? = nil,
            imageURL: URL? = nil,
            links: [Link]
        ) {
            self.name = name
            self.bio = bio
            self.imageURL = imageURL
            self.links = links
        }

        public struct Link: Equatable, Hashable, Sendable {
            public var url: URL
            public var label: String? = nil

            public init(url: URL, label: String? = nil) {
                self.url = url
                self.label = label
            }
        }
    }

    struct ColorScheme: Equatable, Sendable {
#if canImport(SwiftUI)
        public typealias Color = SwiftUI.Color
#else
        public typealias Color = String
#endif

        public var mainColor: Color
        public var workshopsColor: Color
        public var stageColors: StageColorStore
        public var otherColors: [Color]

        public init(
            mainColor: Color,
            workshopsColor: Color,
            stageColors: StageColorStore,
            otherColors: [Color]
        ) {
            self.mainColor = mainColor
            self.workshopsColor = workshopsColor
            self.stageColors = stageColors
            self.otherColors = otherColors
        }

        public typealias StageColorStore = [String: Color]
    }
}

extension UUID: @retroactive ExpressibleByIntegerLiteral {
    public init(integerLiteral value: IntegerLiteralType) {
        self.init(value)
    }
}
public extension Tagged where RawValue == URL {
    init?(string: String) {
        if let url = URL(string: string) {
            self.init(url)
        } else {
            return nil
        }
    }
}


public extension Event {
    static var empty: Self {
        .init(
            name: "",
            timeZone: .current,
            startTime: .now,
            endTime: .now,
            artists: [],
            stages: [],
            schedule: [],
            colorScheme: nil
        )
    }

    static var testival: Self {
        .init(
            name: "Testival",
            timeZone: .current,
            startTime: nil,
            endTime: nil,
            siteMapImageURL: .init(string: "https://firebasestorage.googleapis.com/v0/b/festivl.appspot.com/o/userContent%2FSite%20Map.webp?alt=media&token=48272d3c-ace0-4d5b-96a9-a5142f1c744a"),
            location: Location(address: "1234 Pine Ave, Somewhere in the forest"),
            artists: [
                Artist(
                    name: "Cantos",
                    bio: "**Cantos** is an electronic music producer and DJ who fuses a sense of otherworldly mysticism with cutting-edge sonic craft. Exploring everything from deep and funky house to techno, drum & bass, and garage, Cantos delivers powerful, underground sets rooted in soundsystem culture. High production quality and immersive, dancefloor-focused energy define each performance, creating unforgettable experiences that meld the ancient and the futuristic into a single, pulsing groove.",
                    imageURL: URL(string: "https://firebasestorage.googleapis.com/v0/b/festivl.appspot.com/o/userContent%2FIMG_9907_Original.png?alt=media&token=3c2c0140-a28a-40bc-9f50-f77954b2294d"),
                    links: [
                        Event.Artist.Link(url: URL(string: "https://soundcloud.com/cantos_music")!),
                        Event.Artist.Link(url: URL(string: "https://www.instagram.com/cantos/")!)
                    ]
                ),
                Artist(
                    name: "Boids",
                    bio: "**Boids** is an experimental electronic music project blending elements of technology, nature, math, and art. Drawing inspiration from the complex patterns of flocking behavior, boids creates immersive soundscapes that evolve through algorithmic structures and organic, flowing rhythms. With a foundation in house music, the project explores new auditory dimensions while maintaining a connection to the dance floor, inviting listeners to explore both the natural world and the mathematical systems that underpin it.",
                    imageURL: URL(string: "https://firebasestorage.googleapis.com/v0/b/festivl.appspot.com/o/userContent%2FSubsonic.webp?alt=media&token=8b732938-f9c7-4216-8fb5-3ff4acad9384"),
                    links: []
                ),
                Artist(
                    name: "Phantom Groove",
                    bio: nil,
                    imageURL: nil,
                    links: []
                ),
                Artist(
                    name: "Sunspear",
                    bio: nil,
                    imageURL: URL(string: "https://firebasestorage.googleapis.com/v0/b/festivl.appspot.com/o/userContent%2FSunspear-image.webp?alt=media&token=be30f499-8356-41a9-9425-7e19e36e2ea9")!,
                    links: []
                ),
                Artist(
                    name: "Rhythmbox",
                    bio: nil,
                    imageURL: nil,
                    links: []
                ),
                Artist(
                    name: "Prism Sound",
                    bio: nil,
                    imageURL: nil,
                    links: []
                ),
                Artist(
                    name: "Oaktrail",
                    bio: nil,
                    imageURL: URL(string: "https://firebasestorage.googleapis.com/v0/b/festivl.appspot.com/o/userContent%2FOaktrail.webp?alt=media&token=db962b24-e144-476c-ac4c-71ffa7f7f32d"),
                    links: []
                ),
                Artist(
                    name: "Space Chunk",
                    bio: nil,
                    imageURL: URL(string: "https://i1.sndcdn.com/avatars-oI73KB5SpEOGCmFq-5ezWjw-t500x500.jpg")!,
                    links: [
                        .init(url: URL(string: "https://soundcloud.com/spacechunk")!, label: nil)
                    ]
                ),
                Artist(
                    name: "The Sleepies",
                    bio: nil,
                    imageURL: nil,
                    links: []
                ),
                Artist(
                    name: "Sylvan Beats",
                    bio: nil,
                    imageURL: nil,
                    links: []
                ),
                Artist(
                    name: "Overgrowth",
                    bio: nil,
                    imageURL: URL(string: "https://firebasestorage.googleapis.com/v0/b/festivl.appspot.com/o/userContent%2FOvergrowth%20DJ%20Profile.webp?alt=media&token=f0856acd-ab9c-47bf-b1d8-d7e385048beb"),
                    links: [
                        .init(url: URL(string: "https://soundcloud.com/overgrowthmusic")!, label: nil)
                    ]
                ),
                Artist(
                    name: "Floods",
                    bio: nil,
                    imageURL: URL(string: "https://firebasestorage.googleapis.com/v0/b/festivl.appspot.com/o/userContent%2FFloods.webp?alt=media&token=2fca7492-7de5-4390-bf9a-d9fe7eb55cd8"),
                    links: []
                ),
                Artist(
                    name: "Float On",
                    bio: nil,
                    imageURL: nil,
                    links: []
                ),
                Artist(
                    name: "Caribou State",
                    bio: nil,
                    imageURL: nil,
                    links: []
                )
            ],
            stages: [
//                Stage(
//                    name: "Fractal Forest",
//                    iconImageURL: URL(string: "https://firebasestorage.googleapis.com:443/v0/b/festivl.appspot.com/o/userContent%2F0545133C-90A6-4A64-99F9-EA563A8E976E.png?alt=media&token=35509f1f-a977-47d2-bd76-2d3898d0e465")
//                ),
//
//                Stage(
//                    name: "Village",
//                    iconImageURL: URL(string: "https://firebasestorage.googleapis.com:443/v0/b/festivl.appspot.com/o/userContent%2F96A24076-86EB-4327-BC13-26B3A8B1B769.png?alt=media&token=cb596866-35e6-4e39-a018-004b7338d7e8")
//                ),
//                Stage(
//                    name: "Grove",
//                    iconImageURL: URL(string: "https://firebasestorage.googleapis.com:443/v0/b/festivl.appspot.com/o/userContent%2F980B90FE-4868-4E65-B0B8-045A54BEFBD2.png?alt=media&token=91037e7e-5702-424d-a4f5-f0c78c5c9fde")
//                )

            ],
            schedule: [
//                Schedule(
//                    date: CalendarDate(year: 2024, month: 6, day: 16),
//                    customTitle: nil,
//                    stageSchedules: [
//                            Performance(
//                                customTitle: nil,
//                                artistIDs: [.known(Artist.ID(9))],
//                                startTime: Date(year: 2024, month: 6, day: 12, hour: 16, minute: 30)!,
//                                endTime: Date(year: 2024, month: 6, day: 12, hour: 18, minute: 30)!,
//                                stageID: Stage.ID(0)
//                            ),
//                            Performance(
//                                id: Performance.ID(1),
//                                customTitle: nil,
//                                artistIDs: [.known(Artist.ID(12))],
//                                startTime: Date(year: 2024, month: 6, day: 12, hour: 18, minute: 30)!,
//                                endTime: Date(year: 2024, month: 6, day: 12, hour: 20)!,
//                                stageID: Stage.ID(0)
//                            ),
//                            Performance(
//                                id: Performance.ID(12),
//                                customTitle: nil,
//                                artistIDs: [.known(Artist.ID(2))],
//                                startTime: Date(year: 2024, month: 6, day: 12, hour: 20)!,
//                                endTime: Date(year: 2024, month: 6, day: 12, hour: 21, minute: 30)!,
//                                stageID: Stage.ID(0)
//                            ),
//                            // Additional performances for other artists
//                            Performance(
//                                id: Performance.ID(14),
//                                customTitle: nil,
//                                artistIDs: [.known(Artist.ID(0))],
//                                startTime: Date(year: 2024, month: 6, day: 12, hour: 21, minute: 30)!,
//                                endTime: Date(year: 2024, month: 6, day: 12, hour: 23)!,
//                                stageID: Stage.ID(0)
//                            )
//                        ],
//                        Stage.ID(1): [
//                            Performance(
//                                id: Performance.ID(4),
//                                customTitle: nil,
//                                artistIDs: [.known(Artist.ID(0))],
//                                startTime: Date(year: 2024, month: 6, day: 12, hour: 20)!,
//                                endTime: Date(year: 2024, month: 6, day: 12, hour: 22)!,
//                                stageID: Stage.ID(1)
//                            ),
//                            Performance(
//                                id: Performance.ID(5),
//                                customTitle: nil,
//                                artistIDs: [.known(Artist.ID(4))],
//                                startTime: Date(year: 2024, month: 6, day: 12, hour: 22)!,
//                                endTime: Date(year: 2024, month: 6, day: 12, hour: 23, minute: 30)!,
//                                stageID: Stage.ID(1)
//                            ),
//                            Performance(
//                                id: Performance.ID(6),
//                                customTitle: nil,
//                                artistIDs: [.known(Artist.ID(5))],
//                                startTime: Date(year: 2024, month: 6, day: 12, hour: 23, minute: 30)!,
//                                endTime: Date(year: 2024, month: 6, day: 13, hour: 1)!,
//                                stageID: Stage.ID(1)
//                            )
//                        ],
//                        Stage.ID(2): [
//                            // Performances for artists on Village stage
//                            Performance(
//                                id: Performance.ID(7),
//                                customTitle: nil,
//                                artistIDs: [.known(Artist.ID(6))],
//                                startTime: Date(year: 2024, month: 6, day: 12, hour: 17)!,
//                                endTime: Date(year: 2024, month: 6, day: 12, hour: 18, minute: 30)!,
//                                stageID: Stage.ID(2)
//                            ),
//                            Performance(
//                                id: Performance.ID(8),
//                                customTitle: nil,
//                                artistIDs: [.known(Artist.ID(7))],
//                                startTime: Date(year: 2024, month: 6, day: 12, hour: 18, minute: 30)!,
//                                endTime: Date(year: 2024, month: 6, day: 12, hour: 20)!,
//                                stageID: Stage.ID(2)
//                            ),
//                            Performance(
//                                id: Performance.ID(9),
//                                customTitle: nil,
//                                artistIDs: [.known(Artist.ID(8))],
//                                startTime: Date(year: 2024, month: 6, day: 12, hour: 20)!,
//                                endTime: Date(year: 2024, month: 6, day: 12, hour: 21, minute: 30)!,
//                                stageID: Stage.ID(2)
//                            ),
//                            Performance(
//                                id: Performance.ID(10),
//                                customTitle: nil,
//                                artistIDs: [.known(Artist.ID(9))],
//                                startTime: Date(year: 2024, month: 6, day: 12, hour: 21, minute: 30)!,
//                                endTime: Date(year: 2024, month: 6, day: 12, hour: 23)!,
//                                stageID: Stage.ID(2)
//                            ),
//                            Performance(
//                                id: Performance.ID(11),
//                                customTitle: nil,
//                                artistIDs: [.known(Artist.ID(12))],
//                                startTime: Date(year: 2024, month: 6, day: 12, hour: 23)!,
//                                endTime: Date(year: 2024, month: 6, day: 13, hour: 0, minute: 30)!,
//                                stageID: Stage.ID(2)
//                            ),
//                            Performance(
//                                id: Performance.ID(12),
//                                customTitle: nil,
//                                artistIDs: [.known(Artist.ID(11)), .known(Artist.ID(10))],
//                                startTime: Date(year: 2024, month: 6, day: 13, hour: 0, minute: 30)!,
//                                endTime: Date(year: 2024, month: 6, day: 13, hour: 2)!,
//                                stageID: Stage.ID(2)
//                            )
//                        ]
//                    ]
//                )
            ]
            ,
            colorScheme: .init(
                mainColor: .accentColor,
                workshopsColor: .accentColor,
                stageColors: .init(),
                otherColors: [
                    .blue,
                    .cyan,
                    .green,
                    .yellow,
                    .orange,
                    .red
                ]
            )
        )
    }
}

import Foundation

extension Date {
    init?(
        year: Int,
        month: Int,
        day: Int,
        hour: Int = 0,
        minute: Int = 0,
        second: Int = 0,
        calendar: Calendar = .current
    ){
        var dateComponents = DateComponents()
        dateComponents.year = year
        dateComponents.month = month
        dateComponents.day = day
        dateComponents.hour = hour
        dateComponents.minute = minute
        dateComponents.second = second

        if let date = calendar.date(from: dateComponents) {
            self = date
            return
        }

        return nil
    }
}





extension Optional where Wrapped: RangeReplaceableCollection {
    mutating func appendOrCreate(value: Wrapped.Element) {
        if self != nil {
            self?.append(value)
        } else {
            self = Wrapped([value])
        }
    }
}



extension Sequence {
    func sorted<PrimaryKey: Comparable, SecondaryKey: Comparable>(
        by primaryKeyPath: KeyPath<Element, PrimaryKey?>,
        then secondaryKeyPath: KeyPath<Element, SecondaryKey>
    ) -> [Element] {
        return sorted { lhs, rhs in
            if let lhsPrimary = lhs[keyPath: primaryKeyPath], let rhsPrimary = rhs[keyPath: primaryKeyPath] {
                if lhsPrimary != rhsPrimary {
                    return lhsPrimary < rhsPrimary
                }
            } else if lhs[keyPath: primaryKeyPath] != nil {
                return true
            } else if rhs[keyPath: primaryKeyPath] != nil {
                return false
            }
            return lhs[keyPath: secondaryKeyPath] < rhs[keyPath: secondaryKeyPath]
        }
    }
}

