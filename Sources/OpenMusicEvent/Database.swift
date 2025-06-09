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
        CREATE TABLE organizers (
            "url" TEXT PRIMARY KEY NOT NULL,
            "name" TEXT NOT NULL,
            "imageURL" TEXT
        ) STRICT;
        """).execute(db)

        try #sql("""
        CREATE TABLE musicEvents(
            "id" INTEGER PRIMARY KEY AUTOINCREMENT,
            "organizerURL" TEXT,
            "name" TEXT NOT NULL,
            "startTime" TEXT,
            "endTime" TEXT,
            "timeZone" TEXT,
            "imageURL" TEXT,
            "siteMapImageURL" TEXT,
            "location" TEXT,
            "contactNumbers" TEXT,
        
            FOREIGN KEY("organizerURL") REFERENCES "organizers"("url") ON DELETE CASCADE
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
            "imageURL" TEXT,
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
            "customTitle" TEXT,
        
            FOREIGN KEY("musicEventID") REFERENCES "musicEvents"("id") ON DELETE CASCADE
        ) STRICT;
        """).execute(db)

        try #sql("""
        CREATE TABLE performances(
            "id" INTEGER PRIMARY KEY AUTOINCREMENT,
            "stageID" INTEGER NOT NULL,
            "scheduleID" INTEGER,
            "title" TEXT NOT NULL,
            "description" TEXT,
            "startTime" TEXT NOT NULL,
            "endTime" TEXT NOT NULL,
        
            FOREIGN KEY("stageID") REFERENCES "stages"("id") ON DELETE CASCADE,
            FOREIGN KEY("scheduleID") REFERENCES "schedules"("id") ON DELETE CASCADE
        ) STRICT;
        """).execute(db)

        try #sql("""
        CREATE TABLE performanceArtists (
            "id" INTEGER PRIMARY KEY AUTOINCREMENT,
            "performanceID" INTEGER NOT NULL,
            "artistID" INTEGER REFERENCES artists(id) ON DELETE CASCADE,
            "anonymousArtistName" TEXT,

            FOREIGN KEY("performanceID") REFERENCES "performances"("id") ON DELETE CASCADE
            FOREIGN KEY("artistID") REFERENCES "artists"("id") ON DELETE CASCADE
        ) STRICT;
        """).execute(db)
    }

    #if DEBUG
    if context == .preview {
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
//        try seed {
//            
//            Organizer.wickedWoods
//            MusicEvent.testival
//            
//            for artist in Artist.previewValues {
//                artist
//            }
//
//            for stage in Stage.previewValues {
//                stage
//            }
//        }
    }
}
#endif

