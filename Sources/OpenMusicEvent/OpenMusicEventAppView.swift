//
//  OpenMusicEventAppView.swift
//  open-music-event
//
//  Created by Woodrow Melling on 5/6/25.
//

import SwiftUI
import Sharing
import SharingGRDB
import ImageCaching

public struct OpenFestivalAppEntryPointView: View {
    public init(store: ViewModel) {
        self.store = store
    }

    let store: ViewModel

    @MainActor
    @Observable
    public class ViewModel {
        enum State {
            case eventViewer(EventViewerView.ViewModel)
            case festivalList(OrganizationListView.ViewModel)
        }

        init() {
            @Shared(.eventID) var eventID

            if let eventID {
                self.state = .eventViewer(.init(id: eventID))
            } else {
                self.state = .festivalList(.init())
            }
        }

        var state: State
    }

    public var body: some View {
        switch store.state {
        case .eventViewer(let store):
            EventViewerView(store: store)

        case .festivalList(let store):
            OrganizationListView(store: store)
        }
    }
}

struct OrganizationListView: View {
    @MainActor
    @Observable
    class ViewModel {
        @ObservationIgnored
        @FetchAll(Organization.all.order(by: \.name))
        var organizations

        func didTapOrganization(id: Organization.ID) {
            unimplemented()
        }

        func didTapAddOrganizationButton() {

        }
    }

    let store: ViewModel

    public var body: some View {
        List(store.organizations, id: \.url) { org in
            Button {
                store.didTapOrganization(id: org.id)
            } label: {
                HStack {
                    CachedAsyncImage(
                        url: org.imageURL,
                        content: { $0.resizable() },
                        placeholder: {
                            Image(systemName: "photo.artframe")
                                .resizable()
                        }
                    )
                    .frame(width: 60, height: 60)
                    .aspectRatio(contentMode: .fit)

                    Text(org.name)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
            }
//            .buttonStyle(.navigationLink)
        }
        .listStyle(.plain)
        .navigationTitle("Organizations")
        .toolbar {
            Button("Add Organization", systemImage: "plus") {
                store.didTapAddOrganizationButton()
            }
        }
//        .sheet(
//            item: $store.scope(
//                state: \.destination?.addRepository,
//                action: \.destination.addRepository
//            ),
//            content: AddRepositoryView.init(store:)
//        )
//        .navigationDestination(
//            item: $store.scope(
//                state: \.destination?.organizationDetail,
//                action: \.destination.organizationDetail
//            ),
//            destination: OrganizationDetailView.init(store:)
//        )
    }
}

struct EventViewerView: View {

    class ViewModel {
        var id: MusicEvent.ID

        init(id: MusicEvent.ID) {
            self.id = id
        }
    }

    let store: ViewModel

    public var body: some View {

    }
}

#Preview {
    OpenFestivalAppEntryPointView(store: .init())
}
