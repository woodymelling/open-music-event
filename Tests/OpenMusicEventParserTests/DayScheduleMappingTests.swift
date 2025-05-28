//
//  File.swift
//  
//
//  Created by Woodrow Melling on 6/12/24.
//

import Foundation
import Testing

@testable import OpenMusicEventParser
import Dependencies
import FileTree
import DependenciesTestSupport
import CustomDump
import SnapshotTestingCustomDump
import InlineSnapshotTesting

fileprivate let day = CalendarDate(year: 2024, month: 6, day: 12)

@Suite(.dependency(\.calendar, .current))
struct DayScheduleConversionTests {

    @Test
    func multiStage() async throws {
        let dto = FileContent(fileName: "2024-06-12", fileType: "yaml", data: DTOs.Event.DaySchedule(
            customTitle: nil,
            date: CalendarDate(year: 2024, month: 6, day: 12),
            performances: [
                "Bass Haven": [
                    PerformanceDTO(
                        artist: "Sunspear",
                        time: "4:30 PM"
                    ),
                    PerformanceDTO(
                        artist: "Phantom Groove",
                        time: "6:30 PM"
                    ),
                    PerformanceDTO(
                        artist: "Caribou State",
                        time: "8:00 PM",
                        endTime: "9:30 PM"
                    )
                ],
                "Main Stage": [
                    PerformanceDTO(
                        artist: "Oaktrail",
                        time: "8:00 PM"
                    ),
                    PerformanceDTO(
                        artist: "Rhythmbox",
                        time: "10:00 PM",
                        endTime: "11:30 PM"
                    )
                ]
            ]
        ))

        try assertInlineSnapshot(of: ScheduleDayConversion().apply(dto), as: .customDump) {
            """
            StringlyTyped.Schedule(
              metadata: StringlyTyped.Metadata(
                date: 6/12/2024,
                customTitle: nil
              ),
              stageSchedules: [
                "Bass Haven": [
                  [0]: StringlyTyped.Schedule.Performance(
                    title: "Sunspear",
                    subtitle: nil,
                    artistNames: Set([
                      "Sunspear"
                    ]),
                    startTime: Date(2024-06-12T23:30:00.000Z),
                    endTime: Date(2024-06-13T01:30:00.000Z),
                    stageName: "Bass Haven"
                  ),
                  [1]: StringlyTyped.Schedule.Performance(
                    title: "Phantom Groove",
                    subtitle: nil,
                    artistNames: Set([
                      "Phantom Groove"
                    ]),
                    startTime: Date(2024-06-13T01:30:00.000Z),
                    endTime: Date(2024-06-13T03:00:00.000Z),
                    stageName: "Bass Haven"
                  ),
                  [2]: StringlyTyped.Schedule.Performance(
                    title: "Caribou State",
                    subtitle: nil,
                    artistNames: Set([
                      "Caribou State"
                    ]),
                    startTime: Date(2024-06-13T03:00:00.000Z),
                    endTime: Date(2024-06-13T04:30:00.000Z),
                    stageName: "Bass Haven"
                  )
                ],
                "Main Stage": [
                  [0]: StringlyTyped.Schedule.Performance(
                    title: "Oaktrail",
                    subtitle: nil,
                    artistNames: Set([
                      "Oaktrail"
                    ]),
                    startTime: Date(2024-06-13T03:00:00.000Z),
                    endTime: Date(2024-06-13T05:00:00.000Z),
                    stageName: "Main Stage"
                  ),
                  [1]: StringlyTyped.Schedule.Performance(
                    title: "Rhythmbox",
                    subtitle: nil,
                    artistNames: Set([
                      "Rhythmbox"
                    ]),
                    startTime: Date(2024-06-13T05:00:00.000Z),
                    endTime: Date(2024-06-13T06:30:00.000Z),
                    stageName: "Main Stage"
                  )
                ]
              ]
            )
            """
        }

    }

    @Test
    func testSingleStage() async throws {
        let dto = FileContent(fileName: "2024-06-12", fileType: "yaml", data: DTOs.Event.DaySchedule(
            customTitle: nil,
            date: day,
            performances: [
                "Bass Haven": [
                    PerformanceDTO(
                        artist: "Sunspear",
                        time: "6:30 PM"
                    ),
                    PerformanceDTO(
                        artist: "Phantom Groove",
                        time: "10:30 PM"
                    ),
                    PerformanceDTO(
                        artist: "Oaktrail",
                        time: "12:30 AM"
                    ),
                    PerformanceDTO(
                        artist: "Rhythmbox",
                        time: "4:00 AM",
                        endTime: "7:30 AM"
                    )
                ]
            ]
        ))

        try assertInlineSnapshot(of: ScheduleDayConversion().apply(dto), as: .customDump) {
            """
            StringlyTyped.Schedule(
              metadata: StringlyTyped.Metadata(
                date: 6/12/2024,
                customTitle: nil
              ),
              stageSchedules: [
                "Bass Haven": [
                  [0]: StringlyTyped.Schedule.Performance(
                    title: "Sunspear",
                    subtitle: nil,
                    artistNames: Set([
                      "Sunspear"
                    ]),
                    startTime: Date(2024-06-13T01:30:00.000Z),
                    endTime: Date(2024-06-13T05:30:00.000Z),
                    stageName: "Bass Haven"
                  ),
                  [1]: StringlyTyped.Schedule.Performance(
                    title: "Phantom Groove",
                    subtitle: nil,
                    artistNames: Set([
                      "Phantom Groove"
                    ]),
                    startTime: Date(2024-06-13T05:30:00.000Z),
                    endTime: Date(2024-06-13T07:30:00.000Z),
                    stageName: "Bass Haven"
                  ),
                  [2]: StringlyTyped.Schedule.Performance(
                    title: "Oaktrail",
                    subtitle: nil,
                    artistNames: Set([
                      "Oaktrail"
                    ]),
                    startTime: Date(2024-06-13T07:30:00.000Z),
                    endTime: Date(2024-06-13T11:00:00.000Z),
                    stageName: "Bass Haven"
                  ),
                  [3]: StringlyTyped.Schedule.Performance(
                    title: "Rhythmbox",
                    subtitle: nil,
                    artistNames: Set([
                      "Rhythmbox"
                    ]),
                    startTime: Date(2024-06-13T11:00:00.000Z),
                    endTime: Date(2024-06-13T14:30:00.000Z),
                    stageName: "Bass Haven"
                  )
                ]
              ]
            )
            """
        }
    }
}
