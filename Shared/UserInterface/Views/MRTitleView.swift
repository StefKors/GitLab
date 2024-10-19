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

    @State private var isHovering = false

    private var textLabel: String {
        if linkText.isDraft {
            return linkText.removeDraft
        }

        return linkText
    }

    var body: some View {
        HStack(alignment: .firstTextBaseline, spacing: 4) {
            if linkText.isDraft {
                Text("Draft")
                    .font(.footnote)
                    .padding(.vertical, 2)
                    .padding(.horizontal, 6)
                    .background(.quaternary, in: Capsule())
                    .foregroundColor(isHovering ? .accentColor  : .secondary)
                    .transition(.opacity.combined(with: .blurReplace).combined(with: .move(edge: .leading)))
            }

            Text(linkText.removeDraft)
                .fontWeight(weight)
                .foregroundColor(isHovering ? .accentColor  : .primary)
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
    MRTitleView(linkText: "Draft: Fix MRTitleView preview", isLink: true)
        .scenePadding()
}
