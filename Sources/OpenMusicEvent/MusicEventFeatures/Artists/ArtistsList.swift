//
//  Artists.swift
//  open-music-event
//
//  Created by Woodrow Melling on 5/3/25.
//

import SwiftUI
import SharingGRDB
import ImageCaching


let x = Current.artists
@Observable
public class ArtistsList {

    // MARK: Data
    @ObservationIgnored
    @FetchAll(
        Current.artists
        .group(by: \.id)
        .rightJoin(Performance.Artists.all) { $1.artistID.eq($0.id) }
        .join(Performance.all) { $1.performanceID.eq($2.id) }
        .join(Stage.all) { $2.stageID.eq($3.id) }
        .order(by: \.name)
        .select {
            ArtistRow.Columns(
                id: $0.id,
                name: $0.name,
                imageURL: $0.imageURL,
                performanceColors: $3.color.jsonGroupArray()
            )
        }
    )
    var artists

    @Selection
    @Table
    struct ArtistRow: Identifiable {
        var id: Artist.ID?
        var name: String?
        var imageURL: URL?

        @Column(as: [Color].JSONRepresentation.self)
        var performanceColors: [Color]
    }

    // MARK: State
    var searchText: String = ""
}



struct ArtistsListView: View {
    @Bindable var store: ArtistsList

    var body: some View {
        List(store.artists) { artist in
            NavigationLink(value: artist.id) {
                Row(artist: artist)
            }
        }
        .searchable(text: $store.searchText)
        .autocorrectionDisabled()
        .textInputAutocapitalization(.never)
        .navigationTitle("Artists")
        .listStyle(.plain)
        .navigationDestination(for: Artist.ID.self) {
            ArtistDetailView(store: .init(artistID: $0))
        }
        .refreshable {
            await withErrorReporting {
                try await store.$artists.load()
            }
        }
    }

    struct Row: View {
        init(artist: ArtistsList.ArtistRow) {
            self.artist = artist
        }

        var artist: ArtistsList.ArtistRow
        var stageColors: [Color] = []

        private var imageSize: CGFloat = 60


        var body: some View {
            HStack(spacing: 10) {
                ArtistImage(imageURL: artist.imageURL)

                StagesIndicatorView(colors: artist.performanceColors)
                    .frame(width: 5)

                if let name = artist.name {
                    Text(name)
                        .lineLimit(1)
                }

                Spacer()

//                if favoriteArtists[artist.id] {
//                    Image(systemName: "heart.fill")
//                        .resizable()
//                        .renderingMode(.template)
//                        .aspectRatio(contentMode: .fit)
//                        .frame(square: 15)
//                        .foregroundColor(.accentColor)
//                        .padding(.trailing)
//                }
            }
            .frame(height: 60)
            .foregroundStyle(.primary)
        }


        struct ArtistImage: View {
            var imageURL: URL?
            var body: some View {
                CachedAsyncImage(
                    requests: [
                        ImageRequest(
                            url: imageURL,
                            processors: [
                                .resize(size: CGSize(width: 60, height: 60))
                            ]
                        )
                        .withPipeline(.images)
                    ]
                ) {
                    $0.resizable()
                        .aspectRatio(contentMode: .fill)
                } placeholder: {
                    Image(systemName: "person.fill")
                        .resizable()
                        .frame(square: 30)
                }
                .frame(square: 60)
                .clipped()
            }
        }
    }
}

extension View {
    func frame(square: CGFloat, alignment: Alignment = .center) -> some View {
        self.frame(width: square, height: square, alignment: alignment)
    }
}

#Preview {
    try! prepareDependencies {
        $0.defaultDatabase = try appDatabase()
    }

    return NavigationStack {
        ArtistsListView(store: .init())
    }
}
