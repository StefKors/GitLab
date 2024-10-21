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

    private var names: String {
        approvedBy.map { author in
            return author.name ?? author.username ?? ""
        }.filter({ !$0.isEmpty}).formatted()
    }

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

                if isHovering {
                    HStack(spacing: -4) {
                        ForEach(approvers, id: \.id, content: { author, index in
                            UserAvatarView(author: author, account: account)
                                .foregroundStyle(.primary)
                                .transition(.move(edge: .trailing).combined(with: .opacity).combined(with: .scale).combined(with: .blurReplace).animation(.smooth.delay(index * 0.1)))
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
                        }
                    }
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
        .foregroundStyle(.green)
        .padding(.leading, 6)
        .padding(.trailing, 2)
        .padding(.vertical, 2)
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(Color.green)
                .opacity(0.2)
        )
        .animation(.smooth, value: approvedBy)
        .onHover(perform: { state in
            withAnimation(.snappy) {
                isHovering = state
            }
        })
        .help(String(localized: "Approved by \(names)"))
    }

    /// TODO: Diff in style from CI completed check circle
    var smallView: some View {
        Image(systemName: "checkmark")
            .symbolRenderingMode(.hierarchical)
            .foregroundStyle(.green.mix(with: .black, by: 0.2))
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
    @Previewable @State var authors: [Author] = [.preview]
    VStack {

        ApprovedReviewIcon(approvedBy: authors, account: .preview)
            .scenePadding()

        HStack {

        Button("+") {
            let author: Author? = [.preview, .preview2, .preview3, .preview4].randomElement()
            if let author {
                authors.append(author)
            }
        }

            Button("reset") {
                let author: Author? = [.preview, .preview2, .preview3, .preview4].randomElement()
                if let author {
                    authors = [author]
                }
            }

            Button("-") {
                _ = authors.popLast()
            }
        }

    }.scenePadding()
}

#Preview {
    VStack {
        ApprovedReviewIcon(approvedBy: [.preview4], account: .preview)
            .scenePadding()
        ApprovedReviewIcon(approvedBy: [.preview2, .preview3], account: .preview)
            .scenePadding()

        ApprovedReviewIcon(approvedBy: [.preview2, .preview3, .preview2], account: .preview)
            .scenePadding()

        ApprovedReviewIcon(approvedBy: [.preview2, .preview3, .preview2, .preview3], account: .preview)
            .scenePadding()


        ApprovedReviewIcon(approvedBy: [.preview, .preview2, .preview3, .preview2, .preview3, .preview, .preview2, .preview3, .preview2, .preview3], account: .preview)
            .scenePadding()

        ApprovedReviewIcon(approvedBy: [.preview, .preview2, .preview3], account: .preview)
            .scenePadding()

        ApprovedReviewIcon(approvedBy: [.preview], account: .preview)
            .scenePadding()
    }
    .scenePadding()
}
