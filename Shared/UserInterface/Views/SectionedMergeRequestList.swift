//
//  SectionedMergeRequestList.swift
//  GitLab
//
//  Created by Stef Kors on 18/02/2024.
//

import SwiftUI

struct SectionedMergeRequestList: View {
    let accounts: [Account]
    let selectedView: QueryType

    var body: some View {
        ForEach(accounts) { account in
            Section(header: Text(account.instance)) {
                ForEach(account.requests, id: \.id) { mergeRequest in
                    MergeRequestRowView(MR: mergeRequest)
                        .padding(.bottom, 4)
                        .listRowSeparator(.visible)
                        .listRowSeparatorTint(Color.secondary.opacity(0.2))
                }
            }
        }
    }
}
