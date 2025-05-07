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

extension ScheduleView {
    public struct SingleStageAtOnceView: View {
        @Bindable var store: ScheduleFeature

        @Namespace var namespace

        public init(store: ScheduleFeature) {
            self.store = store
        }

        @Environment(\.dayStartsAtNoon) var dayStartsAtNoon

//        @FetchAll(Current.stages)
//        var stages: []

        public var body: some View {
            ScrollView {
                HorizontalPageView(page: $store.selectedStage) {
//                    ForEach(orderedStageSchedules, id: \.0) { (stageID, schedule) in
//                        SchedulePageView(schedule) { performance in
//                            ScheduleCardView(
//                                performance,
//                                isSelected: false,
//                                isFavorite: false
//                            )
//                            .onTapGesture { store.send(.didTapCard(performance.id)) }
//                            .id(performance.id)
//                        }
//                        .tag(stageID)
//                        .overlay {
//                            if store.showTimeIndicator {
//                                TimeIndicatorView()
//                            }
//                        }
//                    }
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
//            .navigationBarTitleDisplayMode(.inline)
        }
    }
}
