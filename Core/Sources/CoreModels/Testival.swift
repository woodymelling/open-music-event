//
//  Testival.swift
//  open-music-event
//
//  Created by Woodrow Melling on 5/3/25.
//
import Foundation

public extension Organizer {
    static let wickedWoods = Organizer(
        url: Organizer.ID(string: "https://github.com/wicked-woods/wicked-woods-ome/archive/refs/heads/main.zip")!,
        name: "Wicked Woods",
        imageURL: URL(string: "https://images.squarespace-cdn.com/content/v1/66eb917b86dbd460ad209478/5be5a6e6-c5ca-4271-acc3-55767c498061/WW-off_white.png?format=1500w")
    )

    static let shambhala = Organizer(
        url: Organizer.ID(string: "https://github.com/woodymelling/shambhala-ome/archive/refs/heads/main.zip")!,
        name: "Shambhala Music Festival",
        iconImageURL: URL(string: "https://firebasestorage.googleapis.com/v0/b/festivl.appspot.com/o/userContent%2Flogo_small.png?alt=media&token=7766fa90-6591-4e25-92b4-2ff354cb970d")
    )

    static let omeTools = Organizer(
        url: Organizer.ID(string: "https://github.com/ometools/test-ome-config/archive/refs/heads/main.zip")!,
        name: "Open Music Event",
        iconImageURL: URL(string: "https://firebasestorage.googleapis.com/v0/b/festivl.appspot.com/o/userContent%2Flogo_small.png?alt=media&token=7766fa90-6591-4e25-92b4-2ff354cb970d")
    )
}

public extension MusicEvent {
    static let placeholder = MusicEvent(
        id: -1,
        organizerURL: nil,
        name: "",
        timeZone: .current,
        startTime: nil,
        endTime: nil,
        imageURL: nil,
        iconImageURL: nil,
        siteMapImageURL: nil,
        location: nil,
        contactNumbers: []
    )
}

public extension MusicEvent {
    static let testival = MusicEvent(
        id: 1,
        organizerURL: Organizer.omeTools.url,
        name: "Testival",
        timeZone: .current,
        imageURL: nil,
        iconImageURL: nil,
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

public extension Stage {
    static let previewValues: [Stage] = [
//        Stage(
//            id: 0,
//            musicEventID: 0,
//            sortIndex: 0,
//            name: "Unicorn Lounge",
//            iconImageURL: URL(string: "https://firebasestorage.googleapis.com:443/v0/b/festivl.appspot.com/o/userContent%2FF0BC110C-D42E-4CC9-BED3-59E2700938FF.png?alt=media&token=472a66e1-c45a-4a67-895a-5ec7e0ad95c0"), color: .red
//
//        ),
//
//        Stage(
//            id: 1,
//            musicEventID: 0,
//            sortIndex: 1,
//            name: "The Hallow",
//            iconImageURL: URL(string: "https://firebasestorage.googleapis.com:443/v0/b/festivl.appspot.com/o/userContent%2FB36D3658-2659-447C-9ECA-21D07C952A88.png?alt=media&token=d328c04d-6c4d-4be7-8368-786ab5262c9a"), color: .green
//        ),
//        Stage(
//            id: 2,
//            musicEventID: 0,
//            sortIndex: 2,
//            name: "Ursus",
//            iconImageURL: URL(string: "https://firebasestorage.googleapis.com:443/v0/b/festivl.appspot.com/o/userContent%2F274838AC-2BDA-40A0-8FD4-78E9FFC86D6B.png?alt=media&token=b28cc74f-b60d-4472-a31b-900a4f5bfbd8"), color: .blue
//        ),
//        Stage(
//            id: 3,
//            musicEventID: 0,
//            sortIndex: 3,
//            name: "The Portal",
//            iconImageURL: URL(string: "https://firebasestorage.googleapis.com:443/v0/b/festivl.appspot.com/o/userContent%2F8BD98000-C41A-4360-8106-9AD98BF1AD71.png?alt=media&token=a0df8893-0cc7-4442-8921-d6c4e066569c"), color: .purple
//        )
    ]
}
//public extension Stage {
//    static let previewValues: [Stage] = [
//        Stage(
//            id: 0,
//            musicEventID: 0,
//            name: "Unicorn Lounge",
//            iconImageURL: URL(string: "https://firebasestorage.googleapis.com:443/v0/b/festivl.appspot.com/o/userContent%2FF0BC110C-D42E-4CC9-BED3-59E2700938FF.png?alt=media&token=472a66e1-c45a-4a67-895a-5ec7e0ad95c0"), color: .red
//        ),
//
//        Stage(
//            id: 1,
//            musicEventID: 0,
//            name: "The Hallow",
//            iconImageURL: URL(string: "https://firebasestorage.googleapis.com:443/v0/b/festivl.appspot.com/o/userContent%2FB36D3658-2659-447C-9ECA-21D07C952A88.png?alt=media&token=d328c04d-6c4d-4be7-8368-786ab5262c9a"), color: .green
//        ),
//        Stage(
//            id: 2,
//            musicEventID: 0,
//            name: "Ursus",
//            iconImageURL: URL(string: "https://firebasestorage.googleapis.com:443/v0/b/festivl.appspot.com/o/userContent%2F274838AC-2BDA-40A0-8FD4-78E9FFC86D6B.png?alt=media&token=b28cc74f-b60d-4472-a31b-900a4f5bfbd8"), color: .blue
//        ),
//        Stage(
//            id: 3,
//            musicEventID: 0,
//            name: "The Portal",
//            iconImageURL: URL(string: "https://firebasestorage.googleapis.com:443/v0/b/festivl.appspot.com/o/userContent%2F8BD98000-C41A-4360-8106-9AD98BF1AD71.png?alt=media&token=a0df8893-0cc7-4442-8921-d6c4e066569c"), color: .purple
//        )
//    ]
//}
