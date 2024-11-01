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
                if node.locked == false {
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
        let state: PullRequestState?
        let isDraft: Bool?
        let createdAt, updatedAt: Date?
        let baseRefName: String?
        let reviewDecision: ReviewDecision?
        let labels: Labels?
        let isInMergeQueue, locked: Bool?
        let mergeStateStatus: MergeStateStatus?
        let number: Int?
        let permalink: String?
        let repository: Repository?
        let reviews: Reviews?
        let comments: Comments?
        let reactions: Reactions?
        let commits: Commits?

        static let previewGitHub = PullRequestsNode(
            id: "PR_kwDOJOGhKc5diY36",
            title: "Site Summary Window",
            url: "https://github.com/beamlegacy/beam/pull/12",
            state: .open,
            isDraft: false,
            createdAt: Date.from("2023-10-23T14:21:50Z"),
            updatedAt: Date.from("2023-12-11T11:55:38Z"),
            baseRefName: "main",
            reviewDecision: .reviewRequired, labels: nil,
            isInMergeQueue: false,
            locked: false,
            mergeStateStatus: .dirty,
            number: 12,
            permalink: "https://github.com/beamlegacy/beam/pull/12",
            repository: .previewBeam,
            reviews: nil,
            comments: nil,
            reactions: nil,
            commits: nil
        )
    }

    enum PullRequestState: String, Codable, Equatable {
        /// A pull request that has been closed without being merged.
        case closed = "CLOSED"
        /// A pull request that has been closed by being merged.
        case merged = "MERGED"
        /// A pull request that is still open.
        case open = "OPEN"
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
        let isArchived: Bool?
        let url: String?
        let owner: Owner?

        static let previewBeam = Repository(
            name: "beam",
            id: "R_kgDOJOGhKQ",
            isLocked: false,
            isArchived: false,
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

    // MARK: - Commits
    struct Commits: Codable, Equatable {
        let nodes: [CommitsNode]?
    }

    // MARK: - CommitsNode
    struct CommitsNode: Codable, Equatable {
        let commit: Commit?
    }

    // MARK: - Commit
    struct Commit: Codable, Equatable {
        let statusCheckRollup: StatusCheckRollup?
    }

    // MARK: - StatusCheckRollup
    struct StatusCheckRollup: Codable, Equatable {
        let state: StatusCheckState?
        let contexts: Contexts?

        static let preview = StatusCheckRollup(
            state: .pending,
            contexts: Contexts(nodes: [.previewSuccess, .previewSuccess2, .previewPending])
        )

        static let previewSuccess = StatusCheckRollup(
            state: .success,
            contexts: Contexts(nodes: [.previewSuccess, .previewSuccess2])
        )
        static let previewRunning = StatusCheckRollup(
            state: .pending,
            contexts: Contexts(nodes: [.previewPending, .previewPending2])
        )
    }

    enum StatusCheckState: String, Codable, Equatable {
        /// Status is expected.
        case expected = "EXPECTED"
        /// Status is errored.
        case error = "ERROR"
        /// Status is failing.
        case failure = "FAILURE"
        /// Status is pending.
        case pending = "PENDING"
        /// Status is successful.
        case success = "SUCCESS"
    }

    // MARK: - Contexts
    struct Contexts: Codable, Equatable {
        let nodes: [ContextsNode]?
    }

    // MARK: - ContextsNode
    struct ContextsNode: Codable, Equatable {
        let name: String?
        let conclusion: CheckConclusionState?
        let detailsURL: String?
        let context: String?
        let description: String?
        let state: StatusCheckState?
        let targetURL: String?

        enum CodingKeys: String, CodingKey {
            case name, conclusion
            case detailsURL = "detailsUrl"
            case context, description, state
            case targetURL = "targetUrl"
        }

        static let previewSuccess = ContextsNode(
            name: "Success",
            conclusion: .success,
            detailsURL: "https://github.com/octocat/Hello-World/pull/1/checks",
            context: "success",
            description: "All tests passed",
            state: .success,
            targetURL: "https://github.com/octocat/Hello-World/pull/1"
        )

        static let previewSuccess2 = ContextsNode(
            name: "Success",
            conclusion: .success,
            detailsURL: "https://github.com/octocat/Hello-World/pull/2/checks",
            context: "success",
            description: "All tests passed",
            state: .success,
            targetURL: "https://github.com/octocat/Hello-World/pull/2"
        )

        static let previewFailure = ContextsNode(
            name: "Failure",
            conclusion: .failure,
            detailsURL: "https://github.com/octocat/Hello-World/pull/1/checks",
            context: "failure",
            description: "All tests failed",
            state: .failure,
            targetURL: "https://github.com/octocat/Hello-World/pull/1"
        )

        static let previewPending = ContextsNode(
            name: "Pending",
            conclusion: .neutral,
            detailsURL: "https://github.com/octocat/Hello-World/pull/1/checks",
            context: "pending",
            description: "All tests are pending",
            state: .pending,
            targetURL: "https://github.com/octocat/Hello-World/pull/1"
        )


        static let previewPending2 = ContextsNode(
            name: "Pending",
            conclusion: "pending",
            detailsURL: "https://github.com/octocat/Hello-World/pull/2/checks",
            context: "pending",
            description: "All tests are pending",
            state: .pending,
            targetURL: "https://github.com/octocat/Hello-World/pull/2"
        )
    }


    enum MergeStateStatus: String, Codable, Equatable {
        /// The merge commit cannot be cleanly created.
        case dirty = "DIRTY"
        /// The state cannot currently be determined.
        case unknown = "UNKNOWN"
        /// The merge is blocked.
        case blocked = "BLOCKED"
        /// The head ref is out of date.
        case behind = "BEHIND"
        /// Mergeable with non-passing commit status.
        case unstable = "UNSTABLE"
        /// Mergeable with passing commit status and pre-receive hooks.
        case hasHooks = "HAS_HOOKS"
        /// Mergeable and passing commit status.
        case clean = "CLEAN"
    }

    enum CheckConclusionState: String, Codable, Equatable {
        /// The check suite or run requires action.
        case actionRequired = "ACTION_REQUIRED"
        /// The check suite or run has timed out.
        case timedOut = "TIMED_OUT"
        /// The check suite or run has been cancelled.
        case cancelled = "CANCELLED"
        /// The check suite or run has failed.
        case failure = "FAILURE"
        /// The check suite or run has succeeded.
        case success = "SUCCESS"
        /// The check suite or run was neutral.
        case neutral = "NEUTRAL"
        /// The check suite or run was skipped.
        case skipped = "SKIPPED"
        /// The check suite or run has failed at startup.
        case startupFailure = "STARTUP_FAILURE"
        /// The check suite or run was marked stale by GitHub. Only GitHub can use this conclusion.
        case stale = "STALE"
    }

    // MARK: - Reactions
    struct Reactions: Codable, Equatable {
        let nodes: [ReactionsNode]?
    }

    // MARK: - ReactionsNode
    struct ReactionsNode: Codable, Equatable {
        let id: String?
        let user: Author?
    }

    // MARK: - Reviews
    struct Reviews: Codable, Equatable {
        let nodes: [ReviewsNode]?
    }

    enum ReviewDecision: String, Codable, Equatable {
        // The pull request has received an approving review.
        case approved = "APPROVED"
        // A review is required before the pull request can be merged.
        case reviewRequired = "REVIEW_REQUIRED"
        // Changes have been requested on the pull request.
        case changesRequested = "CHANGES_REQUESTED"
    }

    // MARK: - ReviewsNode
    struct ReviewsNode: Codable, Equatable {
        let id: String?
        let state: ReviewState?
        let author: Author?
    }

    enum ReviewState: String, Codable, Equatable {
        /// A review that has not yet been submitted.
        case pending = "PENDING"
        /// An informational review.
        case approved = "APPROVED"
        /// A review allowing the pull request to merge.
        case changesRequested = "CHANGES_REQUESTED"
        /// A review blocking the pull request from merging.
        case commented = "COMMENTED"
        /// A review that has been dismissed.
        case dismissed = "DISMISSED"
    }

    // MARK: - Author
    struct Author: Codable, Equatable {
        let avatarURL: String?
        let name: String?
        let login: String?

        enum CodingKeys: String, CodingKey {
            case avatarURL = "avatarUrl"
            case name, login
        }
    }}
