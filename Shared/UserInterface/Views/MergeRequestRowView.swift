//
//  MergeRequestRowView.swift
//
//
//  Created by Stef Kors on 24/06/2022.
//

import SwiftUI

struct MergeRequestRowView: View {
    var request: UniversalMergeRequest

    @Environment(\.openURL) private var openURL
    @Environment(\.dismissWindow) private var dismissWindow

    var body: some View {
        Button {
            if let url = request.url {
                openURL(url)
                dismissWindow()
            }
        } label: {
            VStack(alignment: .leading, spacing: 5) {
                MRTitleView(linkText: request.title ?? "untitled", isDraft: request.isDraft)
                    .multilineTextAlignment(.leading)
                    .truncationMode(.middle)
                    .padding(.trailing


                    )

                HorizontalMergeRequestSubRowView(request: request)
            }
        }
        .buttonStyle(.shaded)
    }
}

#Preview {
    VStack(alignment: .leading, spacing: 50, content: {
        VStack(alignment: .leading, content: {
            MergeRequestRowView(request: .preview)
            MergeRequestRowView(request: .preview3)
            MergeRequestRowView(request: .preview2)
        })
        .frame(width: 190)

        VStack(alignment: .leading, content: {
            MergeRequestRowView(request: .preview)
            MergeRequestRowView(request: .preview3)
            MergeRequestRowView(request: .preview2)
        })
        .frame(width: 290)

        VStack(alignment: .leading, content: {
            MergeRequestRowView(request: .preview)
            MergeRequestRowView(request: .preview3)
            MergeRequestRowView(request: .preview2)
        })
    })
    .scenePadding()
}
