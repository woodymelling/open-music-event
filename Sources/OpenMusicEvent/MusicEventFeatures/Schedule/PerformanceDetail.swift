//
//  PerformanceDetail.swift
//  open-music-event
//
//  Created by Woodrow Melling on 5/14/25.
//

import SwiftUI
import SharingGRDB

extension Artist {
    struct Simple: Codable {
        var id: Artist.ID
        var name: String
        var imageURL: URL?
    }
}

@Selection
struct PerformanceDetail: Identifiable {
    public typealias ID = OmeID<Performance>
    public let id: ID

    public let title: String
    public let stageID: Stage.ID

    @Column(as: Date.ISO8601Representation.self)
    public let startTime: Date

    @Column(as: Date.ISO8601Representation.self)
    public let endTime: Date
//
//    @Column(as: [Artist.Simple].JSONRepresentation.self)
//    public let artists: [Artist.Simple]

    public let stageColor: Color
    public let stageName: String
    public let stageImageURL: URL?

    static let empty: Self = .init(
        id: .init(0),
        title: "",
        stageID: .init(0),
        startTime: Date(),
        endTime: Date(),
//        artists: [],
        stageColor: .gray,
        stageName: "",
        stageImageURL: nil
    )
}

extension Performance {
    public struct ScheduleDetailView: View {

        init(performance: PerformanceDetail) {
            self._performance = FetchOne(wrappedValue: performance)
        }

        init(id: Performance.ID) {

            let query = Performance
                .find(id)
                .withArtists
                .join(Stage.all) { $0.stageID.eq($3.id) }
                .select {
                    PerformanceDetail.Columns(
                        id: $0.id,
                        title: $0.customTitle ?? "",
                        stageID: $0.stageID,
                        startTime: $0.startTime,
                        endTime: $0.endTime,
                        stageColor: $3.color,
                        stageName: $3.name,
                        stageImageURL: $3.iconImageURL
                    )
                }

            self._performance = FetchOne(
                wrappedValue: .empty,
                query
            )
        }

        @FetchOne
        var performance: PerformanceDetail

        var timeIntervalLabel: String {
            (performance.startTime..<performance.endTime)
                .formatted(.performanceTime)
        }

        public var body: some View {
            HStack(alignment: .top) {
                // Artist Section
                VStack(alignment: .leading, spacing: 12) {
                    Text(performance.title)
                        .font(.title2.bold())

                    Label {
                        VStack(alignment: .leading) {
                            Text(timeIntervalLabel)
                            Text(performance.startTime.formatted(.daySegment))
                        }
                    } icon: {
                        Image(systemName: "clock")
                    }
                }

                Spacer(minLength: 24)

                // Stage Section
                VStack(alignment: .center, spacing: 8) {
                    StageIconView(stageID: performance.stageID)
                        .frame(square: 60)

                    Text(performance.stageName)
                        .font(.subheadline.bold())
                        .multilineTextAlignment(.trailing)
                }
            }
            .padding()
            .background(
                AnimatedMeshView()
                .overlay(Material.thinMaterial)
                .opacity(0.25)
            )
            .environment(\.meshBaseColors, [performance.stageColor])
            .background(.ultraThinMaterial)
            .clipShape(RoundedRectangle(cornerRadius: 16))
        }
    }
}

#Preview("Context Menu") {
    try! prepareDependencies {
        $0.defaultDatabase = try appDatabase()
    }

    return Performance.ScheduleDetailView(performance: .preview)
        .contextMenu {
            Button("Add to Favorites") {}
        }
        .padding()
}

#Preview("Material Popover") {
    ZStack {
        Color.black.opacity(0.2).ignoresSafeArea()
        Performance.ScheduleDetailView(performance: .preview)
            .padding()
            .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 24, style: .continuous))
            .padding()
    }
}

extension PerformanceDetail {
    static var preview: PerformanceDetail {
        PerformanceDetail(
            id: 1,
            title: "Overgrowth",
            stageID: 1,
            startTime: .now,
            endTime: .now.addingTimeInterval(60 * 45),
//            artists: [
//                .init(id: 1, name: "Overgrowth", imageURL: nil),
//            ],
            stageColor: .purple,
            stageName: "The Hallow",
            stageImageURL: Stage.previewValues.first?.iconImageURL
        )
    }
}
