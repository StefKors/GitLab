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

    @Environment(\.openURL) var openURL

    @State var receivedURL: URL?

    @Environment(\.openWindow) private var openWindow
    @Environment(\.dismissWindow) private var dismissWindow

    @State var searchText: String = ""

    var body: some Scene {
        // TODO: close after opening link from widget
        Window("GitLab", id: "GitLab-Window") {
            ExtraWindow()
                .modelContainer(sharedModelContainer)
                .navigationTitle("GitLab")
                .presentedWindowBackgroundStyle(.translucent)
        }
        .windowToolbarStyle(.unified(showsTitle: true))
        .windowResizability(.contentMinSize)
        .windowIdealSize(.fitToContent)

        MenuBarExtra(content: {
            MainGitLabView()
                .modelContainer(sharedModelContainer)
                .frame(width: 600)
                .onOpenURL { url in
                    openURL(url)
                }
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
