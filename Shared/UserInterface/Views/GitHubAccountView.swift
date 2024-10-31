//
//  GitHubAccountView.swift
//  GitLab
//
//  Created by Stef Kors on 31/10/2024.
//

import SwiftUI

fileprivate enum SubmitState {
    case readyToSubmit
    case validating
    case success(token: String)
    case failed
}

struct GitHubAccountView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss

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
                .onChange(of: token, initial: false) { oldValue, newValue in
                    state = .readyToSubmit
                }

            TextField("Base URL", text: $instance, prompt: Text("https://www.gitlab.com"))
                .onChange(of: instance, initial: false) { oldValue, newValue in
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
        addAccount()
        dismiss()
    }

    func addAccount() {
        withAnimation {
            let newAccount = Account(token: token, instance: instance, provider: .GitHub)
            modelContext.insert(newAccount)
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
