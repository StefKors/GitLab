//
//  MediumMergeRequestWidgetInterface.swift
//  GitLab
//
//  Created by Stef Kors on 26/04/2024.
//

import SwiftUI

struct MediumMergeRequestWidgetInterface: View {
    var mergeRequests: [MergeRequest]
    var accounts: [Account]
    var repos: [LaunchpadRepo]
    var selectedView: QueryType

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack(spacing: 2) {
                Image(.mergeRequest).resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(height: 20)
                Text(mergeRequests.count.description)
            }
            .font(.largeTitle)

            VStack(alignment: .leading, spacing: 2) {
                ForEach(mergeRequests, id: \.id) { MR in
                    HStack(alignment: .top, spacing: 4) {
                        GitProviderView(provider: MR.account?.provider)
                            .frame(width: 18, height: 18, alignment: .center)

                        TitleWebLink(linkText: MR.title ?? "untitled", destination: MR.webUrl, weight: .regular)
                            .multilineTextAlignment(.leading)
                            .lineLimit(1)
                            .truncationMode(.tail)
                    }
                }
            }
        }
        .frame(alignment: .top)
    }
}



#Preview {
    MediumMergeRequestWidgetInterface(
        mergeRequests: [.preview, .preview, .preview, .preview],
        accounts: [.preview],
        repos: [],
        selectedView: .authoredMergeRequests
    )
}
