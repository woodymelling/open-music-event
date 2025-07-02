//
//  OrganizerListView.swift
//  open-music-event
//
//  Created by Woodrow Melling on 5/7/25.
//

import CoreModels
import SwiftUI; import SkipFuse
import GRDB
import Dependencies
import IssueReporting

struct OrganizerListView: View {

    @MainActor
    @Observable
    class Model {
        public init() {}

        // The live list
        var organizers: [Organizer] = []


        enum Destination {
            case organizerDetail(URL)
            case addOrganization(OrganizationFormView.Model)
        }


        var destination: Destination?

        // The observation handle


        func onAppear() async {
            @Dependency(\.defaultDatabase) var defaultDatabase

            let values = ValueObservation.tracking { db in
                try Organizer.fetchAll(db)
            }
            .values(in: defaultDatabase)

            do {
                for try await organizers in values {
                    self.organizers = organizers
                }
            } catch {
                reportIssue(error)
            }
        }


        func didTapOrganizer(id: Organizer.ID) {
            self.destination = .organizerDetail(id)
        }

        func didTapAddOrganizerButton() {
            self.destination = .addOrganization(.init())
        }

        func didDeleteOrganization(organization: Organizer) {
            @Dependency(\.defaultDatabase) var database

            withErrorReporting {
              try database.write { db in
//                try Organizer.delete(organization)
//                  .execute(db)
              }
            }
        }

        // These are needed because SwiftNavigation is not usable on Android at the moment
        var organizerDetail: URL? {
            get {
                if case let .organizerDetail(orgDetail) = destination {
                    return orgDetail
                } else {
                    return nil
                }
            }

            set {
                // This should be okay, the binding doesn't know how to set anythinb but nil
                destination = nil
            }
        }

        var addOrganization: OrganizationFormView.Model? {
            get {
                if case let .addOrganization(addOrg) = destination {
                    return addOrg
                } else {
                    return nil
                }
            }

            set {
                destination = nil
            }
        }
    }

    @Bindable var store: Model

    public var body: some View {
        Group {

            if !store.organizers.isEmpty {
                List {
                    ForEach(store.organizers) { org in
                        NavigationLinkButton {
                            store.didTapOrganizer(id: org.id)
                        } label: {
                            Row(org: org)
                        }
//                        .swipeActions(edge: .trailing) {
//                            Button(role: .destructive) {
//                                store.didDeleteOrganization(organization: org)
//                            } label: {
//                                Image(systemName: "trash")
//                            }
//                            .tint(.red)
//                        }
                    }
                }
                .listStyle(.plain)

            } else {
//                ContentUnavailableView(
//                    "No Organizations Yet",
//                    systemImage: "folder.badge.plus",
//                    description: Text("Use the + button in the top right, and add a link to any Open Music Event directory")
//                )
                Text("Content Unavailable")
            }
        }
        .onAppear { Task { await store.onAppear() }}
        .navigationTitle("Organizations")
        .toolbar {
            Button("Add Organization", systemImage: "plus") {
                store.didTapAddOrganizerButton()
            }
//            .popoverTip(AddOrganizationTip())
        }
//        .navigationDestination(item: $store.organizerDetail) { url in
//            OrganizerDetailView(store: .init(url: url))
//        }
        .sheet(item: $store.addOrganization) { store in
            NavigationStack {
                OrganizationFormView(store: store)
                    .navigationTitle("Add Organization")
            }
        }
    }

    struct Row: View {
        var org: Organizer

        var body: some View {
            HStack {
                Organizer.IconView(organizer: org)
                    .frame(width: 60, height: 60)
                    .aspectRatio(contentMode: .fit)

                VStack(alignment: .leading) {
                    Text(org.name)
                    Text(org.url.absoluteString)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
    }
}

//
//@MainActor
//func observe<Model: AnyObject, Entity: FetchableRecord & TableRecord & Sendable>(
//    query: QueryInterfaceRequest<Entity>,
//    at keyPath: ReferenceWritableKeyPath<Model, [Entity]>,
//    for model: Model,
//    dbWriter: any DatabaseWriter
//) async throws -> AnyDatabaseCancellable {
//    try await withCheckedThrowingContinuation { continuation in
//        let observation = ValueObservation
//            .tracking { db in
//                try query.fetchAll(db)
//            }
//
//        var firstValueRecieved = false
//
//        var token = observation
//            .start(
//                in: dbWriter,
//                onError: { error in
//                    reportIssue(error, "Failed to observe query")
//                    if !firstValueRecieved {
//                        continuation.resume(throwing: error)
//                    }
//                },
//                onChange: { [weak model] entities in
//                    guard let model = model else { return }
//                    model[keyPath: keyPath] = entities
//
//                    continuation.resume()
//                }
//            )
//    }
//}

//// Overload — uses defaultDatabase automatically
//import Dependencies
//
//@MainActor
//func fetchAndObserveQuery<Model: AnyObject, Entity: FetchableRecord & TableRecord & Sendable>(
//    query: QueryInterfaceRequest<Entity>,
//    on model: Model,
//    at keyPath: ReferenceWritableKeyPath<Model, [Entity]>
//) async throws -> AnyDatabaseCancellable {
//    @Dependency(\.defaultDatabase) var dbWriter
//    return try await observe(
//        query: query,
//        at: keyPath,
//        for: model,
//        dbWriter: dbWriter
//    )
//}

