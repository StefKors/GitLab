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
                    image
                        .resizable()
                        .transition(.opacity.combined(with: .scale).combined(with: .blurReplace))
                } placeholder: {
                    if let name = (author.name ?? author.username)?.first {
                        Text(String(name))
                            .foregroundStyle(.primary)
                            .frame(width: 14, height: 14, alignment: .center)
                            .font(.system(size: 8, weight: .semibold))
                            .textCase(.uppercase)
                            .contentTransition(.interpolate)
                    } else {
                        Text(Image(systemName: "person.fill"))
                            .foregroundStyle(.primary)
                            .foregroundStyle(.secondary)
                            .font(.system(size: 8, weight: .semibold))
                            .clipShape(Circle())
                            .frame(width: 14, height: 14)
                    }
                }
            } else if let name = (author.name ?? author.username)?.first {
                Text(String(name))
                    .foregroundStyle(.primary)
                    .frame(width: 14, height: 14, alignment: .center)
                    .font(.system(size: 8, weight: .semibold))
                    .textCase(.uppercase)
                    .contentTransition(.interpolate)
            } else {
                Text(Image(systemName: "person.fill"))
                    .foregroundStyle(.primary)
                    .foregroundStyle(.secondary)
                    .font(.system(size: 8, weight: .semibold))
                    .clipShape(Circle())
                    .frame(width: 14, height: 14)
            }
        }
        .aspectRatio(contentMode: .fill)
        .background {
            Circle()
                .stroke(lineWidth: 1)
                .foregroundStyle(.primary)
//                .background(.tertiary)
//                .background(.background)
        }
        .overlay(content: {
            Circle()
                .stroke(lineWidth: 2)
                .foregroundStyle(.primary)
        })
        .clipShape(Circle())
        .frame(width: 14, height: 14)
        .help((author.name ?? author.username) ?? "")
    }
}

#Preview {
    VStack {

        UserAvatarView(author: .preview, account: .preview)

        HStack(spacing: -4) {
            UserAvatarView(author: .preview, account: .preview)
            UserAvatarView(author: .preview2, account: .preview)
            UserAvatarView(author: .preview3, account: .preview)
        }

        HStack(spacing: -4) {
            UserAvatarView(author: .preview3, account: .preview)
            UserAvatarView(author: .preview4, account: .preview)
            UserAvatarView(author: .preview3, account: .preview)
        }

    }.scenePadding()
}
