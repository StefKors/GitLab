//
//  AccountSettingsView.swift
//
//
//  Created by Stef Kors on 21/07/2022.
//

import SwiftUI
import UserNotifications
import SwiftData

struct AccountRow: View {
    let account: Account
    var body: some View {
        VStack {
            Text(account.instance)
            Text(String(repeating: "⏺", count: account.token.count))
                .lineLimit(1)
                .truncationMode(.middle)
        }
    }
}

#Preview {
    AccountRow(account: .preview)
}

struct AccountListEmptyView: View {
    var body: some View {
        Text("Add your GitLab Account")
    }
}

#Preview {
    AccountListEmptyView()
}

enum SubmitState {
    case disabled
    case validating
    case success(token: AccessToken)
    case failed
}

struct AddAccountView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject public var network: NetworkManager

    @State private var token: String = ""
    @State private var instance: String = "https://www.gitlab.com"

    @State private var state: SubmitState = .disabled



    var tokenInformation: AccessToken? {
        if case .success(let token) = state {
            return token
        }

        return nil
    }

    var enableButton: Bool {
        token.isEmpty || instance.isEmpty
    }

    var body: some View {
        Form {
            Section {
                VStack {
                    TextField("GitLab Token", text: $token, prompt: Text("Enter token here..."))
                        .onChange(of: token, initial: false) { oldValue, newValue in
                            state = .disabled
                        }
                }

                TextField("Base URL", text: $instance, prompt: Text("https://www.gitlab.com"))
                    .onChange(of: instance, initial: false) { oldValue, newValue in
                        state = .disabled
                    }

                TokenInformationView(token: tokenInformation)

            } header: {
                Text("Account").bold()

                Text("Create a read-only GitLab [access-token](https://gitlab.com/-/profile/personal_access_tokens) that the app can use to query the API with.")
                    .foregroundColor(.secondary)
            } footer: {
                Button("Close") {
                    dismiss()
                }


                switch state {
                case .disabled:
                    Button(action: handleSubmit, label: {
                        Text("Submit")
                    })
                    .buttonStyle(.borderedProminent)
                    .disabled(enableButton)
                case .validating:
                    Button(action: {}, label: {
                        Text("Validating...")
                    })
                    .buttonStyle(.bordered)
                    .disabled(true)
                case .success:
                    Button(action: handleSave, label: {
                        Text("Save")
                    })
                    .buttonStyle(.borderedProminent)
                case .failed:
                    Button(role: .destructive, action: handleSubmit, label: {
                        Text("Failed")
                    })
                }
            }
        }
        .scrollDisabled(true)
        .formStyle(.grouped)
        .textFieldStyle(RoundedBorderTextFieldStyle())
        .scenePadding()
    }

    func handleSubmit() {
        Task {
            withAnimation {
                self.state = .validating
            }

            if let validatedToken = await network.validateToken(token: token) {
                withAnimation {
                    self.state = .success(token: validatedToken)
                }
            } else {
                withAnimation {
                    self.state = .failed
                }
            }
        }
    }

    func handleSave() {

    }

    func addAccount() {
        withAnimation {
            let newAccount = Account(token: "", instance: "")
            modelContext.insert(newAccount)
        }
    }
}

#Preview {
    AddAccountView()
}

public struct AccountSettingsView: View {
    @EnvironmentObject public var model: NetworkManager

    @AppStorage("apiToken") var apiToken: String = ""
    @AppStorage("baseURL") var baseURL: String = "https://gitlab.com"

    @State private var tokenInformation: AccessToken? = nil
    @State private var showTokenError: Bool = false

    @Query var accounts: [Account]
    @State private var showCreateSheet: Bool = false

    public var body: some View {
        Form {
            Section("GitLab Token") {
                if accounts.isEmpty {
                    AccountListEmptyView()
                } else {
                    List {
                        ForEach(accounts) { account in
                            AccountRow(account: account)
                        }
                    }
                }
                HStack {
                    Button("Add Account", action: { showCreateSheet.toggle() })
                        .buttonStyle(.borderedProminent)
                }
            }.sheet(isPresented: $showCreateSheet, content: {
                AddAccountView()
                    .interactiveDismissDisabled(false)
                    .presentationCompactAdaptation(.fullScreenCover)
                    // .presentationContentInteraction(.resizes)
            })

            // Section("GitLab Token (old)") {
            //     HStack(alignment: .top) {
            //         Text("GitLab Token")
            //         VStack(alignment: .leading) {
            //             HStack {
            //                 TextField("GitLab Token", text: $apiToken, prompt: Text("Enter token here..."))
            //                     .textFieldStyle(RoundedBorderTextFieldStyle())
            //                     .labelsHidden()
            //                     .onSubmit(of: .text) {
            //                         Task {
            //                             model.tokenExpired = false
            //                             await model.fetch()
            //                         }
            //                     }
            // 
            //                 Button("Update", action: {
            //                     Task {
            //                         model.tokenExpired = false
            //                         await model.fetch()
            //                     }
            //                 })
            // 
            //                 Button("Validate Token", action: {
            //                     Task {
            //                         model.tokenExpired = false
            //                         // if let token = await model.validateToken() {
            //                         //     showTokenError = false
            //                         //     self.tokenInformation = token
            //                         // } else {
            //                         //     showTokenError = true
            //                         // }
            //                     }
            //                 })
            // 
            //                 Button("Clear", action: {
            //                     self.apiToken = ""
            //                 })
            //             }
            // 
            //             Text("Create a read-only GitLab [access-token](https://gitlab.com/-/profile/personal_access_tokens) that the app can")
            //                 .foregroundColor(.secondary)
            //             Text("use to query the API with.")
            //                 .foregroundColor(.secondary)
            // 
            //             TokenInformationView(token: tokenInformation)
            // 
            //             if showTokenError {
            //                 Text("Token validation failed")
            //                     .padding(.top)
            //                     .padding(.bottom)
            //             }
            //         }
            //     }
            // }
            // 
            // Section("Instance") {
            //     TextField("Base URL", text: $baseURL, prompt: Text("Enter token here..."))
            //         .textFieldStyle(RoundedBorderTextFieldStyle())
            //         .onSubmit(of: .text) {
            //             Task {
            //                 model.noticeState.clearNetworkNotices()
            //                 model.tokenExpired = false
            //                 await model.fetch()
            //             }
            //         }
            // 
            //     Button("Reset to Default", action: setDefaultBaseURL)
            // }

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
