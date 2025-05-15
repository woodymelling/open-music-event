//
//  PerformanceDetail.swift
//  open-music-event
//
//  Created by Woodrow Melling on 5/14/25.
//

import SwiftUI
import SharingGRDB

extension Artist {
    @Selection
    struct Simple: Codable {
        var id: Artist.ID
        var name: String
        var imageURL: URL?
    }


    static let simple = Artist.select {
        Artist.Simple.Columns(
            id: $0.id,
            name: $0.name,
            imageURL: $0.imageURL
        )
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

    @Column(as: [Artist.ID].JSONRepresentation.self)
    public let artists: [Artist.ID]

    public let stageColor: Color
    public let stageName: String
    public let stageImageURL: URL?

    static let empty: Self = .init(
        id: .init(0),
        title: "",
        stageID: .init(0),
        startTime: Date(),
        endTime: Date(),
        artists: [],
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
                        title: $0.title,
                        stageID: $0.stageID,
                        startTime: $0.startTime,
                        endTime: $0.endTime,
                        artists: $2.id.jsonGroupArray(),
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
            VStack {
                Text(performance.title)
                    .lineLimit(nil)
                    .multilineTextAlignment(.center)
                    .font(.largeTitle.weight(.bold))

                HStack {
                    // Artist Section
    //                ArtistsListView.Row.ArtistImage(id: performance.)
    //                 StageIconView(stageID: performance.stageID)
    //                     .frame(square: 60)
    //                     .offset(x: -30)Simple

                    if let firstArtistID = performance.artists.first {
                        Artist.ImageView(artistID: firstArtistID)
                            .frame(square: 60)
                            .clipShape(RoundedRectangle(cornerRadius: 8))
                    }

                    VStack(alignment: .center, spacing: 16) {

                        VStack {
                            Text(performance.startTime.formatted(.daySegment))
    //                            .font(.thin)
                                .fontWeight(.thin)

                            Label {
                                Text(timeIntervalLabel)
                                    .textCase(.lowercase)
                                    .fontWeight(.bold)
                            } icon: {
                                Image(systemName: "clock")
                            }


                            Text(performance.stageName)
                                .fontWeight(.thin)
                        }

    //                        .offset(x: 30)

//                            .font(.title)
//                            .font(.)
//                            .fontWeight(.thin)
                    }

    //                Spacer(minLength: 24)


                    StageIconView(stageID: performance.stageID)
                        .frame(square: 60)
                        .background {
                            Circle()
                                .fill(performance.stageColor)
                                .shadow()
                        }
    //

                }
            }

            .padding()
            .background(
                AnimatedMeshView()
                .overlay(Material.thinMaterial)
                .opacity(0.25)
            )
            .environment(\.meshBaseColors, [performance.stageColor])
//            .background(.ultraThinMaterial)
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
            startTime: Date(hour: 22, minute: 30)!,
            endTime: Date(hour: 23, minute: 30)!,
            artists: [
                1
//                .init(id: 1, name: "Overgrowth", imageURL: nil),
            ],
            stageColor: .purple,
            stageName: "The Hallow",
            stageImageURL: Stage.previewValues.first?.iconImageURL
        )
    }
}
