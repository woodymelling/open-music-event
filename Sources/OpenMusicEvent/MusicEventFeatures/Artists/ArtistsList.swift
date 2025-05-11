//
//  Artists.swift
//  open-music-event
//
//  Created by Woodrow Melling on 5/3/25.
//

import SwiftUI
import SharingGRDB
import ImageCaching

@Observable
public class ArtistsList {
    public init() {
    }

    // MARK: Data
    @ObservationIgnored
    @FetchAll(Current.artists)
    public var artists: [Artist]

    // MARK: State
    public var searchText: String = ""

}

struct ArtistsListView: View {
    @Bindable var store: ArtistsList

    var body: some View {
        List(store.artists) { artist in
            NavigationLink(value: artist.id) {
                ArtistRow(artist: artist)
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
    }

    struct ArtistRow: View {
        init(artist: Artist) {
            self.artist = artist
        }

        var artist: Artist

        private var imageSize: CGFloat = 60

        var body: some View {
            HStack(spacing: 10) {
                ArtistImage(artist: artist)
//
//
//                StagesIndicatorView(stageIDs: performances.map(\.stageID))
//                    .frame(width: 5)


                Text(artist.name)
                    .lineLimit(1)

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
            var artist: Artist
            var body: some View {
                CachedAsyncImage(
                    requests: [
                        ImageRequest(
                            url: artist.imageURL,
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
