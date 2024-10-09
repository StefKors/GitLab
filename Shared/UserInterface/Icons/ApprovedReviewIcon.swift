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

struct UserAvatarView: View {
    let author: Author
    let account: Account?

    @Environment(\.isInWidget) private var isInWidget

    var body: some View {
        VStack {
            // TODO: ios support
            // TODO: cache data fetch response
            if isInWidget, let avatarUrl = author.avatarUrl, let data = try? Data(contentsOf: avatarUrl), let image = PlatformImage(data: data) {
#if os(iOS)
                Image(uiImage: image)
                    .resizable()
#elseif os(macOS)
                Image(nsImage: image)
                    .resizable()
#endif

            } else
            // Previously we used account.instace to create the base url
            if let avatarUrl = author.avatarUrl {
                AsyncImage(url: avatarUrl) { image in
                    image.resizable()
                } placeholder: {
                    Image(systemName: "person.circle.fill")
                        .symbolRenderingMode(.hierarchical)
                        .foregroundColor(.secondary)
                        .font(.system(size: 14))
                }
            }
        }
        .aspectRatio(contentMode: .fill)
        .clipShape(Circle())
        .frame(width: 14, height: 14)
        .help(author.username ?? "")
    }
}

#Preview {
    UserAvatarView(author: .preview, account: .preview)
}

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
        .help("Merge request approved")
    }

    /// TODO: Diff in style from CI completed check circle
    var smallView: some View {
        Image(systemName: "checkmark.circle")
            .symbolRenderingMode(.hierarchical)
            .foregroundColor(.green)
            .font(.system(size: 18))
            .help("Merge request approved")
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
