//
//  WidgetMRRowIcon.swift
//  GitLab
//
//  Created by Stef Kors on 19/10/2024.
//

import SwiftUI

struct WidgetMRRowIcon: View {
    let MR: UniversalMergeRequest
    let providers: [GitProvider]

    var body: some View {
        HStack( spacing: 4) {
            if providers.count > 1 {
                GitProviderView(provider: MR.account.provider)
                    .frame(width: 18, height: 18, alignment: .center)
            }
            
            
            
            TitleWebLink(linkText: MR.title ?? "untitled", destination: MR.url, weight: .regular)
                .multilineTextAlignment(.leading)
                .lineLimit(1)
                .truncationMode(.tail)
                .frame(maxWidth: .infinity, alignment: .leading)
            
            if MR.isApproved {
                WidgetApprovedReviewIcon()
            }
        }
    }
}

#Preview {
    VStack(spacing: 4) {
        WidgetMRRowIcon(MR: .preview, providers: [.GitHub, .GitLab])
        WidgetMRRowIcon(MR: .previewGitHub, providers: [.GitHub, .GitLab])
        WidgetMRRowIcon(MR: .preview2, providers: [.GitHub, .GitLab])
        WidgetMRRowIcon(MR: .preview3, providers: [.GitHub, .GitLab])
    }
    .scenePadding()
}
