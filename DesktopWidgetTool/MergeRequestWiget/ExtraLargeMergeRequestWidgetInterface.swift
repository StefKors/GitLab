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
            ViewThatFits {
                WidgetLaunchPadRow(repos: repos, length: 10)
                WidgetLaunchPadRow(repos: repos, length: 9)
                WidgetLaunchPadRow(repos: repos, length: 8)
                WidgetLaunchPadRow(repos: repos, length: 7)
                WidgetLaunchPadRow(repos: repos, length: 6)
                WidgetLaunchPadRow(repos: repos, length: 5)
                WidgetLaunchPadRow(repos: repos, length: 4)
                WidgetLaunchPadRow(repos: repos, length: 3)
                WidgetLaunchPadRow(repos: repos, length: 2)
                WidgetLaunchPadRow(repos: repos, length: 1)
            }

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
    ExtraLargeMergeRequestWidgetInterface(
        mergeRequests: [.preview, .preview, .preview, .preview],
        accounts: [.preview],
        repos: [],
        selectedView: .authoredMergeRequests
    )
}
