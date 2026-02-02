//
//  PlainMergeRequestList.swift
//  GitLab
//
//  Created by Stef Kors on 18/02/2024.
//

import SwiftUI
import SharingGRDB

struct PlainMergeRequestList: View {
    let mergeRequests: [UniversalMergeRequest]
    let accounts: [Account]
    
    var lastMR: UniversalMergeRequest? {
        mergeRequests.last
    }
    
    @Dependency(\.defaultDatabase) private var database
    
    @State private var account: Account?
    
    var body: some View {
        LazyVStack(alignment: .leading, spacing: 0) {
            ForEach(mergeRequests, id: \.id) { mergeRequest in
                MergeRequestRowView(request: mergeRequest)
                    .transition(.opacity)
                    .id(mergeRequest.pullRequest?.hashValue ?? mergeRequest.mergeRequest?.hashValue)
                    .environment(\.account, accounts.first(where: { $0.id == mergeRequest.accountsId }))
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
    PlainMergeRequestList(mergeRequests: [.preview, .preview2, .preview3, .preview4, .previewGitHub], accounts: [.preview, .previewGitHub])
        .previewEnvironment()
    //        .frame(maxWidth: .infinity, maxHeight: .infinity)
}
