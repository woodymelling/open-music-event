//
//  SwiftUIView.swift
//  
//
//  Created by Woody on 2/20/22.
//

import SwiftUI


struct ScheduleCardView: View {
    let performance: PerformanceTimelineCard
    let isSelected: Bool

    public var body: some View {
        ScheduleCardBackground(color: performance.stageColor, isSelected: isSelected) {
            HStack(alignment: .top) {
                VStack(alignment: .leading) {
                    Text(performance.title)
                    Text(performance.startTime..<performance.endTime, format: .performanceTime)
                        .font(.caption)
                }

                Spacer()
            }
            .padding(.top, 2)

        }
        .id(performance.id)
        .tag(performance.id)
    }
}
