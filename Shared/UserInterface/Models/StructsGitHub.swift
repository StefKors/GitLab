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
            contexts: Contexts(nodes: [.previewSuccess, .previewSuccess2, .previewInProgress])
        )

        static let previewSuccess = StatusCheckRollup(
            state: .success,
            contexts: Contexts(nodes: [.previewSuccess, .previewSuccess2])
        )
        static let previewRunning = StatusCheckRollup(
            state: .pending,
            contexts: Contexts(nodes: [.previewInProgress, .previewInProgress2])
        )
    }

    // MARK: - Contexts
    struct Contexts: Codable, Equatable {
        let nodes: [ContextsNode]?
    }

    // MARK: - ContextsNode
    struct ContextsNode: Codable, Equatable, Hashable {
        let id: String
        let name: String?
        let conclusion: CheckConclusionState?
        let detailsURL: String?
        let context: String?
        let description: String?
        let state: StatusCheckState? // always null?
        let status: CheckStatusState?
        let targetURL: String?
        let steps: Steps?

        enum CodingKeys: String, CodingKey {
            case id
            case name, conclusion
            case detailsURL = "detailsUrl"
            case context, description, state, status
            case targetURL = "targetUrl"
            case steps
        }

        static let previewSuccess = ContextsNode(
            id: "CR_kwDOJO0j5s8AbbbbHiqSLJQ",
            name: "Success",
            conclusion: .success,
            detailsURL: "https://github.com/octocat/Hello-World/pull/1/checks",
            context: "success",
            description: "All tests passed",
            state: .success,
            status: .completed,
            targetURL: "https://github.com/octocat/Hello-World/pull/1",
            steps: Steps(nodes: [.previewCheckout, .previewSetup])

        )

        static let previewSuccess2 = ContextsNode(
            id: "CR_kwDOJO0j5ssssssAAHiqSLJQ",
            name: "Success",
            conclusion: .success,
            detailsURL: "https://github.com/octocat/Hello-World/pull/2/checks",
            context: "success",
            description: "All tests passed",
            state: .success,
            status: .completed,
            targetURL: "https://github.com/octocat/Hello-World/pull/2",
            steps: Steps(nodes: [.previewCheckout, .previewComplete])

        )

        static let previewFailure = ContextsNode(
            id: "CR_kwDOJO0j5s8AAAAHiqwer3425",
            name: "Failure",
            conclusion: .failure,
            detailsURL: "https://github.com/octocat/Hello-World/pull/1/checks",
            context: "failure",
            description: "All tests failed",
            state: .failure,
            status: .completed,
            targetURL: "https://github.com/octocat/Hello-World/pull/1",
            steps: Steps(nodes: [.previewCheckout, .previewBuild])

        )

        static let previewInProgress = ContextsNode(
            id: "CR_kwDOJO0j53453453AAAHiqSLJQ",
            name: "Pending",
            conclusion: nil,
            detailsURL: "https://github.com/octocat/Hello-World/pull/1/checks",
            context: "pending",
            description: "All tests are pending",
            state: .pending,
            status: .inProgress,
            targetURL: "https://github.com/octocat/Hello-World/pull/1",
            steps: Steps(nodes: [.previewCheckout, .previewTestsRunning])

        )

        static let previewInProgress2 = ContextsNode(
            id: "CR_kwDOJO0j545345345AAAHi234234JQ",
            name: "Pending",
            conclusion: nil,
            detailsURL: "https://github.com/octocat/Hello-World/pull/2/checks",
            context: "pending",
            description: "All tests are pending",
            state: .pending,
            status: .inProgress,
            targetURL: "https://github.com/octocat/Hello-World/pull/2",
            steps: Steps(nodes: [.previewCheckout, .previewTestsRunning])

        )
    }

    //
    // Hashable or Equatable:
    // The compiler will not be able to synthesize the implementation of Hashable or Equatable
    // for types that require the use of JSONAny, nor will the implementation of Hashable be
    // synthesized for types that have collections (such as arrays or dictionaries).

    // MARK: - Steps
    struct Steps: Codable, Equatable, Hashable {
        let nodes: [StepsNode]?
    }

    //
    // Hashable or Equatable:
    // The compiler will not be able to synthesize the implementation of Hashable or Equatable
    // for types that require the use of JSONAny, nor will the implementation of Hashable be
    // synthesized for types that have collections (such as arrays or dictionaries).

    // MARK: - StepsNode
    struct StepsNode: Codable, Equatable, Hashable {
        let externalID, name: String?
        let number, secondsToCompletion: Int?
        let status: CheckStatusState?
        let conclusion: CheckConclusionState?

        enum CodingKeys: String, CodingKey {
            case externalID = "externalId"
            case name, number, secondsToCompletion, status, conclusion
        }

        static let previewSetup = StepsNode(
            externalID: "93f6797a-d3bb-4a26-9981-5e0831ba29df",
            name: "Set up job",
            number: 1,
            secondsToCompletion: 2,
            status: .completed,
            conclusion: .success
        )
        static let previewSwift = StepsNode(
            externalID: "9511a5d9-44d1-5380-a997-0bfb480f7464",
            name: "Run swift-actions/setup-swift@65540b95f51493d65f5e59e97dcef9629ddf11bf",
            number: 2,
            secondsToCompletion: 30,
            status: .completed,
            conclusion: .success
        )
        static let previewCheckout = StepsNode(
            externalID: "c22f11ce-a3c9-5cf4-6a2d-2d5ca16e5748",
            name: "Run actions/checkout@v4",
            number: 3,
            secondsToCompletion: 2,
            status: .completed,
            conclusion: .success
        )
        static let previewBuild = StepsNode(
            externalID: "e1e32bd6-b618-583c-c296-d7781de5f1de",
            name: "Build",
            number: 4,
            secondsToCompletion: 0,
            status: .completed,
            conclusion: .failure
        )
        static let previewTests = StepsNode(
            externalID: "1de2774f-0b93-5355-32ed-5fe67637718a",
            name: "Run tests",
            number: 5,
            secondsToCompletion: 0,
            status: .completed,
            conclusion: .skipped
        )

        static let previewTestsRunning = StepsNode(
            externalID: "1de2774f-0b93-5355-32ed-sdfsdfsdf234",
            name: "Run tests",
            number: 15,
            secondsToCompletion: 36,
            status: .inProgress,
            conclusion: .neutral
        )
        static let previewCheckout2 = StepsNode(
            externalID: "f537545f-f3ca-4455-b3fb-b8053b932e0d",
            name: "Post Run actions/checkout@v4",
            number: 10,
            secondsToCompletion: 0,
            status: .completed,
            conclusion: .success
        )
        static let previewComplete = StepsNode(
            externalID: "e81b9bb7-8c50-451a-8091-8e0aa864e00f",
            name: "Complete job",
            number: 11,
            secondsToCompletion: 1,
            status: .completed,
            conclusion: .success
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

    enum CheckStatusState: String, Codable, Equatable {
        /// The check suite or run has been requested.
        case requested = "REQUESTED"
        /// The check suite or run has been queued.
        case queued = "QUEUED"
        /// The check suite or run is in progress.
        case inProgress = "IN_PROGRESS"
        /// The check suite or run has been completed.
        case completed = "COMPLETED"
        /// The check suite or run is in waiting state.
        case waiting = "WAITING"
        /// The check suite or run is in pending state.
        case pending = "PENDING"
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
