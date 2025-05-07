//
//  Formattings.swift
//  open-music-event
//
//  Created by Woodrow Melling on 5/9/25.
//

import Foundation

extension FormatStyle where Self == PerformanceTimeStyle {
    static var performanceTime: PerformanceTimeStyle {
        PerformanceTimeStyle()
    }
}
struct PerformanceTimeStyle: FormatStyle {
    typealias FormatInput = Range<Date>
    typealias FormatOutput = String

    func format(_ value: Range<Date>) -> String {
        var timeFormat = Date.FormatStyle.dateTime.hour().minute()
        timeFormat.timeZone = NSTimeZone.default

        return "\(value.lowerBound.formatted(timeFormat)) - \(value.upperBound.formatted(timeFormat))"
    }

}
