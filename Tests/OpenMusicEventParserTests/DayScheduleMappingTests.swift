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
import OMECoreModels

fileprivate let day = CalendarDate(year: 2024, month: 6, day: 12)

@Suite(.dependency(\.calendar, .current))
struct DayScheduleConversionTests {

    @Test
    func multiStage() async throws {
        let dto = FileContent(fileName: "2024-06-12", fileType: "yaml", data: OMECoreModels.Schedule.YamlRepresentation(
            customTitle: nil,
            date: CalendarDate(year: 2024, month: 6, day: 12),
            performances: [
                "Bass Haven": [
                    Performance.YamlRepresentation(
                        artist: "Sunspear",
                        time: "4:30 PM"
                    ),
                    Performance.YamlRepresentation(
                        artist: "Phantom Groove",
                        time: "6:30 PM"
                    ),
                    Performance.YamlRepresentation(
                        artist: "Caribou State",
                        time: "8:00 PM",
                        endTime: "9:30 PM"
                    )
                ],
                "Main Stage": [
                    Performance.YamlRepresentation(
                        artist: "Oaktrail",
                        time: "8:00 PM"
                    ),
                    Performance.YamlRepresentation(
                        artist: "Rhythmbox",
                        time: "10:00 PM",
                        endTime: "11:30 PM"
                    )
                ]
            ]
        ))

        try assertInlineSnapshot(of: ScheduleConversion().apply(dto), as: .customDump) {
            """
            (extension in OpenMusicEventParser):Schedule.StringlyTyped(
              metadata: (extension in OpenMusicEventParser):Schedule.Metadata(
                date: 6/12/2024,
                customTitle: nil
              ),
              stageSchedules: [
                "Bass Haven": [
                  [0]: (extension in OpenMusicEventParser):Schedule.StringlyTyped.Performance(
                    title: "Sunspear",
                    subtitle: nil,
                    artistNames: Set([
                      "Sunspear"
                    ]),
                    startTime: Date(2024-06-12T23:30:00.000Z),
                    endTime: Date(2024-06-13T01:30:00.000Z),
                    stageName: "Bass Haven"
                  ),
                  [1]: (extension in OpenMusicEventParser):Schedule.StringlyTyped.Performance(
                    title: "Phantom Groove",
                    subtitle: nil,
                    artistNames: Set([
                      "Phantom Groove"
                    ]),
                    startTime: Date(2024-06-13T01:30:00.000Z),
                    endTime: Date(2024-06-13T03:00:00.000Z),
                    stageName: "Bass Haven"
                  ),
                  [2]: (extension in OpenMusicEventParser):Schedule.StringlyTyped.Performance(
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
                  [0]: (extension in OpenMusicEventParser):Schedule.StringlyTyped.Performance(
                    title: "Oaktrail",
                    subtitle: nil,
                    artistNames: Set([
                      "Oaktrail"
                    ]),
                    startTime: Date(2024-06-13T03:00:00.000Z),
                    endTime: Date(2024-06-13T05:00:00.000Z),
                    stageName: "Main Stage"
                  ),
                  [1]: (extension in OpenMusicEventParser):Schedule.StringlyTyped.Performance(
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
        let dto = FileContent(fileName: "2024-06-12", fileType: "yaml", data: OMECoreModels.Schedule.YamlRepresentation(
            customTitle: nil,
            date: day,
            performances: [
                "Bass Haven": [
                    Performance.YamlRepresentation(
                        artist: "Sunspear",
                        time: "6:30 PM"
                    ),
                    Performance.YamlRepresentation(
                        artist: "Phantom Groove",
                        time: "10:30 PM"
                    ),
                    Performance.YamlRepresentation(
                        artist: "Oaktrail",
                        time: "12:30 AM"
                    ),
                    Performance.YamlRepresentation(
                        artist: "Rhythmbox",
                        time: "4:00 AM",
                        endTime: "7:30 AM"
                    )
                ]
            ]
        ))

        try assertInlineSnapshot(of: ScheduleConversion().apply(dto), as: .customDump) {
            """
            (extension in OpenMusicEventParser):Schedule.StringlyTyped(
              metadata: (extension in OpenMusicEventParser):Schedule.Metadata(
                date: 6/12/2024,
                customTitle: nil
              ),
              stageSchedules: [
                "Bass Haven": [
                  [0]: (extension in OpenMusicEventParser):Schedule.StringlyTyped.Performance(
                    title: "Sunspear",
                    subtitle: nil,
                    artistNames: Set([
                      "Sunspear"
                    ]),
                    startTime: Date(2024-06-13T01:30:00.000Z),
                    endTime: Date(2024-06-13T05:30:00.000Z),
                    stageName: "Bass Haven"
                  ),
                  [1]: (extension in OpenMusicEventParser):Schedule.StringlyTyped.Performance(
                    title: "Phantom Groove",
                    subtitle: nil,
                    artistNames: Set([
                      "Phantom Groove"
                    ]),
                    startTime: Date(2024-06-13T05:30:00.000Z),
                    endTime: Date(2024-06-13T07:30:00.000Z),
                    stageName: "Bass Haven"
                  ),
                  [2]: (extension in OpenMusicEventParser):Schedule.StringlyTyped.Performance(
                    title: "Oaktrail",
                    subtitle: nil,
                    artistNames: Set([
                      "Oaktrail"
                    ]),
                    startTime: Date(2024-06-13T07:30:00.000Z),
                    endTime: Date(2024-06-13T11:00:00.000Z),
                    stageName: "Bass Haven"
                  ),
                  [3]: (extension in OpenMusicEventParser):Schedule.StringlyTyped.Performance(
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
