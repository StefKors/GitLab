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
        VStack(alignment: .leading) {
            GroupBox {
                HStack {
                    Text("GitLab Token")
                    VStack(alignment: .leading) {
                        HStack {
                            TextField(
                                "Enter token here...",
                                text: model.$apiToken,
                                onCommit: {
                                    // make API call with token.
                                    Task {
                                        await model.fetch()
                                    }
                                })
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                            Button("Clear API Token", action: {model.apiToken = ""})
                        }

                        Text("Create a read-only GitLab [access-token](https://gitlab.com/-/profile/personal_access_tokens) that the app can")
                            .foregroundColor(.secondary)
                        Text("use to query the API with.")
                            .foregroundColor(.secondary)
                    }
                }.padding()
            }
        }.padding()
    }
}

