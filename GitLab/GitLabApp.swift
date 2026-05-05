//
//  GitLabApp.swift
//  GitLab
//
//  Created by Stef Kors on 13/09/2021.
//

import SwiftUI
import SwiftData
import SharingGRDB

//private static func updateDockIcon() {
//    dockContentView.needsDisplay = true
//    NSApp.dockTile.display()
//}
//
//private final class ContentView: NSView {
//    override func draw(_ dirtyRect: CGRect) {
//        NSGraphicsContext.current?.imageInterpolation = .high
//
//        NSApp.applicationIconImage?.draw(in: bounds)
//
//        // TODO: If the `progress` is 1, draw the full circle, then schedule another draw in n milliseconds to hide it
//        guard
//            displayedProgress > 0,
//            displayedProgress < 1
//        else {
//            return
//        }
//
//        switch style {
//        case .bar:
//            drawProgressBar(bounds)
//        case .squircle(let inset, let color):
//            drawProgressSquircle(bounds, inset: inset, color: color)
//        case .circle(let radius, let color):
//            drawProgressCircle(bounds, radius: radius, color: color)
//        case .badge(let color, let badgeValue):
//            drawProgressBadge(bounds, color: color, badgeLabel: badgeValue())
//        case .pie(let color):
//            drawProgressBadge(bounds, color: color, badgeLabel: 0, isPie: true)
//        case .custom(let drawingHandler):
//            drawingHandler(bounds)
//        }
//    }
//}



class AppDelegate: NSObject, NSApplicationDelegate, ObservableObject {
    @AppStorage("Settings.activationPolicy") private var activationPolicy: Bool = false
    /// Setting activation policy to `.prohibited` to prevent it from stealing the current app's focus
    func applicationWillFinishLaunching(_ notification: Notification) {
//        NSApplication.shared.setActivationPolicy(.prohibited)
    }
    /// Setting desired activation policy (`.regular` or `.accessory`) and showing app's windows
    func applicationDidFinishLaunching(_ notification: Notification) {
//        let newActivationPolicy: NSApplication.ActivationPolicy = activationPolicy ? .regular : .accessory
        NSApplication.shared.setActivationPolicy(.regular)
//        WindowManager.shared.show()
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
    @Environment(\.openWindow) private var openWindow
    @Environment(\.dismissWindow) private var dismissWindow

    // Persisted state objects
    @StateObject private var settingsState = SettingsState()

    // Non-Persisted state objects
    @StateObject private var noticeState = NoticeState()
    @StateObject private var networkState = NetworkState()
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
//                .modelContainer(.shared)
                .navigationTitle("GitLab")
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
            //                .presentedWindowBackgroundStyle(.translucent)
        }
        .handlesExternalEvents(matching: ["openNewWindow"])
        .windowToolbarStyle(.unified(showsTitle: true))
        .windowResizability(.contentMinSize)
        .windowIdealSize(.fitToContent)



//        Window("Welcome", id: "Welcome") {
//            Text("Welcome")
//                .modelContainer(.shared)
//                .navigationTitle("GitLab")
//                .toolbarBackgroundVisibility(.hidden, for: .windowToolbar)
//                .containerBackground(.thinMaterial, for: .window)
//            //                .presentedWindowBackgroundStyle(.translucent)
//        }
//        .windowToolbarStyle(.unified(showsTitle: true))
//        .windowResizability(.contentMinSize)
//        .windowIdealSize(.fitToContent)
//        .defaultLaunchBehavior(.presented)

//
        MenuBarExtra(content: {
            UserInterface()
                .environmentObject(noticeState)
                .environmentObject(networkState)
                .environmentObject(settingsState)
                .frame(width: 600)
        }, label: {
            SwiftUI.Label {
                Text("GitLab Desktop")
            } icon: {
                Image(.iconGradientsPNG)
            }
        })
        .menuBarExtraStyle(.window)
        .windowResizability(.contentSize)

        Settings {
            SettingsView()
                .environmentObject(noticeState)
                .environmentObject(networkState)
                .environmentObject(settingsState)
//                .modelContainer(.shared)
                .ignoresSafeArea(.all, edges: .top)
                .navigationTitle("Settings")
                .toolbar(removing: .title)
                .toolbarBackgroundVisibility(.hidden, for: .windowToolbar)
                .containerBackground(.thinMaterial, for: .window)
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
            print("open", path)
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
                //                table.column("accountId", .integer)
                //                    .references(Account.databaseTableName, column: "id", onDelete: .cascade)
                //                    .notNull()
                // Deletes MRs when Account is deleted
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
        //        migrator.registerMigration("Create 'universal_merge_requests' table") { db in
        //
        //        }
        try migrator.migrate(database)
        print("migrator.migrations: \(migrator.migrations)")
        return database
    }
}
