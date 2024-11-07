//
//  MainContentView.swift
//  GitLab
//
//  Created by Stef Kors on 19/10/2024.
//

import SwiftUI
import SwiftData
import Get

struct MainContentView: View {
    let repos: [LaunchpadRepo]
    let filteredMergeRequests: [UniversalMergeRequest]
    let accounts: [Account]
    var withScrollView: Bool = false
    @Binding var selectedView: QueryType

    var body: some View {
        VStack(alignment: .center, spacing: 0) {
            LaunchpadView(repos: repos)
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
                VStack(alignment: .leading) {
                    MergeRequestList(
                        mergeRequests: filteredMergeRequests,
                        accounts: accounts,
                        selectedView: selectedView
                    )
                }
                .animation(.snappy(duration: 0.3), value: selectedView)
                .padding(6)
                .useScrollView(when: withScrollView)
                .scrollBounceBehavior(.basedOnSize)
            }

            LastUpdateMessageView()
        }
        .frame(maxHeight: .infinity, alignment: .top)
    }
}

#Preview {
    MainContentView(
        repos: [.preview],
        filteredMergeRequests: [.preview, .preview2, .preview3, .preview4],
        accounts: [.preview],
        selectedView: .constant(.authoredMergeRequests)
    )
    .environmentObject(NoticeState())
}
