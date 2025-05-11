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
                .transition(.scale)
        } else {
            NavigationStack {
                 OrganizationListView()
            }
        }
    }
}


#Preview {
    let _ = try! prepareDependencies {
      $0.defaultDatabase = try appDatabase()
    }

    OpenMusicEventAppEntryPoint()
}
