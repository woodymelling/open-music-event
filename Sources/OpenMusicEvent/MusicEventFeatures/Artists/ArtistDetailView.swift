//
//  ArtistDetailView.swift
//  event-viewer
//
//  Created by Woodrow Melling on 2/21/25.
//

import SwiftUI
import SharingGRDB
import ImageCaching

extension Artist {
    static let placeholder = Artist(
        id: .init(0),
        musicEventID: nil,
        name: "",
        bio: "",
        imageURL: nil,
        links: []
    )
}






struct ArtistDetailView: View {

    @Observable
    class ViewModel {
        init(artistID: Artist.ID) {
            self.artistID = artistID
            self._artist = FetchOne(wrappedValue: .placeholder, Artist.find(artistID))

//            self._performances = FetchAll(placholder: [], Artist.performances(artistID)
        }

        let artistID: Artist.ID

        @ObservationIgnored
        @FetchOne
        var artist: Artist


        @ObservationIgnored
        @FetchAll
        var performances: [PerformanceDetail]


//        static func performances(for artistID: Artist.ID) -> some StructuredQueriesCore.Statement<PerformanceDetail> {
//            fatalError()
////            Artist.performances(artistID)
//                .join(Stage.all) { $0.id.eq($0.stageID) }
//                .select {
//                    PerformanceDetail.Columns(
//                        id: $1.0.id,
//                        stageID: $1.0.stageID,
//                        startTime: $1.0.startTime,
//                        endTime: $1.0.endTime,
//                        customTitle: $1.0.customTitle,
//                        stageColor: $1.1.color
//                    )
//                }
//        }

        static func performanceColors(for artistID: Artist.ID) -> some StructuredQueriesCore.Statement<Color.HexRepresentation.QueryValue> {
            Performance.Artists
                .where { $0.artistID.eq(artistID) }
                .join(Performance.all) { $0.performanceID.eq($1.id) }
                .join(Stage.all) { $1.stageID.eq($2.id) }
                .select { $2.color }
        }
    }

    


    let store: ViewModel

    var bioMarkdown: AttributedString? {
        guard let bio = store.artist.bio, !bio.isEmpty
        else { return nil }

        #if SKIP
        return try? AttributedString(markdown: bio)
        #else
        return try? AttributedString(
            markdown: bio,
            options: .init(failurePolicy: .returnPartiallyParsedIfPossible)
        )
        #endif
    }

    var body: some View {
        StretchyHeaderList(
            title: Text(store.artist.name),
            stretchyContent: {
                ArtistImage(artist: store.artist)
            },
            listContent: {
                ForEach(store.performances) { performance in
                    NavigationLinkButton {
//                        store.send(.didTapPerformance(performance.id))
                    } label: {
                        PerformanceDetailRow(performance: performance)
                    }
                }


                if let bio = bioMarkdown {
                    Text(bio)
                        .font(.body)
                }

                // MARK: Socials
                if !store.artist.links.isEmpty {
                    Section("Links") {
                        ForEach(store.artist.links, id: \.url) { link in
//                            Text(link.url.absoluteString)
//                            NavigationLinkButton {
//                                store.send(.didTapURL(link.url))
//                            } label: {
//                                LinkView(link)
//                            }
                            Link(link.url.absoluteString, destination: link.url)
                                #if os(iOS)
                                .foregroundStyle(.tint)
                                #endif
                        }
                    }
                }
            }
        )
        .listStyle(.plain)
        #if !Skip
//        .environment(\.meshBaseColors, meshColors)
        #endif
//        .toolbar {
//            Toggle("Favorite", isOn: $store.favoriteArtists[store.artist.id])
//                .frame(square: 20)
//                .toggleStyle(FavoriteToggleStyle())
//        }
    }

    struct ArtistImage: View {
        let artist: Artist

        var body: some View {
            CachedAsyncImage(
                requests: [
                    ImageRequest(
                        url: artist.imageURL,
                        processors: [.resize(width: 440)]
                    )
                    .withPipeline(.images)
                ]
            ) {
                $0.resizable()
            } placeholder: {
                #if !SKIP
                AnimatedMeshView()
                    .overlay(Material.thinMaterial)
                    .opacity(0.25)
                #else
                ProgressView().frame(square: 440)
                #endif

            }
            .frame(maxWidth: .infinity)
        }
    }
}

#Preview {
    try! prepareDependencies {
        $0.defaultDatabase = try appDatabase()
    }

    return ArtistDetailView(store: .init(artistID: 0))
}

