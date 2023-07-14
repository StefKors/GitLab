//
//  AccountSettingsView.swift
//
//
//  Created by Stef Kors on 21/07/2022.
//

import SwiftUI
import UserNotifications

public struct AccountSettingsView: View {
    @EnvironmentObject public var model: NetworkManager

    @AppStorage("apiToken") var apiToken: String = ""
    @AppStorage("baseURL") var baseURL: String = "https://gitlab.com"

    @State private var tokenInformation: AccessToken? = nil
    @State private var showTokenError: Bool = false

    public var body: some View {
        Form {
            Section("GitLab Token") {
                HStack(alignment: .top) {
                    Text("GitLab Token")
                    VStack(alignment: .leading) {
                        HStack {
                            TextField("GitLab Token", text: $apiToken, prompt: Text("Enter token here..."))
                                .textFieldStyle(RoundedBorderTextFieldStyle())
                                .labelsHidden()
                                .onSubmit(of: .text) {
                                    Task {
                                        model.tokenExpired = false
                                        await model.fetch()
                                    }
                                }
                            
                            Button("Update", action: {
                                Task {
                                    model.tokenExpired = false
                                    await model.fetch()
                                }
                            })
                            
                            Button("Validate Token", action: {
                                Task {
                                    model.tokenExpired = false
                                    if let token = await model.validateToken() {
                                        showTokenError = false
                                        self.tokenInformation = token
                                    } else {
                                        showTokenError = true
                                    }
                                }
                            })
                            
                            Button("Clear", action: {
                                self.apiToken = ""
                            })
                        }
                        
                        Text("Create a read-only GitLab [access-token](https://gitlab.com/-/profile/personal_access_tokens) that the app can")
                            .foregroundColor(.secondary)
                        Text("use to query the API with.")
                            .foregroundColor(.secondary)
                        
                        TokenInformationView(token: tokenInformation)
                        
                        if showTokenError {
                            Text("Token validation failed")
                                .padding(.top)
                                .padding(.bottom)
                        }
                    }
                }
            }

            Section("Instance") {
                TextField("Base URL", text: $baseURL, prompt: Text("Enter token here..."))
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .onSubmit(of: .text) {
                        Task {
                            model.noticeState.clearNetworkNotices()
                            model.tokenExpired = false
                            await model.fetch()
                        }
                    }

                Button("Reset to Default", action: setDefaultBaseURL)
            }

            Section("Notifications") {
                HStack {
                    Text("Clear all Notifications")
                    Spacer()
                    Button("Clear", action: clearNotifications)
                }

            }
        }
        .formStyle(.grouped)
    }

    func setDefaultBaseURL() {
        self.baseURL = "https://gitlab.com"
        model.noticeState.clearNetworkNotices()
        model.tokenExpired = false
        Task {
            await model.fetch()
        }
    }

    func clearNotifications() {
        let notifs = UNUserNotificationCenter.current()
        notifs.getDeliveredNotifications { delivereds in
            for delivered in delivereds {
                print("has delivered notif \(delivered.description)")
            }
        }

        notifs.getPendingNotificationRequests { pendings in
            for pending in pendings {
                print("has pending notif \(pending.description)")
            }
        }

        notifs.removeAllDeliveredNotifications()
        if #available(macOS 13.0, *) {
            notifs.setBadgeCount(0) { error in
                print("error? \(String(describing: error?.localizedDescription))")
            }
        } else {
            // Fallback on earlier versions
        }
    }
}
