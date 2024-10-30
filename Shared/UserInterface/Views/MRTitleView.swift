//
//  MRTitleView.swift
//  GitLab
//
//  Created by Stef Kors on 17/10/2024.
//


import SwiftUI

struct MRTitleView: View {
    var linkText: String
    var isLink: Bool = false
    var weight: Font.Weight = .semibold
    var isDraft: Bool = false

    @State private var isHovering = false

    var body: some View {
        HStack(alignment: .center, spacing: 4) {
            if isDraft {
                Text("Draft")
                    .font(.footnote)
                    .padding(.vertical, 2)
                    .padding(.horizontal, 6)
                    .background(.quaternary, in: Capsule())
                    .foregroundStyle(isHovering ? Color.accentColor  : .secondary)
                    .transition(.opacity.combined(with: .blurReplace).combined(with: .move(edge: .leading)))
            }

            Text(linkText.removeDraft)
                .fontWeight(weight)
                .foregroundStyle(isHovering ? Color.accentColor  : .primary)
                .multilineTextAlignment(.leading)
                .contentTransition(.interpolate)
        }
        .onHover { hovering in
            if isLink {
                isHovering = hovering
            }
        }

    }
}

#Preview {
    VStack(alignment: .leading) {
        MRTitleView(
            linkText: "GitHub Support + Improvements",
            isLink: true,
            isDraft: true
        )
        MRTitleView(
            linkText: "Draft: Fix MRTitleView preview",
            isLink: true
        )
        MRTitleView(
            linkText: "Fix MRTitleView preview",
            isLink: true,
            isDraft: true
        )
    }
        .scenePadding()
}
