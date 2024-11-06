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
    // works here
//    var timer = Timer.scheduledTimer(withTimeInterval: 2, repeats: true) {
//        (_) in
//        let log2 = Logger()
//        log2.warning("Jenga 2 (simple timer)")
//    }

    func applicationDidFinishLaunching(_ aNotification: Notification)  {
        print("hi from app delegate")
        print("hi 1")
//        timer.fire()
//        activity.repeats = true
//        activity.interval = 10 // seconds
////        activity.tolerance = 0
////        activity.qualityOfService = .userInitiated
//        print("hi 2")
//        log.warning("Jenga 4")
////        activity.invalidate()
//        activity.schedule { completion in
//            // perform activity
//            if self.activity.shouldDefer {
//                self.log.warning("Jenga 5 (defered)")
//                return completion(.deferred)
//            } else {
//                print("hi 3 from background activity")
//                self.log.warning("Jenga 5 (success)")
//                return completion(.finished)
//            }
//        }

//        activity.invalidate()


        let serviceName = "com.stefkors.BackgroundFetcher"
        connection = NSXPCConnection(serviceName: serviceName)
        connection?.remoteObjectInterface = NSXPCInterface(with: BackgroundFetcherProtocol.self)
        connection?.resume()

        service = connection?.remoteObjectProxyWithErrorHandler { error in
            print("Received error:", error)
        } as? BackgroundFetcherProtocol

        callXPC()
    }

    func callXPC() {


        service?.performCalculation(firstNumber: 122, secondNumber: 20)
    }
}

@main
struct GitLabApp: App {
    @NSApplicationDelegateAdaptor(AppDelegate.self) private var appDelegate

    private var sharedModelContainer: ModelContainer = .shared

    @State private var receivedURL: URL?
    @State var searchText: String = ""

    @Environment(\.openURL) private var openURL
    @Environment(\.openWindow) private var openWindow
    @Environment(\.dismissWindow) private var dismissWindow

    let log = Logger()

    var body: some Scene {
        // TODO: close after opening link from widget
        Window("GitLab", id: "GitLab-Window") {
            ExtraWindow()
                .modelContainer(sharedModelContainer)
                .navigationTitle("GitLab")
                .presentedWindowBackgroundStyle(.translucent)
        }
        .windowToolbarStyle(.unified(showsTitle: true))
        .windowResizability(.contentMinSize)
        .windowIdealSize(.fitToContent)
        .backgroundTask(.urlSession("com.stefkors.GitLab.updatecheck2")) { value in
            log.warning("Jenga 5 (success)")
        }

        MenuBarExtra(content: {
            MainGitLabView()
                .modelContainer(sharedModelContainer)
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

        Settings {
            SettingsView()
                .modelContainer(sharedModelContainer)
        }
    }
}
