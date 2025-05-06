//
//  Testival.swift
//  open-music-event
//
//  Created by Woodrow Melling on 5/3/25.
//
import Foundation

public extension MusicEvent {
    static let testival = MusicEvent(
        id: 0,
        organizationID: URL.temporaryDirectory,
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
            eventID: nil,
            name: "Overgrowth",
            bio: "",
            imageURL: nil,
            links: []
        )
    ]
}
