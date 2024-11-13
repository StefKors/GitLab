//
//  PlainMergeRequestList.swift
//  GitLab
//
//  Created by Stef Kors on 18/02/2024.
//

import SwiftUI

struct PlainMergeRequestList: View {
    let mergeRequests: [UniversalMergeRequest]

    var lastMR: UniversalMergeRequest? {
        mergeRequests.last
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            ForEach(mergeRequests, id: \.id) { mergeRequest in
                MergeRequestRowView(request: mergeRequest)
                    .transition(.opacity)
                    .id(mergeRequest.pullRequest?.hashValue ?? mergeRequest.mergeRequest?.hashValue)
                //                .listRowSeparator(.visible)
                //                .listRowSeparatorTint(Color.secondary.opacity(0.2))
                if mergeRequest != lastMR {
                    Divider()
                        .padding(.horizontal, 4)
                        .transition(.opacity)
                }
            }
        }

    }
}

#Preview {
    PlainMergeRequestList(mergeRequests: [.preview, .preview2, .preview3, .preview4, .previewGitHub])
        .previewEnvironment()
//        .frame(maxWidth: .infinity, maxHeight: .infinity)
}
