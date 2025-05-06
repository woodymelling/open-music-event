import Testing
@testable import OpenMusicEventParser

import Dependencies
import CustomDump
import Foundation

extension URL {
    static let resourcesFolder = Bundle.module.bundleURL.appending(component: "Contents/Resources/ExampleFestivals")
}
struct EventDecodingTests {

    @Test(
        .disabled("""
            This fails because there is nothing at the .resourcesFolder at all.
            I think it's trying to decode from the wrong place?
            Something is not correctly copying
            """)
    )
    func testival() async throws {
        let url = URL.resourcesFolder.appending(component: "Testival").appendingPathComponent("2024")
        try await withDependencies {
            $0.calendar = .current
            $0.timeZone = .current
            $0.date = .constant(.now)
        } operation: {
            let event = try await OpenFestivalDecoder().decode(from: url)

            customDump(event)
        }
    }
}

