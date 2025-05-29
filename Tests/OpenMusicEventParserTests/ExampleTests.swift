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
                EventConfiguration(
                  info: MusicEvent.Draft(
                    id: nil,
                    organizerURL: nil,
                    name: "",
                    timeZone: TimeZone(
                      identifier: "America/Denver",
                      abbreviation: "MDT",
                      secondsFromGMT: -21600,
                      isDaylightSavingTime: true
                    ),
                    startTime: nil,
                    endTime: nil,
                    imageURL: URL(https://www.example.com/main-image),
                    siteMapImageURL: URL(https://www.example.com/amap),
                    location: MusicEvent.Location(
                      address: "1234, somewhere in a forest",
                      directions: nil,
                      coordinates: nil
                    ),
                    contactNumbers: []
                  ),
                  artists: [
                    [0]: Artist.Draft(
                      id: nil,
                      musicEventID: nil,
                      name: "Boid",
                      bio: """
                      
                      **boid** is an experimental electronic music project blending elements of technology, nature, math, and art. Drawing inspiration from the complex patterns of flocking behavior, boids creates immersive soundscapes that evolve through algorithmic structures and organic, flowing rhythms. With a foundation in house music, the project explores new auditory dimensions while maintaining a connection to the dance floor, inviting listeners to explore both the natural world and the mathematical systems that underpin it.
                      
                      """,
                      imageURL: URL(http://boid.com/artist-image.png),
                      links: [
                        [0]: Artist.Link(
                          url: URL(http://soundcloud.com/boid%22),
                          label: nil
                        ),
                        [1]: Artist.Link(
                          url: URL(http://instagram.com/boid),
                          label: nil
                        )
                      ]
                    ),
                    [1]: Artist.Draft(
                      id: nil,
                      musicEventID: nil,
                      name: "Subsonic",
                      bio: """
                      
                      Subsonic delivers powerful bass-driven music that shakes the ground and moves the crowd, known for their high-energy performances and deep, resonant beats.
                      
                      """,
                      imageURL: URL(http://example.com/subsonic.jpg),
                      links: [
                        [0]: Artist.Link(
                          url: URL(http://soundcloud.com/subsonic),
                          label: nil
                        ),
                        [1]: Artist.Link(
                          url: URL(http://instagram.com/subsonic),
                          label: nil
                        )
                      ]
                    )
                  ],
                  stages: [
                    [0]: Stage.Draft(
                      id: nil,
                      musicEventID: nil,
                      name: "Bass Haven",
                      iconImageURL: nil,
                      color: Color(
                        provider: ColorBox(
                          base: ResolvedColorProvider(
                            color: Color.Resolved(
                              linearRed: 0.73791057,
                              linearGreen: 0.084376216,
                              linearBlue: 0.34670416,
                              opacity: 1.0
                            )
                          )
                        )
                      )
                    ),
                    [1]: Stage.Draft(
                      id: nil,
                      musicEventID: nil,
                      name: "Mystic Grove",
                      iconImageURL: nil,
                      color: Color(
                        provider: #1 ColorBox(
                          base: ResolvedColorProvider(
                            color: Color.Resolved(
                              linearRed: 0.49102098,
                              linearGreen: 0.5028866,
                              linearBlue: 0.14126328,
                              opacity: 1.0
                            )
                          )
                        )
                      )
                    ),
                    [2]: Stage.Draft(
                      id: nil,
                      musicEventID: nil,
                      name: "Tranquil Meadow",
                      iconImageURL: nil,
                      color: Color(
                        provider: #2 ColorBox(
                          base: ResolvedColorProvider(
                            color: Color.Resolved(
                              linearRed: 0.18447499,
                              linearGreen: 0.50888145,
                              linearBlue: 0.2831488,
                              opacity: 1.0
                            )
                          )
                        )
                      )
                    )
                  ],
                  schedule: [
                    [0]: (extension in OpenMusicEventParser):Schedule.StringlyTyped(
                      metadata: (extension in OpenMusicEventParser):Schedule.Metadata(
                        date: 5/27/2024,
                        customTitle: nil
                      ),
                      stageSchedules: [
                        "The Portal": [
                          [0]: (extension in OpenMusicEventParser):Schedule.StringlyTyped.Performance(
                            title: "Opening Ceremony",
                            subtitle: nil,
                            artistNames: Set([]),
                            startTime: Date(2024-05-27T23:30:00.000Z),
                            endTime: Date(2024-05-28T00:30:00.000Z),
                            stageName: "The Portal"
                          ),
                          [1]: (extension in OpenMusicEventParser):Schedule.StringlyTyped.Performance(
                            title: "Kerz",
                            subtitle: nil,
                            artistNames: Set([
                              "Kerz"
                            ]),
                            startTime: Date(2024-05-28T00:30:00.000Z),
                            endTime: Date(2024-05-28T01:30:00.000Z),
                            stageName: "The Portal"
                          ),
                          [2]: (extension in OpenMusicEventParser):Schedule.StringlyTyped.Performance(
                            title: "Overgrown Sunset",
                            subtitle: nil,
                            artistNames: Set([
                              "Overgrowth"
                            ]),
                            startTime: Date(2024-05-28T01:30:00.000Z),
                            endTime: Date(2024-05-28T02:15:00.000Z),
                            stageName: "The Portal"
                          ),
                          [3]: (extension in OpenMusicEventParser):Schedule.StringlyTyped.Performance(
                            title: "Duskee",
                            subtitle: nil,
                            artistNames: Set([
                              "Duskee"
                            ]),
                            startTime: Date(2024-05-28T02:30:00.000Z),
                            endTime: Date(2024-05-28T03:30:00.000Z),
                            stageName: "The Portal"
                          ),
                          [4]: (extension in OpenMusicEventParser):Schedule.StringlyTyped.Performance(
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
                          [5]: (extension in OpenMusicEventParser):Schedule.StringlyTyped.Performance(
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
                          [0]: (extension in OpenMusicEventParser):Schedule.StringlyTyped.Performance(
                            title: "Woofax",
                            subtitle: nil,
                            artistNames: Set([
                              "Woofax"
                            ]),
                            startTime: Date(2024-05-27T22:00:00.000Z),
                            endTime: Date(2024-05-27T23:30:00.000Z),
                            stageName: "Ursus"
                          ),
                          [1]: (extension in OpenMusicEventParser):Schedule.StringlyTyped.Performance(
                            title: "Tube Screamer",
                            subtitle: nil,
                            artistNames: Set([
                              "Tube Screamer"
                            ]),
                            startTime: Date(2024-05-27T23:30:00.000Z),
                            endTime: Date(2024-05-28T00:30:00.000Z),
                            stageName: "Ursus"
                          ),
                          [2]: (extension in OpenMusicEventParser):Schedule.StringlyTyped.Performance(
                            title: "Skreid",
                            subtitle: nil,
                            artistNames: Set([
                              "Skreid"
                            ]),
                            startTime: Date(2024-05-28T00:30:00.000Z),
                            endTime: Date(2024-05-28T01:30:00.000Z),
                            stageName: "Ursus"
                          ),
                          [3]: (extension in OpenMusicEventParser):Schedule.StringlyTyped.Performance(
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
                          [4]: (extension in OpenMusicEventParser):Schedule.StringlyTyped.Performance(
                            title: "Dragon Fli Empire",
                            subtitle: nil,
                            artistNames: Set([
                              "Dragon Fli Empire"
                            ]),
                            startTime: Date(2024-05-28T03:00:00.000Z),
                            endTime: Date(2024-05-28T04:00:00.000Z),
                            stageName: "Ursus"
                          ),
                          [5]: (extension in OpenMusicEventParser):Schedule.StringlyTyped.Performance(
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
                  ]
                )
                """#
            }
        }
    }
}

