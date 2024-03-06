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
    
    @State private var isHovering = false
    
    var body: some View {
        if let url = destination {
            Link(linkText, destination: url)
                .onHover { hovering in
                    isHovering = hovering
                }
                .foregroundColor(isHovering ? .primary : .secondary)
                .animation(.interactiveSpring(), value: isHovering)
        } else {
            Text(linkText)
                .foregroundColor(.secondary)
        }
    }
}

