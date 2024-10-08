//
//  SettingsView.swift
//
//
//  Created by Stef Kors on 21/07/2022.
//

import SwiftUI
import SwiftData

struct SettingsView: View {
    // Persistance objects
    private enum Tabs: Hashable {
        case Account
    }

    init() { }

    var body: some View {
        TabView {
            AccountSettingsView()
                .tabItem {
                    Image(systemName: "person.badge.shield.checkmark.fill")
                    Text("Account")
                }
                .tag(Tabs.Account)
        }
        .frame(idealWidth: 600, idealHeight: 500)
        .navigationTitle("Settings")
    }
}
