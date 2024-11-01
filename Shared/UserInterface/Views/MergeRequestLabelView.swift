//
//  MergeRequestLabelView.swift
//  
//
//  Created by Stef Kors on 24/06/2022.
//

import SwiftUI

struct MergeRequestLabelView: View {
    var request: GitLab.MergeRequest
    var body: some View {
        VStack(alignment: .leading, spacing: 5) {
            TitleWebLink(linkText: request.title ?? "untitled", destination: request.webUrl, isDraft: request.title?.isDraft ?? false)
                /// hacks we actually want line wrapping
                .multilineTextAlignment(.leading)
                .truncationMode(.middle)
            WebLink(
                linkText: "\(request.targetProject?.path ?? "")\("/")\(request.targetProject?.group?.fullPath ?? "")\(request.reference ?? "")",
                destination: request.targetProject?.webURL
            )
        }.fixedSize(horizontal: false, vertical: true)
    }
}
