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
            case addOrganization(OrganizationFormView.Model)
        }

        var destination: Destination?

        func didTapOrganizer(id: Organizer.ID) {
            self.destination = .organizerDetail(.init(url: id))
        }

        func didTapAddOrganizerButton() {
            self.destination = .addOrganization(.init())
        }

        func didDeleteOrganization(organization: Organizer) {
            @Dependency(\.defaultDatabase) var database

            withErrorReporting {
              try database.write { db in
                try Organizer.delete(organization)
                  .execute(db)
              }
            }
        }
    }

    @State var store = ViewModel()

    public var body: some View {
        List {
            ForEach(store.organizers) { org in
                NavigationLinkButton {
                    store.didTapOrganizer(id: org.id)
                } label: {
                    Row(org: org)
                }
                .swipeActions(edge: .trailing) {
                    Button(role: .destructive) {
                        store.didDeleteOrganization(organization: org)
                    } label: {
                        Image(systemName: "trash")
                    }
                    .tint(.red)
                }
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
        .sheet(item: $store.destination.addOrganization) { store in
            NavigationStack {
                OrganizationFormView(store: store)
                    .navigationTitle("Add Organization")
            }
        }
//        .navigationDestination(item: , destination: <#T##(Hashable) -> View#>)
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
