//
//  PlainMergeRequestList.swift
//  GitLab
//
//  Created by Stef Kors on 18/02/2024.
//

import SwiftUI

struct PlainMergeRequestList: View {
    let mergeRequests: [MergeRequest]

    var lastMR: MergeRequest? {
        mergeRequests.last
    }

    var body: some View {
        ForEach(mergeRequests, id: \.id) { mergeRequest in
            MergeRequestRowView(MR: mergeRequest)
                .listRowSeparator(.visible)
                .listRowSeparatorTint(Color.secondary.opacity(0.2))
            if mergeRequest != lastMR {
                Divider()
            }
        }
    }
}

#Preview {
    PlainMergeRequestList(mergeRequests: [])
}