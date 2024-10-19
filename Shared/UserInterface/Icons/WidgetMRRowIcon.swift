//
//  WidgetMRRowIcon.swift
//  GitLab
//
//  Created by Stef Kors on 19/10/2024.
//

import SwiftUI

struct WidgetMRRowIcon: View {
    let MR: MergeRequest
    let providers: [GitProvider]

    private var isApproved: Bool {
        guard let approvers = MR.approvedBy?.edges?.compactMap({ $0.node }) else {
            return false
        }

        return !approvers.isEmpty
    }

    var body: some View {
        HStack( spacing: 4) {
            if providers.count > 1 {
                GitProviderView(provider: MR.account?.provider)
                    .frame(width: 18, height: 18, alignment: .center)
            }
            
            
            
            TitleWebLink(linkText: MR.title ?? "untitled", destination: MR.webUrl, weight: .regular)
                .multilineTextAlignment(.leading)
                .lineLimit(1)
                .truncationMode(.tail)
                .frame(maxWidth: .infinity, alignment: .leading)
            
            if isApproved {
                WidgetApprovedReviewIcon()
            }
        }
    }
}

#Preview {
    VStack(spacing: 4) {
        WidgetMRRowIcon(MR: .preview, providers: [.GitHub, .GitLab])
        WidgetMRRowIcon(MR: .previewGithub, providers: [.GitHub, .GitLab])
        WidgetMRRowIcon(MR: .preview2, providers: [.GitHub, .GitLab])
        WidgetMRRowIcon(MR: .preview3, providers: [.GitHub, .GitLab])
    }
    .scenePadding()
}
