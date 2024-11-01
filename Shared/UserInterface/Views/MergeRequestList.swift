//
//  MergeRequestList.swift
//  GitLab
//
//  Created by Stef Kors on 08/05/2024.
//

import SwiftUI

struct MergeRequestList: View {
    var mergeRequests: [UniversalMergeRequest]
    var accounts: [Account]
    var selectedView: QueryType

    var body: some View {
        PlainMergeRequestList(mergeRequests: mergeRequests)
//        if accounts.count > 1 {
//            SectionedMergeRequestList(
//                accounts: accounts,
//                selectedView: selectedView
//            )
//        } else {
//            PlainMergeRequestList(mergeRequests: mergeRequests)
//        }
    }
}

#Preview {
    MergeRequestList(
        mergeRequests: [.preview, .preview2],
        accounts: [.preview],
        selectedView: .authoredMergeRequests
    )
}
