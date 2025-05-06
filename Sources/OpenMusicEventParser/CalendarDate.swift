//
//  File.swift
//  
//
//  Created by Woodrow Melling on 5/29/24.
//

import Foundation
import CustomDump
import Dependencies

/**
 CalendarDate is a Swift type that represents a Date as year, month and day value.
 Includes support for simple date calculations, formatting as a ISO 8601
 string ('yyyy-mm-dd') and JSON coding.
 Restriction: `CalendarDate` has no understanding of time zones. It is meant to be used
 in places where the time zone doesn't matter. It uses the logic of Foundation's Date
 to transform the current time into year/month/day based on TimeZone.current.
 */
public struct CalendarDate: Equatable, Hashable, Sendable {
    public var year, month, day: Int

    public init(year: Int, month: Int, day: Int) {
        self.year = year
        self.month = month
        self.day = day
    }

    public init(_ date: Date) {
        @Dependency(\.calendar) var calendar
        self.year = calendar.component(.year, from: date)
        self.month = calendar.component(.month, from: date)
        self.day = calendar.component(.day, from: date)
    }

    public var date: Date {
        get {
            @Dependency(\.calendar) var calendar
            return DateComponents(calendar: calendar, year: self.year, month: self.month, day: self.day).date!
        }
        set {
            self = CalendarDate(newValue)
        }
    }
}

extension CalendarDate: LosslessStringConvertible {
    public init?(_ description: String) {
        if let date = Self.formatter.date(from: description) {
            self.init(date)
        } else {
            return nil
        }
    }

    public var description: String {
        Self.formatter.string(from: self.date)
    }

    private static let formatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter
    }()
}

extension CalendarDate: Codable {
    public init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        let string = try container.decode(String.self)

        guard let value = CalendarDate(string) else {
            throw DecodingError.dataCorruptedError(
                in: container,
                debugDescription: "Not a valid calendar date: \"\(string)\""
            )
        }

        self = value
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        try container.encode(self.description)
    }
}

/// Date calculations
public extension CalendarDate {
    static var today: CalendarDate {
        @Dependency(\.date) var date
        return CalendarDate(date())
    }

    func adding(years: Int? = nil, months: Int? = nil, weeks: Int? = nil, days: Int? = nil) -> CalendarDate {
        @Dependency(\.calendar) var calendar
        let components = DateComponents(year: years, month: months, day: days, weekOfYear: weeks)
        return CalendarDate(calendar.date(byAdding: components, to: self.date)!)
    }

    func atTimeOfDay(hour: Int? = nil, minute: Int? = nil, seconds: Int? = nil) -> Date {
        @Dependency(\.calendar) var calendar
        let nextDay = (hour ?? 0) > 24

        let components = DateComponents(
            day: nextDay ? 1 : 0,
            hour: (hour ?? 0) % 24,
            minute: minute,
            second: seconds
        )

        return calendar.date(byAdding: components, to: self.date)!
    }

    func daysTowards(date towardsDate: CalendarDate) -> Int {
        @Dependency(\.calendar) var calendar
        return calendar.dateComponents([.day], from: self.date, to: towardsDate.date).day!
    }

    static var yesterday: CalendarDate {
        self.today.adding(days: -1)
    }

    static var tomorrow: CalendarDate {
        self.today.adding(days: 1)
    }

    var isToday: Bool {
        self == CalendarDate.today
    }

    var isYesterday: Bool {
        self == CalendarDate.yesterday
    }

    var isTomorrow: Bool {
        self == CalendarDate.tomorrow
    }

    func isWithin(rhs: Self, lhs: Self) -> Bool {
        return self > rhs && self < lhs
    }
}

extension CalendarDate: Comparable {
    public static func < (lhs: CalendarDate, rhs: CalendarDate) -> Bool {
        guard lhs.year == rhs.year else { return lhs.year < rhs.year }

        guard lhs.month == rhs.month else { return lhs.month < rhs.month }

        return lhs.day < rhs.day
    }
}

extension CalendarDate: CustomDumpStringConvertible {
    public var customDumpDescription: String {
        return "\(month)/\(day)/\(year)"
    }
}

extension CalendarDate: CustomStringConvertible {}

#if canImport(Dependencies)

#endif

public extension Date {
    var calendarDate: CalendarDate {
        get { CalendarDate(self) }
        set {
            @Dependency(\.calendar) var calendar
            let components = calendar.dateComponents([.hour, .minute, .hour, .second], from: self)
            self = newValue.atTimeOfDay(hour: components.hour, minute: components.minute, seconds: components.second)
        }
    }
}

extension CalendarDate: Strideable {
    public func distance(to other: CalendarDate) -> Int {
        @Dependency(\.calendar) var calendar
        let startDate = calendar.date(from: DateComponents(year: year, month: month, day: day))!
        let endDate = calendar.date(from: DateComponents(year: other.year, month: other.month, day: other.day))!
        let components = calendar.dateComponents([.day], from: startDate, to: endDate)
        return components.day!
    }

    public func advanced(by n: Int) -> CalendarDate {
        @Dependency(\.calendar) var calendar
        let currentDate = calendar.date(from: DateComponents(year: year, month: month, day: day))!
        let futureDate = calendar.date(byAdding: .day, value: n, to: currentDate)!
        let futureDateComponents = calendar.dateComponents([.year, .month, .day], from: futureDate)
        return CalendarDate(year: futureDateComponents.year!, month: futureDateComponents.month!, day: futureDateComponents.day!)
    }
}

