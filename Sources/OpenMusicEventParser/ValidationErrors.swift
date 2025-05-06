//
//  Validation.swift
//  OpenFestival
//
//  Created by Woodrow Melling on 10/31/24.
//


enum Validation: Error {
    case stage(Stage)
    case generic
    case schedule(ScheduleError)
    case artist

    enum Stage: Error {
        case generic
    }

    enum ScheduleError: Error {
//        case daySchedule(DayScheduleError)
    }
}