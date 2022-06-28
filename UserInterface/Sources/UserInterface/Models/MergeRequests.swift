// This file was generated from JSON Schema using quicktype, do not modify it directly.
// To parse the JSON, add this file to your project and do:
//

import Foundation
import Defaults

// MARK: - GitLabQuery
public struct GitLabQuery: Codable, DefaultsSerializable, Equatable {
    let data: DataClass?
}

public extension GitLabQuery {
    var mergeRequests: [MergeRequest] {
        return self.data?.currentUser?.authoredMergeRequests?.edges?.compactMap({ edge in
            return edge.node
        }) ?? []
    }
}

// MARK: - DataClass
public struct DataClass: Codable, DefaultsSerializable, Equatable {
    let currentUser: CurrentUser?
}

// MARK: - CurrentUser
public struct CurrentUser: Codable, DefaultsSerializable, Equatable {
    let name: String?
    let authoredMergeRequests: AuthoredMergeRequests?
}

// MARK: - MergeRequest
public struct MergeRequest: Codable, DefaultsSerializable, Equatable {
    let id, title: String?
    let state: MergeRequestState?
    let draft: Bool?
    let webURL: URL?
    let mergeStatusEnum: MergeStatus?
    let approvedBy: ApprovedMergeRequests?
    let approved: Bool?
    let approvalsLeft: Int?
    let userDiscussionsCount: Int?
    let headPipeline: HeadPipeline?
    let reference: String?
    let targetProject: TargetProject?

    enum CodingKeys: String, CodingKey {
        case state, id, title, draft
        case webURL = "webUrl"
        case reference, targetProject, approvedBy, mergeStatusEnum, approved, approvalsLeft, userDiscussionsCount, headPipeline
    }
}

extension BidirectionalCollection where Element == MergeRequest {
    /// Goes through all merge requests and returns the approvedBy authors
    /// - Returns: in the format of `["!4": [Author]]`
    var approvedByDict: [String: [Author]] {
        var beforeDict: [String: [Author]] = [:]
        self.forEach({ mr in
            guard let id = mr.reference else { return }
            let approved = mr.approvedBy?.edges?.compactMap({ $0.node })
            beforeDict[id] = approved
        })
        return beforeDict
    }
}

public struct Author: Codable, DefaultsSerializable, Equatable {
    let id, name, username: String?
    let avatarUrl: URL?

    enum CodingKeys: String, CodingKey {
        case id, name, username
        case avatarUrl = "avatarUrl"
    }
}

// MARK: - ApprovedMergeRequestsEdge
public struct ApprovedMergeRequestsEdge: Codable, DefaultsSerializable, Equatable {
    let node: Author?
}

// MARK: - ApprovedMergeRequests
public struct ApprovedMergeRequests: Codable, DefaultsSerializable, Equatable {
    let edges: [ApprovedMergeRequestsEdge]?
}

// MARK: - AuthoredMergeRequestsEdge
public struct AuthoredMergeRequestsEdge: Codable, DefaultsSerializable, Equatable {
    let node: MergeRequest?
}

// MARK: - AuthoredMergeRequests
public struct AuthoredMergeRequests: Codable, DefaultsSerializable, Equatable {
    let edges: [AuthoredMergeRequestsEdge]?
}

// MARK: - JobsEdge
public struct JobsEdge: Codable, DefaultsSerializable, Equatable {
    let node: HeadPipeline?
}

// MARK: - Jobs
public struct Jobs: Codable, DefaultsSerializable, Equatable {
    let edges: [JobsEdge]?
}

// MARK: - FluffyNode
public struct FluffyNode: Codable, DefaultsSerializable, Equatable {
    let id: String?
    let status: StageStatusType?
    let name: String?
    let jobs: Jobs?
}

// MARK: - StagesEdge
public struct StagesEdge: Codable, DefaultsSerializable, Equatable {
    let node: FluffyNode?
}

