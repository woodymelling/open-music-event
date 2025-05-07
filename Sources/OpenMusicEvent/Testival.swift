//
//  Testival.swift
//  open-music-event
//
//  Created by Woodrow Melling on 5/3/25.
//
import Foundation

public extension Organization {
    static let ome = Organization(
        url: URL(string: "https://github.com/woodymelling/wicked-woods")!,
        name: "Wicked Woods",
        imageURL: URL(string: "https://images.squarespace-cdn.com/content/v1/66eb917b86dbd460ad209478/5be5a6e6-c5ca-4271-acc3-55767c498061/WW-off_white.png?format=1500w")
    )
}

public extension MusicEvent {
    static let testival = MusicEvent(
        id: 0,
        organizationURL: Organization.ome.url,
        name: "Testival",
        timeZone: .current,
        imageURL: nil,
        siteMapImageURL: URL(string: "https://firebasestorage.googleapis.com/v0/b/festivl.appspot.com/o/userContent%2FSite%20Map.webp?alt=media&token=48272d3c-ace0-4d5b-96a9-a5142f1c744a"),
        location: Location(
            address: "3901 Kootenay Hwy, Fairmont Hot Springs, BC V0B 1L1, Canada",
            directions: "Get back on San Vincente, take it to the 10, then switch over to the 405 north, and let it dump you onto Mullholland where you belong!",
            coordinates: .init(latitude: 50.366265, longitude: -115.871286)
            ),
        contactNumbers: [
            .init(
                phoneNumber: "5555551234",
                title: "Emergency Services",
                description: "This will connect you directly with our switchboard, and alert the appropriate services."
            ),
            .init(
                phoneNumber: "5555554321",
                title: "General Information Line",
                description: "For general information, questions or concerns, or to report any sanitation issues within the WW grounds, please contact this number."
            )
        ]
    )
}

public extension Artist {
    static let previewValues: [Artist] = [
        Artist(
            id: Artist.ID(0),
            musicEventID: .init(0),
            name: "Cantos",
            bio: "**Cantos** is an electronic music producer and DJ who fuses a sense of otherworldly mysticism with cutting-edge sonic craft. Exploring everything from deep and funky house to techno, drum & bass, and garage, Cantos delivers powerful, underground sets rooted in soundsystem culture. High production quality and immersive, dancefloor-focused energy define each performance, creating unforgettable experiences that meld the ancient and the futuristic into a single, pulsing groove.",
            imageURL: URL(string: "https://firebasestorage.googleapis.com/v0/b/festivl.appspot.com/o/userContent%2FIMG_9907_Original.png?alt=media&token=3c2c0140-a28a-40bc-9f50-f77954b2294d"),
            links: [
                Artist.Link(url: URL(string: "https://soundcloud.com/cantos_music")!),
                Artist.Link(url: URL(string: "https://www.instagram.com/cantos/")!)
            ]
        ),
        Artist(
            id: Artist.ID(40),
            musicEventID: .init(0),
            name: "Boids",
            bio: "**Boids** is an experimental electronic music project blending elements of technology, nature, math, and art. Drawing inspiration from the complex patterns of flocking behavior, boids creates immersive soundscapes that evolve through algorithmic structures and organic, flowing rhythms. With a foundation in house music, the project explores new auditory dimensions while maintaining a connection to the dance floor, inviting listeners to explore both the natural world and the mathematical systems that underpin it.",
            imageURL: URL(string: "https://firebasestorage.googleapis.com/v0/b/festivl.appspot.com/o/userContent%2FSubsonic.webp?alt=media&token=8b732938-f9c7-4216-8fb5-3ff4acad9384"),
            links: []
        ),
        Artist(
            id: Artist.ID(1),
            musicEventID: .init(0),
            name: "Phantom Groove",
            bio: nil,
            imageURL: nil,
            links: []
        ),
        Artist(
            id: Artist.ID(2),
            musicEventID: .init(0),
            name: "Sunspear",
            bio: nil,
            imageURL: URL(string: "https://firebasestorage.googleapis.com/v0/b/festivl.appspot.com/o/userContent%2FSunspear-image.webp?alt=media&token=be30f499-8356-41a9-9425-7e19e36e2ea9")!,
            links: []
        ),
        Artist(
            id: Artist.ID(3),
            musicEventID: .init(0),
            name: "Rhythmbox",
            bio: nil,
            imageURL: nil,
            links: []
        ),
        Artist(
            id: Artist.ID(4),
            musicEventID: .init(0),
            name: "Prism Sound",
            bio: nil,
            imageURL: nil,
            links: []
        ),
        Artist(
            id: Artist.ID(5),
            musicEventID: .init(0),
            name: "Oaktrail",
            bio: nil,
            imageURL: URL(string: "https://firebasestorage.googleapis.com/v0/b/festivl.appspot.com/o/userContent%2FOaktrail.webp?alt=media&token=db962b24-e144-476c-ac4c-71ffa7f7f32d"),
            links: []
        ),
        Artist(
            id: Artist.ID(6),
            musicEventID: .init(0),
            name: "Space Chunk",
            bio: nil,
            imageURL: URL(string: "https://i1.sndcdn.com/avatars-oI73KB5SpEOGCmFq-5ezWjw-t500x500.jpg")!,
            links: [
                .init(url: URL(string: "https://soundcloud.com/spacechunk")!, label: nil)
            ]
        ),
        Artist(
            id: Artist.ID(7),
            musicEventID: .init(0),
            name: "The Sleepies",
            bio: nil,
            imageURL: nil,
            links: []
        ),
        Artist(
            id: Artist.ID(8),
            musicEventID: .init(0),
            name: "Sylvan Beats",
            bio: nil,
            imageURL: nil,
            links: []
        ),
        Artist(
            id: Artist.ID(9),
            musicEventID: .init(0),
            name: "Overgrowth",
            bio: nil,
            imageURL: URL(string: "https://firebasestorage.googleapis.com/v0/b/festivl.appspot.com/o/userContent%2FOvergrowth%20DJ%20Profile.webp?alt=media&token=f0856acd-ab9c-47bf-b1d8-d7e385048beb"),
            links: [
                .init(url: URL(string: "https://soundcloud.com/overgrowthmusic")!, label: nil)
            ]
        ),
    ]
}
