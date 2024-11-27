//
//  WidgetMRRowIcon.swift
//  GitLab
//
//  Created by Stef Kors on 19/10/2024.
//

import SwiftUI

struct WidgetMRRowIcon: View {
    let request: UniversalMergeRequest
    let providers: [GitProvider]
    let account: Account?
    var body: some View {
        HStack( spacing: 4) {
            if providers.count > 1, let provider = account?.provider {
                GitProviderView(provider: provider)
                    .frame(width: 18, height: 18, alignment: .center)
            }

            TitleWebLink(linkText: request.title ?? "untitled", destination: request.url, weight: .regular)
                .multilineTextAlignment(.leading)
                .lineLimit(1)
                .truncationMode(.tail)
                .frame(maxWidth: .infinity, alignment: .leading)

            if request.isApproved {
                WidgetApprovedReviewIcon()
            }
        }
    }
}

#Preview {
    VStack(spacing: 4) {
        WidgetMRRowIcon(request: .preview, providers: [.GitHub, .GitLab], account: .previewGitHub)
        WidgetMRRowIcon(request: .previewGitHub, providers: [.GitHub, .GitLab], account: .previewGitHub)
        WidgetMRRowIcon(request: .preview2, providers: [.GitHub, .GitLab], account: .previewGitHub)
        WidgetMRRowIcon(request: .preview3, providers: [.GitHub, .GitLab], account: .previewGitHub)
    }
    .scenePadding()
}
