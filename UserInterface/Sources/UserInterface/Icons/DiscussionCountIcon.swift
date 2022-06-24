//
//  CommentIcon.swift
//  CommentIcon
//
//  Created by Stef Kors on 14/09/2021.
//

import SwiftUI

struct DiscussionCountIcon: View {
    var count: Int? = nil
    var body: some View {
        if let count = count, count > 1 {
            if count <= 50 {
                HStack {
                    Image(systemName: "bubble.left.and.bubble.right")
                        .symbolRenderingMode(.hierarchical)
                        .font(.system(size: 14))
                    Text("\(count)")
                        .font(.system(size: 12))
                        .help("\(count) discussions")
                }
            } else {
                Image(systemName: "gift.circle")
                    .symbolRenderingMode(.hierarchical)
                    .font(.system(size: 18))
                    .help("Too much discussions")
            }
        }
    }
}

struct CommentIcon_Previews: PreviewProvider {
    static var previews: some View {
        DiscussionCountIcon(count: 12)
    }
}
