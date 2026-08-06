//
//  GitLabApp.swift
//  GitLab
//
//  Created by Stef Kors on 13/09/2021.
//

import SwiftUI
import SQLiteData
import OSLog

class AppDelegate: NSObject, NSApplicationDelegate, ObservableObject {
    @AppStorage("Settings.activationPolicy") private var activationPolicy: Bool = false

    @Environment(\.isPreview) private var isPreview

    /// Setting desired activation policy (`.regular` or `.accessory`) and showing app's windows
    func applicationDidFinishLaunching(_ notification: Notification) {
        let newActivationPolicy: NSApplication.ActivationPolicy = activationPolicy && !isPreview ? .regular : .accessory
        NSApplication.shared.setActivationPolicy(newActivationPolicy)
    }

    func application(_ application: NSApplication, open urls: [URL]) {
        // open urls clicked in widget in browser
        for url in urls {
            NSWorkspace.shared.open(url)
        }
    }
}

// "Application is background only" run in background?
@main
struct GitLabApp: App {
    @NSApplicationDelegateAdaptor(AppDelegate.self) private var appDelegate

    // Persisted state objects
    @StateObject private var settingsState = SettingsState()

    // Non-Persisted state objects
    @StateObject private var noticeState = NoticeState()
    @StateObject private var networkState = NetworkState()
    @StateObject private var accountSlotStore = AccountSlotStore()
    private let startupDatabaseError: String?

    static let dbInitLogger = Logger(subsystem: "com.stefkors.gitlab", category: "DatabaseInit")

    @Environment(\.isPreview) private var isPreview

    init() {
        var startupError: String?
        prepareDependencies {
            do {
                let db = try Self.appDatabase()
                $0.defaultDatabase = db
                Self.dbInitLogger.info("[MERGERDB] Main app database initialized and ready")
            } catch {
                startupError = error.localizedDescription
                Self.dbInitLogger.error("[MERGERDB] Main app database initialization failed: \(error.localizedDescription, privacy: .public)")
                do {
                    $0.defaultDatabase = try DatabaseQueue()
                    Self.dbInitLogger.warning("[MERGERDB] Main app database fallback to in-memory database")
                } catch {
                    startupError = "Failed to initialize app database: \(error.localizedDescription)"
                    Self.dbInitLogger.fault("[MERGERDB] Main app database in-memory fallback failed: \(error.localizedDescription, privacy: .public)")
                }
            }
        }
        startupDatabaseError = startupError
    }

    var body: some Scene {
        Window("GitLab", id: "GitLab-Window") {
            ExtraWindow()
                .environmentObject(noticeState)
                .environmentObject(networkState)
                .environmentObject(settingsState)
                .environmentObject(accountSlotStore)
                .navigationTitle("Merger")
                .toolbarBackgroundVisibility(.hidden, for: .windowToolbar)
                .containerBackground(.thinMaterial, for: .window)
                .task(id: startupDatabaseError) {
                    guard let startupDatabaseError else { return }
                    noticeState.addNotice(
                        notice: NoticeMessage(
                            label: "Database unavailable, running in degraded mode: \(startupDatabaseError)",
                            type: .error
                        )
                    )
                }
        }
        .handlesExternalEvents(matching: ["openNewWindow"])
        .windowToolbarStyle(.unified(showsTitle: true))
        .windowResizability(.contentMinSize)
        .windowIdealSize(.fitToContent)

        MenuBarExtra(isInserted: .constant(!isPreview), content: {
            MenuBarRootView(
                noticeState: noticeState,
                networkState: networkState,
                settingsState: settingsState,
                accountSlotStore: accountSlotStore
            )
        }, label: {
            MenuBarLabelView()
        })
        .menuBarExtraStyle(.window)
        .windowResizability(.contentSize)

        Settings {
            SettingsView()
                .environmentObject(noticeState)
                .environmentObject(networkState)
                .environmentObject(settingsState)
                .environmentObject(accountSlotStore)
                .ignoresSafeArea(.all, edges: .top)
                .navigationTitle("Settings")
                .toolbar(removing: .title)
                .toolbarBackgroundVisibility(.hidden, for: .windowToolbar)
                .containerBackground(.thinMaterial, for: .window)
                .windowMinimizeBehavior(.disabled)
                .windowResizeBehavior(.disabled)
        }
        .windowResizability(.contentSize)
        .defaultSize(width: 600, height: 500)
        .restorationBehavior(.disabled)
    }

