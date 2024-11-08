//
//  GitLabApp.swift
//  GitLab
//
//  Created by Stef Kors on 13/09/2021.
//

import SwiftUI
import SwiftData


class AppDelegate: NSObject, NSApplicationDelegate{

    func applicationDidFinishLaunching(_ aNotification: Notification) {

    }
//
//    func applicationDidBecomeActive(_ notification: Notification) {
//        NSApp.unhide(self)
//
////        if let wnd = NSApp.windows.first {
////            wnd.makeKeyAndOrderFront(self)
////            wnd.setIsVisible(true)
////        }
//    }

    func application(_ application: NSApplication, open urls: [URL]) {
        print("handle URL", urls)
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

    var body: some Scene {
        Window("GitLab", id: "GitLab-Window") {
            ExtraWindow()
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
            MainGitLabView()
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
