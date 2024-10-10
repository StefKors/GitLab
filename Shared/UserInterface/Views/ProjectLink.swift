//
//  ProjectLink.swift
//  GitLab
//
//  Created by Stef Kors on 19/04/2024.
//

import SwiftUI

struct ProjectLink: View {
    let group: String?
    let project: String?
    let reference: String?

    let destination: URL?

    var long: String {
        [group, project, reference].compactMap({ $0 }).joined(separator: "/")
    }

    var medium: String {
        [project, reference].compactMap({ $0 }).joined(separator: "/")
    }

    var short: String {
        [reference].compactMap({ $0 }).joined(separator: "/")
    }



    var body: some View {
        ViewThatFits {
            WebLink(
                linkText: long,
                destination: destination
            )

            WebLink(
                linkText: medium,
                destination: destination
            )

            WebLink(
                linkText: short,
                destination: destination
            )
        }
    }
}

#Preview {
    VStack(alignment: .leading) {
        ProjectLink(
            group: "MonstersInc",
            project: "ScreamCollector",
            reference: "!2342",
            destination: URL(string: "https://gitlab.com")!
        )
        .frame(maxWidth: 320)

        ProjectLink(
            group: "MonstersInc",
            project: "ScreamCollector",
            reference: "!2342",
            destination: URL(string: "https://gitlab.com")!
        )
        .frame(maxWidth: 170)

        ProjectLink(
            group: "MonstersInc",
            project: "ScreamCollector",
            reference: "!2342",
            destination: URL(string: "https://gitlab.com")!
        )
        .frame(maxWidth: 40)
    }
    .scenePadding()
}
