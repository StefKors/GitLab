//
//  GitLabAccountView.swift
//  GitLab
//
//  Created by Stef Kors on 30/10/2024.
//

import SwiftUI
import SQLiteData

private enum SubmitState {
    case readyToSubmit
    case validating
    case success(token: AccessToken)
    case failed
}

struct GitLabAccountView: View {
    @Dependency(\.defaultDatabase) private var database
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject private var accountSlotStore: AccountSlotStore
    @EnvironmentObject private var noticeState: NoticeState
    @FetchAll(Account.order(by: { $0.createdAt.desc() })) private var accounts: [Account]

    @State private var token: String = ""
    @State private var instance: String = "https://www.gitlab.com"

    @State private var state: SubmitState = .readyToSubmit

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
        Section {
            TextField("GitLab Token", text: $token, prompt: Text("Enter token here..."))
                .onChange(of: token, initial: false) { _, _ in
                    state = .readyToSubmit
                }

            // Menu("Options") {
            TextField("Base URL", text: $instance, prompt: Text("https://www.gitlab.com"))
                .onChange(of: instance, initial: false) { _, _ in
                    state = .readyToSubmit
                }

            // Button("custom item", action: {})
            // }

            TokenInformationView(token: tokenInformation)

        } header: {
            Text("Account").bold()

            Text("Create a read-only GitLab [access-token](https://gitlab.com/-/profile/personal_access_tokens) that the app can use to query the API with.")
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

            if let validatedToken = await NetworkManagerGitLab.shared.validateToken(instance: instance, token: token) {
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
                    try Account.insert(Account(token: token, instance: instance, provider: .GitLab))
                        .execute(db)
                }
            } catch {
                print("[Add GitLab Account] Failed to add account: \(error.localizedDescription)")
                noticeState.addNotice(
                    notice: NoticeMessage(
                        label: "[Add GitLab Account] \(error.localizedDescription)",
                        type: .error
                    )
                )
            }
        }
    }
}

#Preview {
    Form {
        GitLabAccountView()
    }
    .scenePadding()
    .formStyle(.grouped)
    .textFieldStyle(RoundedBorderTextFieldStyle())
}
