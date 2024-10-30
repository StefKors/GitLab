//
//  HorizontalMergeRequestSubRowView.swift
//  GitLab
//
//  Created by Stef Kors on 17/10/2024.
//


import SwiftUI

struct HorizontalMergeRequestSubRowView: View {
    var MR: UniversalMergeRequest

    var body: some View {
        HStack(alignment: .center, spacing: 4) {
            GitProviderView(provider: MR.account.provider)
                .frame(width: 18, height: 18, alignment: .center)

            AutoSizingWebLinks(MR: MR)

            Spacer()
            if let count = MR.discussionCount, count > 1 {
                DiscussionCountIcon(count: count)
            }
            MergeStatusView(MR: MR)
            // TODO: support github pipelines
            if let pipeline = MR.mergeRequest?.headPipeline {
                PipelineView(pipeline: pipeline, instance: MR.account.instance)
            }
        }
    }
}

#Preview {
    VStack {
        HorizontalMergeRequestSubRowView(MR: .preview)
        HorizontalMergeRequestSubRowView(MR: .preview2)
        HorizontalMergeRequestSubRowView(MR: .preview3)
        HorizontalMergeRequestSubRowView(MR: .preview4)
        HorizontalMergeRequestSubRowView(MR: .previewGitHub)
    }
    .scenePadding()
}
