//
//  LargeMergeRequestWidgetInterface.swift
//  GitLab
//
//  Created by Stef Kors on 26/04/2024.
//

import SwiftUI

struct LargeMergeRequestWidgetInterface: View {
    var mergeRequests: [UniversalMergeRequest]
    var accounts: [Account]
    var repos: [LaunchpadRepo]
    var selectedView: QueryType

    private var filteredMRs: [UniversalMergeRequest] {
        if selectedView == .reviewRequestedMergeRequests {
            return mergeRequests.filter { mr in
                mr.isApproved == false
            }
        }

        return mergeRequests
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            if selectedView == .reviewRequestedMergeRequests {
                ViewThatFits(in: .horizontal, content: {
                    HStack(alignment: .center, spacing: 6) {
                        Text(Image(.mergeRequest))
                        Text("^[\(mergeRequests.count) reviews](inflect: true) requested")
                    }

                    HStack(alignment: .center, spacing: 6) {
                        Text(Image(.mergeRequest))
                        Text(mergeRequests.count.description)
                    }
                })
            }

            if selectedView == .authoredMergeRequests {
                ViewThatFits(in: .horizontal, content: {
                    HStack(alignment: .center, spacing: 6) {
                        Text(Image(.branch))
                        Text("^[\(mergeRequests.count) merge requests](inflect: true)")
                    }

                    HStack(alignment: .center, spacing: 6) {
                        Text(Image(.branch))
                        Text(mergeRequests.count.description)
                    }
                })
            }

            MergeRequestList(
                mergeRequests: Array(filteredMRs.prefix(4)),
                accounts: accounts,
                selectedView: selectedView
            )
        }
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
