//
//  GeneralSettingsView.swift
//  GitLab
//
//  Created by Stef Kors on 08/11/2024.
//

import SwiftUI
import LaunchAtLogin

struct GeneralSettingsView: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            SettingsTitleView(label: "General", systemImage: "gear", fill: .gray.darker(by: 15))
                .padding()
//                .padding(.horizontal)
                .padding(.leading, 4)

            Divider()

            Form {
                Section {
                    LaunchAtLogin.Toggle()
                } header: {
                    Text("System")
                        .foregroundStyle(.secondary)
                }

            }
            .formStyle(.grouped)
            .groupBoxStyle(PlainGroupBoxStyle())
        }
    }
}

#Preview {
    GeneralSettingsView()
}
