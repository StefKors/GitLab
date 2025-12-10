//
//  DoubleLineMergeRequestSubRowView.swift
//  GitLab
//
//  Created by Stef Kors on 17/10/2024.
//

import SwiftUI

struct LabelsView: View {
    var request: UniversalMergeRequest

    var body: some View {
        HStack {
            ForEach(request.labels, id: \.self) { label in
                Text(label)
                    .font(.footnote)
                    .padding(.vertical, 2)
                    .padding(.horizontal, 6)
                    .background(.quaternary, in: Capsule())
                    .foregroundStyle(.secondary)
                    .transition(.opacity.combined(with: .blurReplace).combined(with: .move(edge: .leading)))
            }
        }
    }
}

#Preview {
    LabelsView(
        request: UniversalMergeRequest(
            request: .previewGitHub,
            account: .previewGitHub,
            provider: .GitHub,
            type: .authoredMergeRequests
        )
    )
    .scenePadding()
}

struct DoubleLineMergeRequestSubRowView: View {
    var request: UniversalMergeRequest
    var account: Account?

    var body: some View {
        VStack(alignment: .leading) {
            HStack(alignment: .center, spacing: 4) {
                if let account = account {
                    GitProviderView(provider: account.provider)
                        .frame(width: 18, height: 18, alignment: .center)
                }

                AutoSizingWebLinks(request: request)

                LabelsView(request: request)

                Spacer()
            }

            HStack(alignment: .center, spacing: 4) {
                if let count = request.discussionCount, count > 1 {
                    DiscussionCountIcon(count: count, provider: request.provider)
                }
                MergeStatusView(request: request, account: account)

                if let pipeline = request.mergeRequest?.headPipeline {
                    PipelineView(pipeline: pipeline, instance: account?.instance)
                }

                if let status = request.pullRequest?.statusCheckRollup {
                    ActionsView(status: status, instance: account?.instance)
                }
            }
        }
    }
}
