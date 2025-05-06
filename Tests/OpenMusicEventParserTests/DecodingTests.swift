import XCTest
@testable import OpenMusicEventParser
import CustomDump

import Testing
import Parsing


func expect<C: Conversion>(
    _ data: C.Input,
    toRoundtripUsing conversion: C,
    fileID: StaticString = #fileID,
    filePath: StaticString = #filePath,
    line: UInt = #line,
    column: UInt = #column
) throws where C.Input: Equatable  {
    let result = try conversion.unapply(conversion.apply(data))
    expectNoDifference(result, data, fileID: fileID, filePath: filePath, line: line, column: column)
}


struct YamlCodingTests {
    @Test
    func simpleEventInfo() throws {
        let yaml = Data("""
        version: "0.1.0" # Schema Version

        # General Information
        name: "Testival"
        address: "123 Festival Road, Music City"
        timeZone: "America/Seattle"

        # Images
        imageURL: "http://example.com/event-image.jpg"
        siteMapImageURL: "http://example.com/site-map.jpg"
        """.utf8)

        let expectedResult = Event.Info.YamlRepresentation(
            name: "Testival",
            address: "123 Festival Road, Music City",
            timeZone: "America/Seattle",
            imageURL: URL(string: "http://example.com/event-image.jpg"),
            siteMapImageURL: URL(string: "http://example.com/site-map.jpg"),
            contactNumbers: nil
//            colorScheme: .init(primaryColor: "#FF5733", workshopsColor: "#C70039")
        )

        let result = try Conversions.YamlConversion(Event.Info.YamlRepresentation.self).apply(yaml)
        expectNoDifference(result, expectedResult)

        // Test roundtripping from struct to yaml back to struct
//        try expect(expectedResult, toRoundtripUsing: Conversions.YamlConversion(Event.Info.YamlRepresentation.self).inverted())
    }

    @Test
    func decodingSimpleStageInfo() throws {
        let yaml = Data("""
        - name: "Mystic Grove"
          color: "#1DB954"
          imageURL: "http://example.com/mystic-grove.jpg"

        - name: "Bass Haven"
          color: "#FF5733"
          imageURL: "http://example.com/bass-haven.jpg"

        - name: "Tranquil Meadow"
          color: "#4287f5"
        """.utf8)

        let expectedResult = [
            StageDTO(name: "Mystic Grove", color: "#1DB954", imageURL: URL(string: "http://example.com/mystic-grove.jpg")!),
            StageDTO(name: "Bass Haven", color: "#FF5733", imageURL: URL(string: "http://example.com/bass-haven.jpg")!),
            StageDTO(name: "Tranquil Meadow", color: "#4287f5", imageURL: nil)
        ]

        let result = try Conversions.YamlConversion([StageDTO].self).apply(yaml)

        expectNoDifference(result, expectedResult)

        try expect(expectedResult, toRoundtripUsing: Conversions.YamlConversion([StageDTO].self).inverted())
    }

    @Test
    func decodeSimpleContactInfo() throws {
        let yaml = Data("""
        - phoneNumber: "+1234567890"
          title: "General Info"

        - phoneNumber: "+0987654321"
          title: "Emergency"
          description: "For emergencies only"
        """.utf8)

        let expectedResult = [
            ContactInfoDTO(phoneNumber: "+1234567890", title: "General Info", description: nil),
            ContactInfoDTO(phoneNumber: "+0987654321", title: "Emergency", description: "For emergencies only")
        ]

        let result = try Conversions.YamlConversion([ContactInfoDTO].self).apply(yaml)

        expectNoDifference(result, expectedResult)

        try expect(expectedResult, toRoundtripUsing: Conversions.YamlConversion([ContactInfoDTO].self).inverted())
    }


