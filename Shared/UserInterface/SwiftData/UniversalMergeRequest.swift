//
//  UniversalMergeRequest.swift
//  GitLab
//
//  Created by Stef Kors on 31/10/2024.
//

import SwiftUI
import SwiftData

@Model class UniversalMergeRequest: Equatable {
    #Unique<UniversalMergeRequest>([\.id, \.requestID])
    #Index<UniversalMergeRequest>([\.id])

    @Attribute(.unique) var id: String
    var requestID: String

    var createdAt: Date
    var provider: GitProvider
    var mergeRequest: GitLab.MergeRequest?
    var pullRequest: GitHub.PullRequestsNode?
    var account: Account
    var type: QueryType

    init(request: GitLab.MergeRequest, account: Account, provider: GitProvider, type: QueryType) {
        self.mergeRequest = request
        self.requestID = request.id
        self.id = request.id.deletingPrefix("gid://").replacingOccurrences(of: "/", with: "-")
        self.account = account
        self.provider = provider
        self.type = type
        self.createdAt = Date.from(request.createdAt) ?? Date.now
    }

    init(request: GitHub.PullRequestsNode, account: Account, provider: GitProvider, type: QueryType) {
        self.pullRequest = request
        self.requestID = request.id
        self.id = request.id
        self.account = account
        self.provider = provider
        self.type = type
        self.createdAt = request.createdAt ?? Date.now
    }

    var title: String? {
        switch provider {
        case .GitHub: return pullRequest?.title
        case .GitLab: return mergeRequest?.title?.removeDraft
        }
    }

    var updatedAt: Date {
        switch provider {
        case .GitLab:
            Date.from(mergeRequest?.updatedAt) ?? Date.now
        case .GitHub:
            pullRequest?.updatedAt ?? Date.now
        }
    }

    var isDraft: Bool {
        switch provider {
        case .GitHub: return pullRequest?.isDraft ?? false
        case .GitLab: return mergeRequest?.title?.isDraft ?? false
        }
    }

    var url: URL? {
        switch provider {
        case .GitHub:
            if let url = pullRequest?.url {
                return URL(string: url)
            } else {
                return nil
            }
        case .GitLab: return mergeRequest?.webUrl
        }
    }

    var repoUrl: URL? {
        switch provider {
        case .GitHub:
            if let url = pullRequest?.repository?.url {
                return URL(string: url)
            } else {
                return nil
            }
        case .GitLab: return mergeRequest?.targetProject?.webURL
        }
    }

    var repoName: String? {
        switch provider {
        case .GitHub: return pullRequest?.repository?.name
        case .GitLab: return mergeRequest?.targetProject?.name
        }
    }

    var repoOwner: String? {
        switch provider {
        case .GitHub: return pullRequest?.repository?.owner?.login
        case .GitLab: return mergeRequest?.targetProject?.group?.name
        }
    }

    var repoImage: URL? {
        switch provider {
        case .GitHub: return pullRequest?.repository?.owner?.avatarUrl
        case .GitLab: return mergeRequest?.targetProject?.avatarUrl
        }
    }

    var repoId: String? {
        switch provider {
        case .GitHub: return pullRequest?.repository?.owner?.id
        case .GitLab: return mergeRequest?.targetProject?.id
        }
    }


    var number: String? {
        switch provider {
        case .GitHub: return pullRequest?.number?.description
        case .GitLab: return mergeRequest?.reference
        }
    }

    var sourceBranch: String? {
        switch provider {
        case .GitHub: return nil
        case .GitLab: return mergeRequest?.sourceBranch
        }
    }

    var targetBranch: String? {
        switch provider {
        case .GitHub: return pullRequest?.baseRefName
        case .GitLab: return mergeRequest?.targetBranch
        }
    }

    var draft: Bool? {
        switch provider {
        case .GitHub: return pullRequest?.isDraft
        case .GitLab: return mergeRequest?.draft
        }
    }

    var discussionCount: Int? {
        switch provider {
        case .GitHub: return pullRequest?.totalCommentsCount ?? 0
        case .GitLab: return mergeRequest?.userDiscussionsCount
        }
    }

    var approvals: [Approval]? {
        switch provider {
        case .GitHub: return pullRequest?.reviews?.nodes?.compactMap { node in
            if node.state == .approved, let author = node.author {
                return Approval(author: author)
            }
            return nil
        }.uniqueElements(byProperty: \.username)
        case .GitLab: return mergeRequest?.approvedBy?.edges?.compactMap { node in
            if let author = node.node {
                return Approval(author: author)
            }
            return nil
        }.uniqueElements(byProperty: \.username)
        }
    }

    var isApproved: Bool {
        switch provider {
        case .GitHub: return pullRequest?.reviewDecision == .approved
        case .GitLab: return (approvals?.count ?? 0) > 0
        }

    }
}

extension UniversalMergeRequest {
    static let preview = UniversalMergeRequest(
        request: .preview,
        account: .preview,
        provider: .GitLab,
        type: .authoredMergeRequests
    )

    static let preview2 = UniversalMergeRequest(
        request: .preview2,
        account: .preview,
        provider: .GitLab,
        type: .authoredMergeRequests
    )

    static let preview3 = UniversalMergeRequest(
        request: .preview3,
        account: .preview,
        provider: .GitLab,
        type: .authoredMergeRequests
    )

    static let preview4 = UniversalMergeRequest(
        request: .preview4,
        account: .preview,
        provider: .GitLab,
        type: .authoredMergeRequests
    )

    static let previewGitHub = UniversalMergeRequest(
        request: .previewGitHub,
        account: .previewGitHub,
        provider: .GitHub,
        type: .authoredMergeRequests
    )
}

// extension MergeRequest: CustomDebugStringConvertible {
//    var debugDescription: String {
//        return "MergeRequest(mergerequestID: \(mergerequestID ?? "nil"), title: \(title ?? "nil"))"
//    }
// }

struct Approval: Codable, Equatable, Identifiable, Hashable {
    let id: String
    let name: String?
    let username: String?
    let picture: URL?

    init(id: String, name: String?, username: String?, picture: URL?) {
        self.id = id
        self.name = name
        self.username = username
        self.picture = picture
    }

    init(author: GitLab.Author) {
        self.id = author.id ?? UUID().uuidString
        self.name = author.name
        self.username = author.username
        self.picture = author.avatarUrl
    }

    init(author: GitHub.Author) {
        self.id = UUID().uuidString
        self.name = author.login
        self.username = author.login
        if let url = author.avatarURL {
            self.picture = URL(string: url)
        } else {
            self.picture = nil
        }
    }

    static let preview = Approval(author: .preview)
    static let preview2 = Approval(author: .preview2)
    static let preview3 = Approval(author: .preview3)
    static let preview4 = Approval(author: .preview4)
}
