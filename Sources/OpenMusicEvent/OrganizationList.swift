//
//  OrganizationListView.swift
//  open-music-event
//
//  Created by Woodrow Melling on 5/7/25.
//

import SwiftUI
import SharingGRDB
import SwiftUINavigation
import ImageCaching


struct OrganizationListView: View {
    @MainActor
    @Observable
    class ViewModel {
        public init() {}

        @ObservationIgnored
        @FetchAll(Organization.all.order(by: \.name))
        var organizations


        @CasePathable
        enum Destination {
            case organizationDetail(OrganizationDetailView.ViewModel)
        }

        var destination: Destination?

        func didTapOrganization(id: Organization.ID) {
            self.destination = .organizationDetail(.init(id: id))
        }

        func didTapAddOrganizationButton() {
            unimplemented()
        }
    }

    @State var store = ViewModel()

    public var body: some View {
        List(store.organizations, id: \.url) { org in
            Button {
                store.didTapOrganization(id: org.id)
            } label: {
                Row(org: org)
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
        .navigationDestination(item: $store.destination.organizationDetail) { store in
            OrganizationDetailView(store: store)
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
//                state: \.destination?.organizationDetail,
//                action: \.destination.organizationDetail
//            ),
//            destination: OrganizationDetailView.init(store:)
//        )
    }

    struct Row: View {
        var org: Organization

        var body: some View {
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
    }
}
