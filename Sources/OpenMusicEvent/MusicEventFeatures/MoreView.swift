import SwiftUI
import SharingGRDB
import Observation

@MainActor
@Observable
final class MoreTabFeature {
    @ObservationIgnored
    @FetchOne(
        Current.musicEvent
             .join(Organizer.select(\.name)) { $0.organizerURL.eq($1.url) }
    )
    var organizerName: String = ""

    @ObservationIgnored
    @FetchOne(Current.musicEvent)
    var musicEvent: MusicEvent?

    var isLoadingOrganizer = false

    var errorMessage: String?

    func didTapReloadOrganizer() async {
        guard let currentOrganizerID = musicEvent?.organizerURL
        else { return }
        self.errorMessage = nil

        self.isLoadingOrganizer = true

        do {
            try await downloadAndStoreOrganizer(from: currentOrganizerID)
            self.isLoadingOrganizer = false
        } catch {
            self.errorMessage = error.localizedDescription
            self.isLoadingOrganizer = true

        }
    }
}

struct MoreView: View {
    let store: MoreTabFeature

    var body: some View {
        List {
            Button {
                Task {
                    await store.didTapReloadOrganizer()
                }
            } label: {
                VStack {
                    HStack {
                        Text("Reload \(store.organizerName)")
                        Spacer()
                        if store.isLoadingOrganizer {
                            ProgressView()
                        }
                    }

                    if let errorMessage = store.errorMessage {
                        Text(errorMessage)
                            .foregroundStyle(.red)
                    }
                }
            }

            Button("See other Wicked Wood events") {
                @Shared(Current.musicEventID)
                var musicEventID

                $musicEventID.withLock { $0 = nil }
            }
        }
        .navigationTitle("More")
    }
}
