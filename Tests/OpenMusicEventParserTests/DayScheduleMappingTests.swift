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

fileprivate let day = CalendarDate(year: 2024, month: 6, day: 12)

@Suite(.dependency(\.calendar, .current))
struct DayScheduleConversionTests {

    @Test
    func multiStage() async throws {
        let dto = FileContent(fileName: "2024-06-12", data: DTOs.Event.DaySchedule(
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
        let schedule = StringlyTyped.Schedule(
            metadata: .init(
                date: day,
                customTitle: nil
            ),
            stageSchedules: [
                "Bass Haven": [
                    StringlyTyped.Schedule.Performance(
                        customTitle: nil,
                        artistNames: ["Sunspear"],
                        startTime: day.atTime(ScheduleTime(hour: 16, minute: 30)!),
                        endTime: day.atTime(ScheduleTime(hour: 18, minute: 30)!),
                        stageName: "Bass Haven"
                    ),
                    StringlyTyped.Schedule.Performance(
                        customTitle: nil,
                        artistNames: ["Phantom Groove"],
                        startTime: day.atTime(ScheduleTime(hour: 18, minute: 30)!),
                        endTime: day.atTime(ScheduleTime(hour: 20)!),
                        stageName: "Bass Haven"
                    ),
                    StringlyTyped.Schedule.Performance(
                        customTitle: nil,
                        artistNames: ["Caribou State"],
                        startTime: day.atTime(ScheduleTime(hour: 20)!),
                        endTime: day.atTime(ScheduleTime(hour: 21, minute: 30)!),
                        stageName: "Bass Haven"
                    )
                ],
                "Main Stage": [
                    StringlyTyped.Schedule.Performance(
                        customTitle: nil,
                        artistNames: ["Oaktrail"],
                        startTime: day.atTime(ScheduleTime(hour: 20)!),
                        endTime: day.atTime(ScheduleTime(hour: 22)!),
                        stageName: "Main Stage"
                    ),
                    StringlyTyped.Schedule.Performance(
                        customTitle: nil,
                        artistNames: ["Rhythmbox"],
                        startTime: day.atTime(ScheduleTime(hour: 22)!),
                        endTime: day.atTime(ScheduleTime(hour: 23, minute: 30)!),
                        stageName: "Main Stage"
                    )
                ]
            ]
        )
        let result = try await ScheduleDayConversion().apply(dto)


        expectNoDifference(result, schedule)

        let roundTrip = try await ScheduleDayConversion().unapply(result)
        expectNoDifference(roundTrip, dto)
    }


    @Test
    func testSingleStage() async throws {
        let dto = FileContent(fileName: "2024-06-12", data: DTOs.Event.DaySchedule(
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
        let schedule = StringlyTyped.Schedule(
            metadata: .init(
                date: CalendarDate(year: 2024, month: 6, day: 12),
                customTitle: nil
            ),
            stageSchedules: [
                "Bass Haven": [
                    StringlyTyped.Schedule.Performance(
                        customTitle: nil,
                        artistNames: ["Sunspear"],
                        startTime: day.atTime(ScheduleTime(hour: 18, minute: 30)!),
                        endTime: day.atTime(ScheduleTime(hour: 22, minute: 30)!),
                        stageName: "Bass Haven"
                    ),
                    StringlyTyped.Schedule.Performance(
                        customTitle: nil,
                        artistNames: ["Phantom Groove"],
                        startTime: day.atTime(ScheduleTime(hour: 22, minute: 30)!),
                        endTime: day.atTime(ScheduleTime(hour: 24, minute: 30)!),
                        stageName: "Bass Haven"
                    ),
                    StringlyTyped.Schedule.Performance(
                        customTitle: nil,
                        artistNames: ["Oaktrail"],
                        startTime: day.atTime(ScheduleTime(hour: 24, minute: 30)!),
                        endTime: day.atTime(ScheduleTime(hour: 28)!),
                        stageName: "Bass Haven"
                    ),
                    StringlyTyped.Schedule.Performance(
                        customTitle: nil,
                        artistNames: ["Rhythmbox"],
                        startTime: day.atTime(ScheduleTime(hour: 28)!),
                        endTime: day.atTime(ScheduleTime(hour: 31, minute: 30)!),
                        stageName: "Bass Haven"
                    )
                ]
            ]
        )

        let result = try await ScheduleDayConversion().apply(dto)


        expectNoDifference(result, schedule)

        let roundTrip = try await ScheduleDayConversion().unapply(result)
        expectNoDifference(roundTrip, dto)
    }
}
