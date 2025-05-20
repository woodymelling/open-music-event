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

    public let stageColor: Color
    public let stageName: String
    public let stageImageURL: URL?

    @Selection
    struct SimpleArtist: Codable {
        var id: Artist.ID
        var name: String
    }

    static let empty: Self = .init(
        id: .init(0),
        title: "",
        stageID: .init(0),
        startTime: Date(),
        endTime: Date(),
        stageColor: .gray,
        stageName: "",
        stageImageURL: nil
    )


    static let find = { @Sendable (id: Performance.ID) in
        Performance
            .find(id)
            .join(Stage.all) { $0.stageID.eq($1.id) }
            .select {
                PerformanceDetail.Columns(
                    id: $0.id,
                    title: $0.title,
                    stageID: $0.stageID,
                    startTime: $0.startTime,
                    endTime: $0.endTime,
                    stageColor: $1.color,
                    stageName: $1.name,
                    stageImageURL: $1.iconImageURL
                )
            }
    }
}


extension Performance {
    public struct ScheduleDetailView: View {

        init(performance: PerformanceDetail, performingArtists: [Artist]) {
            self._performance = FetchOne(wrappedValue: performance)
            self._performingArtists = FetchAll(wrappedValue: performingArtists)
        }

        init(id: Performance.ID) {
            self._performance = FetchOne(wrappedValue: .empty, PerformanceDetail.find(id))
            self._performingArtists = FetchAll(
                Performance.find(id)
                    .join(Performance.Artists.all) { $0.id == $1.performanceID }
                    .join(Artist.all) { $1.artistID.eq($2.id) }
                    .select { $2 }
            )
        }

        @FetchOne
        var performance: PerformanceDetail


        @FetchAll
        var performingArtists: [Artist]

        var timeIntervalLabel: String {
            (performance.startTime..<performance.endTime)
                .formatted(.performanceTime)
        }

        public var body: some View {
            VStack {
                Text(performance.title)
                    .scaledToFill()
                    .minimumScaleFactor(0.5)
                    .frame(maxWidth: .infinity)
                    .lineLimit(nil)
                    .multilineTextAlignment(.center)
                    .font(.largeTitle.weight(.bold))

                HStack {

                    if performingArtists.count == 1, let firstArtist = performingArtists.first {
                        Artist.ImageView(artistID: firstArtist.id)
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

    return Performance.ScheduleDetailView(
        performance: .preview,
        performingArtists: []
    )
        
}

#Preview("Material Popover") {
    ZStack {
        Color.black.opacity(0.2).ignoresSafeArea()
        Performance.ScheduleDetailView(
            performance: .preview,
            performingArtists: []
        )
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
            stageColor: .purple,
            stageName: "The Hallow",
            stageImageURL: Stage.previewValues.first?.iconImageURL
        )
    }
}
