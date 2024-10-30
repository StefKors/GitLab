//
//  TitleWebLink.swift
//  GitLab
//
//  Created by Stef Kors on 23/06/2022.
//

import SwiftUI

/// the original variant
struct TitleWebLink: View {
    var linkText: String
    var destination: URL?
    var weight: Font.Weight = .bold
    var isDraft: Bool = false


    var body: some View {
        if let url = destination {
            Link(destination: url, label: {
                MRTitleView(linkText: linkText, isLink: true, weight: weight, isDraft: isDraft)
            })
        } else {
            MRTitleView(linkText: linkText, weight: weight, isDraft: isDraft)
        }
    }
}

#Preview {
    VStack(alignment: .leading) {
        TitleWebLink(linkText: "Fix MR title link", destination: URL(string: "https://gitlab.com"), weight: .black)
        TitleWebLink(linkText: "Fix MR title link", destination: URL(string: "https://gitlab.com"), weight: .bold)
        TitleWebLink(linkText: "Fix MR title link", destination: URL(string: "https://gitlab.com"), weight: .semibold)
        TitleWebLink(linkText: "Fix MR title link", destination: URL(string: "https://gitlab.com"), weight: .medium)
    }
    .scenePadding()
}
