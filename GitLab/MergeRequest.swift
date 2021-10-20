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
struct MergeRequestElement: Codable {
    let id, iid, projectID: Int?
    let title, mergeRequestDescription: String?
    let state: MergeRequestState?
    let createdAt, updatedAt: String?
    let mergedBy: Author?
    let mergedAt, closedBy, closedAt: String?
    let targetBranch: TargetBranch?
    let sourceBranch: String?
    let userNotesCount, upvotes, downvotes: Int?
    let author: Author?
    let assignees: [Author]?
    let assignee: Author?
    let reviewers: [Author]?
    let sourceProjectID, targetProjectID: Int?
    let labels: [String]?
    let draft, workInProgress: Bool?
    let milestone: Milestone?
    let mergeWhenPipelineSucceeds: Bool?
    let mergeStatus: MergeStatus?
    let sha: String?
    let mergeCommitSHA, squashCommitSHA, discussionLocked: String?
    let shouldRemoveSourceBranch: Bool?
    let forceRemoveSourceBranch: Bool?
    let reference: String?
    let references: References?
    let webURL: String?
    let timeStats: TimeStats?
    let squash: Bool?
    let taskCompletionStatus: TaskCompletionStatus?
    let hasConflicts, blockingDiscussionsResolved: Bool?
    let approvalsBeforeMerge: Bool?
    let allowCollaboration, allowMaintainerToPush: Bool?
}

// MARK: - Author
struct Author: Codable {
    let id: Int
    let name, username: String
    let state: AuthorState
    let avatarURL: String?
    let webURL: String?
}

enum AuthorState: String, Codable {
    case active
}

enum MergeStatus: String, Codable {
    case canBeMerged
    case unchecked
}

// MARK: - Milestone
struct Milestone: Codable {
    let id, iid, projectID: Int
    let title, milestoneDescription, state, createdAt: String
    let updatedAt, dueDate, startDate: String
    let webURL: String?
}

// MARK: - References
struct References: Codable {
    let short, relative, full: String
}

enum MergeRequestState: String, Codable {
    case merged
    case opened
}

enum TargetBranch: String, Codable {
    case develop
    case master
}

// MARK: - TaskCompletionStatus
struct TaskCompletionStatus: Codable {
    let count, completedCount: Int
}

// MARK: - TimeStats
struct TimeStats: Codable {
    let timeEstimate, totalTimeSpent: Int
    let humanTimeEstimate, humanTotalTimeSpent: Int?
}
