//
//  Approval.swift
//  GitLab
//
//  Created by Stef Kors on 21/10/2021.
//

import Foundation

// MARK: - Approval
struct Approval {
    let id, iid, projectID: Int
    let title, approvalDescription, state, createdAt: String
    let updatedAt, mergeStatus: String
    let approved: Bool
    let approvalsRequired, approvalsLeft: Int
    let requirePasswordToApprove: Bool
    let approvedBy: [ApprovedBy]
    let suggestedApprovers, approvers, approverGroups: [Any?]
    let userHasApproved, userCanApprove: Bool
    let approvalRulesLeft: [Any?]
    let hasApprovalRules, mergeRequestApproversAvailable, multipleApprovalRulesAvailable: Bool
}

// MARK: - ApprovedBy
struct ApprovedBy: Codable {
    let user: Author
}
