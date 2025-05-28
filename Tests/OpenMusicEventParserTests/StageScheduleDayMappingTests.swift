//
//  File.swift
//
//
//  Created by Woodrow Melling on 6/3/24.
//
import XCTest
import Foundation
@testable import OpenMusicEventParser
import Testing
import Parsing
import CustomDump
import InlineSnapshotTesting

typealias ScheduleError = Validation.ScheduleError.StageDayScheduleError

struct StageScheduleDayMappingTests {
    let conversion = ScheduleDayConversion.ScheduleDictionaryConversion.StagelessPerformanceConversion()

    // MARK: - Success Cases
    @Test("Simple schedule before midnight converts successfully")
    func simpleBeforeMidnight() throws {
        let dtos = [
            PerformanceDTO(
                artist: "Sunspear",
                time: "4:30 PM"
            ),
            PerformanceDTO(
                artist: "Phantom Groove",
                time: "6:30 PM"
            ),
            PerformanceDTO(
                artist: "Oaktrail",
                time: "8:00 PM"
            ),
            PerformanceDTO(
                artist: "Rhythmbox",
                time: "10 PM",
                endTime: "11:30 PM"
            )
        ]

        let result = try conversion.apply(dtos)
        assertInlineSnapshot(of: result, as: .customDump) {
            """
            [
              [0]: StagelessPerformance(
                customTitle: nil,
                artistNames: Set([
                  "Sunspear"
                ]),
                startTime: ScheduleTime(
                  hour: 16,
                  minute: 30
                ),
                endTime: ScheduleTime(
                  hour: 18,
                  minute: 30
                )
              ),
              [1]: StagelessPerformance(
                customTitle: nil,
                artistNames: Set([
                  "Phantom Groove"
                ]),
                startTime: ScheduleTime(
                  hour: 18,
                  minute: 30
                ),
                endTime: ScheduleTime(
                  hour: 20,
                  minute: 0
                )
              ),
              [2]: StagelessPerformance(
                customTitle: nil,
                artistNames: Set([
                  "Oaktrail"
                ]),
                startTime: ScheduleTime(
                  hour: 20,
                  minute: 0
                ),
                endTime: ScheduleTime(
                  hour: 22,
                  minute: 0
                )
              ),
              [3]: StagelessPerformance(
                customTitle: nil,
                artistNames: Set([
                  "Rhythmbox"
                ]),
                startTime: ScheduleTime(
                  hour: 22,
                  minute: 0
                ),
                endTime: ScheduleTime(
                  hour: 23,
                  minute: 30
                )
              )
            ]
            """
        }
    }

    @Test("Schedule through midnight converts successfully")
    func throughMidnight() throws {
        let dtos = [
            PerformanceDTO(
                artist: "Sunspear",
                time: "10:30 PM"
            ),
            PerformanceDTO(
                artist: "Phantom Groove",
                time: "12:30 AM"
            ),
            PerformanceDTO(
                artist: "Oaktrail",
                time: "2:00 AM"
            ),
            PerformanceDTO(
                artist: "Rhythmbox",
                time: "4 AM",
                endTime: "5:30 AM"
            )
        ]

        let result = try conversion.apply(dtos)
        assertInlineSnapshot(of: result, as: .customDump) {
            """
            [
              [0]: StagelessPerformance(
                customTitle: nil,
                artistNames: Set([
                  "Sunspear"
                ]),
                startTime: ScheduleTime(
                  hour: 22,
                  minute: 30
                ),
                endTime: ScheduleTime(
                  hour: 24,
                  minute: 30
                )
              ),
              [1]: StagelessPerformance(
                customTitle: nil,
                artistNames: Set([
                  "Phantom Groove"
                ]),
                startTime: ScheduleTime(
                  hour: 24,
                  minute: 30
                ),
                endTime: ScheduleTime(
                  hour: 26,
                  minute: 0
                )
              ),
              [2]: StagelessPerformance(
                customTitle: nil,
                artistNames: Set([
                  "Oaktrail"
                ]),
                startTime: ScheduleTime(
                  hour: 26,
                  minute: 0
                ),
                endTime: ScheduleTime(
                  hour: 28,
                  minute: 0
                )
              ),
              [3]: StagelessPerformance(
                customTitle: nil,
                artistNames: Set([
                  "Rhythmbox"
                ]),
                startTime: ScheduleTime(
                  hour: 28,
                  minute: 0
                ),
                endTime: ScheduleTime(
                  hour: 29,
                  minute: 30
                )
              )
            ]
            """
        }
    }

    @Test("Back to back performances convert successfully")
    func backToBackPerformances() throws {
        let dtos = [
            PerformanceDTO(
                artist: "Sunspear",
                time: "4:30 PM",
                endTime: "5:30 PM"
            ),
            PerformanceDTO(
                artist: "Phantom Groove",
                time: "5:30 PM",
                endTime: "6:30 PM"
            )
        ]

        let result = try conversion.apply(dtos)

        assertInlineSnapshot(of: result, as: .customDump) {
            """
            [
              [0]: StagelessPerformance(
                customTitle: nil,
                artistNames: Set([
                  "Sunspear"
                ]),
                startTime: ScheduleTime(
                  hour: 16,
                  minute: 30
                ),
                endTime: ScheduleTime(
                  hour: 17,
                  minute: 30
                )
              ),
              [1]: StagelessPerformance(
                customTitle: nil,
                artistNames: Set([
                  "Phantom Groove"
                ]),
                startTime: ScheduleTime(
                  hour: 17,
                  minute: 30
                ),
                endTime: ScheduleTime(
                  hour: 18,
                  minute: 30
                )
              )
            ]
            """
        }
    }

