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
    @StateObject var networkManager = NetworkManager()

    let container = try! ModelContainer(for: [Account.self, MergeRequest.self])

    var body: some Scene {
        MenuBarExtra(content: {
            MenubarContentView()
                .environmentObject(self.networkManager)
                .environmentObject(self.networkManager.noticeState)
                .modelContainer(container)
        }, label: {
            Label(title: {
                Text("GitLab Desktop")
            }, icon: {
                Image("Icon-Gradients-PNG")
            })
        })

        .menuBarExtraStyle(.window)
        
        Settings {
            SettingsView()
                .environmentObject(self.networkManager)
                .environmentObject(self.networkManager.noticeState)
        }
        .modelContainer(container)
    }
}
