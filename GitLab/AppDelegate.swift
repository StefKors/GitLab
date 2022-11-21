//
//  AppDelegate.swift
//  GitLab
//
//  Created by Stef Kors on 13/09/2021.
//

import SwiftUI
import UserInterface

@main
struct GitLabApp: App {
    @StateObject var networkManager = NetworkManager()
    
    var body: some Scene {
        MenuBarExtra("GitLab Desktop", image: "Icon-Gradients-PNG") {
            MenubarContentView()
                .environmentObject(self.networkManager)
                .environmentObject(self.networkManager.noticeState)
        }
        .menuBarExtraStyle(.window)

        Settings {
            SettingsView()
                .environmentObject(self.networkManager)
                .environmentObject(self.networkManager.noticeState)
        }
    }
}
