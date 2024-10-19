//
//  MediumMergeRequestWidgetInterface.swift
//  GitLab
//
//  Created by Stef Kors on 26/04/2024.
//

import SwiftUI

struct MediumMergeRequestWidgetInterface: View {
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

    private var providers: [GitProvider] {
        Array(Set(accounts.map(\.provider)))
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack(alignment: .center, spacing: 6) {
                if selectedView == .reviewRequestedMergeRequests {
                    Text(Image(.mergeRequest))
                    Text("^[\(mergeRequests.count) reviews](inflect: true) requested")
                }

                if selectedView == .authoredMergeRequests {
                    Text(Image(.branch))
                    Text("^[\(mergeRequests.count) merge requests](inflect: true)")
                }
            }

            VStack(alignment: .leading, spacing: 4) {
                ForEach(Array(mergeRequests.prefix(5)), id: \.id) { MR in
                    WidgetMRRowIcon(MR: MR, providers: providers)
                }
            }
        }
        .frame(alignment: .top)
    }
}


#Preview {
    VStack {
        GroupBox {
            MediumMergeRequestWidgetInterface(
                mergeRequests: [.preview, .preview, .preview3, .preview2],
                accounts: [.preview],
                repos: [],
                selectedView: .reviewRequestedMergeRequests
            )
            .padding(20)
        }

        GroupBox {
            MediumMergeRequestWidgetInterface(
                mergeRequests: [.preview, .previewGithub, .preview3, .preview2],
                accounts: [.preview, .previewGitHub],
                repos: [],
                selectedView: .authoredMergeRequests
            )
            .padding(20)
        }
    }
    .scenePadding()
}



#Preview {
    MediumMergeRequestWidgetInterface(
        mergeRequests: [.preview, .preview, .preview, .preview],
        accounts: [.preview],
        repos: [],
        selectedView: .authoredMergeRequests
    )
}

