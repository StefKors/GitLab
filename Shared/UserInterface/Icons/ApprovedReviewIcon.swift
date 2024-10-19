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

    private var instance: String {
        account?.instance ?? "https://gitlab.com"
    }

    @State private var isHovering: Bool = false

    var largeView: some View {
        HStack() {
            Image(systemName: "checkmark")
                .font(.system(size: 9, weight: .semibold))
                .help(String(localized: "Merge request approved"))
                .clipShape(Rectangle())
                .padding(.vertical, 2)


                HStack {
                    Text("Approved")
                        .fixedSize()
                    HStack(spacing: -4) {
                        ForEach(approvedBy, id: \.id, content: { author in
                            UserAvatarView(author: author, account: account)
                        })
                    }
                }
                    .font(.system(size: 11, weight: .regular))
                    .transition(
                        .opacity
                            .combined(with: .scale(0, anchor: .leading)
                                .animation(.snappy.delay(0.1))
                                .combined(with: .blurReplace)
                            )
                            .animation(.snappy)
                    )

        }
        .foregroundColor(.green.mix(with: .black, by: 0.2))
        .padding(.leading, 6)
        .padding(.trailing, 2)
        .padding(.vertical, 2)
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(Color.green)
                .opacity(0.2)
        )
        .onHover(perform: { state in
            withAnimation(.snappy) {
                isHovering = state
            }
        })
        .help(String(localized: "Merge request approved"))
    }

    /// TODO: Diff in style from CI completed check circle
    var smallView: some View {
        Image(systemName: "checkmark")
            .symbolRenderingMode(.hierarchical)
            .foregroundColor(.green.mix(with: .black, by: 0.2))
            .padding(4)
            .overlay(
                RoundedRectangle(cornerRadius: 20)
                    .fill(Color.green)
                    .opacity(0.2)
            )
            .font(.system(size: 10, weight: .semibold))
            .help(String(localized: "Merge request approved"))
            .clipShape(Rectangle())
        //        .frame(width: 20, height: 20)
    }

    var body: some View {
        largeView
//        ViewThatFits {
//            largeView
//
//            smallView
//        }

    }
}

#Preview {
    VStack {

        ApprovedReviewIcon(approvedBy: [.preview], account: .preview)
            .scenePadding()

        GroupBox {
            HStack {
                ApprovedReviewIcon(approvedBy: [.preview], account: .preview)
                    .scenePadding()

                Text("title")
            }
            .frame(maxWidth: 100)
        }
    }
    .scenePadding()
}
