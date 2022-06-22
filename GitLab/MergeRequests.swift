// This file was generated from JSON Schema using quicktype, do not modify it directly.
// To parse the JSON, add this file to your project and do:
//
//   let mergeRequests = try? newJSONDecoder().decode(MergeRequests.self, from: jsonData)

import Foundation

// MARK: - MergeRequests
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

// MARK: - AuthoredMergeRequests
struct AuthoredMergeRequests: Codable {
    let edges: [AuthoredMergeRequestsEdge]?
}

// MARK: - AuthoredMergeRequestsEdge
struct AuthoredMergeRequestsEdge: Codable {
    let node: MergeRequest?
}

// MARK: - MergeRequest
struct MergeRequest: Codable {
    let state, id, title: String?
    let draft: Bool?
    let webURL: String?
    let approvedBy: ApprovedBy?
    let approved: Bool?
    let approvalsLeft: Int?
    let headPipeline: HeadPipeline?

    enum CodingKeys: String, CodingKey {
        case state, id, title, draft
        case webURL
        case approvedBy, approved, approvalsLeft, headPipeline
    }
}

// MARK: - ApprovedBy
struct ApprovedBy: Codable {
    let edges: [ApprovedByEdge]?
}

// MARK: - ApprovedByEdge
struct ApprovedByEdge: Codable {
    let node: FluffyNode?
}

// MARK: - FluffyNode
struct FluffyNode: Codable {
    let id, name, username: String?
}

// MARK: - JobsEdge
struct JobsEdge: Codable {
    let node: HeadPipeline?
}

// MARK: - Jobs
struct Jobs: Codable {
    let edges: [JobsEdge]?
}

// MARK: - TentacledNode
struct TentacledNode: Codable {
    let id: String?
    let status: PurpleStatus?
    let name: Name?
    let jobs: Jobs?
}

// MARK: - StagesEdge
struct StagesEdge: Codable {
    let node: TentacledNode?
}

// MARK: - Stages
struct Stages: Codable {
    let edges: [StagesEdge]?
}

// MARK: - HeadPipeline
struct HeadPipeline: Codable {
    let id: String?
    let active: Bool?
    let status: HeadPipelineStatus?
    let stages: Stages?
    let name: String?
}

enum Name: String, Codable {
    case build = "build"
    case deploy = "deploy"
    case test = "test"
}

enum PurpleStatus: String, Codable {
    case success = "success"
}

enum HeadPipelineStatus: String, Codable {
    case manual = "MANUAL"
    case success = "SUCCESS"
}
