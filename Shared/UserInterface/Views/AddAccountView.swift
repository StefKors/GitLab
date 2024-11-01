//
//  AddAccountView.swift
//  GitLab
//
//  Created by Stef Kors on 10/08/2023.
//

import SwiftUI

struct AddAccountView: View {
    @State private var selectedView: GitProvider = .GitHub

    var body: some View {
        VStack {
            Picker(selection: $selectedView, content: {
                Text("GitHub").tag(GitProvider.GitHub)
                Text("GitLab").tag(GitProvider.GitLab)
            }, label: {
                EmptyView()
            })
            .pickerStyle(.segmented)

            Form {
                if selectedView == .GitHub {
                    GitHubAccountView()
                } else {
                    GitLabAccountView()
                }
            }
            .scrollDisabled(true)
            .formStyle(.grouped)
            .textFieldStyle(RoundedBorderTextFieldStyle())
        }
#if os(macOS)
        .scenePadding()
#else
        .presentationDragIndicator(.hidden)
        .presentationDetents([.medium])
#endif
    }
}

#Preview("MacOS") {
    AddAccountView()
}

#Preview("iOS") {
    VStack {
        Spacer()
    }
    .sheet(isPresented: .constant(true), content: {
        AddAccountView()
    })
}
