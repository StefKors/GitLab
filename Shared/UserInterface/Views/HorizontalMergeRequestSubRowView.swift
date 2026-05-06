//
//  HorizontalMergeRequestSubRowView.swift
//  GitLab
//
//  Created by Stef Kors on 17/10/2024.
//

import SwiftUI

struct HorizontalMergeRequestSubRowView: View, Equatable {
    let request: UniversalMergeRequest
    let provider: GitProvider?
    let account: Account?
    let instance: String?
    let isHoveringRow: Bool

    static func == (lhs: HorizontalMergeRequestSubRowView, rhs: HorizontalMergeRequestSubRowView) -> Bool {
        lhs.request == rhs.request &&
            lhs.provider == rhs.provider &&
            lhs.account == rhs.account &&
            lhs.instance == rhs.instance &&
            lhs.isHoveringRow == rhs.isHoveringRow
    }

    var body: some View {
        HStack(alignment: .center, spacing: 4) {
            if let provider {
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
                EquatablePipelineView(pipeline: pipeline, instance: instance, isHoveringRow: isHoveringRow)
            }

            if let status = request.pullRequest?.statusCheckRollup {
                EquatableActionsView(status: status, instance: instance)
            }
        }
    }
}

private struct EquatablePipelineView: View, Equatable {
    let pipeline: GitLab.HeadPipeline
    let instance: String?
    let isHoveringRow: Bool

    var body: some View {
        PipelineView(pipeline: pipeline, instance: instance, isHoveringRow: isHoveringRow)
    }
}

private struct EquatableActionsView: View, Equatable {
    let status: GitHub.StatusCheckRollup
    let instance: String?

    var body: some View {
        ActionsView(status: status, instance: instance)
    }
}

#Preview {
    VStack {
        HorizontalMergeRequestSubRowView(request: .preview, provider: .GitLab, account: .preview, instance: Account.preview.instance, isHoveringRow: false)
        HorizontalMergeRequestSubRowView(request: .preview2, provider: .GitLab, account: .preview, instance: Account.preview.instance, isHoveringRow: false)
        HorizontalMergeRequestSubRowView(request: .preview3, provider: .GitLab, account: .preview, instance: Account.preview.instance, isHoveringRow: false)
        HorizontalMergeRequestSubRowView(request: .preview4, provider: .GitLab, account: .preview, instance: Account.preview.instance, isHoveringRow: false)
        HorizontalMergeRequestSubRowView(request: .previewGitHub, provider: .GitHub, account: .previewGitHub, instance: Account.previewGitHub.instance, isHoveringRow: false)
    }
    .scenePadding()
}
