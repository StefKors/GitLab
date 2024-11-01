//
//  DiscussionCountIcon.swift
//
//
//  Created by Stef Kors on 14/09/2021.
//

import SwiftUI

struct DiscussionCountIcon: View {
    var count: Int?
    var provider: GitProvider

    private var min: Int {
        switch provider {
        case .GitHub:
            0
        case .GitLab:
            1
        }
    }

    var body: some View {
        if let count = count, count > min {
            if count <= 50 {
                HStack(spacing: 2) {
                    Text(Image(systemName: "bubble.left.and.bubble.right"))
                        .symbolRenderingMode(.hierarchical)
                    Text("\(count)")

                        .help(String(localized: "\(count) discussions"))
                }
                .font(.system(size: 12))
            } else {
                Text(Image(systemName: "gift.circle"))
                    .symbolRenderingMode(.hierarchical)
                    .help(String(localized: "Too much discussions"))
                    .font(.system(size: 12))
            }
        }
    }
}

struct CommentIcon_Previews: PreviewProvider {
    static var previews: some View {
        DiscussionCountIcon(count: 12, provider: .GitHub)
    }
}
