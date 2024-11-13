//
//  GitLabApp.swift
//  GitLab
//
//  Created by Stef Kors on 13/09/2021.
//

import SwiftUI
import SwiftData

//private static func updateDockIcon() {
//    dockContentView.needsDisplay = true
//    NSApp.dockTile.display()
//}
//
//private final class ContentView: NSView {
//    override func draw(_ dirtyRect: CGRect) {
//        NSGraphicsContext.current?.imageInterpolation = .high
//
//        NSApp.applicationIconImage?.draw(in: bounds)
//
//        // TODO: If the `progress` is 1, draw the full circle, then schedule another draw in n milliseconds to hide it
//        guard
//            displayedProgress > 0,
//            displayedProgress < 1
//        else {
//            return
//        }
//
//        switch style {
//        case .bar:
//            drawProgressBar(bounds)
//        case .squircle(let inset, let color):
//            drawProgressSquircle(bounds, inset: inset, color: color)
//        case .circle(let radius, let color):
//            drawProgressCircle(bounds, radius: radius, color: color)
//        case .badge(let color, let badgeValue):
//            drawProgressBadge(bounds, color: color, badgeLabel: badgeValue())
//        case .pie(let color):
//            drawProgressBadge(bounds, color: color, badgeLabel: 0, isPie: true)
//        case .custom(let drawingHandler):
//            drawingHandler(bounds)
//        }
//    }
//}



class AppDelegate: NSObject, NSApplicationDelegate, ObservableObject {
    @AppStorage("Settings.activationPolicy") private var activationPolicy: Bool = false
    /// Setting activation policy to `.prohibited` to prevent it from stealing the current app's focus
    func applicationWillFinishLaunching(_ notification: Notification) {
        NSApplication.shared.setActivationPolicy(.prohibited)
    }
    /// Setting desired activation policy (`.regular` or `.accessory`) and showing app's windows
    func applicationDidFinishLaunching(_ notification: Notification) {
        let newActivationPolicy: NSApplication.ActivationPolicy = activationPolicy ? .regular : .accessory
        NSApplication.shared.setActivationPolicy(newActivationPolicy)
//        WindowManager.shared.show()
    }

    func application(_ application: NSApplication, open urls: [URL]) {
        // open urls clicked in widget in browser
        for url in urls {
            NSWorkspace.shared.open(url)
        }
    }
}

// "Application is background only" run in background?
@main
struct GitLabApp: App {
    @NSApplicationDelegateAdaptor(AppDelegate.self) private var appDelegate
    @Environment(\.openWindow) private var openWindow
    @Environment(\.dismissWindow) private var dismissWindow

    // Persisted state objects
    @StateObject private var settingsState = SettingsState()

    // Non-Persisted state objects
    @StateObject private var noticeState = NoticeState()
    @StateObject private var networkState = NetworkState()

    var body: some Scene {
        Window("GitLab", id: "GitLab-Window") {
            ExtraWindow()
                .environmentObject(noticeState)
                .environmentObject(networkState)
                .environmentObject(settingsState)
                .modelContainer(.shared)
                .navigationTitle("GitLab")
                .toolbarBackgroundVisibility(.hidden, for: .windowToolbar)
                .containerBackground(.thinMaterial, for: .window)
            //                .presentedWindowBackgroundStyle(.translucent)
        }
        .handlesExternalEvents(matching: ["openNewWindow"])
        .windowToolbarStyle(.unified(showsTitle: true))
        .windowResizability(.contentMinSize)
        .windowIdealSize(.fitToContent)



//        Window("Welcome", id: "Welcome") {
//            Text("Welcome")
//                .modelContainer(.shared)
//                .navigationTitle("GitLab")
//                .toolbarBackgroundVisibility(.hidden, for: .windowToolbar)
//                .containerBackground(.thinMaterial, for: .window)
//            //                .presentedWindowBackgroundStyle(.translucent)
//        }
//        .windowToolbarStyle(.unified(showsTitle: true))
//        .windowResizability(.contentMinSize)
//        .windowIdealSize(.fitToContent)
//        .defaultLaunchBehavior(.presented)


        MenuBarExtra(content: {
            UserInterface()
                .environmentObject(noticeState)
                .environmentObject(networkState)
                .environmentObject(settingsState)
                .modelContainer(.shared)
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
                .environmentObject(noticeState)
                .environmentObject(networkState)
                .environmentObject(settingsState)
                .modelContainer(.shared)
                .ignoresSafeArea(.all, edges: .top)
                .navigationTitle("Settings")
                .toolbar(removing: .title)
                .toolbarBackgroundVisibility(.hidden, for: .windowToolbar)
                .containerBackground(.thinMaterial, for: .window)
                .containerBackground(.thinMaterial, for: .window)
                .windowMinimizeBehavior(.disabled)
                .windowResizeBehavior(.disabled)
        }
        .windowResizability(.contentSize)
        .defaultSize(width: 600, height: 400)
        .restorationBehavior(.disabled)

    }
}
