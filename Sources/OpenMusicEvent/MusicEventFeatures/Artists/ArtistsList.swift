//
//  Artists.swift
//  open-music-event
//
//  Created by Woodrow Melling on 5/3/25.
//

import SwiftUI
import SharingGRDB
import ImageCaching
import CoreModels

@MainActor
@Observable
public class ArtistsList {

    // MARK: Data
    @ObservationIgnored
    @FetchAll
    var artists: [ArtistRow]

    @ObservationIgnored
    @Dependency(\.musicEventID)
    var musicEventID

    @Selection
    struct ArtistRow: Identifiable {
        var id: Artist.ID?
        var name: String?
        var imageURL: URL?

        @Column(as: [Color].JSONRepresentation.self)
        var performanceColors: [Color]
    }


    // MARK: State
    var searchText: String = ""

    func searchTextDidChange() async {
        let artistsSearchQuery = Current.artists
            .where {
                $0.name.collate(.nocase).contains(self.searchText)
            }
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

        await withErrorReporting {
            try await $artists.load(artistsSearchQuery)
        }
    }

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
        .task(id: store.searchText) {
            await withDependencies(from: store) { @Sendable in
                await store.searchTextDidChange()
            }
        }
        .autocorrectionDisabled()
        .textInputAutocapitalization(.never)
        .navigationTitle("Artists")
        .listStyle(.plain)
        .navigationDestination(for: Artist.ID.self) {
            ArtistDetailView(store: .init(artistID: $0))
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
                Artist.ImageView(imageURL: artist.imageURL)
                    .frame(square: 60)

                Stage.IndicatorView(colors: artist.performanceColors)
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
