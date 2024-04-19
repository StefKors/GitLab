//
//  GitLab_iOSApp.swift
//  GitLab iOS
//
//  Created by Stef Kors on 24/06/2022.
//

import SwiftUI
import SwiftData

@main
struct GitLab_iOSApp: App {
    // Non-Persisted state objects
    @StateObject private var noticeState = NoticeState()

    // Persistance objects
    var sharedModelContainer: ModelContainer = {
        let schema = Schema([Account.self, MergeRequest.self, LaunchpadRepo.self])
        let modelConfiguration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)

        do {
            return try ModelContainer(for: schema, configurations: [modelConfiguration])
        } catch {
            fatalError("Could not create ModelContainer: \(error)")
        }
    }()

    var body: some Scene {
        WindowGroup {
            NavigationView {
                NavigationStack {
                    UserInterface()
                }
                .toolbar {
                    ToolbarItem {
                        NavigationLink {
                            SettingsView()
                        } label: {
                            Label("Settings", systemImage: "gear")
                        }
                    }
                }
            }
            .environmentObject(self.noticeState)
            .modelContainer(sharedModelContainer)
        }
    }
}
