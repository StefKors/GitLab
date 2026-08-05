//
//  DesktopWidgetTool.swift
//  DesktopWidgetTool
//
//  Created by Stef Kors on 06/03/2024.
//

import WidgetKit
import SwiftUI
import GRDB
import SQLiteData
import OSLog

// Interactions & open link from widgets https://stackoverflow.com/a/77190038/3199999

/// Shared database accessor for widget extensions
enum WidgetDatabase {
    static let dbLogger = Logger(subsystem: "com.stefkors.gitlab", category: "WidgetDatabaseInit")

    enum WidgetDatabaseError: LocalizedError {
        case missingDatabase

        var errorDescription: String? {
            switch self {
            case .missingDatabase:
                return "Shared widget database was not found in expected locations."
            }
        }
    }

    /// Shared app group identifier used by the main app and widget.
    static let appGroupIdentifiers: [String] = [
        "group.com.stefkors.gitlab"
    ]

    /// Resolve a database file path from the app group first, then legacy documents path.
    static var resolvedDatabasePath: String? {
        let fileManager = FileManager.default

        for groupIdentifier in appGroupIdentifiers {
            if let groupURL = fileManager.containerURL(forSecurityApplicationGroupIdentifier: groupIdentifier) {
                let candidate = groupURL.appending(component: "db.sqlite").path
                if fileManager.fileExists(atPath: candidate) {
                    return candidate
                }
            }
        }

        let documentsCandidate = URL.documentsDirectory.appending(component: "db.sqlite").path
        if fileManager.fileExists(atPath: documentsCandidate) {
            return documentsCandidate
        }

        return nil
    }

    /// Get the database path used by the main app
    static var databasePath: String {
        resolvedDatabasePath ?? URL.documentsDirectory.appending(component: "db.sqlite").path
    }

    /// Create a read-only database connection for widgets
    static func openDatabase() throws -> DatabaseReader {
        WidgetDatabase.dbLogger.info("[MERGERDB] Widget database initialization starting...")
        var configuration = Configuration()
        configuration.foreignKeysEnabled = true
        configuration.readonly = true

        let path = databasePath
        WidgetDatabase.dbLogger.info("[MERGERDB] Widget database resolved path: \(path, privacy: .public)")
        let fileExists = FileManager.default.fileExists(atPath: path)
        WidgetDatabase.dbLogger.info("[MERGERDB] Widget database state: file exists = \(fileExists, privacy: .public)")
        guard fileExists else {
            WidgetDatabase.dbLogger.error("[MERGERDB] Widget database error: missing database at \(path, privacy: .public)")
            throw WidgetDatabaseError.missingDatabase
        }

        WidgetDatabase.dbLogger.info("[MERGERDB] Widget database state: opening")
        do {
            let reader = try DatabasePool(path: path, configuration: configuration)
            WidgetDatabase.dbLogger.info("[MERGERDB] Widget database state: connection opened")

            // Verify the connection is usable and check table counts
            try reader.read { db in
                try db.execute(sql: "SELECT 1")



                // Check table counts for debugging - use custom tableName properties
                let accountCount = try Int.fetchOne(db, sql: "SELECT COUNT(*) FROM \(Account.tableName)") ?? 0
                WidgetDatabase.dbLogger.info("[MERGERDB] executed sql: SELECT COUNT(*) FROM \(Account.tableName)")
                let mrCount = try Int.fetchOne(db, sql: "SELECT COUNT(*) FROM \(UniversalMergeRequest.tableName)") ?? 0
                WidgetDatabase.dbLogger.info("[MERGERDB] executed sql: SELECT COUNT(*) FROM \(UniversalMergeRequest.tableName)")
                let repoCount = try Int.fetchOne(db, sql: "SELECT COUNT(*) FROM \(LaunchpadRepo.tableName)") ?? 0
                WidgetDatabase.dbLogger.info("[MERGERDB] executed sql: SELECT COUNT(*) FROM \(LaunchpadRepo.tableName)")
            }
            WidgetDatabase.dbLogger.info("[MERGERDB] Widget database state: connected correctly = true")

            return reader
        } catch {
            WidgetDatabase.dbLogger.error("[MERGERDB] Widget database error: \(error.localizedDescription, privacy: .public)")
            throw error
        }
    }
    
