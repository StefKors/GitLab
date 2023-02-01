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
        case Advanced, Account
    }

    public init() { }
    
    public var body: some View {
        TabView {
            AdvancedSettingsView()
                .tabItem {
                    Image(systemName: "bubbles.and.sparkles.fill")
                        .symbolRenderingMode(.palette)
                        .foregroundStyle(.white, .blue)
                    Text("Advanced")
                    // Label("Advanced", systemImage: "bubbles.and.sparkles.fill")
                }
                .tag(Tabs.Advanced)
            AccountSettingsView()
                .tabItem {
                    Image(systemName: "person.badge.shield.checkmark.fill")
                        .symbolRenderingMode(.palette)
                        .foregroundStyle(.white, .blue)
                    Text("Account")
                    // Label("Account", systemImage: "person.badge.shield.checkmark.fill")
                }
                .tag(Tabs.Account)
        }.frame(minWidth: 500)

    }
}