    @Test
    func decodeSimpleSchedule() throws {
        let yaml = Data("""
        Bass Haven:
          - time: "10:00 PM"
            artist: "Prism Sound"

          - time: "11:30 PM"
            title: "Subsonic B2B Sylvan"
            artists:
               - "Subsonic"
               - "Sylvan Beats"

          - time: "12:30 AM"
            endTime: "2:00 AM"
            artist: "Space Chunk"

        Mystic Grove:
          - time: "4:30 PM"
            artist: "Sunspear"

          - time: "6:30 PM"
            artist: "Phantom Groove"

          - time: "10:30 PM"
            artist: "Oaktrail"

          - time: "12:00 AM"
            endTime: "4:00 AM"
            artist: "Rhythmbox"

        Tranquil Meadow:
          - time: "3:00 PM"
            artist: "Float On"

          - time: "4:30 PM"
            artist: "Floods"

          - time: "04:00 PM"
            endTime: "6:00 PM"
            artist: "Overgrowth"

          - time: "1:00 AM"
            endTime: "2:00 AM"
            artist: "The Sleepies"
            title: "The Wind Down"
        """.utf8)

        let expectedResult = DTOs.Event.DaySchedule(
            customTitle: nil,
            date: nil,
            performances: [
            "Bass Haven": [
                PerformanceDTO(title: nil, artist: "Prism Sound", artists: nil, time: "10:00 PM"),
                PerformanceDTO(title: "Subsonic B2B Sylvan", artist: nil, artists: ["Subsonic", "Sylvan Beats"], time: "11:30 PM"),
                PerformanceDTO(title: nil, artist: "Space Chunk", artists: nil, time: "12:30 AM", endTime: "2:00 AM")
            ],
            "Mystic Grove": [
                PerformanceDTO(title: nil, artist: "Sunspear", artists: nil, time: "4:30 PM"),
                PerformanceDTO(title: nil, artist: "Phantom Groove", artists: nil, time: "6:30 PM"),
                PerformanceDTO(title: nil, artist: "Oaktrail", artists: nil, time: "10:30 PM"),
                PerformanceDTO(title: nil, artist: "Rhythmbox", artists: nil, time: "12:00 AM", endTime: "4:00 AM")
            ],
            "Tranquil Meadow": [
                PerformanceDTO(title: nil, artist: "Float On", artists: nil, time: "3:00 PM"),
                PerformanceDTO(title: nil, artist: "Floods", artists: nil, time: "4:30 PM"),
                PerformanceDTO(title: nil, artist: "Overgrowth", artists: nil, time: "04:00 PM", endTime: "6:00 PM"),
                PerformanceDTO(title: "The Wind Down", artist: "The Sleepies", artists: nil, time: "1:00 AM", endTime: "2:00 AM")
            ]
        ])

        let result = try Conversions.YamlConversion<DTOs.Event.DaySchedule>().apply(yaml)

        expectNoDifference(result, expectedResult)

        try expect(expectedResult, toRoundtripUsing: Conversions.YamlConversion<DTOs.Event.DaySchedule>().inverted())
    }

    @Test
    func decodingSimpleArtistFrontMatter() throws {
        let yaml = Data("""
            imageURL: http://example.com/subsonic.jpg
            links:
            - url: http://soundcloud.com/subsonic
            - url: http://instagram.com/subsonic
        """.utf8)

        let expectedResult = ArtistInfoFrontMatter(
            imageURL: .init(string: "http://example.com/subsonic.jpg"),
            links: [
                .init(url: URL(string: "http://soundcloud.com/subsonic")!),
                .init(url: URL(string: "http://instagram.com/subsonic")!)
            ]
        )

        let result = try Conversions.YamlConversion<ArtistInfoFrontMatter>().apply(yaml)

        expectNoDifference(result, expectedResult)

        try expect(expectedResult, toRoundtripUsing: Conversions.YamlConversion<ArtistInfoFrontMatter>().inverted())
    }
}

struct ArtistDecodingTests {
    @Test(.tags(.frontmatter))
    func decodingStandardArtistFile() throws {
        let markdown = """
        ---
        imageURL: http://example.com/subsonic.jpg
        links:
        - url: http://soundcloud.com/subsonic
        - url: http://instagram.com/subsonic
        ---
        Subsonic delivers powerful bass-driven music that shakes the ground and moves the crowd, known for their high-energy performances and deep, resonant beats.
        """

        var text = Substring(markdown)
        let parser = MarkdownWithFrontMatter<ArtistInfoFrontMatter>.Parser()
        let dto = try parser.parse(&text)

        #expect(
            dto == MarkdownWithFrontMatter(
                frontMatter: ArtistInfoFrontMatter(
                    imageURL: .init(string: "http://example.com/subsonic.jpg"),
                    links: [
                        .init(url: URL(string: "http://soundcloud.com/subsonic")!),
                        .init(url: URL(string: "http://instagram.com/subsonic")!)
                    ]
                ),
                body: "Subsonic delivers powerful bass-driven music that shakes the ground and moves the crowd, known for their high-energy performances and deep, resonant beats."
            )
        )

        try parser.print(dto, into: &text)
        #expect(Substring(markdown) == text)
    }

    @Test(.tags(.frontmatter))
    func decodingArtistFileWithNoFrontmatterRoundtripping() throws {
        let markdown = """
        Subsonic delivers powerful bass-driven music that shakes the ground and moves the crowd, known for their high-energy performances and deep, resonant beats.
        """

        var text = Substring(markdown)
        let parser = MarkdownWithFrontMatter<ArtistInfoFrontMatter>.Parser()
        let dto = try parser.parse(&text)

        #expect(
            dto == MarkdownWithFrontMatter(
                frontMatter: nil,
                body: "Subsonic delivers powerful bass-driven music that shakes the ground and moves the crowd, known for their high-energy performances and deep, resonant beats."
            )
        )

        try parser.print(dto, into: &text)
        #expect(markdown == text)
    }
}

