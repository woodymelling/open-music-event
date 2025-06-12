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
    var artists: [Artist]

    @ObservationIgnored
    @Dependency(\.musicEventID)
    var musicEventID

    // MARK: State
    var searchText: String = ""

    func searchTextDidChange() async {
        let artistsSearchQuery = Current.artists
            .where {
                $0.name.collate(.nocase).contains(self.searchText)
            }
            .order(by: \.name)
            .group(by: \.id)


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
        init(artist: Artist) {
            self.artist = artist

            let query = Performance.Artists
                .where { $0.artistID.eq(artist.id) }
                .join(Performance.all, on: { $0.performanceID.eq($1.id) })
                .join(Stage.all) { $1.stageID.eq($2.id) }
                .select { $2.color }


            self._performanceStageColors = FetchAll(query)

        }

        var artist: Artist

        private var imageSize: CGFloat = 60

        @FetchAll
        var performanceStageColors: [Color]

        @FetchAll
        var allStages: [Stage] = []
        var lineupStagesColors: [Color] {
            allStages.filter { $0.lineup?.contains(artist.id) ?? false }.map(\.color)
        }

        var stageColors: Set<Color> {
            Set(performanceStageColors + lineupStagesColors)
        }

        @Environment(\.showingArtistImages)
        var showingArtistImages

        var body: some View {
            HStack(spacing: 10) {
                if showingArtistImages {

                    Artist.ImageView(imageURL: artist.imageURL)
                        .frame(square: 60)

                    Stage.IndicatorView(colors: Array(stageColors))
                        .frame(width: 5)
                }

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
    }
}

extension EnvironmentValues {
    @Entry var showingArtistImages = true
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
