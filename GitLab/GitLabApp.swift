//
//  GitLabApp.swift
//  GitLab
//
//  Created by Stef Kors on 13/09/2021.
//

import SwiftUI
import SwiftData

@main
struct GitLabApp: App {
    var sharedModelContainer: ModelContainer = .shared

    var body: some Scene {
//        Window("GitLab", id: "GitLab-Window") {
//            MainGitLabView()
//                .modelContainer(sharedModelContainer)
//                .frame(width: 500)
//        }
//        .windowResizability(.contentMinSize)

        MenuBarExtra(content: {
            MainGitLabView()
                .modelContainer(sharedModelContainer)

                .frame(width: 600)
        }, label: {
            Label(title: {
                Text("GitLab Desktop")
            }, icon: {
                Image(.iconGradientsPNG)
            })
        })
        .menuBarExtraStyle(.window)
        .windowResizability(.contentSize)

        Settings {
            SettingsView()
                .modelContainer(sharedModelContainer)
        }
    }
}
