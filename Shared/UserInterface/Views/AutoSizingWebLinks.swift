//
//  AutoSizingWebLinks.swift
//  GitLab
//
//  Created by Stef Kors on 19/04/2024.
//

import SwiftUI

struct AutoSizingWebLinks: View {
    var MR: MergeRequest

    var group: String {
        if let name = MR.targetProject?.group?.fullPath?.trimmingPrefix("/"), !name.isEmpty {
            return name + "/"
        }

        return ""
    }

    var path: String {
        if let name = MR.targetProject?.path?.trimmingPrefix("/"), !name.isEmpty {
            return name + "/"
        }

        return ""
    }

    var reference: String {
        if let name = MR.reference?.trimmingPrefix("/"), !name.isEmpty {
            return String(name)
        }

        return ""
    }

    var body: some View {
        ViewThatFits(in: .horizontal) {
            WebLink(
                linkText: group + path + reference,
                destination: MR.targetProject?.webURL
            )

            WebLink(
                linkText: path,
                destination: MR.targetProject?.webURL
            )

            WebLink(
                linkText: reference,
                destination: MR.targetProject?.webURL
            )

        }
        .frame(minWidth: 50, idealWidth: 320, maxWidth: 400, alignment: .leading)
    }

    //    var body: some View {
    //        ViewThatFits(in: .horizontal) {
    //            HStack {
    //                WebLink(
    //                    linkText: group + path + reference,
    //                    destination: MR.targetProject?.webURL
    //                )
    //            }
    //            .frame(minWidth: 50, idealWidth: 200, maxWidth: 400, alignment: .leading)
    //
    //            HStack {
    //                WebLink(
    //                    linkText: path + reference,
    //                    destination: MR.targetProject?.webURL
    //                )
    //            }
    //            .frame(minWidth: 50, idealWidth: 100, maxWidth: 400, alignment: .leading)
    //
    //            HStack {
    //                WebLink(
    //                    linkText: reference,
    //                    destination: MR.targetProject?.webURL
    //                )
    //            }
    //            .frame(minWidth: 50, idealWidth: 50, maxWidth: 400, alignment: .leading)
    //        }
    //        .frame(minWidth: 50, idealWidth: 320, maxWidth: 400, alignment: .leading)
    //    }
}

#Preview {
    VStack(alignment: .leading) {
        AutoSizingWebLinks(MR: .preview)
            .frame(width: 40, alignment: .leading)
            .border(Color.blue)
        AutoSizingWebLinks(MR: .preview)
            .frame(width: 110, alignment: .leading)
            .border(Color.blue)
        AutoSizingWebLinks(MR: .preview)
            .frame(width: 190, alignment: .leading)
            .border(Color.blue)
        AutoSizingWebLinks(MR: .preview)
            .frame(width: 290, alignment: .leading)
            .border(Color.blue)
    }
    .scenePadding()
}
