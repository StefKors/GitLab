//
//  GitLab_iOSApp.swift
//  GitLab iOS
//
//  Created by Stef Kors on 24/06/2022.
//

import SwiftUI

@main
struct GitLab_iOSApp: App {
    @StateObject var networkManager = NetworkManager()

    var body: some Scene {
        WindowGroup {
            UserInterface()
                .environmentObject(self.networkManager)
                .environmentObject(self.networkManager.noticeState)
        }
    }
}
