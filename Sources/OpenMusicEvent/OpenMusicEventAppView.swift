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
import CasePaths

public struct OpenFestivalAppEntryPointView: View {
    public init(store: ViewModel) {
        self.store = store
    }

    let store: ViewModel

    @MainActor
    @Observable
    public class ViewModel {
        @CasePathable
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
            NavigationStack {
                OrganizationListView(store: store)
            }
        }
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
    let _ = try! prepareDependencies {
      $0.defaultDatabase = try appDatabase()
    }

    OpenFestivalAppEntryPointView(store: .init())
}