    @Test("Empty schedule converts successfully")
    func emptySchedule() throws {
        let result = try conversion.apply([])
        assertInlineSnapshot(of: result, as: .customDump) {
            """
            []
            """
        }
    }

    // MARK: - Error Cases

    @Test("Overlapping performances throw error")
    func overlappingPerformances() throws {
        let dtos = [
            PerformanceDTO(
                artist: "Rhythmbox",
                time: "4 AM",
                endTime: "5:30 AM"
            ),
            PerformanceDTO(
                artist: "Rhythmbox",
                time: "5:00 AM",
                endTime: "6:30 AM"
            )
        ]

        do {
            _ = try conversion.apply(dtos)
        } catch {
            assertInlineSnapshot(of: error, as: .customDump) {
                """
                Validation.ScheduleError.StageDayScheduleError.overlappingPerformances(
                  StagelessPerformance(
                    customTitle: nil,
                    artistNames: Set([
                      "Rhythmbox"
                    ]),
                    startTime: ScheduleTime(
                      hour: 4,
                      minute: 0
                    ),
                    endTime: ScheduleTime(
                      hour: 5,
                      minute: 30
                    )
                  ),
                  StagelessPerformance(
                    customTitle: nil,
                    artistNames: Set([
                      "Rhythmbox"
                    ]),
                    startTime: ScheduleTime(
                      hour: 5,
                      minute: 0
                    ),
                    endTime: ScheduleTime(
                      hour: 6,
                      minute: 30
                    )
                  )
                )
                """
            }
        }
    }

    @Test("Overlapping performances at midnight throw error")
    func overlappingAtMidnight() throws {
        let dtos = [
            PerformanceDTO(
                artist: "Rhythmbox",
                time: "11:30 PM",
                endTime: "12:30 AM"
            ),
            PerformanceDTO(
                artist: "Rhythmbox",
                time: "11:45 PM",
                endTime: "1:30 AM"
            )
        ]

        let expectedError = ScheduleError.overlappingPerformances(
            StagelessPerformance(
                artistNames: ["Rhythmbox"],
                startTime: ScheduleTime(hour: 23, minute: 30)!,
                endTime: ScheduleTime(hour: 24, minute: 30)!
            ),
            StagelessPerformance(
                artistNames: ["Rhythmbox"],
                startTime: ScheduleTime(hour: 23, minute: 45)!,
                endTime: ScheduleTime(hour: 25, minute: 30)!
            )
        )
        
        do {
            _ = try conversion.apply(dtos)
        } catch {
            assertInlineSnapshot(of: error, as: .customDump) {
                """
                Validation.ScheduleError.StageDayScheduleError.overlappingPerformances(
                  StagelessPerformance(
                    customTitle: nil,
                    artistNames: Set([
                      "Rhythmbox"
                    ]),
                    startTime: ScheduleTime(
                      hour: 23,
                      minute: 30
                    ),
                    endTime: ScheduleTime(
                      hour: 24,
                      minute: 30
                    )
                  ),
                  StagelessPerformance(
                    customTitle: nil,
                    artistNames: Set([
                      "Rhythmbox"
                    ]),
                    startTime: ScheduleTime(
                      hour: 23,
                      minute: 45
                    ),
                    endTime: ScheduleTime(
                      hour: 25,
                      minute: 30
                    )
                  )
                )
                """
            }
        }
    }

    @Test("Missing end time throws error")
    func missingEndTime() throws {
        let dtos = [
            PerformanceDTO(
                artist: "Sunspear",
                time: "4:30 PM"
            ),
            PerformanceDTO(
                artist: "Phantom Groove",
                time: "6:30 PM"
            ),
            PerformanceDTO(
                artist: "Oaktrail",
                time: "8:00 PM"
            )
        ]

        let expectedError = ScheduleError.cannotDetermineEndTimeForPerformance(
            TimelessStagelessPerformance(
                startTime: ScheduleTime(hour: 20)!,
                artistNames: ["Oaktrail"]
            )
        )

        do {
            _ = try conversion.apply(dtos)
        } catch {
            assertInlineSnapshot(of: error, as: .customDump) {
                """
                Validation.ScheduleError.StageDayScheduleError.cannotDetermineEndTimeForPerformance(
                  TimelessStagelessPerformance(
                    startTime: ScheduleTime(
                      hour: 20,
                      minute: 0
                    ),
                    endTime: nil,
                    customTitle: nil,
                    artistNames: Set([
                      "Oaktrail"
                    ])
                  )
                )
                """
            }
        }

    }
}
