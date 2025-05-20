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

public struct OpenMusicEventAppEntryPoint: View {
    @ObservationIgnored
    @Shared(.eventID) var eventID

    public var body: some View {
        if let eventID {
            MusicEventViewer(id: eventID)
                .environment(\.exitEvent) {
                    $eventID.withLock { $0 = nil }
                }
        } else {
            NavigationStack {
                 OrganizationListView()
            }
        }
    }
}

public struct WhiteLabeledOrganizationEntryPoint: View {
    public init(url: Organization.ID) {
        self.url = url
    }

    @ObservationIgnored
    @Shared(.eventID) var eventID

    var url: Organization.ID

    public var body: some View {
        Group {
            if let eventID {
                MusicEventViewer(id: eventID)
                    .environment(\.exitEvent) {
                        $eventID.withLock { $0 = nil }
                    }
                    .transition(.slide.animation(.snappy))
            } else {
                OrganizationDetailView(url: self.url)
            }
        }
    }
}

extension EnvironmentValues {
    @Entry var exitEvent: () -> Void = { unimplemented() }
}


#Preview {
    let _ = try! prepareDependencies {
      $0.defaultDatabase = try appDatabase()
    }

    OpenMusicEventAppEntryPoint()
}
