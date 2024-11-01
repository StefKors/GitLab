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
    @Environment(\.colorScheme) private var colorScheme
    var approvedBy: [Approval]
    var account: Account?

    private var instance: String {
        account?.instance ?? "https://gitlab.com"
    }

    //    @State private var isHovering: Bool = false

    private var names: String {
        approvedBy.map { author in
            return author.name ?? author.username ?? ""
        }.filter({ !$0.isEmpty}).formatted()
    }

    var largeView: some View {
        HStack {
            Image(systemName: "checkmark")
                .font(.system(size: 9, weight: .semibold))
                .help(String(localized: "Merge request approved"))
//                .clipShape(Rectangle())
                .padding(.vertical, 2)

            HStack {
                Text("Approved")
                    .fixedSize()

                AvatarRowView(approvedBy: approvedBy, account: account)
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
        .foregroundStyle(.green.mix(with: .black, by: colorScheme == .dark ? 0 : 0.2))
        .padding(.leading, 6)
        .padding(.trailing, approvedBy.count > 0 ? 2 : 8)
        .padding(.vertical, 2)
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(Color.green.gradient.quinary)
        )
        .animation(.smooth, value: approvedBy)
        //        .onHover(perform: { state in
        //            withAnimation(.snappy) {
        //                isHovering = state
        //            }
        //        })
        .help(String(localized: "Approved by \(names)"))
    }

    /// TODO: Diff in style from CI completed check circle
    var smallView: some View {
        HStack {
            Image(systemName: "checkmark")
                .font(.system(size: 9, weight: .semibold))
                .help(String(localized: "Merge request approved"))
                .clipShape(Rectangle())
                .padding(.vertical, 2)
        }
        .foregroundStyle(.green)
        .frame(width: 18, height: 18, alignment: .center)
        .background(
            Circle()
                .fill(Color.green)
                .opacity(0.2)
        )
        .animation(.smooth, value: approvedBy)
    }

    var body: some View {
        VStack(alignment: .trailing) {
            ViewThatFits(in: .horizontal, content: {
                largeView

                smallView
            })
        }
        .transition(.move(edge: .trailing).combined(with: .opacity).combined(with: .blurReplace).animation(.smooth))
    }
}

#Preview("Change authors") {
    @Previewable @State var authors: [Approval] = [.preview]
    VStack {

        ApprovedReviewIcon(approvedBy: authors, account: .preview)
            .scenePadding()

        HStack {

            Button("+") {
                let author: Approval? = [.preview, .preview2, .preview3, .preview4].randomElement()
                if let author {
                    authors.append(author)
                }
            }

            Button("reset") {
                let author: Approval? = [.preview, .preview2, .preview3, .preview4].randomElement()
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

#Preview("Toggle Approved Icon") {
    @Previewable @State var show = false
    VStack {
        HStack {
            Text("MR Title")

            Spacer()

            if show {
                ApprovedReviewIcon(approvedBy: [.preview2, .preview3], account: .preview)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .scenePadding()

        Button("toggle") {
            withAnimation {
                show.toggle()
            }
        }
    }.frame(width: 400, height: 300).scenePadding()
}

#Preview("Variations") {
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

        GroupBox("Small", content: {
            ApprovedReviewIcon(approvedBy: [.preview, .preview2, .preview3, .preview2, .preview3, .preview, .preview2, .preview3, .preview2, .preview3], account: .preview)
                .scenePadding()
        })
        .frame(maxWidth: 100)

        GroupBox("Large", content: {
            ApprovedReviewIcon(approvedBy: [.preview, .preview2, .preview3, .preview2, .preview3, .preview, .preview2, .preview3, .preview2, .preview3], account: .preview)
                .scenePadding()
        })
        .frame(maxWidth: 200)
        .scenePadding()
    }
    .scenePadding()
}
