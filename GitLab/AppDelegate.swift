//
//  AppDelegate.swift
//  GitLab
//
//  Created by Stef Kors on 13/09/2021.
//

import SwiftUI

@main
struct StocksMenuBarApp: App {
    @NSApplicationDelegateAdaptor(AppDelegate.self) private var appDelegate
    
    var body: some Scene {
        WindowGroup {
            ContentView(model: NetworkManager())
        }.windowStyle(.automatic)
    }
}

// macos13
// @main
// struct UtilityApp: App {
//     var body: some Scene {
//         MenuBarExtra("Utility App", systemImage: "hammer") {
//             AppMenu()
//         }
//     }
// }

class AppDelegate: NSObject, NSApplicationDelegate, ObservableObject {
    
    private var statusItem: NSStatusItem!
    var popover: NSPopover!
    private var networkManager: NetworkManager!
    
    @MainActor func applicationDidFinishLaunching(_ notification: Notification) {
        
        self.networkManager = NetworkManager()
        
        statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)
        
        if let statusButton = statusItem.button {
            statusButton.image = NSImage(named: "Icon")
            statusButton.action = #selector(togglePopover)
        }
        
        self.popover = NSPopover()
        self.popover.contentSize = NSSize(width: 440, height: 260)
        self.popover.behavior = .transient
        self.popover.animates = true
        self.popover.contentViewController = NSHostingController(rootView: ContentView(model: self.networkManager))
    }
    
    @objc func togglePopover() {
        
        Task {
            await self.networkManager.getMRs()
        }
        
        if let button = statusItem.button {
            if popover.isShown {
                self.popover.performClose(nil)
            } else {
                popover.show(relativeTo: button.bounds, of: button, preferredEdge: NSRectEdge.minY)
            }
        }
        
    }
    
}
