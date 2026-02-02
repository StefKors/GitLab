//
//  MainContentView.swift
//  GitLab
//
//  Created by Stef Kors on 19/10/2024.
//

import SwiftUI
import Get

struct MainContentView: View {
    let repos: [LaunchpadRepo]
    let filteredMergeRequests: [UniversalMergeRequest]
    let accounts: [Account]
    var withScrollView: Bool = false
    var allowScrollBounce: Bool = true
    @Binding var selectedView: QueryType
    @Binding var activeRepoUrl: URL?

    var body: some View {
        VStack(alignment: .center, spacing: 0) {
            LaunchpadView(repos: repos, activeRepoUrl: $activeRepoUrl)
                .padding(6)

            Divider()

            // Disabled in favor for real notifications?
            NoticeListView()
                .padding(6)

            if accounts.isEmpty {
                BaseTextView(message: "Setup your accounts in the settings")
            } else if filteredMergeRequests.isEmpty {
                BaseTextView(message: "All done 🥳")
                    .foregroundStyle(.secondary)
            } else {
                mergeRequestList
            }

            LastUpdateMessageView()
        }
        .frame(maxHeight: .infinity, alignment: .top)
    }

    @ViewBuilder
    private var mergeRequestList: some View {
        let listContent = PlainMergeRequestList(mergeRequests: filteredMergeRequests, accounts: accounts)
//            MergeRequestList(
//                mergeRequests: filteredMergeRequests,
//                accounts: accounts,
//                selectedView: selectedView
//            )
            .animation(.snappy(duration: 0.3), value: selectedView)
            .padding(6)

        let list = ScrollView {
            listContent
        }

        if withScrollView {
            if allowScrollBounce {
                list.scrollBounceBehavior(.basedOnSize)
            } else {
                list
            }
        } else {
            listContent
        }
    }
}

#Preview {
    MainContentView(
        repos: [.preview],
        filteredMergeRequests: [.preview, .preview2, .preview3, .preview4],
        accounts: [.preview],
        selectedView: .constant(.authoredMergeRequests),
        activeRepoUrl: .constant(nil)
    )
    .previewEnvironment()
}
