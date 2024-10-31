//
//  StructsGitHub.swift
//  GitLab
//
//  Created by Stef Kors on 30/10/2024.
//

import Foundation
import SwiftData

class GitHub {
    // MARK: - GitHubQuery
    struct Query: Codable, Equatable {
        let data: DataClass

        var authoredMergeRequests: [GitHub.PullRequestsNode] {
            return self.data.viewer?.pullRequests?.nodes?.compactMap({ node in
                if (node.locked == false)  {
                    return node
                } else {
                    return nil
                }
            }) ?? []
        }
    }

    // MARK: - DataClass
    struct DataClass: Codable, Equatable {
        let viewer: Viewer?
    }

    // MARK: - Viewer
    struct Viewer: Codable, Equatable {
        let pullRequests: PullRequests?
    }

    // MARK: - PullRequestsNode
    struct PullRequestsNode: Codable, Equatable, Identifiable {
        let id: String
        let title: String?
        let url: String?
        let state: String?
        let isDraft: Bool?
        let createdAt, updatedAt: Date?
        let baseRefName: String?
        let labels: Labels?
        let isInMergeQueue, locked: Bool?
        let mergeStateStatus: String?
        let number: Int?
        let permalink: String?
        let repository: Repository?
        let reviewDecision: String?
        let reviews: Reviews?
        let comments: Comments?

        static let previewGitHub = PullRequestsNode(
            id: "PR_kwDOJOGhKc5diY36",
            title: "Site Summary Window",
            url: "https://github.com/beamlegacy/beam/pull/12",
            state: "OPEN",
            isDraft: false,
            createdAt: Date.from("2023-10-23T14:21:50Z"),
            updatedAt: Date.from("2023-12-11T11:55:38Z"),
            baseRefName: "main",
            labels: nil,
            isInMergeQueue: false,
            locked: false,
            mergeStateStatus: "DIRTY",
            number: 12,
            permalink: "https://github.com/beamlegacy/beam/pull/12",
            repository: .previewBeam,
            reviewDecision: "REVIEW_REQUIRED",
            reviews: nil,
            comments: nil
        )
    }

    // MARK: - PullRequests
    struct PullRequests: Codable, Equatable {
        let nodes: [PullRequestsNode]?
    }

    // MARK: - Labels
    struct Labels: Codable, Equatable {
        let nodes: [LabelsNode]?
    }

    // MARK: - LabelsNode
    struct LabelsNode: Codable, Equatable {
        let id, name, color: String?
        let isDefault: Bool?
    }

    // MARK: - Repository
    struct Repository: Codable, Equatable {
        let name, id: String?
        let isLocked: Bool?
        let url: String?
        let owner: Owner?

        static let previewBeam = Repository(
            name: "beam",
            id: "R_kgDOJOGhKQ",
            isLocked: false,
            url: "https://github.com/beamlegacy/beam",
            owner: .previewBeam
        )
    }

    // MARK: - Comments
    struct Comments: Codable, Equatable {
        let nodes: [CommentsNode]?
    }

    // MARK: - CommentsNode
    struct CommentsNode: Codable, Equatable {
        let id: String?
        let author: Owner?
        let bodyText: String?
    }

    // MARK: - Owner
    struct Owner: Codable, Equatable {
        let login: String?

        static let previewBeam = Owner(login: "beamLegacy")
    }

    // MARK: - Reviews
    struct Reviews: Codable, Equatable {
        let nodes: [ReviewsNode]?
    }

    // MARK: - ReviewsNode
    struct ReviewsNode: Codable, Equatable {
        let id: String?
        let state: String?
//        PENDING
//        A review that has not yet been submitted.
//
//        COMMENTED
//        An informational review.
//
//        APPROVED
//        A review allowing the pull request to merge.
//
//        CHANGES_REQUESTED
//        A review blocking the pull request from merging.
//
//        DISMISSED
//        A review that has been dismissed.
        let author: Author?
    }

    // MARK: - Author
    struct Author: Codable, Equatable {
        let avatarURL: String?
        let login: String?

        enum CodingKeys: String, CodingKey {
            case avatarURL = "avatarUrl"
            case login
        }
    }
}
