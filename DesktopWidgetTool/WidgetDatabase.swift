//
//  WidgetDatabase.swift
//  DesktopWidgetTool
//
//  Created for widget database access
//

import Foundation
import GRDB
import SharingGRDB

/// Shared database accessor for widget extensions
enum WidgetDatabase {
    /// Get the database path used by the main app
    static var databasePath: String {
        URL.documentsDirectory.appending(component: "db.sqlite").path()
    }
    
    /// Create a read-only database connection for widgets
    static func openDatabase() throws -> DatabaseReader {
        var configuration = Configuration()
        configuration.foreignKeysEnabled = true
        configuration.readonly = true
        
        let path = databasePath
        return try DatabaseQueue(path: path, configuration: configuration)
    }
    
    /// Run migrations on the database
    static func migrateDatabase(_ database: DatabaseWriter) throws {
        var migrator = DatabaseMigrator()
        
        migrator.registerMigration("Create Account table") { db in
            try db.create(table: Account.tableName, ifNotExists: true) { table in
                table.autoIncrementedPrimaryKey("id")
                table.column("token", .text).notNull()
                table.column("instance", .text).notNull()
                table.column("provider", .jsonb).notNull()
                table.column("createdAt", .datetime).notNull()
            }
        }
        
        migrator.registerMigration("Create UniversalMergeRequest table") { db in
            try db.create(table: UniversalMergeRequest.tableName, ifNotExists: true) { table in
                table.column("id", .text).notNull().unique()
                table.column("requestID", .text).notNull()
                table.column("createdAt", .datetime).notNull()
                table.column("provider", .jsonb).notNull()
                table.column("mergeRequest", .jsonb)
                table.column("pullRequest", .jsonb)
                table.belongsTo(Account.tableName, onDelete: .cascade).notNull()
                table.column("type", .jsonb)
            }
        }
        
        migrator.registerMigration("Create LaunchpadRepo table") { db in
            try db.create(table: LaunchpadRepo.tableName, ifNotExists: true) { table in
                table.column("id", .text).notNull().unique()
                table.column("name", .text).notNull()
                table.column("image", .blob)
                table.column("imageURL", .jsonb)
                table.column("group", .text).notNull()
                table.column("url", .jsonb).notNull()
                table.column("createdAt", .datetime).notNull()
                table.column("updatedAt", .datetime).notNull()
                table.column("provider", .jsonb)
                table.column("hasUpdatedSinceLaunch", .boolean).notNull().defaults(to: false)
            }
        }
        
        try migrator.migrate(database)
    }
    
    /// Fetch merge requests filtered by type
    static func fetchMergeRequests(
        type: QueryType,
        limit: Int? = nil,
        database: DatabaseReader
    ) throws -> [UniversalMergeRequest] {
        // Fetch all merge requests and filter by type in memory
        // This is simpler than trying to query JSON columns directly
        var allRequests = try UniversalMergeRequest
            .order(Column("createdAt").desc)
            .fetchAll(database)
        
        // Filter by type
        allRequests = allRequests.filter { $0.type == type }
        
        // Apply limit if specified
        if let limit = limit {
            allRequests = Array(allRequests.prefix(limit))
        }
        
        return allRequests
    }
    
    /// Fetch all accounts
    static func fetchAccounts(database: DatabaseReader) throws -> [Account] {
        try Account.order(Column("createdAt").desc).fetchAll(database)
    }
    
    /// Fetch launchpad repos
    static func fetchRepos(
        limit: Int? = nil,
        database: DatabaseReader
    ) throws -> [LaunchpadRepo] {
        var request = LaunchpadRepo.order(Column("updatedAt").desc)
        
        if let limit = limit {
            request = request.limit(limit)
        }
        
        return try request.fetchAll(database)
    }
}