    static func appDatabase() throws -> any DatabaseWriter {
        Self.dbInitLogger.info("[MERGERDB] Main app database initialization starting...")
        let database: any DatabaseWriter
        var configuration = Configuration()
        configuration.foreignKeysEnabled = true
        configuration.prepareDatabase { db in
#if DEBUG
//            db.trace(options: .profile) {
//                print($0.expandedDescription)
//            }
#endif
        }
        @Dependency(\.context) var context
        if context == .live {
            Self.dbInitLogger.info("[MERGERDB] Main app database state: resolving URL (live context)")
            let fileManager = FileManager.default
            let groupIdentifier = "group.com.stefkors.gitlab"
            let legacyURL = URL.documentsDirectory.appending(component: "db.sqlite")
            let sharedURL = fileManager.containerURL(forSecurityApplicationGroupIdentifier: groupIdentifier)?
                .appending(component: "db.sqlite")

            let databaseURL: URL
            if let sharedURL {
                if fileManager.fileExists(atPath: sharedURL.path) {
                    databaseURL = sharedURL
                    Self.dbInitLogger.info("[MERGERDB] Main app database state: using existing shared database")
                } else if fileManager.fileExists(atPath: legacyURL.path) {
                    Self.dbInitLogger.info("[MERGERDB] Main app database state: migrating legacy database to shared container")
                    // Migrate the legacy database (and any WAL/SHM files) into the
                    // shared app group container so the widget extension can read it.
                    let sharedDirectory = sharedURL.deletingLastPathComponent()
                    let legacyDirectory = legacyURL.deletingLastPathComponent()
                    try fileManager.createDirectory(at: sharedDirectory, withIntermediateDirectories: true)
                    let fileNames = try fileManager.contentsOfDirectory(atPath: legacyDirectory.path)
                        .filter { $0.hasPrefix("db.sqlite") }
                    for fileName in fileNames where !fileManager.fileExists(atPath: sharedDirectory.appending(component: fileName).path) {
                        let source = legacyDirectory.appending(component: fileName)
                        let destination = sharedDirectory.appending(component: fileName)
                        try fileManager.moveItem(at: source, to: destination)
                    }
                    databaseURL = sharedURL
                } else {
                    databaseURL = sharedURL
                    Self.dbInitLogger.info("[MERGERDB] Main app database state: creating new shared database")
                }
            } else {
                databaseURL = legacyURL
                Self.dbInitLogger.info("[MERGERDB] Main app database state: shared group unavailable, using legacy documents database")
            }

            Self.dbInitLogger.info("[MERGERDB] Main app database URL: \(databaseURL.path, privacy: .public)")
            Self.dbInitLogger.info("[MERGERDB] Main app database state: file exists = \(fileManager.fileExists(atPath: databaseURL.path), privacy: .public)")
            Self.dbInitLogger.info("[MERGERDB] Main app database state: opening")
            database = try DatabasePool(path: databaseURL.path, configuration: configuration)
            Self.dbInitLogger.info("[MERGERDB] Main app database state: connection opened")
        } else {
            Self.dbInitLogger.info("[MERGERDB] Main app database state: using in-memory database (non-live context)")
            database = try DatabaseQueue(configuration: configuration)
        }

        var migrator = DatabaseMigrator()
#if DEBUG
        migrator.eraseDatabaseOnSchemaChange = true
#endif
        // 
        // // Migration to rename tables from plural to singular to match @Table macro expectations
        // migrator.registerMigration("Rename tables to singular for @Table macro") { db in
        //     // Check if old plural tables exist and rename them to singular
        //     if try db.tableExists("accounts") {
        //         try db.rename(table: "accounts", to: "account")
        //     }
        //     if try db.tableExists("universalMergeRequests") {
        //         try db.rename(table: "universalMergeRequests", to: "universalMergeRequest")
        //     }
        //     if try db.tableExists("launchpadRepos") {
        //         try db.rename(table: "launchpadRepos", to: "launchpadRepo")
        //     }
        // }
        // 
        migrator.registerMigration("Create Account table") { db in
            try db.create(table: Account.tableName) { table in
                table.autoIncrementedPrimaryKey("id")
                table.column("token", .text).notNull()
                table.column("instance", .text).notNull()
                table.column("provider", .jsonb).notNull()
                table.column("createdAt", .datetime).notNull()
            }
        }

        migrator.registerMigration("Create UniversalMergeRequest table") { db in
            try db.create(table: UniversalMergeRequest.tableName) { table in
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
            try db.create(table: LaunchpadRepo.tableName) { table in
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

        Self.dbInitLogger.info("[MERGERDB] Main app database state: migrating")
        try migrator.migrate(database)
        Self.dbInitLogger.info("[MERGERDB] Main app database state: migration complete")

        try database.write { db in
            try db.execute(sql: "SELECT 1")
        }
        Self.dbInitLogger.info("[MERGERDB] Main app database state: connected correctly = true")

        return database
    }
}

private struct MenuBarRootView: View {
    @ObservedObject var noticeState: NoticeState
    @ObservedObject var networkState: NetworkState
    @ObservedObject var settingsState: SettingsState
    @ObservedObject var accountSlotStore: AccountSlotStore

    var body: some View {
        UserInterface()
            .environmentObject(noticeState)
            .environmentObject(networkState)
            .environmentObject(settingsState)
            .environmentObject(accountSlotStore)
            .frame(width: 600)
    }
}

private struct MenuBarLabelView: View {
    var body: some View {
        SwiftUI.Label {
            Text("GitLab Desktop")
        } icon: {
            Image(.merge)
                .symbolVariant(.fill)
        }
    }
}
