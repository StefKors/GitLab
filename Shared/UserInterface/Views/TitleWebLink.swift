//
//  TitleWebLink.swift
//  GitLab
//
//  Created by Stef Kors on 23/06/2022.
//

import SwiftUI

struct LongTitleWebLink: View {
    var linkText: String
    var destination: URL?
    @State var isHovering = false

    var body: some View {
        let text = Text(linkText)
            .fontWeight(.bold)
            .foregroundColor(isHovering ? .accentColor  : .primary)
            .animation(.interactiveSpring(), value: isHovering)
            .multilineTextAlignment(.leading)

        if let url = destination {
            Link(destination: url, label: {
                text
            }).onHover { hovering in
                isHovering = hovering
            }
        } else {
            text
        }
    }
}

struct ShortTitleWebLink: View {
    var linkText: String
    var destination: URL?
    @State var isHovering = false

    var body: some View {
        let text = Text(linkText)
            .fontWeight(.bold)
            .foregroundColor(isHovering ? .accentColor  : .primary)
            .animation(.interactiveSpring(), value: isHovering)
            .multilineTextAlignment(.leading)

        if let url = destination {
            Link(destination: url, label: {
                text
            }).onHover { hovering in
                isHovering = hovering
            }
        } else {
            text
        }
    }
}

/// the original variant
struct TitleWebLink: View {
    var linkText: String
    var destination: URL?
    @State var isHovering = false
    
    var body: some View {
        let text = Text(linkText)
            .fontWeight(.bold)
            .foregroundColor(isHovering ? .accentColor  : .primary)
            .animation(.interactiveSpring(), value: isHovering)
            .multilineTextAlignment(.leading)

        if let url = destination {
            Link(destination: url, label: {
                text
            }).onHover { hovering in
                isHovering = hovering
            }
        } else {
            text
        }
    }
    
}
