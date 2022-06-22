// This file was generated from JSON Schema using quicktype, do not modify it directly.
// To parse the JSON, add this file to your project and do:
//

import Foundation

// MARK: - GitLabQuery
struct GitLabQuery: Codable {
    let data: DataClass?
}

// MARK: - DataClass
struct DataClass: Codable {
    let currentUser: CurrentUser?
}

// MARK: - CurrentUser
struct CurrentUser: Codable {
    let name: String?
    let authoredMergeRequests: AuthoredMergeRequests?
}

// MARK: - MergeRequest
struct MergeRequest: Codable {
    let state, id, title: String?
    let draft: Bool?
    let webURL: String?
    let approvedBy: AuthoredMergeRequests?
    let approved: Bool?
    let approvalsLeft: Int?
    let headPipeline: HeadPipeline?

    enum CodingKeys: String, CodingKey {
        case state, id, title, draft
        case webURL
        case approvedBy, approved, approvalsLeft, headPipeline
    }
}

// MARK: - AuthoredMergeRequestsEdge
struct AuthoredMergeRequestsEdge: Codable {
    let node: MergeRequest?
}

// MARK: - AuthoredMergeRequests
struct AuthoredMergeRequests: Codable {
    let edges: [AuthoredMergeRequestsEdge]?
}

// MARK: - JobsEdge
struct JobsEdge: Codable {
    let node: HeadPipeline?
}

// MARK: - Jobs
struct Jobs: Codable {
    let edges: [JobsEdge]?
}

// MARK: - FluffyNode
struct FluffyNode: Codable {
    let id, status, name: String?
    let jobs: Jobs?
}

// MARK: - StagesEdge
struct StagesEdge: Codable {
    let node: FluffyNode?
}

// MARK: - Stages
struct Stages: Codable {
    let edges: [StagesEdge]?
}

// MARK: - HeadPipeline
struct HeadPipeline: Codable {
    let id: String?
    let active: Bool?
    let status: Status?
    let stages: Stages?
    let name: String?
}

enum Status: String, Codable {
    case failed = "FAILED"
    case canceled = "CANCELED"
    case created = "CREATED"
    case manual = "MANUAL"
    case running = "RUNNING"
    case success = "SUCCESS"
}
