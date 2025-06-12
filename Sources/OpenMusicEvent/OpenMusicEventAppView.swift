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
import CoreModels


public enum OME {
    public static func prepareDependencies() {
        try! Dependencies.prepareDependencies {
            $0.defaultDatabase = try appDatabase()
        }
    }

    public struct AppEntryPoint: View {
        @ObservationIgnored
        @Shared(.eventID) var eventID

        public init() {}
        public var body: some View {
            if let eventID {
                MusicEventViewer(id: eventID)
                    .environment(\.exitEvent) {
                        $eventID.withLock { $0 = nil }
                    }
            } else {
                NavigationStack {
                     OrganizerListView()
                }
            }
        }
    }

    public struct WhiteLabeledEntryPoint: View {
        public init(url: Organizer.ID) {
            self.url = url
        }

        @ObservationIgnored
        @Shared(.eventID) var eventID

        var url: Organizer.ID

        public var body: some View {
            Group {
                if eventID == nil {
                    OrganizerDetailView(url: self.url)
                }

                if let eventID {
                    MusicEventViewer(id: eventID)
                        .transition(.slide)
                        .environment(\.exitEvent) {
                            $eventID.withLock { $0 = nil }
                        }
                }

            }
            .animation(.default, value: eventID)
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

    OME.AppEntryPoint()
}
