//
//  SettingsView.swift
//
//
//  Created by Stef Kors on 21/07/2022.
//

import SwiftUI
import SwiftData

struct SettingsView: View {

    private enum Tabs: String, Hashable, CaseIterable {
        case general
        case account
    }


    @State private var selectedTab: Tabs = .general

    var body: some View {
        HStack(alignment: .top, spacing: 0) {
            List(Tabs.allCases, id: \.rawValue, selection: $selectedTab) { tab in
                switch tab {
                case .general: Label(tab.rawValue.capitalized, systemImage: "gear").tag(tab)
                case .account: Label(tab.rawValue.capitalized, systemImage: "person.2.fill").tag(tab)
                }
            }
            .scrollContentBackground(.hidden)
            .listStyle(.sidebar)
            .frame(width: 180)
            .padding(.top, 20)

            Divider()

            ZStack {
                switch selectedTab {
                case .general: GeneralSettingsView()
                case .account: AccountSettingsView()
                }
            }
            //            .ignoresSafeArea()
            .navigationTitle(selectedTab.rawValue.capitalized)
        }
    }
}

#Preview {
    SettingsView()
}
