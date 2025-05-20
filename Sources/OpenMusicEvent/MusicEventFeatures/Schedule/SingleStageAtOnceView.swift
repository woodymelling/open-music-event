//
//  Schedule.swift
//
//
//  Created by Woody on 2/17/2022.
//

import SwiftUI
import OrderedCollections
import SharingGRDB


extension Performance: DateIntervalRepresentable {
    public var dateInterval: DateInterval {
        .init(start: startTime, end: endTime)
    }
}

extension Where<Performance> {
    public func `for`(schedule scheduleID: Schedule.ID) -> Where<Performance> {
        self.where { $0.scheduleID == scheduleID }
    }

    func `for`(schedule scheduleID: Schedule.ID, at stageID: Stage.ID) -> Where<Performance> {
        self.where { $0.scheduleID == scheduleID && $0.stageID == stageID }
    }
}

extension ScheduleView {
    public struct SingleStageAtOnceView: View {
        @Observable @MainActor
        class ViewModel {
            init() { }

            @ObservationIgnored
            @Shared(.selectedStage)
            var selectedStage

            @ObservationIgnored
            @SharedReader(.selectedSchedule)
            var selectedSchedule

            @ObservationIgnored
            @FetchAll(Current.stages)
            var stages
        }

        @Bindable var store: ViewModel

        @Namespace var namespace
        @Environment(\.dayStartsAtNoon) var dayStartsAtNoon

        struct StageSchedulePage: View, Identifiable {

            var id: Stage.ID

            @SharedReader(.selectedSchedule) var selectedSchedule

            @FetchAll
            var performances: [PerformanceTimelineCard]

            @Selection
            struct PerformanceTimelineCard: Identifiable, TimelineCard, Codable {
                var id: Performance.ID

                @Column(as: Date.ISO8601Representation.self)
                var startTime: Date

                @Column(as: Date.ISO8601Representation.self)
                var endTime: Date

                var dateInterval: DateInterval {
                    DateInterval(start: startTime, end: endTime)
                }
            }


            func loadPerformances() async throws {
                guard let selectedSchedule
                else { return }

                let performancesQuery = Performance.all
                    .for(schedule: selectedSchedule, at: self.id)
                    .select {
                        PerformanceTimelineCard.Columns(
                            id: $0.id,
                            startTime: $0.startTime,
                            endTime: $0.endTime,
                        )
                    }

                try await self.$performances.load(performancesQuery)

            }

            var body: some View {
                SchedulePageView(performances) { performance in
                    Performance.ScheduleCardView(id: performance.id)
                }
                .tag(id)
                .task(id: selectedSchedule) {
                    await withErrorReporting {
                        try await self.loadPerformances()
                    }
                }
            }
        }


        public var body: some View {
            ScrollView {
                HorizontalPageView(page: $store.selectedStage) {
                    ForEach(store.stages) { stage in
                        StageSchedulePage(id: stage.id)
                    }
                }
                .animation(.default, value: store.selectedStage)
                .frame(height: 1500)
                .scrollClipDisabled()
                .scrollTargetLayout()
            }
//            .scrollPosition($store.highlightedPerformance) { id, size in
//                @Shared(.event) var event
//                guard let performance = event.schedule[id: id]
//                else { return nil }
//
//                return CGPoint(
//                    x: 0,
//                    y: performance.startTime.toY(
//                        containerHeight: size.height,
//                        dayStartsAtNoon: dayStartsAtNoon
//                    )
//                )
//            }
//            .overlay {
//                if store.showingComingSoonScreen {
//                    ScheduleComingSoonView()
//                }
//            }
            .navigationBarExtension {
                StageSelector(
                    stages: store.stages,
                    selectedStage: $store.selectedStage.animation(.snappy)
                )
            }
            .environment(\.dayStartsAtNoon, true)
//            .navigationBarTitleDisplayMode(.inline)
        }
    }
}
