//
//  GitLab_iOSApp.swift
//  GitLab iOS
//
//  Created by Stef Kors on 24/06/2022.
//

import SwiftUI
import UserInterface

@main
struct GitLab_iOSApp: App {
    let model = NetworkManager()
    var body: some Scene {
        WindowGroup {
            UserInterface(model: model)
        }
    }
}
