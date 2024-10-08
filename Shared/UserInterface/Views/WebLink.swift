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
            Link(destination: url, label: {
                Text(linkText)
                    .onHover { hovering in
                        isHovering = hovering
                    }
                    .foregroundColor(isHovering ? .primary : .secondary)
                    .animation(.interactiveSpring(), value: isHovering)
//                    .lineLimit(1)
//                    .truncationMode(.head)
            })
//            Link(linkText, destination: url)
        } else {
            Text(linkText)
                .foregroundColor(.secondary)
//                .lineLimit(1)
//                .truncationMode(.head)
        }
    }
}

#Preview {
    WebLink(linkText: "groupname/projectname!issuenumber", destination: URL(string: "https://gitlab.com"))
        .frame(width: 200)
}
