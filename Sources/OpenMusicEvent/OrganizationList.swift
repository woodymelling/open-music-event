//
//  OrganizerListView.swift
//  open-music-event
//
//  Created by Woodrow Melling on 5/7/25.
//

import SwiftUI
import SharingGRDB
import SwiftUINavigation
import ImageCaching


struct OrganizerListView: View {
    @MainActor
    @Observable
    class ViewModel {
        public init() {}

        @ObservationIgnored
        @FetchAll(Organizer.all.order(by: \.name))
        var organizers


        @CasePathable
        enum Destination {
            case organizerDetail(OrganizerDetailView.ViewModel)
        }

        var destination: Destination?

        func didTapOrganizer(id: Organizer.ID) {
            self.destination = .organizerDetail(.init(url: id))
        }

        func didTapAddOrganizerButton() {
            unimplemented()
        }
    }

    @State var store = ViewModel()

    public var body: some View {
        List(store.organizers, id: \.url) { org in
            
            NavigationLinkButton {
                store.didTapOrganizer(id: org.id)
            } label: {
                Row(org: org)
            }
        }
        .listStyle(.plain)
        .navigationTitle("Organizers")
        .toolbar {
            Button("Add Organizer", systemImage: "plus") {
                store.didTapAddOrganizerButton()
            }
        }
        .navigationDestination(item: $store.destination.organizerDetail) { store in
            OrganizerDetailView(store: store)
        }
//        .navigationDestination(item: <#T##Binding<Optional<Hashable>>#>, destination: <#T##(Hashable) -> View#>)
//        .sheet(
//            item: $store.scope(
//                state: \.destination?.addRepository,
//                action: \.destination.addRepository
//            ),
//            content: AddRepositoryView.init(store:)
//        )
//        .navigationDestination(
//            item: $store.scope(
//                state: \.destination?.organizerDetail,
//                action: \.destination.organizerDetail
//            ),
//            destination: OrganizerDetailView.init(store:)
//        )
    }

    struct Row: View {
        var org: Organizer

        var body: some View {
            HStack {
                Organizer.ImageView(organizer: org)
                    .frame(width: 60, height: 60)
                    .aspectRatio(contentMode: .fit)

                    Text(org.name)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
    }
}
