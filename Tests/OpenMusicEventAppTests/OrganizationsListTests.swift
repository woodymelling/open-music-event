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
    struct OrganizationsListTests {
        @Test
        func testLoadingAllOrganizations() async throws {
            let store = OrganizerListView.ViewModel()
            try await store.$organizers.load()

            // Ensure all the organizers are loaded
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

            // Select the "Test Tools" Organization
            store.didTapOrganizer(id: Organizer.testToolz.id)

            // Ensure we've navigated there
            guard case let .organizerDetail(orgDetailStore) = store.destination else {
                Issue.record()
                return
            }

            await orgDetailStore.onAppear()

            assertInlineSnapshot(of: (orgDetailStore.events, orgDetailStore.organizer), as: .customDump) {
                """
                (
                  [
                    [0]: MusicEvent(
                      id: Tagged(rawValue: 2),
                      organizerURL: URL(https://github.com/woodymelling/test-tewlz/archive/refs/heads/main.zip),
                      name: "Nightfall Collective",
                      timeZone: TimeZone(
                        identifier: "America/Vancouver",
                        abbreviation: "PDT",
                        secondsFromGMT: -25200,
                        isDaylightSavingTime: true
                      ),
                      startTime: Date(2009-02-13T23:31:30.000Z),
                      endTime: Date(2009-02-16T23:31:30.000Z),
                      iconImageURL: nil,
                      imageURL: nil,
                      siteMapImageURL: nil,
                      location: nil,
                      contactNumbers: []
                    ),
                    [1]: MusicEvent(
                      id: Tagged(rawValue: 3),
                      organizerURL: URL(https://github.com/woodymelling/test-tewlz/archive/refs/heads/main.zip),
                      name: "Beats & Botanicals",
                      timeZone: TimeZone(
                        identifier: "America/Los_Angeles",
                        abbreviation: "PDT",
                        secondsFromGMT: -25200,
                        isDaylightSavingTime: true
                      ),
                      startTime: Date(2009-02-13T23:31:30.000Z),
                      endTime: Date(2009-02-14T23:31:30.000Z),
                      iconImageURL: nil,
                      imageURL: nil,
                      siteMapImageURL: nil,
                      location: nil,
                      contactNumbers: []
                    ),
                    [2]: MusicEvent(
                      id: Tagged(rawValue: 1),
                      organizerURL: URL(https://github.com/woodymelling/test-tewlz/archive/refs/heads/main.zip),
                      name: "Testival",
                      timeZone: TimeZone(
                        identifier: "America/Los_Angeles",
                        abbreviation: "PDT",
                        secondsFromGMT: -25200,
                        isDaylightSavingTime: true
                      ),
                      startTime: Date(2009-02-12T23:31:30.000Z),
                      endTime: Date(2009-02-15T23:31:30.000Z),
                      iconImageURL: nil,
                      imageURL: nil,
                      siteMapImageURL: nil,
                      location: nil,
                      contactNumbers: []
                    )
                  ],
                  Organizer(
                    url: URL(https://github.com/woodymelling/test-tewlz/archive/refs/heads/main.zip),
                    name: "Shambhala Music Festival",
                    imageURL: nil,
                    iconImageURL: URL(https://firebasestorage.googleapis.com/v0/b/festivl.appspot.com/o/userContent%2Flogo_small.png?alt=media&token=7766fa90-6591-4e25-92b4-2ff354cb970d)
                  )
                )
                """
            }

        }
    }
}
