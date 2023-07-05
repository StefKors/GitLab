//
//  AccountSettingsView.swift
//
//
//  Created by Stef Kors on 21/07/2022.
//

import SwiftUI

public struct AccountSettingsView: View {
    @EnvironmentObject public var model: NetworkManager

    public var body: some View {
        Form {
            HStack(alignment: .top) {
                Text("GitLab Token")
                VStack(alignment: .leading) {
                    HStack {
                        TextField("GitLab Token", text: NetworkManager.$apiToken, prompt: Text("Enter token here..."))
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                            .labelsHidden()
                            .onSubmit(of: .text) {
                                Task {
                                    await model.fetch()
                                }
                            }

                        Button("Update", action: {
                            Task {
                                await model.fetch()
                            }
                        })

                        Button("Clear", action: {NetworkManager.apiToken = ""})
                    }

                    Text("Create a read-only GitLab [access-token](https://gitlab.com/-/profile/personal_access_tokens) that the app can")
                        .foregroundColor(.secondary)
                    Text("use to query the API with.")
                        .foregroundColor(.secondary)
                }
            }
        }
        .formStyle(.grouped)
    }
}

