//
//  AppDelegate.swift
//  GitLab
//
//  Created by Stef Kors on 13/09/2021.
//

import SwiftUI
import UserInterface
import Preferences
//
// @main
// struct GitLabApp: App {
//     @NSApplicationDelegateAdaptor(AppDelegate.self) private var appDelegate
//
//     var body: some Scene {
//         WindowGroup {
//             if let model = appDelegate.networkManager, appDelegate.networkManager.showAppWindow {
//                 UserInterface(model: model)
//             } else {
//                 Text("test")
//             }
//         }.windowToolbarStyle(.unifiedCompact)
//     }
// }

// macos13 can use MenuBarExtra() instead
@main
class AppDelegate: NSObject, NSApplicationDelegate, ObservableObject, NSMenuDelegate {
    private var appWindow: NSWindow = NSWindow()
    private var statusItem: NSStatusItem!
    private var popover = NSPopover()
    private var statusBarMenu: NSMenu!
    public var networkManager: NetworkManager = NetworkManager()

    @MainActor func applicationDidFinishLaunching(_ notification: Notification) {
        initStatusBarUI()
        initUIBasedOnSettings()
    }

    func applicationShouldHandleReopen(_ sender: NSApplication, hasVisibleWindows flag: Bool) -> Bool {
        return true
    }

    private lazy var settingsWindowController = SettingsWindowController(
        preferencePanes: [
            AccountSettingsViewController(model: self.networkManager),
            AdvancedSettingsViewController(model: self.networkManager)
        ]
    )

    func reopenSettings() {
        settingsWindowController.show()
    }

    fileprivate func initStatusBarUI() {
        statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)

        if let statusButton = statusItem.button {
            let itemImage = NSImage(named: "Icon-Gradients")
            statusButton.image = itemImage
            statusButton.action = #selector(togglePopover)
            statusButton.sendAction(on: [.leftMouseDown, .rightMouseDown])
        }

        self.popover.behavior = NSPopover.Behavior.transient
        self.popover.animates = true

        let view = UserInterface()
            .environmentObject(self.networkManager)
            .environmentObject(self.networkManager.noticeState)
        self.popover.contentViewController = NSHostingController(rootView: view)

        statusBarMenu = NSMenu(title: "Status Bar Menu")
        statusBarMenu.delegate = self
        statusBarMenu.addItem(
            withTitle: "Preferences",
            action: #selector(showPreferences),
            keyEquivalent: ",")

        statusBarMenu.addItem(
            withTitle: "Quit GitLab Widget",
            action: #selector(quitApp),
            keyEquivalent: "q")

    }

    func initUIBasedOnSettings() {
        // Configure macOS dock icon
        let dockImage = Image(self.networkManager.selectedIcon.rawValue)
            .resizable()
            .scaledToFit()
        NSApp.dockTile.contentView = NSHostingView(rootView: dockImage)
        NSApp.dockTile.display()

        // Configure app window
        if self.networkManager.showAppWindow {
            self.appWindow.makeKeyAndOrderFront(nil)
            self.appWindow.isReleasedWhenClosed = false
            self.appWindow.styleMask.insert(NSWindow.StyleMask.fullSizeContentView)
            self.appWindow.styleMask.insert(NSWindow.StyleMask.closable)
            self.appWindow.styleMask.insert(NSWindow.StyleMask.miniaturizable)
            self.appWindow.styleMask.insert(NSWindow.StyleMask.resizable)
            self.appWindow.title = "GitLab Widget"
            let view = UserInterface()
                .environmentObject(self.networkManager)
                .environmentObject(self.networkManager.noticeState)
            self.appWindow.contentViewController = NSHostingController(rootView: view)
            self.appWindow.center()
        }
    }

    @IBAction private func settingsMenuItemActionHandler(_ sender: NSMenuItem) {
        settingsWindowController.show()
    }

    @objc func menuDidClose(_ menu: NSMenu) {
        statusItem.menu = nil // remove menu so button works as before
    }

    @objc func showPreferences() {
        settingsWindowController.show()
    }

    @objc func quitApp() {
        NSApplication.shared.terminate(nil)
    }

    @objc func applicationWillResignActive(_ notification: Notification) {
        print("resign active")
    }

    @objc func togglePopover() {
        if let button = statusItem.button {
            if popover.isShown {
                self.popover.performClose(nil)
                self.popover.resignFirstResponder()
                NSApplication.shared.deactivate()
            } else if let event = NSApp.currentEvent, event.isRightClick {
                statusItem.menu = statusBarMenu // add menu to button...
                statusItem.button?.performClick(nil) // ...and click
            } else {
                NSApplication.shared.activate(ignoringOtherApps: true)
                self.popover.show(relativeTo: button.bounds, of: button, preferredEdge: NSRectEdge.maxY)
                self.popover.contentViewController?.view.window?.makeKey()
            }
        }
    }
}

extension NSEvent {
    var isRightClick: Bool {
        let rightClick = (self.type == .rightMouseDown)
        let controlClick = self.modifierFlags.contains(.control)
        return rightClick || controlClick
    }
}
