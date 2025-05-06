////
////  Schedule.swift
////  OpenFestival
////
////  Created by Woodrow Melling on 1/11/25.
////
//
//import Foundation
//import OrderedCollections
//
//
//public extension Event {
//    struct Schedule: Hashable, Sendable {
//        public init(
//            date: CalendarDate? = nil,
//            customTitle: String? = nil,
//            stageSchedules: [Stage.ID : [Performance]]
//        ) {
//            self.metadata = Metadata(
//                date: date,
//                customTitle: customTitle
//            )
//
//            self.stageSchedules = stageSchedules
//        }
//
//        public init(
//            metadata: Metadata,
//            stageSchedules: [Stage.ID : [Performance]]
//        ) {
//            self.metadata = metadata
//            self.stageSchedules = stageSchedules
//        }
//
//        public struct Metadata: Equatable, Hashable, Sendable {
//            public init(
//                date: CalendarDate? = nil,
//                customTitle: String? = nil
//            ) {
//                self.date = date
//                self.customTitle = customTitle
//            }
//
//            public var date: CalendarDate?
//            public var customTitle: String?
//        }
//
//        public var metadata: Metadata
//
//        public var stageSchedules: [Stage.ID : [Performance]]
//
//        public var name: String {
//            metadata.customTitle ?? metadata.date?.description ?? "Unknown Schedule"
//        }
//    }
//
//}
//
//
//
//extension Set {
//    func sorted(by key: (Element) -> some Comparable) -> OrderedSet<Element> {
//        OrderedSet(self.sorted(by: { key($0) < key($1) }))
//    }
//}
//
//
//
