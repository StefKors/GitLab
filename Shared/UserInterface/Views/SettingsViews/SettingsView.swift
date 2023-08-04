//
//  SettingsView.swift
//
//
//  Created by Stef Kors on 21/07/2022.
//

import SwiftUI
// import Cocoa

public struct SettingsView: View {
    private enum Tabs: Hashable {
        case Account
    }

    public init() { }

    public var body: some View {
        TabView {
            AccountSettingsView()
                .tabItem {
                    Image(systemName: "person.badge.shield.checkmark.fill")
                    Text("Account")
                }
                .tag(Tabs.Account)
        }
        .frame(width: 600, height: 500)
        .navigationTitle("Settings")
    }
}
