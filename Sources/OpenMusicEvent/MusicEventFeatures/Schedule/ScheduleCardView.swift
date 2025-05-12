//
//  SwiftUIView.swift
//  
//
//  Created by Woody on 2/20/22.
//

import SwiftUI

struct PerformanceCard: Equatable {
    var id: Performance.ID
    var title: String
    var startTime: Date
    var endTime: Date
    var isFavorite: Bool
}


struct ScheduleCardView: View {
    let performance: PerformanceCard
    let isSelected: Bool


    public var body: some View {
        ScheduleCardBackground(color: .accentColor, isSelected: isSelected) {
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
