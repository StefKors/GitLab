// This file was generated from JSON Schema using quicktype, do not modify it directly.
// To parse the JSON, add this file to your project and do:
//

import Foundation
import Defaults

struct User: Codable, Defaults.Serializable {
    let name: String
    let age: String
}

extension Defaults.Keys {
    static let user = Key<User>("user", default: .init(name: "Hello", age: "24"))
}


// MARK: - GitLabQuery
struct GitLabQuery: Codable, DefaultsSerializable {
    let data: DataClass?
}

// MARK: - DataClass
struct DataClass: Codable, DefaultsSerializable {
    let currentUser: CurrentUser?
}

// MARK: - CurrentUser
struct CurrentUser: Codable, DefaultsSerializable {
    let name: String?
    let authoredMergeRequests: AuthoredMergeRequests?
}

// MARK: - MergeRequest
struct MergeRequest: Codable, DefaultsSerializable {
    let id, title: String?
    let state: MergeRequestState?
    let draft: Bool?
    let webURL: URL?
    let mergeStatusEnum: MergeStatus?
    let approvedBy: AuthoredMergeRequests?
    let approved: Bool?
    let approvalsLeft: Int?
    let userDiscussionsCount: Int?
    let headPipeline: HeadPipeline?
    let reference: String?
    let targetProject: TargetProject?

    enum CodingKeys: String, CodingKey {
        case mergeStatusEnum, state, id, title, draft, userDiscussionsCount, reference, targetProject
        case webURL = "webUrl"
        case approvedBy, approved, approvalsLeft, headPipeline
    }
}

// MARK: - AuthoredMergeRequestsEdge
struct AuthoredMergeRequestsEdge: Codable, DefaultsSerializable {
    let node: MergeRequest?
}

// MARK: - AuthoredMergeRequests
struct AuthoredMergeRequests: Codable, DefaultsSerializable {
    let edges: [AuthoredMergeRequestsEdge]?
}

// MARK: - JobsEdge
struct JobsEdge: Codable, DefaultsSerializable {
    let node: HeadPipeline?
}

// MARK: - Jobs
struct Jobs: Codable, DefaultsSerializable {
    let edges: [JobsEdge]?
}

// MARK: - FluffyNode
struct FluffyNode: Codable, DefaultsSerializable {
    let id, status, name: String?
    let jobs: Jobs?
}

// MARK: - StagesEdge
struct StagesEdge: Codable, DefaultsSerializable {
    let node: FluffyNode?
}

// MARK: - Stages
struct Stages: Codable, DefaultsSerializable {
    let edges: [StagesEdge]?
}

// MARK: - HeadPipeline
struct HeadPipeline: Codable, DefaultsSerializable {
    let id: String?
    let active: Bool?
    let status: PipelineStatus?
    let stages: Stages?
    let name: String?
    let mergeRequestEventType: MergeRequestEventType?
}

// MARK: - TargetProject
struct TargetProject: Codable, DefaultsSerializable {
    internal init(id: String?, name: String?, path: String?, webURL: URL?, group: Group?) {
        self.id = id
        self.name = name
        self.path = path
        self.webURL = webURL
        self.group = group
    }

    let id, name, path: String?
    let webURL: URL?
    let group: Group?

    enum CodingKeys: String, CodingKey {
        case id, name, path
        case webURL = "webUrl"
        case group
    }
}

// MARK: - Group
struct Group: Codable, DefaultsSerializable {
    let id, name, fullName, fullPath: String?
    let webURL: URL?

    enum CodingKeys: String, CodingKey {
        case id, name, fullName, fullPath
        case webURL = "webUrl"
    }
}


enum PipelineStatus: String, Codable, DefaultsSerializable {
    case failed = "FAILED"
    case canceled = "CANCELED"
    case created = "CREATED"
    case manual = "MANUAL"
    case running = "RUNNING"
    case success = "SUCCESS"
    case skipped = "SKIPPED"
}

enum MergeStatus: String, Codable, DefaultsSerializable {
    case cannotBeMerged = "CANNOT_BE_MERGED"
    case cannotBeMergedRecheck = "CANNOT_BE_MERGED_RECHECK"
    case canBeMerged = "CAN_BE_MERGED"
    case checking = "CHECKING"
    case unchecked = "UNCHECKED"
}

enum MergeRequestState: String, Codable, DefaultsSerializable {
    case merged = "merged"
    case opened = "opened"
    case closed = "closed"
    case locked = "locked"
    case all = "all"
}

enum MergeRequestEventType: String, Codable, DefaultsSerializable {
    /// Pipeline run on the changes from the source branch combined with the target branch.
    case mergedResult = "MERGED_RESULT"
    /// Pipeline run on the changes in the merge request source branch.
    case detached = "DETACHED"
    /// Pipeline ran as part of a merge train.
    case mergeTrain = "MERGE_TRAIN"
}
