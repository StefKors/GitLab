//
//  MergeRequestLabelView.swift
//  
//
//  Created by Stef Kors on 24/06/2022.
//

import SwiftUI

struct MergeRequestLabelView: View {
    var MR: GitLab.MergeRequest
    var body: some View {
        VStack(alignment: .leading, spacing: 5) {
            TitleWebLink(linkText: MR.title ?? "untitled", destination: MR.webUrl, isDraft: MR.title?.isDraft ?? false)
                /// hacks we actually want line wrapping
                .multilineTextAlignment(.leading)
                .truncationMode(.middle)
            WebLink(
                linkText: "\(MR.targetProject?.path ?? "")\("/")\(MR.targetProject?.group?.fullPath ?? "")\(MR.reference ?? "")",
                destination: MR.targetProject?.webURL
            )
        }.fixedSize(horizontal: false, vertical: true)
    }
}
