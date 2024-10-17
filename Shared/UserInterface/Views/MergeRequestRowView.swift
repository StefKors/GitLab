//
//  MergeRequestRowView.swift
//
//
//  Created by Stef Kors on 24/06/2022.
//

import SwiftUI

struct MergeRequestRowView: View {
    var MR: MergeRequest
    
    @Environment(\.openURL) private var openURL
    @Environment(\.dismissWindow) private var dismissWindow
    
    var body: some View {
        Button {
            if let url = MR.webUrl {
                openURL(url)
                dismissWindow()
            }
        } label: {
            VStack(alignment: .leading, spacing: 5) {
                MRTitleView(linkText: MR.title ?? "untitled")
                    .multilineTextAlignment(.leading)
                    .truncationMode(.middle)
                    .padding(.trailing)
                
                HorizontalMergeRequestSubRowView(MR: MR)
            }
        }
        .buttonStyle(.shaded)
    }
}

#Preview {
    VStack(alignment: .leading, spacing: 50, content: {
        VStack(alignment: .leading, content: {
            MergeRequestRowView(MR: .preview)
            MergeRequestRowView(MR: .preview3)
            MergeRequestRowView(MR: .preview2)
        })
        .frame(width: 190)
        
        VStack(alignment: .leading, content: {
            MergeRequestRowView(MR: .preview)
            MergeRequestRowView(MR: .preview3)
            MergeRequestRowView(MR: .preview2)
        })
        .frame(width: 290)
        
        VStack(alignment: .leading, content: {
            MergeRequestRowView(MR: .preview)
            MergeRequestRowView(MR: .preview3)
            MergeRequestRowView(MR: .preview2)
        })
    })
    .scenePadding()
}
