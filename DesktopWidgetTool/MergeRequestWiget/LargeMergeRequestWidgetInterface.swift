//
//  LargeMergeRequestWidgetInterface.swift
//  GitLab
//
//  Created by Stef Kors on 26/04/2024.
//

import SwiftUI

struct LargeMergeRequestWidgetInterface: View {
    var mergeRequests: [MergeRequest]
    var accounts: [Account]
    var repos: [LaunchpadRepo]
    var selectedView: QueryType
    
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            ViewThatFits(in: .vertical) {
                MergeRequestList(
                    mergeRequests: Array(mergeRequests.prefix(9)),
                    accounts: accounts,
                    selectedView: selectedView
                )
                MergeRequestList(
                    mergeRequests: Array(mergeRequests.prefix(8)),
                    accounts: accounts,
                    selectedView: selectedView
                )
                MergeRequestList(
                    mergeRequests: Array(mergeRequests.prefix(7)),
                    accounts: accounts,
                    selectedView: selectedView
                )
                MergeRequestList(
                    mergeRequests: Array(mergeRequests.prefix(6)),
                    accounts: accounts,
                    selectedView: selectedView
                )
                MergeRequestList(
                    mergeRequests: Array(mergeRequests.prefix(5)),
                    accounts: accounts,
                    selectedView: selectedView
                )
                MergeRequestList(
                    mergeRequests: Array(mergeRequests.prefix(4)),
                    accounts: accounts,
                    selectedView: selectedView
                )
                MergeRequestList(
                    mergeRequests: Array(mergeRequests.prefix(3)),
                    accounts: accounts,
                    selectedView: selectedView
                )
                MergeRequestList(
                    mergeRequests: Array(mergeRequests.prefix(3)),
                    accounts: accounts,
                    selectedView: selectedView
                )
            }
        }
        //        .fixedSize(horizontal: false, vertical: true)
        .frame(alignment: .top)
    }
}



#Preview {
    LargeMergeRequestWidgetInterface(
        mergeRequests: [.preview, .preview, .preview, .preview],
        accounts: [.preview],
        repos: [],
        selectedView: .authoredMergeRequests
    )
}
