//
//  MergeRequest.swift
//  GitLab
//
//  Created by Stef Kors on 13/09/2021.
//

// This file was generated from JSON Schema using quicktype, do not modify it directly.
// To parse the JSON, add this file to your project and do:
//
//   let mergeRequest = try? newJSONDecoder().decode(MergeRequest.self, from: jsonData)

import Foundation

// MARK: - MergeRequestElement
struct MergeRequestElement {
    let id, iid, projectID: Int
    let title, mergeRequestDescription: String
    let state: MergeRequestState
    let createdAt, updatedAt: String
    let mergedBy: Author?
    let mergedAt, closedBy, closedAt: String?
    let targetBranch: TargetBranch
    let sourceBranch: String
    let userNotesCount, upvotes, downvotes: Int
    let author: Author
    let assignees: [Author]
    let assignee: Author?
    let reviewers: [Author]
    let sourceProjectID, targetProjectID: Int
    let labels: [String]
    let draft, workInProgress: Bool
    let milestone: Milestone?
    let mergeWhenPipelineSucceeds: Bool
    let mergeStatus: MergeStatus
    let sha: String
    let mergeCommitSHA, squashCommitSHA, discussionLocked: NSNull
    let shouldRemoveSourceBranch: Bool?
    let forceRemoveSourceBranch: Bool
    let reference: String?
    let references: References
    let webURL: String
    let timeStats: TimeStats
    let squash: Bool
    let taskCompletionStatus: TaskCompletionStatus
    let hasConflicts, blockingDiscussionsResolved: Bool
    let approvalsBeforeMerge: NSNull?
    let allowCollaboration, allowMaintainerToPush: Bool?
}

// MARK: - Author
struct Author {
    let id: Int
    let name, username: String
    let state: AuthorState
    let avatarURL: String?
    let webURL: String
}

enum AuthorState {
    case active
}

enum MergeStatus {
    case canBeMerged
    case unchecked
}

// MARK: - Milestone
struct Milestone {
    let id, iid, projectID: Int
    let title, milestoneDescription, state, createdAt: String
    let updatedAt, dueDate, startDate: String
    let webURL: String
}

// MARK: - References
struct References {
    let short, relative, full: String
}

enum MergeRequestState {
    case merged
    case opened
}

enum TargetBranch {
    case develop
    case master
}

// MARK: - TaskCompletionStatus
struct TaskCompletionStatus {
    let count, completedCount: Int
}

// MARK: - TimeStats
struct TimeStats {
    let timeEstimate, totalTimeSpent: Int
    let humanTimeEstimate, humanTotalTimeSpent: NSNull
}
