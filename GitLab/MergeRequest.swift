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
    let title, mergeRequestDescription, state: String
    let mergedBy: Assignee?
    let mergedAt, closedBy, closedAt: String
    let createdAt, updatedAt: Date
    let targetBranch, sourceBranch: String
    let upvotes, downvotes: Int
    let author, assignee: Assignee
    let assignees, reviewers: [Assignee]
    let sourceProjectID, targetProjectID: Int
    let labels: [String]
    let draft, workInProgress: Bool
    let milestone: Milestone
    let mergeWhenPipelineSucceeds: Bool
    let mergeStatus, sha: String
    let mergeCommitSHA, squashCommitSHA: String?
    let userNotesCount: Int
    let discussionLocked: Bool?
    let shouldRemoveSourceBranch, forceRemoveSourceBranch, allowCollaboration, allowMaintainerToPush: Bool
    let webURL: String
    let references: References
    let timeStats: TimeStats
    let squash: Bool
    let taskCompletionStatus: TaskCompletionStatus
    let hasConflicts, blockingDiscussionsResolved: Bool
}

// MARK: - Assignee
struct Assignee {
    let id: Int
    let name, username, state: String
    let avatarURL: String?
    let webURL: String
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

// MARK: - TaskCompletionStatus
struct TaskCompletionStatus {
    let count, completedCount: Int
}

// MARK: - TimeStats
struct TimeStats {
    let timeEstimate, totalTimeSpent: Int
    let humanTimeEstimate, humanTotalTimeSpent: NSNull
}

