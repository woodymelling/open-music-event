//
//  ScheduleDayConversion.swift
//  OpenFestival
//
//  Created by Woodrow Melling on 10/31/24.
//


import FileTree
import Foundation
import Conversions
import IssueReporting

struct ScheduleDayConversion: Conversion {
    typealias Input = FileContent<DTOs.Event.DaySchedule>
    typealias Output = StringlyTyped.Schedule

    var body: some Conversion<Input, Output> {
        FileContentConversion {
            DTOs.Event.DaySchedule.TupleConversion()

            Conversions.Tuple(
                Identity<String?>(),
                Identity<CalendarDate?>(),
                ScheduleDictionaryConversion()
            )
        }

        FileContentToTupleScheduleDayConversion()
    }

    struct ScheduleDictionaryConversion: Conversion {
        typealias Input = [String: [PerformanceDTO]]
        typealias Output = [String: [StagelessPerformance]]

        var body: some Conversion<Input, Output> {
            Conversions.MapKVPairs(
                keyConversion: Identity<String>(),
                valueConversion: StagelessPerformanceConversion()
            )
        }

        struct StagelessPerformanceConversion: Conversion {
            typealias Input = [PerformanceDTO]
            typealias Output = [StagelessPerformance]
            var body: some Conversion<Input, Output> {
                Conversions.MapValues {
                    TimelessStagelessPerformanceConversion()
                }

                DetermineFullSetTimesConversion()
            }
        }
    }

    struct DetermineFullSetTimesConversion: Conversion {
        typealias Input = [TimelessStagelessPerformance]
        typealias Output = [StagelessPerformance]

        func apply(_ partialPerformances: Input) throws(Validation.ScheduleError.StageDayScheduleError) -> Output {
            var schedule: [StagelessPerformance] = []
            var scheduleStartTime: ScheduleTime?

            for (index, performance) in partialPerformances.enumerated() {
                var startTime = performance.startTime
                var endTime: ScheduleTime

                // End times can be manually set
                if let staticEndTime = performance.endTime {
                    endTime = staticEndTime

                    // If they aren't, find the next performance, and make the endtime butt up against it
                } else if let nextPerformance = partialPerformances[safe: index + 1] {
                    endTime = nextPerformance.startTime

                    // If there aren't any performances after this, we can't determine the endtime
                } else {
                    throw .cannotDetermineEndTimeForPerformance(performance)
                }

                if let scheduleStartTime {
                    if startTime < scheduleStartTime {
                        startTime.hour += 24
                    }

                    if endTime < scheduleStartTime {
                        endTime.hour += 24
                    }
                } else {
                    scheduleStartTime = startTime
                    if endTime < startTime {
                        endTime.hour += 24
                    }
                }

                schedule.append(StagelessPerformance(
                    customTitle: performance.customTitle,
                    artistNames: performance.artistNames,
                    startTime: startTime,
                    endTime: endTime
                ))
            }

            for (index, performance) in schedule.enumerated() {
                guard let nextPerformance = schedule[safe: index + 1]
                else { continue }

                guard performance.endTime <= nextPerformance.startTime
                else { throw .overlappingPerformances(performance, nextPerformance) }

                guard performance.startTime < performance.endTime
                else { throw .endTimeBeforeStartTime(performance) }
            }

            return schedule
        }

        func unapply(_ performances: [StagelessPerformance]) throws -> [TimelessStagelessPerformance] {
            var schedule = performances.map {
                TimelessStagelessPerformance(
                    startTime: $0.startTime,
                    endTime: $0.endTime,
                    customTitle: $0.customTitle,
                    artistNames: $0.artistNames
                )
            }

            // remove end times for schedules that butt up against each other.
            for (index, performance) in schedule.enumerated() {
                if let nextPerformance = performances[safe: index + 1],
                   performance.endTime == nextPerformance.startTime {
                    schedule[index].endTime = nil
                }
            }

            return schedule
        }
    }

    struct FileContentToTupleScheduleDayConversion: Conversion {
        typealias Input = FileContent<(String?, CalendarDate?, [String: [StagelessPerformance]])>
        typealias Output = StringlyTyped.Schedule

        func apply(_ input: Input) throws -> Output {

            let customTitle = input.data.0
            let dateFromYaml = input.data.1
            let dateFromFileName = CalendarDate(input.fileName)

            let scheduleDate: CalendarDate
            if let dateFromYaml, let dateFromFileName, dateFromYaml != dateFromFileName {
                reportIssue("Date from filename (\(dateFromFileName)) does not match date from YAML (\(dateFromYaml)), using date from filename: \(dateFromFileName)")
                scheduleDate = dateFromFileName
            } else {
                scheduleDate = (dateFromFileName ?? dateFromYaml ?? .today)
            }
            

            let schedule = input.data.2.mapValuesWithKeys { key, value in
                value.map {
                    StringlyTyped.Schedule.Performance(
                        customTitle: $0.customTitle,
                        artistNames: $0.artistNames,
                        startTime: scheduleDate.atTime($0.startTime),
                        endTime: scheduleDate.atTime($0.endTime),
                        stageName: key
                    )
                }
            }

            return StringlyTyped.Schedule(
                metadata: .init(
                    date: scheduleDate,
                    customTitle: customTitle
                ),
                stageSchedules: schedule
            )
        }

        func unapply(_ output: Output) throws -> Input {
            FileContent(
                fileName: output.metadata.date?.description ?? output.metadata.customTitle ?? "schedule",
                data: (output.metadata.customTitle, output.metadata.date, output.stageSchedules.mapValues {
                    $0.map {
                        StagelessPerformance(
                            customTitle: $0.customTitle,
                            artistNames: $0.artistNames,
                            startTime: ScheduleTime(from: $0.startTime),
                            endTime: ScheduleTime(from: $0.endTime)
                        )
                    }
                })
            )
        }
    }
}
