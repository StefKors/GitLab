//
//  GitLabApp.swift
//  GitLab
//
//  Created by Stef Kors on 13/09/2021.
//

import SwiftUI
import SwiftData

//https://forums.developer.apple.com/forums/thread/108440
//The only approach that’s compatible with the App Store is a sandboxed login item, as installed by
//
//SMLoginItemSetEnabled
//    . That login item can be a normal app but in most cases you also need IPC between your app and your login item and you can do that using XPC, as illustrated by the AppSandboxLoginItemXPCDemo sample code.
//Share and Enjoy

import AppKit
import OSLog

class AppDelegate: NSObject, NSApplicationDelegate {
    let log = Logger()
    // Needs? "Permitted background task scheduler identifiers"
//    let activity = NSBackgroundActivityScheduler(identifier: "updatecheck")

    var service: BackgroundFetcherProtocol? = nil
    var connection: NSXPCConnection? = nil

    func applicationDidFinishLaunching(_ aNotification: Notification)  {
        let serviceName = "com.stefkors.BackgroundFetcher"
        connection = NSXPCConnection(serviceName: serviceName)
        connection?.remoteObjectInterface = NSXPCInterface(with: BackgroundFetcherProtocol.self)
        connection?.resume()

        service = connection?.remoteObjectProxyWithErrorHandler { error in
            print("Received error:", error)
        } as? BackgroundFetcherProtocol

        service?.startFetching()
    }
}

@main
struct GitLabApp: App {
    @NSApplicationDelegateAdaptor(AppDelegate.self) private var appDelegate

//    private var sharedModelContainer: ModelContainer = .shared

    @State private var receivedURL: URL?
    @State var searchText: String = ""

    @Environment(\.openURL) private var openURL
    @Environment(\.openWindow) private var openWindow
    @Environment(\.dismissWindow) private var dismissWindow

    let log = Logger()

    var body: some Scene {
        // TODO: close after opening link from widget
        Window("GitLab", id: "GitLab-Window") {
            Text("hi")
//            ExtraWindow()
//                .modelContainer(sharedModelContainer)
                .navigationTitle("GitLab")
                .presentedWindowBackgroundStyle(.translucent)
        }
        .windowToolbarStyle(.unified(showsTitle: true))
        .windowResizability(.contentMinSize)
        .windowIdealSize(.fitToContent)

        MenuBarExtra(content: {
//            Text("menu")
            UserInterface()
                .modelContainer(.shared)
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

//        Settings {
//            SettingsView()
//                .modelContainer(sharedModelContainer)
//        }
    }
}
