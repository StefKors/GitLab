//
//  MergeRequestList.swift
//  GitLab
//
//  Created by Stef Kors on 08/05/2024.
//

import SwiftUI

struct MergeRequestList: View {
    var mergeRequests: [MergeRequest]
    var accounts: [Account]
    var selectedView: QueryType

    var body: some View {
        if accounts.count > 1 {
            SectionedMergeRequestList(
                accounts: accounts,
                mergeRequests: mergeRequests,
                selectedView: selectedView
            )
        } else {
            PlainMergeRequestList(mergeRequests: mergeRequests)
        }
    }
}

#Preview {
    MergeRequestList(
        mergeRequests: [.preview, .preview2],
        accounts: [.preview],
        selectedView: .authoredMergeRequests
    )
}
