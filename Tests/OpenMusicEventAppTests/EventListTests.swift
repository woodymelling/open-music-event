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
    struct EventListTests {
        @Test
        func testLoadingAllOrganizations() async throws {
            let store = OrganizerListView.ViewModel()
            try await store.$organizers.load()

             assertInlineSnapshot(of: store.organizers, as: .customDump) {
                 """
                 [
                   [0]: Organizer(
                     url: URL(https://github.com/woodymelling/test-tewlz/archive/refs/heads/main.zip),
                     name: "Shambhala Music Festival",
                     imageURL: nil,
                     iconImageURL: URL(https://firebasestorage.googleapis.com/v0/b/festivl.appspot.com/o/userContent%2Flogo_small.png?alt=media&token=7766fa90-6591-4e25-92b4-2ff354cb970d)
                   ),
                   [1]: Organizer(
                     url: URL(https://github.com/woodymelling/shambhala-ome/archive/refs/heads/main.zip),
                     name: "Shambhala Music Festival",
                     imageURL: nil,
                     iconImageURL: URL(https://firebasestorage.googleapis.com/v0/b/festivl.appspot.com/o/userContent%2Flogo_small.png?alt=media&token=7766fa90-6591-4e25-92b4-2ff354cb970d)
                   ),
                   [2]: Organizer(
                     url: URL(https://github.com/wicked-woods/wicked-woods-ome/archive/refs/heads/main.zip),
                     name: "Wicked Woods",
                     imageURL: URL(https://images.squarespace-cdn.com/content/v1/66eb917b86dbd460ad209478/5be5a6e6-c5ca-4271-acc3-55767c498061/WW-off_white.png?format=1500w),
                     iconImageURL: nil
                   )
                 ]
                 """
             }

        }
    }
}
