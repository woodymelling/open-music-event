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
//    public init() {
//    }



//    static func artists() -> some StructuredQueriesCore.Statement<ArtistsListView.Row.ArtistInformation> {
//        Current.artists
//            .join(Performance.Artists.all) { $0.id == $1.artistID }
////            .join(Performance.all) { $1.performanceID == $0.id }
////            .select { artist, _, _ in
////                ArtistsListView.Row.ArtistInformation.Columns(
////                    id: artist.id,
////                    name: artist.name,
////                    imageURL: artist.imageURL,
//////                    performanceColors: []
////                )
////            }
//
////            .join(Performance.all) { _, pa, p in pa.performanceID.eq(p.id) }
////            .join(Stage.all) { _, _, p, s in p.stageID.eq(s.id) }
////            .select { artist, _, _, stage in
////                ArtistsListView.Row.ArtistInformation.Columns(
////                    id: artist.id,
////                    name: artist.name,
////                    imageURL: artist.imageURL,
////                    performanceColors: []//stage.color.jsonGroupArray()
////                )
////            }


//    }

    // MARK: Data
    @ObservationIgnored
    @FetchAll(Current.artists)
    var artists
//    var artists: [ArtistsListView.Row.ArtistInformation] = []

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
    }

    struct Row: View {
        init(artist: Artist) {
            self.artist = artist
        }



        var artist: Artist

        var stageColors: [Color] = []

        private var imageSize: CGFloat = 60


        var body: some View {
            HStack(spacing: 10) {
                ArtistImage(imageURL: artist.imageURL)

//                StagesIndicatorView(colors: artist.performanceColors)
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
