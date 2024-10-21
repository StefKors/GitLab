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

    private var filteredMRs: [MergeRequest] {
        if selectedView == .reviewRequestedMergeRequests {
            return mergeRequests.filter { mr in
                mr.approvedBy?.edges?.count == 0
            }
        }

        return mergeRequests
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
//            ViewThatFits(in: .horizontal) {
//                WidgetLaunchPadRow(repos: repos, length: 10)
//                WidgetLaunchPadRow(repos: repos, length: 9)
//                WidgetLaunchPadRow(repos: repos, length: 8)
//                WidgetLaunchPadRow(repos: repos, length: 7)
//                WidgetLaunchPadRow(repos: repos, length: 6)
//                WidgetLaunchPadRow(repos: repos, length: 5)
//                WidgetLaunchPadRow(repos: repos, length: 4)
//                WidgetLaunchPadRow(repos: repos, length: 3)
//            }
//
//            Divider()

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
