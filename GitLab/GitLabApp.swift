//
//  GitLabApp.swift
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
        MenuBarExtra(content: {
            MenubarContentView()
                .environmentObject(self.networkManager)
                .environmentObject(self.networkManager.noticeState)
                .buttonStyle(.menubar)
        }, label: {
            Label(title: {
                Text("GitLab Desktop")
            }, icon: {
                Image("Icon-Gradients-PNG")
            })
        })
        // MenuBarExtra("GitLab Desktop", image: "Icon-Gradients-PNG") {
        .menuBarExtraStyle(.window)
        
        Settings {
            SettingsView()
                .environmentObject(self.networkManager)
                .environmentObject(self.networkManager.noticeState)
        }
    }
}
