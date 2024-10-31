//
//  GitLabAccountView.swift
//  GitLab
//
//  Created by Stef Kors on 30/10/2024.
//


import SwiftUI

fileprivate enum SubmitState {
    case readyToSubmit
    case validating
    case success(token: AccessToken)
    case failed
}

struct GitLabAccountView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss

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
                .onChange(of: token, initial: false) { oldValue, newValue in
                    state = .readyToSubmit
                }

            // Menu("Options") {
            TextField("Base URL", text: $instance, prompt: Text("https://www.gitlab.com"))
                .onChange(of: instance, initial: false) { oldValue, newValue in
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
        addAccount()
        dismiss()
    }

    func addAccount() {
        withAnimation {
            let newAccount = Account(token: token, instance: instance, provider: .GitLab)
            modelContext.insert(newAccount)
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
