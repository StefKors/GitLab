//
//  AvatarRowView.swift
//  GitLab
//
//  Created by Stef Kors on 21/10/2024.
//


import SwiftUI

struct AvatarRowView: View {
    let approvedBy: [Author]
    let account: Account?

    private let maxSize = 3

    private var moreApprovers: Int {
        approvedBy.count - maxSize
    }

    private var approvers: [Author] {
        if approvedBy.count > maxSize {
            return Array(approvedBy.prefix(maxSize - 1))
        } else {
            return Array(approvedBy.prefix(maxSize))
        }
    }


    var body: some View {
        HStack(spacing: -4) {
            ForEach(Array(approvers.enumerated()), id: \.element, content: { index, author in
                UserAvatarView(author: author, account: account)
                    .foregroundStyle(.primary)
                    .transition(.move(edge: .trailing).combined(with: .opacity).combined(with: .scale).combined(with: .blurReplace).animation(.smooth))
            })

            if approvedBy.count > maxSize {
                Text(Image(systemName: "plus"))
                    .foregroundStyle(.primary)
                    .frame(width: 14, height: 14, alignment: .center)
                    .font(.system(size: 8, weight: .semibold))
                    .textCase(.uppercase)
                    .aspectRatio(contentMode: .fill)
                    .background {
                        Circle()
                            .stroke(lineWidth: 1)
                            .foregroundStyle(.primary)
                            .background(.tertiary)
                            .background(.background)
                    }
                    .overlay(content: {
                        Circle()
                            .stroke(lineWidth: 2)
                            .foregroundStyle(.primary)
                    })
                    .clipShape(Circle())
                    .frame(width: 14, height: 14)
                    .transition(.move(edge: .trailing).combined(with: .opacity).combined(with: .scale).combined(with: .blurReplace).animation(.smooth))
            }
        }
    }
}

#Preview {
    VStack {
        AvatarRowView(approvedBy: [.preview4], account: .preview)
            .scenePadding()
        AvatarRowView(approvedBy: [.preview2, .preview3], account: .preview)
            .scenePadding()

        AvatarRowView(approvedBy: [.preview2, .preview3, .preview2], account: .preview)
            .scenePadding()

        AvatarRowView(approvedBy: [.preview2, .preview3, .preview2, .preview3], account: .preview)
            .scenePadding()


        AvatarRowView(approvedBy: [.preview, .preview2, .preview3, .preview2, .preview3, .preview, .preview2, .preview3, .preview2, .preview3], account: .preview)
            .scenePadding()

        AvatarRowView(approvedBy: [.preview, .preview2, .preview3], account: .preview)
            .scenePadding()

        AvatarRowView(approvedBy: [.preview], account: .preview)
            .scenePadding()
    }
    .scenePadding()
}
