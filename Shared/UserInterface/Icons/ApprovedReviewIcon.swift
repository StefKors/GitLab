//
//  ApprovedReviewIcon.swift
//  GitLab
//
//  Created by Stef Kors on 22/06/2022.
//

#if os(iOS)
typealias PlatformImage = UIImage
#elseif os(macOS)
typealias PlatformImage = NSImage
#endif

import SwiftUI


struct ApprovedReviewIcon: View {
    var approvedBy: [Author]
    var account: Account?

    var instance: String {
        account?.instance ?? "https://gitlab.com"
    }

    var largeView: some View {
        HStack {
            Text("Approved")
            HStack(spacing: -4) {
                ForEach(approvedBy, id: \.id, content: { author in
                    UserAvatarView(author: author, account: account)
                })
            }
        }
        .font(.system(size: 11))
        .foregroundColor(.green)
        .padding(EdgeInsets(top: 2, leading: 5, bottom: 2, trailing: 2))
        .overlay(
            RoundedRectangle(cornerRadius: 20)
                .stroke(Color.green, lineWidth: 2)
                .opacity(0.3)
        )
        .padding(1)
        .help(String(localized: "Merge request approved"))
    }

    /// TODO: Diff in style from CI completed check circle
    var smallView: some View {
        Image(systemName: "checkmark.circle")
            .symbolRenderingMode(.hierarchical)
            .foregroundColor(.green)
            .font(.system(size: 18))
            .help(String(localized: "Merge request approved"))
            .clipShape(Rectangle())
        //        .frame(width: 20, height: 20)
    }

    var body: some View {
        ViewThatFits {
            largeView

            smallView
        }

    }
}

#Preview {
    ApprovedReviewIcon(approvedBy: [.preview], account: .preview)
}
