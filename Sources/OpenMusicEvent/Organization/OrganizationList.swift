//
//  OrganizerListView.swift
//  open-music-event
//
//  Created by Woodrow Melling on 5/7/25.
//

import CoreModels
import SwiftUI
import SwiftUINavigation
import ImageCaching
import GRDB

struct OrganizerListView: View {

    @MainActor
    @Observable
    class Model {
        public init() {}

        // The live list
        var organizers: [Organizer] = []


        @CasePathable
        enum Destination {
            case organizerDetail(OrganizerDetailView.ViewModel)
            case addOrganization(OrganizationFormView.Model)
        }

        var destination: Destination?

        // The observation handle
        private var observation: AnyDatabaseCancellable?
        func onAppear() async {
            guard observation == nil else { return }
            do {
                self.observation = try await fetchAndObserveQuery(
                    query: Organizer.order(Column("name")),
                    on: self,
                    at: \.organizers
                )
            } catch {

            }
        }


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

            } else {
                ContentUnavailableView(
                    "No Organizations Yet",
                    systemImage: "folder.badge.plus",
                    description: Text("Use the + button in the top right, and add a link to any Open Music Event directory")
                )
            }
        }
        .onAppear { Task { await store.onAppear() }}
        .navigationTitle("Organizations")
        .toolbar {
            Button("Add Organization", systemImage: "plus") {
                store.didTapAddOrganizerButton()
            }
            .popoverTip(AddOrganizationTip())
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

import TipKit

struct AddOrganizationTip: Tip {
    var title: Text {
        Text("Add an Organization")
    }

    var message: Text? {
        Text("Tap the + button in the top right to add a new organization from a local directory.")
    }

    var image: Image? {
        Image(systemName: "plus.circle.fill")
    }
}

@MainActor
func observe<Model: AnyObject, Entity: FetchableRecord & TableRecord & Sendable>(
    query: QueryInterfaceRequest<Entity>,
    at keyPath: ReferenceWritableKeyPath<Model, [Entity]>,
    for model: Model,
    dbWriter: any DatabaseWriter
) async throws -> AnyDatabaseCancellable {
    try await withCheckedThrowingContinuation { continuation in
        let observation = ValueObservation
            .tracking { db in
                try query.fetchAll(db)
            }

        var firstValueRecieved = false

        let token = observation
            .start(
                in: dbWriter,
                onError: { error in
                    reportIssue(error, "Failed to observe query")
                    if !firstValueRecieved {
                        continuation.resume(throwing: error)
                    }
                },
                onChange: { [weak model] entities in
                    guard let model = model else { return }
                    model[keyPath: keyPath] = entities


                    if !firstValueRecieved {
                        firstValueRecieved = true
                        continuation.resume(returning: token)
                    }
                }
            )
    }
}

// Overload — uses defaultDatabase automatically
import Dependencies
func fetchAndObserveQuery<Model: AnyObject, Entity: FetchableRecord & TableRecord & Sendable>(
    query: QueryInterfaceRequest<Entity>,
    on model: Model,
    at keyPath: ReferenceWritableKeyPath<Model, [Entity]>
) async throws -> AnyDatabaseCancellable {
    @Dependency(\.defaultDatabase) var dbWriter
    return try await observe(
        query: query,
        at: keyPath,
        for: model,
        dbWriter: dbWriter
    )
}
