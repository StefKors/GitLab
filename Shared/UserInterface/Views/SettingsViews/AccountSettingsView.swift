//
//  AccountSettingsView.swift
//
//
//  Created by Stef Kors on 21/07/2022.
//

import SwiftUI

public struct AccountSettingsView: View {
    @EnvironmentObject public var model: NetworkManager

    @AppStorage("apiToken") var apiToken: String = ""

    @State private var tokenInformation: AccessToken? = nil
    @State private var showTokenError: Bool = false

    public var body: some View {
        Form {
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
        .formStyle(.grouped)
    }
}

struct TokenInformationView: View {
    let token: AccessToken?

    var body: some View {
        if let token {
            Grid(alignment: .leading) {
                GridRow {
                    Text("Name:")
                        .foregroundStyle(.secondary)
                    Text("\(token.name ?? "")")
                }

                GridRow {
                    Text("Created at:")
                        .foregroundStyle(.secondary)
                    Text("\(token.createdAt ?? "")")
                }

                GridRow {
                    Text("Last used at:")
                        .foregroundStyle(.secondary)
                    Text("\(token.lastUsedAt ?? "")")
                }

                GridRow {
                    Text("Expires at:")
                        .foregroundStyle(.secondary)
                    Text("\(token.expiresAt ?? "")")
                }

                GridRow {
                    Text("Scopes:")
                        .foregroundStyle(.secondary)
                    HStack {
                        if let scopes = token.scopes {
                            ForEach(scopes, id: \.self) { scope in
                                Text(scope)
                                    .foregroundStyle(.background)
                                    .padding(2)
                                    .background(Color.accentColor, in: RoundedRectangle(cornerRadius: 4))
                            }

                        }
                    }
                }

                GridRow {
                    Text("Revoked:")
                        .foregroundStyle(.secondary)
                    HStack {
                        Text("\(token.revoked?.description ?? "")")
                        if let revoked = token.revoked, revoked {
                            Image(systemName: "checkmark.circle.fill")
                                .foregroundStyle(.green)
                        } else {
                            Image(systemName: "xmark.circle.fill")
                                .foregroundStyle(.red)
                        }
                    }
                }

                GridRow {
                    Text("Active:")
                        .foregroundStyle(.secondary)
                    HStack {
                        Text("\(token.active?.description ?? "")")
                        if let active = token.active, active {
                            Image(systemName: "checkmark.circle.fill")
                                .foregroundStyle(.green)
                        } else {
                            Image(systemName: "xmark.circle.fill")
                                .foregroundStyle(.red)
                        }
                    }
                }
            }.padding(.top).padding(.bottom)
        }
    }
}
