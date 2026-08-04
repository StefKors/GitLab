//
//  GitLabApp.swift
//  GitLab
//
//  Created by Stef Kors on 13/09/2021.
//

import SwiftUI
import SQLiteData

class AppDelegate: NSObject, NSApplicationDelegate, ObservableObject {
    @AppStorage("Settings.activationPolicy") private var activationPolicy: Bool = false

    /// Setting desired activation policy (`.regular` or `.accessory`) and showing app's windows
    func applicationDidFinishLaunching(_ notification: Notification) {
        let newActivationPolicy: NSApplication.ActivationPolicy = activationPolicy ? .regular : .accessory
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

    init() {
        var startupError: String?
        prepareDependencies {
            do {
                let db = try Self.appDatabase()
                $0.defaultDatabase = db
            } catch {
                startupError = error.localizedDescription
                do {
                    $0.defaultDatabase = try DatabaseQueue()
                } catch {
                    startupError = "Failed to initialize app database: \(error.localizedDescription)"
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

        MenuBarExtra(content: {
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
            let path = URL.documentsDirectory.appending(component: "db.sqlite").path()
            database = try DatabasePool(path: path, configuration: configuration)
        } else {
            database = try DatabaseQueue(configuration: configuration)
        }
        var migrator = DatabaseMigrator()
#if DEBUG
        migrator.eraseDatabaseOnSchemaChange = true
#endif
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

        try migrator.migrate(database)
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
