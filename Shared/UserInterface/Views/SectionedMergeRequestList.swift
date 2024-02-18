//
//  SectionedMergeRequestList.swift
//  GitLab
//
//  Created by Stef Kors on 18/02/2024.
//

import SwiftUI

struct SectionedMergeRequestList: View {
    let accounts: [Account]
    let mergeRequests: [MergeRequest]
    let selectedView: QueryType

    var mergeRequestsDict: [Account?: [MergeRequest]] {
        let filtered = mergeRequests.filter { $0.type == selectedView }
        return Dictionary(grouping: filtered) { element in
            element.account
        }
    }

    var body: some View {
        ForEach(accounts) { account in
            if let accountMRs = mergeRequestsDict[account] {
                Section(header: Text(account.instance)) {
                    ForEach(accountMRs, id: \.id) { mergeRequest in
                        MergeRequestRowView(MR: mergeRequest)
                            .padding(.bottom, 4)
                            .listRowSeparator(.visible)
                            .listRowSeparatorTint(Color.secondary.opacity(0.2))
                    }
                }
            }
        }
    }
}