    /// Fetch merge requests filtered by type
    static func fetchMergeRequests(
        type: QueryType,
        limit: Int? = nil,
        database: DatabaseReader
    ) throws -> [UniversalMergeRequest] {
        WidgetDatabase.dbLogger.info("[MERGERDB] Widget fetching merge requests with type: \(type.rawValue), limit: \(limit ?? 0)")
        return try database.read { db in
            // Fetch all merge requests and filter by type in memory
            var allRequests = try UniversalMergeRequest.fetchAll(db, sql: "SELECT * FROM \(UniversalMergeRequest.tableName)")
            // var allRequests = try UniversalMergeRequest
            //     .order(Column("createdAt").desc)
            //     .fetchAll(db)
            
            WidgetDatabase.dbLogger.info("[MERGERDB] Widget fetched \(allRequests.count) total merge requests from database")
            
            // Debug: show types of fetched MRs
            let typeCounts = Dictionary(grouping: allRequests, by: { $0.type }).mapValues { $0.count }
            WidgetDatabase.dbLogger.info("[MERGERDB] Widget MR type distribution: \(typeCounts)")
            
            // Filter by type
            allRequests = allRequests.filter { $0.type == type }
            WidgetDatabase.dbLogger.info("[MERGERDB] Widget filtered to \(allRequests.count) merge requests with type: \(type.rawValue)")

            // Apply limit if specified
            if let limit = limit {
                allRequests = Array(allRequests.prefix(limit))
                WidgetDatabase.dbLogger.info("[MERGERDB] Widget limited to \(allRequests.count) merge requests")
            }
            
            return allRequests
        }
    }
    
    /// Fetch all accounts
    static func fetchAccounts(database: DatabaseReader) throws -> [Account] {
        WidgetDatabase.dbLogger.info("[MERGERDB] Widget fetching accounts")
        let accounts = try database.read { db in
            try Account.fetchAll(db, sql: "SELECT * FROM \(Account.tableName)")
        }
        WidgetDatabase.dbLogger.info("[MERGERDB] Widget fetched \(accounts.count) accounts from database")
        return accounts
    }
    
    /// Fetch launchpad repos
    static func fetchRepos(
        limit: Int? = nil,
        database: DatabaseReader
    ) throws -> [LaunchpadRepo] {
        WidgetDatabase.dbLogger.info("[MERGERDB] Widget fetching repos with limit: \(limit ?? 0)")
        return try database.read { db in
            // var request = LaunchpadRepo.order(Column("updatedAt").desc)
            let repos = try LaunchpadRepo.fetchAll(db, sql: "SELECT * FROM \(LaunchpadRepo.tableName)")

            // if let limit = limit {
            //     request = request.limit(limit)
            // }
            // 
            // let repos = try request.fetchAll(db)
            WidgetDatabase.dbLogger.info("[MERGERDB] Widget fetched \(repos.count) repos from database")
            return repos
        }
    }
}

struct Provider: TimelineProvider {
    var selectedView: QueryType

    func placeholder(in context: Context) -> SimpleEntry {
        SimpleEntry(
            date: Date(),
            mergeRequests: [.preview, .preview, .preview, .preview],
            accounts: [.preview],
            repos: [],
            selectedView: .authoredMergeRequests
        )
    }

    func getSnapshot(in context: Context, completion: @escaping (SimpleEntry) -> Void) {
        Task {
            let entry = await loadEntry()
            completion(entry)
        }
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<SimpleEntry>) -> Void) {
        Task {
            let now = Date.now
            let entry = await loadEntry()
            
            // Refresh every 15 minutes for timely updates, or sooner if no data
            let refreshInterval: TimeInterval = entry.mergeRequests.isEmpty && entry.accounts.isEmpty ? 5 * 60 : 15 * 60
            let nextUpdate = Calendar.current.date(byAdding: .second, value: Int(refreshInterval), to: now) ?? now.addingTimeInterval(refreshInterval)
            let timeline = Timeline(entries: [entry], policy: .after(nextUpdate))
            completion(timeline)
        }
    }
    
    /// Load entry data from database
    private func loadEntry() async -> SimpleEntry {
        WidgetDatabase.dbLogger.info("[MERGERDB] Widget loadEntry starting for selectedView: \(selectedView.rawValue)")
        do {
            let database = try WidgetDatabase.openDatabase()
            let accounts = try await database.read { db in
                try Account.order(Column("createdAt").desc).fetchAll(db)
            }

            // Fetch data based on widget type
            let mergeRequests: [UniversalMergeRequest]
            let repos: [LaunchpadRepo]
            
            if selectedView == .authoredMergeRequests || selectedView == .reviewRequestedMergeRequests {
                // For MR widgets, fetch merge requests filtered by type
                // Limit based on widget size needs (we'll show up to 5-10 items)
                let limit = 25 // Fetch a bit more than needed for filtering
                mergeRequests = try WidgetDatabase.fetchMergeRequests(
                    type: selectedView,
                    limit: limit,
                    database: database
                )
                // Fetch repos for context (limit to most recent)
                repos = try WidgetDatabase.fetchRepos(limit: 10, database: database)
            } else {
                // For launchpad widget, fetch repos
                mergeRequests = []
                repos = try WidgetDatabase.fetchRepos(limit: 20, database: database)
            }
            
            WidgetDatabase.dbLogger.info("[MERGERDB] Widget loadEntry completed: \(accounts.count) accounts, \(mergeRequests.count) MRs, \(repos.count) repos")
            
            return SimpleEntry(
                date: Date.now,
                mergeRequests: mergeRequests,
                accounts: accounts,
                repos: repos,
                selectedView: selectedView
            )
        } catch {
            // Return empty data on error - widgets will show empty state
            WidgetDatabase.dbLogger.error("[MERGERDB] Widget loadEntry failed: \(error.localizedDescription, privacy: .public)")
            return SimpleEntry(
                date: Date.now,
                mergeRequests: [],
                accounts: [],
                repos: [],
                selectedView: selectedView
            )
        }
    }
}

