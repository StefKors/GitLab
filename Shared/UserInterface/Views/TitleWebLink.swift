//
//  TitleWebLink.swift
//  GitLab
//
//  Created by Stef Kors on 23/06/2022.
//

import SwiftUI

extension String {
    var isDraft: Bool {
        hasPrefix("WIP:") || hasPrefix("Draft:")
    }

    var removeDraft: String {
        replacingOccurrences(of: "WIP:", with: "", options: [.anchored, .caseInsensitive])
            .replacingOccurrences(of: "Draft:", with: "", options: [.anchored, .caseInsensitive])
            .trimmingCharacters(in: .whitespacesAndNewlines)
    }
}

/// the original variant
struct TitleWebLink: View {
    var linkText: String
    var destination: URL?
    var weight: Font.Weight = .bold
    @State var isHovering = false

    var textLabel: String {
        if linkText.isDraft {
            return linkText.removeDraft
        }

        return linkText
    }

    var TitleLabel: some View {
        HStack {
            if linkText.isDraft {
                Text("Draft")
                    .font(.footnote)
                    .padding(.vertical, 2)
                    .padding(.horizontal, 6)
                    .background(.quaternary, in: Capsule())
                    .foregroundColor(isHovering ? .accentColor  : .secondary)
            }

            Text(linkText.removeDraft)
                .fontWeight(weight)
                .foregroundColor(isHovering ? .accentColor  : .primary)
                .multilineTextAlignment(.leading)
        }
    }

    var body: some View {

        if let url = destination {
            Link(destination: url, label: {
                TitleLabel
            }).onHover { hovering in
                isHovering = hovering
            }
        } else {
            TitleLabel
        }
    }

}
