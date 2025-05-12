//
//  IDLessModels.swift
//  OpenFestival
//
//  Created by Woodrow Melling on 11/17/24.
//

import Foundation

import Collections

public enum StringlyTyped {

    public struct Schedule: Equatable, Sendable {
        public var metadata: Metadata
        public var stageSchedules: [String : [Performance]]

        public struct Performance: Equatable, Sendable {
            public var customTitle: String?
            public var artistNames: OrderedSet<String>
            public var startTime: Date
            public var endTime: Date
            public var stageName: String
        }
    }

    public struct Metadata: Equatable, Hashable, Sendable {
        public init(
            date: CalendarDate? = nil,
            customTitle: String? = nil
        ) {
            self.date = date
            self.customTitle = customTitle
        }

        public var date: CalendarDate?
        public var customTitle: String?

        public var startTime: Date? {
            date?.date
        }

        public var endTime: Date? {
            nil
        }
    }
}
