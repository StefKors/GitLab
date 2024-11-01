//
//  AutoSizingWebLinks.swift
//  GitLab
//
//  Created by Stef Kors on 19/04/2024.
//

import SwiftUI

struct GitLabAutoSizingWebLinks: View {
    var request: GitLab.MergeRequest

    // spaced with "thin width space"
    // https://www.compart.com/en/unicode/U+2009
    var group: String {
        if let name = request.targetProject?.group?.fullPath?.trimmingPrefix("/"), !name.isEmpty {
            return name + " / "
        }

        return ""
    }

    var path: String {
        if let name = request.targetProject?.path?.trimmingPrefix("/"), !name.isEmpty {
            return name + " / "
        }

        return ""
    }

    var reference: String {
        if let name = request.reference?.trimmingPrefix("/"), !name.isEmpty {
            return String(name)
        }

        return ""
    }

    var body: some View {
        ViewThatFits(in: .horizontal) {
            Text(group + path + reference)
                .foregroundStyle(.secondary)

            Text(path + reference)
                .foregroundStyle(.secondary)

            Text(reference)
                .foregroundStyle(.secondary)
        }
        .frame(minWidth: 50, idealWidth: 320, maxWidth: 400, alignment: .leading)
        .buttonStyle(.plain)
    }
}

struct GitHubAutoSizingWebLinks: View {
    var MR: GitHub.PullRequestsNode

    // spaced with "thin width space"
    // https://www.compart.com/en/unicode/U+2009
    var group: String {
        if let name = MR.repository?.owner?.login, !name.isEmpty {
            return name + " / "
        }

        return ""
    }

    var path: String {
        if let name = MR.repository?.name, !name.isEmpty {
            return name + " / "
        }

        return ""
    }

    var reference: String {
        if let name = MR.number?.description, !name.isEmpty {
            return String(name)
        }

        return ""
    }

    var url: URL? {
        if let url = MR.url {
            return URL(string: url)
        } else {
            return nil
        }
    }

    var body: some View {
        ViewThatFits(in: .horizontal) {
            Text(group + path + reference)
                .foregroundStyle(.secondary)

            Text(path + reference)
                .foregroundStyle(.secondary)

            Text(reference)
                .foregroundStyle(.secondary)
        }
        .frame(minWidth: 50, idealWidth: 320, maxWidth: 400, alignment: .leading)
        .buttonStyle(.plain)
    }
}

struct AutoSizingWebLinks: View {
    var request: UniversalMergeRequest

    var body: some View {
        if let request = request.mergeRequest {
            GitLabAutoSizingWebLinks(request: request)
        } else if let request = request.pullRequest {
            GitHubAutoSizingWebLinks(MR: request)
        }
    }
}

#Preview {
    VStack(alignment: .leading) {
        AutoSizingWebLinks(request: .preview)
            .frame(width: 40, alignment: .leading)
            .border(Color.blue)
        AutoSizingWebLinks(request: .preview)
            .frame(width: 110, alignment: .leading)
            .border(Color.blue)
        AutoSizingWebLinks(request: .preview)
            .frame(width: 190, alignment: .leading)
            .border(Color.blue)
        AutoSizingWebLinks(request: .preview)
            .frame(width: 290, alignment: .leading)
            .border(Color.blue)
    }
    .scenePadding()
}
