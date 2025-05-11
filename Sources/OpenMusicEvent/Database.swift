//
//  Database.swift
//  open-music-event
//
//  Created by Woodrow Melling on 5/4/25.
//

import SharingGRDB
import Foundation
import OSLog

private let logger = Logger(
    subsystem: "OpenMusicEvent",
    category: "Database"
)

func appDatabase() throws -> any DatabaseWriter {
    print("Preparing Database")
    let database: any DatabaseWriter
    var configuration = Configuration()

    configuration.foreignKeysEnabled = true

    configuration .prepareDatabase { db in
        #if DEBUG
        db.trace(options: .profile) {
            logger.debug("\($0.expandedDescription)")
        }
        #endif
    }

    @Dependency(\.context) var context
    switch context {
    case .live:
        let path = URL.documentsDirectory
            .appending(component: "db.sqlite")
            .path()

        logger.info("open \(path)")

        database = try DatabasePool(path: path, configuration: configuration)
    case .preview, .test:
        database = try DatabaseQueue(configuration: configuration)
    }

    var migrator = DatabaseMigrator()
    #if DEBUG
    migrator.eraseDatabaseOnSchemaChange = true
    #endif
    migrator.registerMigration("Create tables") { db in
        try #sql("""
        CREATE TABLE organizations (
            "url" TEXT PRIMARY KEY NOT NULL,
            "name" TEXT NOT NULL,
            "imageURL" TEXT
        ) STRICT;
        """).execute(db)

        try #sql("""
        CREATE TABLE musicEvents(
            "id" INTEGER PRIMARY KEY AUTOINCREMENT,
            "organizationURL" TEXT,
            "name" TEXT NOT NULL,
            "startTime" TEXT,
            "endTime" TEXT,
            "timeZone" TEXT,
            "imageURL" TEXT,
            "siteMapImageURL" TEXT,
            "location" TEXT,
            "contactNumbers" TEXT,
        
            FOREIGN KEY("organizationURL") REFERENCES "organizations"("url") ON DELETE CASCADE
        ) STRICT;
        """).execute(db)

        try #sql("""
        CREATE TABLE artists(
            "id" INTEGER PRIMARY KEY AUTOINCREMENT,
            "musicEventID" INTEGER,
            "name" TEXT NOT NULL,
            "bio" TEXT,
            "imageURL" TEXT,
            "links" TEXT,
        
            FOREIGN KEY("musicEventID") REFERENCES "musicEvents"("id") ON DELETE CASCADE
        ) STRICT;
        """).execute(db)

        try #sql("""
        CREATE TABLE stages(
            "id" INTEGER PRIMARY KEY AUTOINCREMENT,
            "musicEventID" INTEGER,
            "name" TEXT NOT NULL,
            "iconImageURL" TEXT,
            "color" INTEGER NOT NULL,
            
            FOREIGN KEY("musicEventID") REFERENCES "musicEvents"("id") ON DELETE CASCADE
        ) STRICT;
        """).execute(db)


        try #sql("""
        CREATE TABLE schedules(
            "id" INTEGER PRIMARY KEY AUTOINCREMENT,
            "musicEventID" INTEGER,
            "startTime" TEXT,
            "endTime" TEXT,
            "customTitle" TEXT
        ) STRICT;
        """).execute(db)

        try #sql("""
        CREATE TABLE performances(
            "id" INTEGER PRIMARY KEY AUTOINCREMENT,
            "stageID" INTEGER NOT NULL,
            "scheduleID" INTEGER,
            "customTitle" TEXT,
            "description" TEXT,
            "startTime" TEXT NOT NULL,
            "endTime" TEXT NOT NULL,
        
            FOREIGN KEY("stageID") REFERENCES "stages"("id") ON DELETE CASCADE
        ) STRICT;
        """).execute(db)

        try #sql("""
        CREATE TABLE performance_artists (
            "performanceID" INTEGER NOT NULL REFERENCES performances(id) ON DELETE CASCADE,
            "artistID" INTEGER REFERENCES artists(id) ON DELETE SET NULL,
            "anonymousArtistName" TEXT,

            CHECK(
                (artistID IS NOT NULL AND anonymousArtistName IS NULL) OR
                (artistID IS NULL AND anonymousArtistName IS NOT NULL)
            ),

            PRIMARY KEY (performanceID, artistID, anonymousArtistName)
        ) STRICT;
        """).execute(db)
    }

    #if DEBUG
    if context != .test {
        migrator.registerMigration("Seed sample data") { db in
            try db.seedSampleData()
        }
    }
    #endif

    try migrator.migrate(database)

    return database
}


#if DEBUG
extension Database {
    func seedSampleData() throws {
        logger.log("Seeding sample data...")
        try seed {
            
            Organization.ome
            MusicEvent.testival
            
            for artist in Artist.previewValues {
                artist
            }

            for stage in Stage.previewValues {
                stage
            }
        }
    }
}
#endif

