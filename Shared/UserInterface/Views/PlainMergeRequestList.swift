//
//  PlainMergeRequestList.swift
//  GitLab
//
//  Created by Stef Kors on 18/02/2024.
//

import SwiftUI

struct PlainMergeRequestList: View {
    let rowModels: [MergeRequestRowModel]

    var body: some View {
        LazyVStack(alignment: .leading, spacing: 0) {
            ForEach(rowModels) { rowModel in
                MergeRequestRowView(rowModel: rowModel)
                    .transition(.opacity)
                //                .listRowSeparator(.visible)
                //                .listRowSeparatorTint(Color.secondary.opacity(0.2))
                
                if rowModel.id != rowModels.last?.id {
                    Divider()
                        .padding(.horizontal, 4)
                        .transition(.opacity)
                }
            }
        }
    }
}

#Preview {
    PlainMergeRequestList(rowModels: [
        .init(request: .preview, account: .preview),
        .init(request: .preview2, account: .preview),
        .init(request: .preview3, account: .preview),
        .init(request: .preview4, account: .preview),
        .init(request: .previewGitHub, account: .previewGitHub)
    ])
        .previewEnvironment()
    //        .frame(maxWidth: .infinity, maxHeight: .infinity)
}
