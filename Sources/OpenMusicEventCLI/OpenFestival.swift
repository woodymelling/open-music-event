//
//  OpenMusicEvent.swift
//  open-music-event
//
//  Created by Woodrow Melling on 6/9/25.
//


import ArgumentParser
import OpenMusicEventParser
import Dependencies
import Foundation
import OSLog


extension Logger {
    static let cli = Logger(subsystem: "com.openfestival.ome", category: "CLI")
}

@main
struct OpenMusicEvent: AsyncParsableCommand {
    static let configuration = CommandConfiguration(
        commandName: "ome",
        abstract: "A Swift command-line tool to parse OpenFestival data",
        subcommands: [Validate.self]
    )


    struct Validate: ParsableCommand {
        static let configuration = CommandConfiguration(
            commandName: "validate",
            abstract: "Parse OpenFestival data from a YAML file"
        )

        @Argument(help: "The path to the openFestival directory to parse")
        var path: String
//
        @Flag(name: .shortAndLong, help: "Enable verbose debug logging")
        var verbose: Bool = false

        func run() throws {
//            if verbose {
//                Logger.cli.debug("Verbose mode enabled")
//            }

            Logger.cli.info("Validating OpenFestival data at path: \(path, privacy: .public)")

            do {
                _ = try OrganizerConfiguration.fileTree.read(from: URL(filePath: path))
                Logger.cli.info("✅ Parsed successfully! This data can be used in the OpenFestival app 🎉")
            } catch {
                Logger.cli.error("❌ Failed to parse: \(error.localizedDescription, privacy: .public)")
                throw error
            }
        }

    }
}
