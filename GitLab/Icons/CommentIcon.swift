//
//  CommentIcon.swift
//  CommentIcon
//
//  Created by Stef Kors on 14/09/2021.
//

import SwiftUI

struct CommentIcon: View {
    var count: Int? = nil
    var body: some View {
        if let count = count {
            let counter = count <= 50 ? "\(count).circle.fill" : "gift.circle.fill"
            ZStack {
                Image(systemName: counter)
                    .foregroundColor(.accentColor)
                    .font(.system(size: 18))
            }
        }
    }
}

struct CommentIcon_Previews: PreviewProvider {
    static var previews: some View {
        CommentIcon(count: 12)
    }
}
