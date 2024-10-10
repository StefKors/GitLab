//
//  UserAvatarView.swift
//  GitLab
//
//  Created by Stef Kors on 10/10/2024.
//


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
