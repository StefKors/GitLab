//
//  HorizontalMergeRequestSubRowView.swift
//  GitLab
//
//  Created by Stef Kors on 17/10/2024.
//

import SwiftUI

struct HorizontalMergeRequestSubRowView: View {
    var request: UniversalMergeRequest

    var body: some View {
        HStack(alignment: .center, spacing: 4) {
            GitProviderView(provider: request.account.provider)
                .frame(width: 18, height: 18, alignment: .center)

            AutoSizingWebLinks(request: request)

            Spacer()
            if let count = request.discussionCount, count > 1 {
                DiscussionCountIcon(count: count, provider: request.provider)
            }
            MergeStatusView(request: request)
            // TODO: support github pipelines
            if let pipeline = request.mergeRequest?.headPipeline {
                PipelineView(pipeline: pipeline, instance: request.account.instance)
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
