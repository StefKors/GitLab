//
//  ProjectLink.swift
//  GitLab
//
//  Created by Stef Kors on 23/06/2022.
//

import SwiftUI

struct WebLink: View {
    var linkText: String
    var destination: URL?
    @State var isHovering = false

    var body: some View {
        if let url = destination {
            HStack(spacing: 5) {
                Link(linkText, destination: url)
                    .onHover { hovering in
                        isHovering = hovering
                    }
            }.foregroundColor(isHovering ? .primary : .secondary)
                .animation(.interactiveSpring(), value: isHovering)
        } else {
            Text(linkText)
                .foregroundColor(.secondary)
        }
    }
}