struct SimpleEntry: TimelineEntry {
    let date: Date
    let mergeRequests: [UniversalMergeRequest]
    let accounts: [Account]
    let repos: [LaunchpadRepo]
    let selectedView: QueryType
}

extension SimpleEntry {
    static let preview = SimpleEntry(
        date: .distantFuture,
        mergeRequests: [.preview, .preview, .preview, .preview],
        accounts: [.preview],
        repos: [],
        selectedView: .authoredMergeRequests
    )
}

struct AuthoredMergeRequestWidget: Widget {
    var body: some WidgetConfiguration {
        StaticConfiguration(kind: "AuthoredMergeRequestWidget", provider: Provider(selectedView: .authoredMergeRequests)) { entry in
            MergeRequestWidgetEntryView(entry: entry)
                .frame(maxHeight: .infinity, alignment: .top)
                .containerBackground(.thickMaterial, for: .widget)
                .isInWidget(true)
        }
        .configurationDisplayName("Authored Merge Requests")
        .description("All your Authored Merge Requests directly visible.")
        .supportedFamilies([.systemSmall, .systemMedium, .systemLarge, .systemExtraLarge])
    }
}

struct ReviewRequestedMergeRequestWidget: Widget {
    var body: some WidgetConfiguration {
        StaticConfiguration(kind: "ReviewRequestedMergeRequestWidget", provider: Provider(selectedView: .reviewRequestedMergeRequests)) { entry in
            MergeRequestWidgetEntryView(entry: entry)
                .frame(maxHeight: .infinity, alignment: .top)
                .containerBackground(.thickMaterial, for: .widget)
                .isInWidget(true)
        }
        .configurationDisplayName("Review Requested Merge Requests")
        .description("Merge Requests you should review.")
        .supportedFamilies([.systemSmall, .systemMedium, .systemLarge, .systemExtraLarge])
    }
}

struct LaunchPadWidget: Widget {
    var body: some WidgetConfiguration {
        StaticConfiguration(kind: "LaunchpadWidget", provider: LaunchPadProvider()) { entry in
            LaunchPadWidgetEntryView(entry: entry)
                .frame(maxHeight: .infinity, alignment: .top)
                .containerBackground(.thickMaterial, for: .widget)
                .isInWidget(true)
        }
        .configurationDisplayName("Repo Launchpad")
        .description("Quick access to your recently used Repositories")
        .supportedFamilies([.systemSmall, .systemMedium])
    }
}

/// Specialized provider for LaunchPad widget that only loads repos
struct LaunchPadProvider: TimelineProvider {
    func placeholder(in context: Context) -> SimpleEntry {
        SimpleEntry(
            date: Date(),
            mergeRequests: [],
            accounts: [.preview],
            repos: [.preview, .preview2, .preview3],
            selectedView: .authoredMergeRequests
        )
    }
    
    func getSnapshot(in context: Context, completion: @escaping (SimpleEntry) -> Void) {
        Task {
            let entry = await loadEntry()
            completion(entry)
        }
    }
    
    func getTimeline(in context: Context, completion: @escaping (Timeline<SimpleEntry>) -> Void) {
        Task {
            let now = Date.now
            let entry = await loadEntry()
            
            // Refresh every 30 minutes for launchpad, or sooner if no repos
            let refreshInterval: TimeInterval = entry.repos.isEmpty ? 10 * 60 : 30 * 60
            let nextUpdate = Calendar.current.date(byAdding: .second, value: Int(refreshInterval), to: now) ?? now.addingTimeInterval(refreshInterval)
            let timeline = Timeline(entries: [entry], policy: .after(nextUpdate))
            completion(timeline)
        }
    }
    
    private func loadEntry() async -> SimpleEntry {
        do {
            let database = try WidgetDatabase.openDatabase()
            let accounts = try WidgetDatabase.fetchAccounts(database: database)
            let repos = try WidgetDatabase.fetchRepos(limit: 20, database: database)
            
            return SimpleEntry(
                date: Date.now,
                mergeRequests: [],
                accounts: accounts,
                repos: repos,
                selectedView: .authoredMergeRequests
            )
        } catch {
            print("LaunchPad widget database error: \(error.localizedDescription)")
            return SimpleEntry(
                date: Date.now,
                mergeRequests: [],
                accounts: [],
                repos: [],
                selectedView: .authoredMergeRequests
            )
        }
    }
}
