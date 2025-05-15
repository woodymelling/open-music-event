//
//  PerformanceRow.swift
//  open-music-event
//
//  Created by Woodrow Melling on 5/11/25.
//

import SwiftUI
import SharingGRDB


public struct PerformanceDetailRow: View {

    @Selection
    @Table
    struct ArtistPerformance: Identifiable {
        public typealias ID = OmeID<Performance>
        public let id: ID
        public let stageID: Stage.ID

        @Column(as: Date.ISO8601Representation.self)
        public let startTime: Date

        @Column(as: Date.ISO8601Representation.self)
        public let endTime: Date

        public let customTitle: String?

        public let stageColor: Color
    }


    init(performance: ArtistPerformance) {
        self.performance = performance
    }

    var performance: ArtistPerformance

    var timeIntervalLabel: String {
        (performance.startTime..<performance.endTime)
            .formatted(.performanceTime)
    }


    public var body: some View {
        HStack(spacing: 10) {
            StagesIndicatorView(colors: [performance.stageColor])
                .frame(width: 5)

            StageIconView(stageID: performance.stageID)
                .frame(square: 60)

            if let title = self.performance.customTitle {
                VStack(alignment: .leading) {
                    Text(title)

                    Text(timeIntervalLabel + " " + performance.startTime.formatted(.daySegment))
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            } else {
                VStack(alignment: .leading) {
                    Text(timeIntervalLabel)

                    Text(performance.startTime, format: .daySegment)
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }

            Spacer()
        }
        .padding(.horizontal, 5)
        .frame(height: 60)
    }
}

