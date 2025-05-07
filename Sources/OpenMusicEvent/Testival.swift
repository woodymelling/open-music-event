//
//  Testival.swift
//  open-music-event
//
//  Created by Woodrow Melling on 5/3/25.
//
import Foundation

public extension Organization {
    static let wickedWoods = Organization(
        url: URL(string: "https://github.com/woodymelling/wicked-woods")!,
        name: "Wicked Woods",
        imageURL: URL(string: "https://images.squarespace-cdn.com/content/v1/66eb917b86dbd460ad209478/5be5a6e6-c5ca-4271-acc3-55767c498061/WW-off_white.png?format=1500w")
    )
}

public extension MusicEvent {
    static let testival = MusicEvent(
        id: 0,
        organizationURL: URL.temporaryDirectory,
        name: "Testival",
        timeZone: .autoupdatingCurrent,
        imageURL: nil,
        siteMapImageURL: nil,
        location: nil,
        contactNumbers: []
    )

    static let previewValue = Self.testival
}

public extension Artist {
    static let previewValues: [Artist] = [
        Artist(
            id: 0,
            musicEventID: nil,
            name: "Overgrowth",
            bio: "",
            imageURL: nil,
            links: []
        )
    ]
}
