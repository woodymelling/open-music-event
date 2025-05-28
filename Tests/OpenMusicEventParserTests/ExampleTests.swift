import Testing
@testable import OpenMusicEventParser

import Dependencies
import CustomDump
import Foundation
import InlineSnapshotTesting

extension URL {
    static let resourcesFolder = Bundle.module.resourceURL
//        .appending(component: "Contents/Resources/ExampleFestivals")
}

struct EventDecodingTests {

    @Test()
    func testival() async throws {
        let url = Bundle.module.resourceURL!
            .appending(component: "ExampleFestivals")
            .appending(component: "Testival")
            .appendingPathComponent("2024")

        try withDependencies {
            $0.calendar = .current
            $0.timeZone = .current
            $0.date = .constant(.now)
        } operation: {

            let event = try OpenFestivalDecoder().decode(from: url)
            assertInlineSnapshot(of: event, as: .customDump) {
                #"""
                Event(
                  info: Event.Info(
                    name: "",
                    timeZone: TimeZone(
                      identifier: "America/Denver",
                      abbreviation: "MDT",
                      secondsFromGMT: -21600,
                      isDaylightSavingTime: true
                    ),
                    startTime: nil,
                    endTime: nil,
                    imageURL: Tagged(rawValue: URL(https://www.example.com/main-image)),
                    siteMapImageURL: Tagged(rawValue: URL(https://www.example.com/amap)),
                    location: Event.Location(
                      address: "1234, somewhere in a forest",
                      directions: nil,
                      city: nil,
                      country: nil,
                      postalCode: nil,
                      latitude: nil,
                      longitude: nil
                    ),
                    contactNumbers: []
                  ),
                  artists: [
                    [0]: Event.Artist(
                      name: "Boid",
                      bio: """
                      
                      **boid** is an experimental electronic music project blending elements of technology, nature, math, and art. Drawing inspiration from the complex patterns of flocking behavior, boids creates immersive soundscapes that evolve through algorithmic structures and organic, flowing rhythms. With a foundation in house music, the project explores new auditory dimensions while maintaining a connection to the dance floor, inviting listeners to explore both the natural world and the mathematical systems that underpin it.
                      
                      """,
                      imageURL: URL(http://boid.com/artist-image.png),
                      links: [
                        [0]: Event.Artist.Link(
                          url: URL(http://soundcloud.com/boid%22),
                          label: nil
                        ),
                        [1]: Event.Artist.Link(
                          url: URL(http://instagram.com/boid),
                          label: nil
                        )
                      ]
                    ),
                    [1]: Event.Artist(
                      name: "Subsonic",
                      bio: """
                      
                      Subsonic delivers powerful bass-driven music that shakes the ground and moves the crowd, known for their high-energy performances and deep, resonant beats.
                      
                      """,
                      imageURL: URL(http://example.com/subsonic.jpg),
                      links: [
                        [0]: Event.Artist.Link(
                          url: URL(http://soundcloud.com/subsonic),
                          label: nil
                        ),
                        [1]: Event.Artist.Link(
                          url: URL(http://instagram.com/subsonic),
                          label: nil
                        )
                      ]
                    )
                  ],
                  stages: [
                    [0]: StageDTO(
                      name: "Bass Haven",
                      color: 14635679,
                      imageURL: URL(https://firebasestorage.googleapis.com/v0/b/festivl.appspot.com/o/userContent%2Fstage_logo_amp.png?alt=media&token=259c79a0-0df8-4434-931a-e3b9037789a6)
                    ),
                    [1]: StageDTO(
                      name: "Mystic Grove",
                      color: 12237929,
                      imageURL: URL(https://firebasestorage.googleapis.com/v0/b/festivl.appspot.com/o/userContent%2Fstage_logo_fractal.png?alt=media&token=fc4b8549-b689-4b90-88d6-e318d8db6e4a)
                    ),
                    [2]: StageDTO(
                      name: "Tranquil Meadow",
                      color: 7847313,
                      imageURL: URL(https://firebasestorage.googleapis.com/v0/b/festivl.appspot.com/o/userContent%2Fstage_logo_grove.png?alt=media&token=514a6eca-079f-45cf-8ccf-1decba72b35d)
                    )
                  ],
                  schedule: [
                    [0]: StringlyTyped.Schedule(
                      metadata: StringlyTyped.Metadata(
                        date: 5/27/2024,
                        customTitle: nil
                      ),
                      stageSchedules: [
                        "The Portal": [
                          [0]: StringlyTyped.Schedule.Performance(
                            title: "Opening Ceremony",
                            subtitle: nil,
                            artistNames: Set([]),
                            startTime: Date(2024-05-27T23:30:00.000Z),
                            endTime: Date(2024-05-28T00:30:00.000Z),
                            stageName: "The Portal"
                          ),
                          [1]: StringlyTyped.Schedule.Performance(
                            title: "Kerz",
                            subtitle: nil,
                            artistNames: Set([
                              "Kerz"
                            ]),
                            startTime: Date(2024-05-28T00:30:00.000Z),
                            endTime: Date(2024-05-28T01:30:00.000Z),
                            stageName: "The Portal"
                          ),
                          [2]: StringlyTyped.Schedule.Performance(
                            title: "Overgrown Sunset",
                            subtitle: nil,
                            artistNames: Set([
                              "Overgrowth"
                            ]),
                            startTime: Date(2024-05-28T01:30:00.000Z),
                            endTime: Date(2024-05-28T02:15:00.000Z),
                            stageName: "The Portal"
                          ),
                          [3]: StringlyTyped.Schedule.Performance(
                            title: "Duskee",
                            subtitle: nil,
                            artistNames: Set([
                              "Duskee"
                            ]),
                            startTime: Date(2024-05-28T02:30:00.000Z),
                            endTime: Date(2024-05-28T03:30:00.000Z),
                            stageName: "The Portal"
                          ),
                          [4]: StringlyTyped.Schedule.Performance(
                            title: "Ghillie, Skbr",
                            subtitle: nil,
                            artistNames: Set([
                              "Ghillie",
                              "Skbr"
                            ]),
                            startTime: Date(2024-05-28T03:30:00.000Z),
                            endTime: Date(2024-05-28T04:30:00.000Z),
                            stageName: "The Portal"
                          ),
                          [5]: StringlyTyped.Schedule.Performance(
                            title: "Sub Chakra Takeover",
                            subtitle: nil,
                            artistNames: Set([
                              "Secret Headliner",
                              "Metafloor"
                            ]),
                            startTime: Date(2024-05-28T04:30:00.000Z),
                            endTime: Date(2024-05-28T06:30:00.000Z),
                            stageName: "The Portal"
                          )
                        ],
                        "Ursus": [
                          [0]: StringlyTyped.Schedule.Performance(
                            title: "Woofax",
                            subtitle: nil,
                            artistNames: Set([
                              "Woofax"
                            ]),
                            startTime: Date(2024-05-27T22:00:00.000Z),
                            endTime: Date(2024-05-27T23:30:00.000Z),
                            stageName: "Ursus"
                          ),
                          [1]: StringlyTyped.Schedule.Performance(
                            title: "Tube Screamer",
                            subtitle: nil,
                            artistNames: Set([
                              "Tube Screamer"
                            ]),
                            startTime: Date(2024-05-27T23:30:00.000Z),
                            endTime: Date(2024-05-28T00:30:00.000Z),
                            stageName: "Ursus"
                          ),
                          [2]: StringlyTyped.Schedule.Performance(
                            title: "Skreid",
                            subtitle: nil,
                            artistNames: Set([
                              "Skreid"
                            ]),
                            startTime: Date(2024-05-28T00:30:00.000Z),
                            endTime: Date(2024-05-28T01:30:00.000Z),
                            stageName: "Ursus"
                          ),
                          [3]: StringlyTyped.Schedule.Performance(
                            title: "Rabbit Hole Records Crew",
                            subtitle: nil,
                            artistNames: Set([
                              "The Mad Hatter",
                              "Alice in Chainz",
                              "Queen of your Heart"
                            ]),
                            startTime: Date(2024-05-28T01:30:00.000Z),
                            endTime: Date(2024-05-28T03:00:00.000Z),
                            stageName: "Ursus"
                          ),
                          [4]: StringlyTyped.Schedule.Performance(
                            title: "Dragon Fli Empire",
                            subtitle: nil,
                            artistNames: Set([
                              "Dragon Fli Empire"
                            ]),
                            startTime: Date(2024-05-28T03:00:00.000Z),
                            endTime: Date(2024-05-28T04:00:00.000Z),
                            stageName: "Ursus"
                          ),
                          [5]: StringlyTyped.Schedule.Performance(
                            title: "Def3",
                            subtitle: nil,
                            artistNames: Set([
                              "Def3"
                            ]),
                            startTime: Date(2024-05-28T04:00:00.000Z),
                            endTime: Date(2024-05-28T05:00:00.000Z),
                            stageName: "Ursus"
                          )
                        ]
                      ]
                    )
                  ],
                  colorScheme: nil
                )
                """#
            }
        }
    }
}

