//
//  DoubleLineMergeRequestSubRowView.swift
//  GitLab
//
//  Created by Stef Kors on 17/10/2024.
//

import SwiftUI

struct DoubleLineMergeRequestSubRowView: View {
    var request: UniversalMergeRequest

    var body: some View {
        VStack(alignment: .leading) {
            HStack(alignment: .center, spacing: 4) {
                GitProviderView(provider: request.account.provider)
                    .frame(width: 18, height: 18, alignment: .center)

                AutoSizingWebLinks(request: request)

                Spacer()
            }

            HStack(alignment: .center, spacing: 4) {
                if let count = request.discussionCount, count > 1 {
                    DiscussionCountIcon(count: count, provider: request.provider)
                }
                MergeStatusView(request: request)

                // TODO: support github pipelines
                if let pipeline = request.mergeRequest?.headPipeline {
                    PipelineView(pipeline: pipeline, instance: request.account.instance)
                }

                if let status = request.pullRequest?.commits?.nodes?.first?.commit?.statusCheckRollup {
                    ActionsView(status: status, instance: request.account.instance)
                }
            }
        }
    }
}
