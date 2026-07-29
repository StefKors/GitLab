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

// Interactions & open link from widgets https://stackoverflow.com/a/77190038/3199999

/// Shared database accessor for widget extensions
enum WidgetDatabase {
    enum WidgetDatabaseError: LocalizedError {
        case missingDatabase

        var errorDescription: String? {
            switch self {
            case .missingDatabase:
                return "Shared widget database was not found in expected locations."
            }
        }
    }

    /// Candidate shared app-group identifiers.
    static let appGroupIdentifiers: [String] = [
        "com.stefkors.GitLab",
        "group.com.stefkors.GitLab"
    ]

    /// Resolve a database file path from the app group first, then legacy documents path.
    static var resolvedDatabasePath: String? {
        let fileManager = FileManager.default

        for groupIdentifier in appGroupIdentifiers {
            if let groupURL = fileManager.containerURL(forSecurityApplicationGroupIdentifier: groupIdentifier) {
                let candidate = groupURL.appending(component: "db.sqlite").path()
                if fileManager.fileExists(atPath: candidate) {
                    return candidate
                }
            }
        }

        let documentsCandidate = URL.documentsDirectory.appending(component: "db.sqlite").path()
        if fileManager.fileExists(atPath: documentsCandidate) {
            return documentsCandidate
        }

        return nil
    }

    /// Get the database path used by the main app
    static var databasePath: String {
        resolvedDatabasePath ?? URL.documentsDirectory.appending(component: "db.sqlite").path()
    }
    
    /// Create a read-only database connection for widgets
    static func openDatabase() throws -> DatabaseReader {
        var configuration = Configuration()
        configuration.foreignKeysEnabled = true
        configuration.readonly = true
        
        guard let path = resolvedDatabasePath else {
            throw WidgetDatabaseError.missingDatabase
        }
        return try DatabaseQueue(path: path, configuration: configuration)
    }
    
    /// Fetch merge requests filtered by type
    static func fetchMergeRequests(
        type: QueryType,
        limit: Int? = nil,
        database: DatabaseReader
    ) throws -> [UniversalMergeRequest] {
        return try database.read { db in
            // Fetch all merge requests and filter by type in memory
            var allRequests = try UniversalMergeRequest
                .order(Column("createdAt").desc)
                .fetchAll(db)
            
            // Filter by type
            allRequests = allRequests.filter { $0.type == type }
            
            // Apply limit if specified
            if let limit = limit {
                allRequests = Array(allRequests.prefix(limit))
            }
            
            return allRequests
        }
    }
    
    /// Fetch all accounts
    static func fetchAccounts(database: DatabaseReader) throws -> [Account] {
        return try database.read { db in
            try Account.order(Column("createdAt").desc).fetchAll(db)
        }
    }
    
    /// Fetch launchpad repos
    static func fetchRepos(
        limit: Int? = nil,
        database: DatabaseReader
    ) throws -> [LaunchpadRepo] {
        return try database.read { db in
            var request = LaunchpadRepo.order(Column("updatedAt").desc)
            
            if let limit = limit {
                request = request.limit(limit)
            }
            
            return try request.fetchAll(db)
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
        do {
            let database = try WidgetDatabase.openDatabase()
            
            // Fetch accounts first (needed for all widgets)
            let accounts = try WidgetDatabase.fetchAccounts(database: database)
            
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
            
            return SimpleEntry(
                date: Date.now,
                mergeRequests: mergeRequests,
                accounts: accounts,
                repos: repos,
                selectedView: selectedView
            )
        } catch {
            // Return empty data on error - widgets will show empty state
            print("Widget database error: \(error.localizedDescription)")
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
