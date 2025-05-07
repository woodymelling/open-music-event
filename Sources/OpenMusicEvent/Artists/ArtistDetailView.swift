//
//  ArtistDetailView.swift
//  open-music-event
//
//  Created by Woodrow Melling on 5/3/25.
//


//
//  ArtistDetailView.swift
//  event-viewer
//
//  Created by Woodrow Melling on 2/21/25.
//

import SwiftUI
//import ImageCaching




struct ArtistDetailView: View {
    init(artist: Artist.ID) {
        fatalError()
    }

    var artist: Artist

//    var bioMarkdown: AttributedString? {
//        guard let bio = artist.bio, !bio.isEmpty
//        else { return nil }
//
//        return try? AttributedString(markdown: bio)
////        #if SKIP
////        #else
////        return try? AttributedString(
////            markdown: bio,
////            options: .init(failurePolicy: .returnPartiallyParsedIfPossible)
////        )
////        #endif
//
//    }

    var body: some View {
        StretchyHeaderList(
            title: Text(artist.name),
            stretchyContent: {
                ArtistImage(artist: artist)
            },
            listContent: {
//                ForEach(store.performances) { performance in
//                    NavigationLinkButton {
//                        store.send(.didTapPerformance(performance.id))
//                    } label: {
//                        PerformanceDetailRow(for: performance)
//                    }
//                }

//
//                if let bio = bioMarkdown {
//                    Text(bio)
//                }

                // MARK: Socials
                if !artist.links.isEmpty {
                    Section("Links") {
                        ForEach(artist.links, id: \.url) { link in
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
//        @Shared(.event) var event

        var body: some View {
//            CachedAsyncImage(
//                requests: [
//                    ImageRequest(
//                        url: artist.imageURL,
//                        processors: [.resize(width: 440)]
//                    ).withPipeline(.artist)
//                ]
//            ) {
//                $0.resizable()
//            } placeholder: {
//                #if !SKIP
//                AnimatedMeshView()
//                    .overlay(Material.thinMaterial)
//                    .opacity(0.25)
//                #else
//                ProgressView().frame(square: 440)
//                #endif
//
//            }
//            .frame(maxWidth: .infinity)
        }
    }
}

