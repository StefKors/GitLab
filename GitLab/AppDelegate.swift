//
//  AppDelegate.swift
//  GitLab
//
//  Created by Stef Kors on 13/09/2021.
//

import SwiftUI
import UserInterface
import Preferences

@main
struct GitLabApp: App {
    var body: some Scene {
        MenuBarExtra("GitLab Desktop", image: "Icon-Gradients-PNG") {
            MenubarContentView()
        }
        .menuBarExtraStyle(.window)
    }
}
