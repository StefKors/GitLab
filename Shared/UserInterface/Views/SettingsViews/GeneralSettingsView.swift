//
//  GeneralSettingsView.swift
//  GitLab
//
//  Created by Stef Kors on 08/11/2024.
//

import SwiftUI
import LaunchAtLogin

enum RequestLanguageType: String, Codable, CaseIterable, Identifiable {
    case mergeRequest = "Merge Request"
    case pullRequest = "Pull Request"
    case auto = "Automatic"
    var id: Self { self }
}


struct GeneralSettingsView: View {
    @EnvironmentObject private var settings: SettingsState

    @State private var isSettingActivationPolicy: Bool = false

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
                    Toggle(isOn: $settings.showShareButton) { Text("Show share button") }

                    Toggle(isOn: $settings.showShareButton) { Text("Show share button") }

                    Toggle(isOn: $settings.activationPolicy) { Text("Enable dock icon") }
                        .disabled(isSettingActivationPolicy)
                        .onChange(of: settings.activationPolicy) { isOn in
                            isSettingActivationPolicy = true
                            /// Wait until the dock icon's appearance/disappearance animation completes before allowing to toggle it again.
                            /// Otherwise, there is a chance of having multiple app icons in the dock :)
                            Task {
                                try? await Task.sleep(nanoseconds: NSEC_PER_MSEC * 150)
                                isSettingActivationPolicy = false
                            }
                        }

                    Button("Hide or Show Dock Icon") {

                    }
                } header: {
                    Text("System")
                        .foregroundStyle(.secondary)
                }

                Section {
                    VStack(alignment: .leading) {
                        Picker(selection: $settings.requestLanguage, content: {
                            ForEach(RequestLanguageType.allCases) { type in
                                if type == .auto {
                                    HStack {
                                        Text(type.rawValue) + Text(" (\(settings.language.rawValue))").foregroundStyle(.secondary)
                                    }
                                    .tag(type)
                                } else {
                                    Text(type.rawValue).tag(type)
                                }

                            }
                        }, label: {
                            Text("Request type")
                        })

                        HStack {
                            Text("Automatic uses the right naming convention based on the first configured account.")
                                .foregroundStyle(.secondary)
                                .font(.callout)
                            Spacer(minLength: 80)
                                .background(.red)
                        }
                    }
                } header: {
                    Text("Language")
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
