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
            .modelContainer(.shared)
        }
    }
}
