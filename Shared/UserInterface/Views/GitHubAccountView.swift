//
//  GitHubAccountView.swift
//  GitLab
//
//  Created by Stef Kors on 31/10/2024.
//

import SwiftUI
import SQLiteData

private enum SubmitState {
    case readyToSubmit
    case validating
    case success(token: String)
    case failed
}

struct GitHubAccountView: View {
    @Dependency(\.defaultDatabase) private var database
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject private var accountSlotStore: AccountSlotStore
    @EnvironmentObject private var noticeState: NoticeState
    @FetchAll(Account.order(by: { $0.createdAt.desc() })) private var accounts: [Account]

    @State private var token: String = ""
    @State private var instance: String = "https://api.github.com"

    @State private var state: SubmitState = .readyToSubmit

//    var tokenInformation: AccessToken? {
//        if case .success(let token) = state {
//            return token
//        }
//
//        return nil
//    }

    private var enableButton: Bool {
        token.isEmpty || instance.isEmpty
    }

    var body: some View {
        Section {
            TextField("GitHub Token", text: $token, prompt: Text("Enter token here..."))
                .onChange(of: token, initial: false) { _, _ in
                    state = .readyToSubmit
                }

            TextField("Base URL", text: $instance, prompt: Text("https://www.gitlab.com"))
                .onChange(of: instance, initial: false) { _, _ in
                    state = .readyToSubmit
                }

//            TokenInformationView(token: tokenInformation)

        } header: {
            Text("Account").bold()

            Text("Create a classic read-only GitHub [access-token](https://github.com/settings/tokens) that the app can use to query the API with. You need at least repo, workflow, org, and user permissions.")
                .foregroundStyle(.secondary)
        } footer: {
            Button("Close") {
                dismiss()
            }

            switch state {
            case .readyToSubmit:
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

    func handleSubmit() {
        Task {
            withAnimation {
                self.state = .validating
            }

            if !token.isEmpty {
                withAnimation {
                    self.state = .success(token: token)
                }
            } else {
                withAnimation {
                    self.state = .failed
                }
            }

//            if let validatedToken = await NetworkManager.shared.validateToken(instance: instance, token: token) {
//                withAnimation {
//                    self.state = .success(token: validatedToken)
//                }
//            } else {
//                withAnimation {
//                    self.state = .failed
//                }
//            }
        }
    }

    func handleSave() {
        guard accountSlotStore.canAddAccount(currentCount: accounts.count) else {
            noticeState.addNotice(
                notice: NoticeMessage(
                    label: "You have reached the free account limit. Buy another account slot to add more accounts.",
                    type: .error
                )
            )
            return
        }

        addAccount(token: token, instance: instance)
        dismiss()
    }

    func addAccount(token: String, instance: String) {
        Task {
            do {
                try await database.write { db in
                    try Account.insert(Account(token: token, instance: instance, provider: .GitHub))
                        .execute(db)
                }
            } catch {
                print("[Add GitHub Account] Failed to add account: \(error.localizedDescription)")
                noticeState.addNotice(
                    notice: NoticeMessage(
                        label: "[Add GitHub Account] \(error.localizedDescription)",
                        type: .error
                    )
                )
            }
        }
    }
}

#Preview {
    Form {
        GitHubAccountView()
    }
    .scenePadding()
    .formStyle(.grouped)
    .textFieldStyle(RoundedBorderTextFieldStyle())
}
