//
//  HorizontalMergeRequestSubRowView.swift
//  GitLab
//
//  Created by Stef Kors on 17/10/2024.
//

import SwiftUI

struct HorizontalMergeRequestSubRowView: View {
    var request: UniversalMergeRequest

    @Environment(\.account) private var account

    var body: some View {
        HStack(alignment: .center, spacing: 4) {
            if let provider = account?.provider {
                GitProviderView(provider: provider)
                    .frame(width: 18, height: 18, alignment: .center)
            }

            AutoSizingWebLinks(request: request)

            Spacer()

            if let count = request.discussionCount, count > 1 {
                DiscussionCountIcon(count: count, provider: request.provider)
            }

            MergeStatusView(request: request)

            if let pipeline = request.mergeRequest?.headPipeline {
                PipelineView(pipeline: pipeline, instance: account?.instance)
            }

            if let status = request.pullRequest?.statusCheckRollup {
                ActionsView(status: status, instance: account?.instance)
            }
        }
    }
}

#Preview {
    VStack {
        HorizontalMergeRequestSubRowView(request: .preview)
        HorizontalMergeRequestSubRowView(request: .preview2)
        HorizontalMergeRequestSubRowView(request: .preview3)
        HorizontalMergeRequestSubRowView(request: .preview4)
        HorizontalMergeRequestSubRowView(request: .previewGitHub)
    }
    .scenePadding()
}
