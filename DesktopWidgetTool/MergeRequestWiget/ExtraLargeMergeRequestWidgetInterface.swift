//
//  ExtraLargeMergeRequestWidgetInterface.swift
//  GitLab
//
//  Created by Stef Kors on 26/04/2024.
//

import SwiftUI

struct ExtraLargeMergeRequestWidgetInterface: View {
    var mergeRequests: [MergeRequest]
    var accounts: [Account]
    var repos: [LaunchpadRepo]
    var selectedView: QueryType

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            ViewThatFits(in: .horizontal) {
                WidgetLaunchPadRow(repos: repos, length: 10)
                WidgetLaunchPadRow(repos: repos, length: 9)
                WidgetLaunchPadRow(repos: repos, length: 8)
                WidgetLaunchPadRow(repos: repos, length: 7)
                WidgetLaunchPadRow(repos: repos, length: 6)
                WidgetLaunchPadRow(repos: repos, length: 5)
                WidgetLaunchPadRow(repos: repos, length: 4)
                WidgetLaunchPadRow(repos: repos, length: 3)
            }

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
            }
        }
        //        .fixedSize(horizontal: false, vertical: true)
        .frame(alignment: .top)
    }
}


#Preview {
    ExtraLargeMergeRequestWidgetInterface(
        mergeRequests: [.preview, .preview, .preview, .preview],
        accounts: [.preview],
        repos: [],
        selectedView: .authoredMergeRequests
    )
}
