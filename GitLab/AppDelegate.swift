//
//  AppDelegate.swift
//  GitLab
//
//  Created by Stef Kors on 13/09/2021.
//

import SwiftUI
import UserInterface

// @main
// struct GitLabApp: App {
//     @NSApplicationDelegateAdaptor(AppDelegate.self) private var appDelegate
//
//     var body: some Scene {
//         Settings {
//             EmptyView()
//             // SettingsView()
//         }
//     }
// }

// macos13 can use MenuBarExtra() instead
@main
class AppDelegate: NSObject, NSApplicationDelegate, ObservableObject {
    
    private var statusItem: NSStatusItem!
    var popover: NSPopover = NSPopover()
    private var networkManager: NetworkManager!
    
    @MainActor func applicationDidFinishLaunching(_ notification: Notification) {
        
        self.networkManager = NetworkManager()
        
        statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)
        
        if let statusButton = statusItem.button {
            statusButton.image = NSImage(named: "Icon")
            statusButton.action = #selector(togglePopover)
        }

        // statusItem.menu = menu
        self.popover.contentSize = NSSize(width: 440, height: 260)
        self.popover.behavior = .transient
        self.popover.animates = true
        self.popover.contentViewController = NSHostingController(rootView: UserInterface(model: self.networkManager))
    }
    
    @objc func togglePopover() {
        if let button = statusItem.button {
            if popover.isShown {
                self.popover.performClose(nil)
            } else {
                popover.show(relativeTo: button.bounds, of: button, preferredEdge: NSRectEdge.minY)
            }
        }
    }
}

// struct SettingsView: View {
//     private enum Tabs: Hashable {
//         case general, advanced
//     }
//     var body: some View {
//         TabView {
//             GeneralSettingsView()
//                 .tabItem {
//                     Label("General", systemImage: "gear")
//                 }
//                 .tag(Tabs.general)
//             AdvancedSettingsView()
//                 .tabItem {
//                     Label("Advanced", systemImage: "star")
//                 }
//                 .tag(Tabs.advanced)
//         }
//         .padding(20)
//         .frame(width: 375, height: 150)
//     }
// }
//
// struct GeneralSettingsView: View {
//     @StateObject public var model = NetworkManager()
//
//     var body: some View {
//         VStack(alignment: .leading) {
//             Text("GitLab API Token")
//             TextField(
//                 "Enter token here...",
//                 text: model.$apiToken,
//                 onCommit: {
//                     // make API call with token.
//                     Task {
//                         await model.getMRs()
//                     }
//                 })
//             .textFieldStyle(RoundedBorderTextFieldStyle())
//             Spacer()
//             Button("Clear API Token", action: {model.apiToken = ""})
//             Button("Query GitLab", action: {
//                 Task {
//                     await model.getMRs()
//                 }
//             })
//         }
//     }
// }
//
// struct AdvancedSettingsView: View {
//
//     var body: some View {
//         Text("Advanced settings")
//     }
// }
