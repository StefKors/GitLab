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
        .fixedSize(horizontal: false, vertical: true)
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
