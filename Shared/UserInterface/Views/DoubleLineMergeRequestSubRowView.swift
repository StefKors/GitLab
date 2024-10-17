//
//  DoubleLineMergeRequestSubRowView.swift
//  GitLab
//
//  Created by Stef Kors on 17/10/2024.
//


import SwiftUI

struct DoubleLineMergeRequestSubRowView: View {
    var MR: MergeRequest

    var body: some View {
        VStack(alignment: .leading) {
            HStack(alignment: .center, spacing: 4) {
                if let provider = MR.account?.provider {
                    GitProviderView(provider: provider)
                        .frame(width: 18, height: 18, alignment: .center)
                }

                AutoSizingWebLinks(MR: MR)

                Spacer()
            }

            HStack(alignment: .center, spacing: 4) {
                if let count = MR.userNotesCount, count > 1 {
                    DiscussionCountIcon(count: count)
                }
                MergeStatusView(MR: MR)
                PipelineView(stages: MR.headPipeline?.stages?.edges?.map({ $0.node }) ?? [], instance: MR.account?.instance)
            }
        }
    }
}