// MARK: - Stages
public struct Stages: Codable, DefaultsSerializable, Equatable {
    let edges: [StagesEdge]?
}

// MARK: - HeadPipeline
public struct HeadPipeline: Codable, DefaultsSerializable, Equatable {
    let id: String?
    let active: Bool?
    let status: PipelineStatus?
    let stages: Stages?
    let name: String?
    let mergeRequestEventType: MergeRequestEventType?
}

// MARK: - TargetProject
public struct TargetProject: Codable, DefaultsSerializable, Equatable {
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
public struct Group: Codable, DefaultsSerializable, Equatable {
    let id, name, fullName, fullPath: String?
    let webURL: URL?

    enum CodingKeys: String, CodingKey {
        case id, name, fullName, fullPath
        case webURL = "webUrl"
    }
}

// MARK: - PipelineStatus
public enum PipelineStatus: String, Codable, DefaultsSerializable, Equatable {
    /// Pipeline has been created.
    case created = "CREATED"
    /// A resource (for example, a runner) that the pipeline requires to run is unavailable.
    case waitingForResource = "WAITING_FOR_RESOURCE"
    /// Pipeline is preparing to run.
    case preparing = "PREPARING"
    /// Pipeline has not started running yet.
    case pending = "PENDING"
    /// Pipeline is running.
    case running = "RUNNING"
    /// At least one stage of the pipeline failed.
    case failed = "FAILED"
    /// Pipeline completed successfully.
    case success = "SUCCESS"
    /// Pipeline was canceled before completion.
    case canceled = "CANCELED"
    /// Pipeline was skipped.
    case skipped = "SKIPPED"
    /// Pipeline needs to be manually started.
    case manual = "MANUAL"
    /// Pipeline is scheduled to run.
    case scheduled = "SCHEDULED"
}

// MARK: - MergeStatus
public enum MergeStatus: String, Codable, DefaultsSerializable, Equatable {
    case cannotBeMerged = "CANNOT_BE_MERGED"
    case cannotBeMergedRecheck = "CANNOT_BE_MERGED_RECHECK"
    case canBeMerged = "CAN_BE_MERGED"
    case checking = "CHECKING"
    case unchecked = "UNCHECKED"
}

// MARK: - MergeRequestState
public enum MergeRequestState: String, Codable, DefaultsSerializable, Equatable {
    case merged = "merged"
    case opened = "opened"
    case closed = "closed"
    case locked = "locked"
    case all = "all"
}

// MARK: - MergeRequestEventType
public enum MergeRequestEventType: String, Codable, DefaultsSerializable, Equatable {
    /// Pipeline run on the changes from the source branch combined with the target branch.
    case mergedResult = "MERGED_RESULT"
    /// Pipeline run on the changes in the merge request source branch.
    case detached = "DETACHED"
    /// Pipeline ran as part of a merge train.
    case mergeTrain = "MERGE_TRAIN"
}

public enum StageStatusType: String, Codable, DefaultsSerializable, Equatable {
    /// Pipeline has been created.
    case created = "created"
    /// A resource (for example, a runner) that the pipeline requires to run is unavailable.
    case waitingForResource = "waiting_for_resource"
    /// Pipeline is preparing to run.
    case preparing = "preparing"
    /// Pipeline has not started running yet.
    case pending = "pending"
    /// Pipeline is running.
    case running = "running"
    /// At least one stage of the pipeline failed.
    case failed = "failed"
    /// Pipeline completed successfully.
    case success = "success"
    /// Pipeline was canceled before completion.
    case canceled = "canceled"
    /// Pipeline was skipped.
    case skipped = "skipped"
    /// Pipeline needs to be manually started.
    case manual = "manual"
    /// Pipeline is scheduled to run.
    case scheduled = "scheduled"

    public func toPipelineStatus() -> PipelineStatus? {
        PipelineStatus(rawValue: self.rawValue.uppercased())
    }
}
