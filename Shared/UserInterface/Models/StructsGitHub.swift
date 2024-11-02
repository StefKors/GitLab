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
    struct Query: Codable, Equatable, Sendable, Hashable {
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
    struct DataClass: Codable, Equatable, Sendable, Hashable {
        let viewer: Viewer?
    }

    // MARK: - Viewer
    struct Viewer: Codable, Equatable, Sendable, Hashable {
        let pullRequests: PullRequests?
    }

    // MARK: - PullRequestsNode
    struct PullRequestsNode: Codable, Equatable, Identifiable, Hashable {
        let id: String
        let title: String?
        let url: String?
        let state: PullRequestState?
        let isDraft: Bool?
        let createdAt: Date?
        let updatedAt: Date?
        let headRefName: String?
        let baseRefName: String?
        let reviewDecision: ReviewDecision?
        let labels: Labels?
        let isInMergeQueue, locked: Bool?
        let mergeStateStatus: MergeStateStatus?
        let number: Int?
        let permalink: String?
        let totalCommentsCount: Int?
        let repository: Repository?
        let reviews: Reviews?
        let statusCheckRollup: StatusCheckRollup?

        static let previewGitHub = PullRequestsNode(
            id: "PR_kwDOJOGhKc5diY36",
            title: "Site Summary Window",
            url: "https://github.com/beamlegacy/beam/pull/12",
            state: .open,
            isDraft: false,
            createdAt: Date.from("2023-10-23T14:21:50Z"),
            updatedAt: Date.from("2023-12-11T11:55:38Z"),
            headRefName: "summary-implementation",
            baseRefName: "main",
            reviewDecision: .reviewRequired, labels: nil,
            isInMergeQueue: false,
            locked: false,
            mergeStateStatus: .dirty,
            number: 12,
            permalink: "https://github.com/beamlegacy/beam/pull/12",
            totalCommentsCount: 4,
            repository: .previewBeam,
            reviews: nil,
            statusCheckRollup: .preview
//            comments: nil,
//            reactions: nil,
//            commits: nil
        )
    }

    enum PullRequestState: String, Codable, Equatable, Sendable {
        /// A pull request that has been closed without being merged.
        case closed = "CLOSED"
        /// A pull request that has been closed by being merged.
        case merged = "MERGED"
        /// A pull request that is still open.
        case open = "OPEN"
    }

    // MARK: - PullRequests
    struct PullRequests: Codable, Equatable, Sendable, Hashable {
        let nodes: [PullRequestsNode]?
    }

    // MARK: - Labels
    struct Labels: Codable, Equatable, Sendable, Hashable {
        let nodes: [LabelsNode]?
    }

    // MARK: - LabelsNode
    struct LabelsNode: Codable, Equatable, Sendable, Hashable {
        let id, name, color: String?
        let isDefault: Bool?
    }

    // MARK: - Repository
    struct Repository: Codable, Equatable, Sendable, Hashable {
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

//    // MARK: - Comments
//    struct Comments: Codable, Equatable, Sendable, Hashable {
//        let nodes: [CommentsNode]?
//    }
//
//    // MARK: - CommentsNode
//    struct CommentsNode: Codable, Equatable, Sendable, Hashable {
//        let id: String?
//        let author: Owner?
//        let bodyText: String?
//    }

    // MARK: - Owner
    struct Owner: Codable, Equatable, Sendable, Hashable {
        let id: String
        let login: String?
        let avatarUrl: URL?

        static let previewBeam = Owner(id: "UUID", login: "beamLegacy", avatarUrl: nil)
    }

//    // MARK: - Commits
//    struct Commits: Codable, Equatable, Sendable, Hashable {
//        let nodes: [CommitsNode]?
//    }
//
//    // MARK: - CommitsNode
//    struct CommitsNode: Codable, Equatable, Sendable, Hashable {
//        let commit: Commit?
//    }
//
//    // MARK: - Commit
//    struct Commit: Codable, Equatable, Sendable, Hashable {
//        let statusCheckRollup: StatusCheckRollup?
//    }

    // MARK: - StatusCheckRollup
    struct StatusCheckRollup: Codable, Equatable, Sendable, Hashable {
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
    struct Contexts: Codable, Equatable, Sendable, Hashable {
        let nodes: [ContextsNode]?
    }

    // MARK: - ContextsNode (Like jobs in GitLab)
    struct ContextsNode: Codable, Equatable, Hashable, Sendable {
        let id: String
        let name: String?
        let status: CheckStatusState?
        let conclusion: CheckConclusionState?
        let detailsURL: String?
        let title: String?
        let url: String?
        let checkSuite: CheckSuite?

        enum CodingKeys: String, CodingKey {
            case id = "id"
            case name = "name"
            case status = "status"
            case conclusion = "conclusion"
            case detailsURL = "detailsUrl"
            case title = "title"
            case url = "url"
            case checkSuite = "checkSuite"
        }

        static let previewSuccess = ContextsNode(
            id: "CR_kwDOJO0j5s8AbbbbHiqSLJQ",
            name: "SwiftLint",
            status: .completed,
            conclusion: .success,
            detailsURL: "https://github.com/StefKors/GitLab/actions/runs/11632934479/job/32397042416",
            title: "No header rules processed",
            url: "https://github.com/StefKors/GitLab/runs/32397042416",
            checkSuite: .previewLint
        )

        static let previewSuccess2 = ContextsNode(
            id: "CR_kwDOJO0j5s8AbbbbHi23423234",
            name: "SwiftLint",
            status: .completed,
            conclusion: .success,
            detailsURL: "https://github.com/StefKors/GitLab/actions/runs/11632934479/job/32397042416",
            title: nil,
            url: "https://github.com/StefKors/GitLab/runs/32397042416",
            checkSuite: .previewLint
        )

        static let previewFailure = ContextsNode(
            id: "CR_kwDOJO0j523424",
            name: "Build",
            status: .completed,
            conclusion: .failure,
            detailsURL: "https://github.com/StefKors/GitLab/actions/runs/11632934479/job/32397042416",
            title: nil,
            url: "https://github.com/StefKors/GitLab/runs/32397042416",
            checkSuite: .previewNetlify
        )

        static let previewInProgress = ContextsNode(
            id: "CR_kwD09w8er-089wre",
            name: "Build",
            status: .inProgress,
            conclusion: nil,
            detailsURL: "https://github.com/StefKors/GitLab/actions/runs/11632934479/job/32397042416",
            title: nil,
            url: "https://github.com/StefKors/GitLab/runs/32397042416",
            checkSuite: .previewNetlify
        )

        static let previewInProgress2 = ContextsNode(
            id: "CR_kwslkfsadlfkjad",
            name: "E2E Test",
            status: .inProgress,
            conclusion: nil,
            detailsURL: "https://github.com/StefKors/GitLab/actions/runs/11632934479/job/32397042416",
            title: nil,
            url: "https://github.com/StefKors/GitLab/runs/32397042416",
            checkSuite: .previewNetlify
        )

        static let previewFailed = ContextsNode(
            id: "CR_kwslkfsadlfkjad",
            name: "Deploy",
            status: .completed,
            conclusion: .failure,
            detailsURL: "https://github.com/StefKors/GitLab/actions/runs/11632934479/job/32397042416",
            title: nil,
            url: "https://github.com/StefKors/GitLab/runs/32397042416",
            checkSuite: .previewNetlify
        )
    }

    // MARK: - CheckSuite
    struct CheckSuite: Codable, Equatable, Hashable, Sendable {
        let workflowRun: WorkflowRun?

        enum CodingKeys: String, CodingKey {
            case workflowRun = "workflowRun"
        }

        static let previewLint = CheckSuite(workflowRun: WorkflowRun(workflow: Workflow(id: "CR_kwDOJO0j5s8AbbbbHiqSLJQ", name: "lint")))
        static let previewNetlify = CheckSuite(workflowRun: WorkflowRun(workflow: Workflow(id: "CR_lksjdflkjdsflksdjf", name: "Netlify")))
    }

    // MARK: - WorkflowRun
    struct WorkflowRun: Codable, Equatable, Hashable, Sendable {
        let workflow: Workflow?

        enum CodingKeys: String, CodingKey {
            case workflow = "workflow"
        }
    }

    // MARK: - Workflow
    struct Workflow: Codable, Equatable, Hashable, Sendable {
        let id: String?
        let name: String?

        enum CodingKeys: String, CodingKey {
            case id = "id"
            case name = "name"
        }
    }

    // MARK: - Steps
    /// Not used At the moment
    struct Steps: Codable, Equatable, Hashable, Sendable {
        let nodes: [StepsNode]?

//        steps: Steps(nodes: [.previewCheckout, .previewSetup])
//        steps: Steps(nodes: [.previewCheckout, .previewComplete])
//        steps: Steps(nodes: [.previewCheckout, .previewBuild])
//        steps: Steps(nodes: [.previewCheckout, .previewTestsRunning])
//        steps: Steps(nodes: [.previewCheckout, .previewTestsRunning])
    }

    // MARK: - StepsNode
    struct StepsNode: Codable, Equatable, Hashable, Sendable {
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

    enum StatusCheckState: String, Codable, Equatable, Sendable {
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

    enum CheckStatusState: String, Codable, Equatable, Sendable {
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

    enum MergeStateStatus: String, Codable, Equatable, Sendable {
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

    enum CheckConclusionState: String, Codable, Equatable, Sendable {
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
    struct Reactions: Codable, Equatable, Sendable, Hashable {
        let nodes: [ReactionsNode]?
    }

    // MARK: - ReactionsNode
    struct ReactionsNode: Codable, Equatable, Sendable, Hashable {
        let id: String?
        let user: Author?
    }

    // MARK: - Reviews
    struct Reviews: Codable, Equatable, Sendable, Hashable {
        let nodes: [ReviewsNode]?
    }

    enum ReviewDecision: String, Codable, Equatable, Sendable {
        // The pull request has received an approving review.
        case approved = "APPROVED"
        // A review is required before the pull request can be merged.
        case reviewRequired = "REVIEW_REQUIRED"
        // Changes have been requested on the pull request.
        case changesRequested = "CHANGES_REQUESTED"
    }

    // MARK: - ReviewsNode
    struct ReviewsNode: Codable, Equatable, Sendable, Hashable {
        let id: String?
        let state: ReviewState?
        let author: Author?
    }

    enum ReviewState: String, Codable, Equatable, Sendable {
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
    struct Author: Codable, Equatable, Sendable, Hashable {
        let avatarURL: String?
        let name: String?
        let login: String?

        enum CodingKeys: String, CodingKey {
            case avatarURL = "avatarUrl"
            case name, login
        }
    }}
