//
//  EventViewerTests.swift
//  open-music-event
//
//  Created by Woodrow Melling on 6/20/25.
//


//
//  EventListTests.swift
//  open-music-event
//
//  Created by Woodrow Melling on 6/20/25.
//

import Testing
@testable import OpenMusicEvent
import SnapshotTestingCustomDump
import InlineSnapshotTesting

extension OpenMusicEventBaseTestSuite {
    @MainActor
    struct EventViewerTests {
        @Test
        func eventViewerLoadsSelectedEvent() async throws {
            let eventViewer = MusicEventViewer.Model(id: MusicEvent.testival.id)

            await eventViewer.onAppear()

            


        }
    }
}
