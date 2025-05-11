import SwiftUI
import SharingGRDB
import Observation

@MainActor
@Observable
final class MoreTabFeature {
    @ObservationIgnored
    @FetchOne(
        Current.musicEvent
             .join(Organization.select(\.name)) { $0.organizationURL.eq($1.url) }
    )
    var organizationName: String = ""

    @ObservationIgnored
    @FetchOne(Current.musicEvent)
    var musicEvent: MusicEvent = .testival

    var isLoadingOrganization = false

    var errorMessage: String?

    func didTapReloadOrganization() async {
        guard let currentOrganizationID = musicEvent.organizationURL
        else { return }

        self.isLoadingOrganization = true

        do {
            try await downloadAndStoreOrganization(id: currentOrganizationID)
            self.isLoadingOrganization = false
        } catch {
            self.errorMessage = error.localizedDescription
        }
    }
}

struct MoreView: View {
    let store: MoreTabFeature

    var body: some View {
        List {
            Button {
                Task {
                    await store.didTapReloadOrganization()
                }
            } label: {
                VStack {
                    HStack {
                        Text("Reload \(store.organizationName)")
                        Spacer()
                        if store.isLoadingOrganization {
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
