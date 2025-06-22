//
//  GRDB+.swift
//  open-music-event
//
//  Created by Woodrow Melling on 6/22/25.
//

import GRDB
import StructuredQueries

public protocol GRDBDraft:
    EncodableRecord, PersistableRecord, MutablePersistableRecord, TableRecord
{}


public extension GRDBDraft where Self: TableDraft {
static var databaseTableName: String {
        Self.tableName
    }
}

public extension GRDBDraft where Self: MutableIdentifiable, ID: Numeric {
    mutating func didInsert(_ inserted: InsertionSuccess) {
        self.id = .init(exactly: inserted.rowID)!
    }
}

public protocol MutableIdentifiable: Identifiable {
    var id: ID { get set }
}
