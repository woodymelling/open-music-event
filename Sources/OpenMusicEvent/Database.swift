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
            "organizationURL" INTEGER,
            "name" TEXT NOT NULL,
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
            "eventID" INTEGER,
            "name" TEXT NOT NULL,
            "bio" TEXT,
            "imageURL" TEXT,
            "links" TEXT,
        
            FOREIGN KEY("eventID") REFERENCES "events"("id") ON DELETE CASCADE
        ) STRICT;
        """).execute(db)

        try #sql("""
        CREATE TABLE stages(
            "id" INTEGER PRIMARY KEY AUTOINCREMENT,
            "eventID" INTEGER,
            "name" TEXT NOT NULL,
            "iconImageURL" TEXT,
            
            FOREIGN KEY("eventID") REFERENCES "events"("id") ON DELETE CASCADE
        ) STRICT;
        """).execute(db)


        try #sql("""
        CREATE TABLE schedules(
            "id" INTEGER PRIMARY KEY AUTOINCREMENT,
            "eventID" INTEGER,
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

    try migrator.migrate(database)

    return database
}


