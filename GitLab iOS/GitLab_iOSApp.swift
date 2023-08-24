//
//  GitLab_iOSApp.swift
//  GitLab iOS
//
//  Created by Stef Kors on 24/06/2022.
//

import SwiftUI
import SwiftData

@main
struct GitLab_iOSApp: App {
    // Non-Persisted state objects
    @StateObject private var noticeState = NoticeState()

    // Persistance objects
    let container = try! ModelContainer(for: [Account.self, MergeRequest.self, LaunchpadRepo.self])

    var body: some Scene {
        WindowGroup {
            UserInterface()
                .environmentObject(self.noticeState)
                .modelContainer(container)
        }
    }
}
