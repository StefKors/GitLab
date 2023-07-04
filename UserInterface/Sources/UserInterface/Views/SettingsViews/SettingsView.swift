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
                }
                .tag(Tabs.Advanced)
            AccountSettingsView()
                .tabItem {
                    Image(systemName: "person.badge.shield.checkmark.fill")
                        .symbolRenderingMode(.palette)
                        .foregroundStyle(.white, .blue)
                    Text("Account")
                }
                .tag(Tabs.Account)
        }.frame(width: 600, height: 300)

    }
}
