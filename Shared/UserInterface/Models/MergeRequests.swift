// This file was generated from JSON Schema using quicktype, do not modify it directly.
// To parse the JSON, add this file to your project and do:
//

import Foundation
import Defaults

// MARK: - GitLabQuery
public struct GitLabQuery: Codable, Defaults.Serializable, Equatable {
    public let data: DataClass?
}

public extension GitLabQuery {
    var authoredMergeRequests: [MergeRequest] {
        return self.data?.currentUser?.authoredMergeRequests?.edges?.compactMap({ edge in
            return edge.node
        }) ?? self.data?.user?.authoredMergeRequests?.edges?.compactMap({ edge in
            return edge.node
        }) ?? []
    }

    var reviewRequestedMergeRequests: [MergeRequest] {
        return self.data?.currentUser?.reviewRequestedMergeRequests?.edges?.compactMap({ edge in
            return edge.node
        }) ?? self.data?.user?.reviewRequestedMergeRequests?.edges?.compactMap({ edge in
            return edge.node
        }) ?? []
    }
}

// MARK: - DataClass
public struct DataClass: Codable, Defaults.Serializable, Equatable {
    public let currentUser: CurrentUser?
    public let user: CurrentUser?
}

// MARK: - CurrentUser
public struct CurrentUser: Codable, Defaults.Serializable, Equatable {
    public let name: String?
    public let authoredMergeRequests: AuthoredMergeRequests?
    public let reviewRequestedMergeRequests: ReviewRequestedMergeRequests?
}

// MARK: - MergeRequest
public struct MergeRequest: Codable, Defaults.Serializable, Equatable {
    public let id, title: String?
    public let state: MergeRequestState?
    public let draft: Bool?
    public let webURL: URL?
    public let mergeStatusEnum: MergeStatus?
    public let approvedBy: ApprovedMergeRequests?
    public let userDiscussionsCount: Int?
    public let userNotesCount: Int?
    public let headPipeline: HeadPipeline?
    public let reference: String?
    public let targetProject: TargetProject?

    enum CodingKeys: String, CodingKey {
        case state, id, title, draft
        case webURL = "webUrl"
        case reference, targetProject, approvedBy, mergeStatusEnum, userDiscussionsCount, userNotesCount, headPipeline
    }

    public init(id: String?, title: String?, state: MergeRequestState?, draft: Bool?, webURL: URL?, mergeStatusEnum: MergeStatus?, approvedBy: ApprovedMergeRequests?, userDiscussionsCount: Int?, userNotesCount: Int?, headPipeline: HeadPipeline?, reference: String?, targetProject: TargetProject?) {
        self.id = id
        self.title = title
        self.state = state
        self.draft = draft
        self.webURL = webURL
        self.mergeStatusEnum = mergeStatusEnum
        self.approvedBy = approvedBy
        self.userDiscussionsCount = userDiscussionsCount
        self.userNotesCount = userNotesCount
        self.headPipeline = headPipeline
        self.reference = reference
        self.targetProject = targetProject
    }

    public init(from decoder: Decoder) throws {
        let container: KeyedDecodingContainer<MergeRequest.CodingKeys> = try decoder.container(keyedBy: MergeRequest.CodingKeys.self)
        
        self.state = try container.decodeIfPresent(MergeRequestState.self, forKey: MergeRequest.CodingKeys.state)
        self.id = try container.decodeIfPresent(String.self, forKey: MergeRequest.CodingKeys.id)
        self.title = try container.decodeIfPresent(String.self, forKey: MergeRequest.CodingKeys.title)
        self.draft = try container.decodeIfPresent(Bool.self, forKey: MergeRequest.CodingKeys.draft)
        self.webURL = try container.decodeURLWithEncodingIfPresent(forKey: MergeRequest.CodingKeys.webURL)
        self.reference = try container.decodeIfPresent(String.self, forKey: MergeRequest.CodingKeys.reference)
        self.targetProject = try container.decodeIfPresent(TargetProject.self, forKey: MergeRequest.CodingKeys.targetProject)
        self.approvedBy = try container.decodeIfPresent(ApprovedMergeRequests.self, forKey: MergeRequest.CodingKeys.approvedBy)
        self.mergeStatusEnum = try container.decodeIfPresent(MergeStatus.self, forKey: MergeRequest.CodingKeys.mergeStatusEnum)
        self.userDiscussionsCount = try container.decodeIfPresent(Int.self, forKey: MergeRequest.CodingKeys.userDiscussionsCount)
        self.userNotesCount = try container.decodeIfPresent(Int.self, forKey: MergeRequest.CodingKeys.userNotesCount)
        self.headPipeline = try container.decodeIfPresent(HeadPipeline.self, forKey: MergeRequest.CodingKeys.headPipeline)
        
    }
    
    public func encode(to encoder: Encoder) throws {
        var container: KeyedEncodingContainer<MergeRequest.CodingKeys> = encoder.container(keyedBy: MergeRequest.CodingKeys.self)
        
        try container.encodeIfPresent(self.state, forKey: MergeRequest.CodingKeys.state)
        try container.encodeIfPresent(self.id, forKey: MergeRequest.CodingKeys.id)
        try container.encodeIfPresent(self.title, forKey: MergeRequest.CodingKeys.title)
        try container.encodeIfPresent(self.draft, forKey: MergeRequest.CodingKeys.draft)
        try container.encodeIfPresent(self.webURL, forKey: MergeRequest.CodingKeys.webURL)
        try container.encodeIfPresent(self.reference, forKey: MergeRequest.CodingKeys.reference)
        try container.encodeIfPresent(self.targetProject, forKey: MergeRequest.CodingKeys.targetProject)
        try container.encodeIfPresent(self.approvedBy, forKey: MergeRequest.CodingKeys.approvedBy)
        try container.encodeIfPresent(self.mergeStatusEnum, forKey: MergeRequest.CodingKeys.mergeStatusEnum)
        try container.encodeIfPresent(self.userDiscussionsCount, forKey: MergeRequest.CodingKeys.userDiscussionsCount)
        try container.encodeIfPresent(self.userNotesCount, forKey: MergeRequest.CodingKeys.userNotesCount)
        try container.encodeIfPresent(self.headPipeline, forKey: MergeRequest.CodingKeys.headPipeline)
    }
}

extension BidirectionalCollection where Element == MergeRequest {
    /// Goes through all merge requests and returns the approvedBy authors
    /// - Returns: in the format of `["!4": [Author]]`
    public var approvedByDict: [String: [Author]] {
        var beforeDict: [String: [Author]] = [:]
        self.forEach({ mr in
            guard let id = mr.reference else { return }
            let approved = mr.approvedBy?.edges?.compactMap({ $0.node })
            beforeDict[id] = approved
        })
        return beforeDict
    }
}

extension BidirectionalCollection where Element == CollectionDifference<Author>.Change {
    /// Return all elements of changed type `.insert`
    var insertedElements: [Author] {
        return self.compactMap({ insertion -> Author? in
            guard case let .insert(offset: _, element: element, associatedWith: _) = insertion else {
                return nil
            }
            return element
        })
    }

    /// Return all elements of changed type `.remove`
    var removedElements: [Author] {
        return self.compactMap({ insertion -> Author? in
            guard case let .remove(offset: _, element: element, associatedWith: _) = insertion else {
                return nil
            }
            return element
        })
    }
}

public struct Author: Codable, Defaults.Serializable, Equatable {
    public let id, name, username: String?
    public let avatarUrl: URL?

    enum CodingKeys: String, CodingKey {
        case id, name, username
        case avatarUrl = "avatarUrl"
    }

    public init(id: String?, name: String?, username: String?, avatarUrl: URL?) {
        self.id = id
        self.name = name
        self.username = username
        self.avatarUrl = avatarUrl
    }
    
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: Author.CodingKeys.self)
        self.id = try container.decode(String.self, forKey: .id)
        self.name = try container.decodeIfPresent(String.self, forKey: .name)
        self.username = try container.decodeIfPresent(String.self, forKey: .username)
        // Should re-encode any non-escaped utf8 strings
        self.avatarUrl = try? container.decodeURLWithEncodingIfPresent(forKey: .avatarUrl)
    }
}

/// (same as Author above ^ but with int for id
public struct EventAuthor: Codable, Defaults.Serializable, Equatable {
    public let id: Int?
    public let name, username: String?
    public let avatarUrl: URL?

    enum CodingKeys: String, CodingKey {
        case id, name, username
        case avatarUrl = "avatarUrl"
    }

    public init(id: Int?, name: String?, username: String?, avatarUrl: URL?) {
        self.id = id
        self.name = name
        self.username = username
        self.avatarUrl = avatarUrl
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: EventAuthor.CodingKeys.self)
        self.id = try container.decodeIfPresent(Int.self, forKey: .id)
        self.name = try container.decodeIfPresent(String.self, forKey: .name)
        self.username = try container.decodeIfPresent(String.self, forKey: .username)
        // Should re-encode any non-escaped utf8 strings
        self.avatarUrl = try? container.decodeURLWithEncodingIfPresent(forKey: .avatarUrl)
    }
}

// MARK: - ApprovedMergeRequestsEdge
public struct ApprovedMergeRequestsEdge: Codable, Defaults.Serializable, Equatable {
    public let node: Author?
}

// MARK: - ApprovedMergeRequests
public struct ApprovedMergeRequests: Codable, Defaults.Serializable, Equatable {
    public let edges: [ApprovedMergeRequestsEdge]?
}

// MARK: - AuthoredMergeRequestsEdge
public struct AuthoredMergeRequestsEdge: Codable, Defaults.Serializable, Equatable {
    public let node: MergeRequest?
}

// MARK: - AuthoredMergeRequests
public struct AuthoredMergeRequests: Codable, Defaults.Serializable, Equatable {
    public let edges: [AuthoredMergeRequestsEdge]?
}

// MARK: - ReviewRequestedMergeRequests
public struct ReviewRequestedMergeRequests: Codable, Defaults.Serializable, Equatable {
    public let edges: [ReviewRequestedMergeRequestsEdge]?
}

// MARK: - ReviewRequestedMergeRequestsEdge
public struct ReviewRequestedMergeRequestsEdge: Codable, Defaults.Serializable, Equatable {
    public let node: MergeRequest?
}

// MARK: - JobsEdge
public struct JobsEdge: Codable, Defaults.Serializable, Equatable {
    public let node: HeadPipeline?
}


// MARK: - Jobs
public struct Jobs: Codable, Defaults.Serializable, Equatable {
    public let edges: [JobsEdge]?
}

extension Jobs {
    // static let preview = Jobs(edges: [
    //     JobsEdge(node: .previewTestFailed),
    //     JobsEdge(node: .previewTestRunning1)
    // ])
    static let previewBuildJobs = Jobs(edges: [
        JobsEdge(node: .previewBuildiOS),
        JobsEdge(node: .previewBuildMacOS)
    ])
    static let previewTestJobs = Jobs(edges: [
        JobsEdge(node: .previewTestFailed),
        JobsEdge(node: .previewTestRunning1),
        JobsEdge(node: .previewTestRunning2),
        JobsEdge(node: .previewTestPending1),
        JobsEdge(node: .previewTestPending2)
    ])
}

// MARK: - FluffyNode
public struct FluffyNode: Codable, Defaults.Serializable, Equatable {
    public let id: String?
    public let status: StageStatusType?
    public let name: String?
    public let jobs: Jobs?
}

extension FluffyNode {
    // static let preview = FluffyNode(
    //     id: "id-id-id",
    //     status: .running,
    //     name: "Test",
    //     jobs: .previewBuildJobs
    // )

    static let previewBuild = FluffyNode(
        id: "id-id-id",
        status: .running,
        name: "Build",
        jobs: .previewBuildJobs
    )

    static let previewTest = FluffyNode(
        id: "id-id-id",
        status: .running,
        name: "Test",
        jobs: .previewTestJobs
    )

    static let previewNoChildren = FluffyNode(
        id: "id-id-id",
        status: .success,
        name: "Build",
        jobs: nil
    )
}

// MARK: - StagesEdge
public struct StagesEdge: Codable, Defaults.Serializable, Equatable {
    public let node: FluffyNode?
}

// MARK: - Stages
public struct Stages: Codable, Defaults.Serializable, Equatable {
    public let edges: [StagesEdge]?
}

extension Stages {
    static let previewParent = Stages(edges: [StagesEdge(node: .previewTest)])
    static let previewChild = Stages(edges: [StagesEdge(node: .previewNoChildren)])
}

// MARK: - HeadPipeline
public struct HeadPipeline: Codable, Defaults.Serializable, Equatable {
    public let id: String?
    public let active: Bool?
    public let status: PipelineStatus?
    public let stages: Stages?
    public let name: String?
    public let detailedStatus: DetailedStatus?
    public let mergeRequestEventType: MergeRequestEventType?
}

extension HeadPipeline {
    // previewBuildiOS
    // previewBuildMacOS
    // previewTestFailed
    // previewTestRunning1
    // previewTestRunning2
    // previewTestPending1
    // previewTestPending2
    static let previewBuildiOS = HeadPipeline(
        id: "id-id-id",
        active: true,
        status: .running,
        stages: .previewChild,
        name: "build:ios-dev",
        detailedStatus: .preview,
        mergeRequestEventType: .mergeTrain
    )

    static let previewBuildMacOS = HeadPipeline(
        id: "id-id-id",
        active: false,
        status: .success,
        stages: .previewChild,
        name: "build:macos-dev",
        detailedStatus: .preview,
        mergeRequestEventType: .mergedResult
    )

    static let previewTestFailed = HeadPipeline(
        id: "id-id-id",
        active: false,
        status: .failed,
        stages: .previewChild,
        name: "test:macos-uitest",
        detailedStatus: .preview,
        mergeRequestEventType: .mergedResult
    )

    static let previewTestRunning1 = HeadPipeline(
        id: "id-id-id",
        active: false,
        status: .running,
        stages: .previewChild,
        name: "test:macos-uitest",
        detailedStatus: .preview,
        mergeRequestEventType: .mergedResult
    )

    static let previewTestRunning2 = HeadPipeline(
        id: "id-id-id",
        active: false,
        status: .running,
        stages: .previewChild,
        name: "test:macos-unit",
        detailedStatus: .preview,
        mergeRequestEventType: .mergedResult
    )

    static let previewTestPending1 = HeadPipeline(
        id: "id-id-id",
        active: false,
        status: .waitingForResource,
        stages: .previewChild,
        name: "test:ios-unit",
        detailedStatus: .preview,
        mergeRequestEventType: .mergedResult
    )

    static let previewTestPending2 = HeadPipeline(
        id: "id-id-id",
        active: false,
        status: .pending,
        stages: .previewChild,
        name: "test:ios-uitest",
        detailedStatus: .preview,
        mergeRequestEventType: .mergedResult
    )
}

// MARK: - DetailedStatus
public struct DetailedStatus: Codable, Defaults.Serializable, Equatable {
    public let id: String?
    public let detailsPath: String?
}

extension DetailedStatus {
    static let preview = DetailedStatus(id: "id-id-id", detailsPath: "/details?...")
}

// MARK: - TargetProject
public struct TargetProject: Codable, Defaults.Serializable, Equatable, Hashable, Identifiable {
    public let id: String
    public let name, path: String?
    public let webURL: URL?
    public let avatarUrl: URL?
    public let namespace: NameSpace?
    public let repository: Repository?
    public let group: Group?
    public let fetchedAvatarData: Data?

    enum CodingKeys: String, CodingKey {
        case id, name, path
        case webURL = "webUrl"
        case avatarUrl = "avatarUrl"
        case namespace
        case repository
        case group
        case fetchedAvatarData
    }

    public init(id: String, name: String?, path: String?, webURL: URL?, avatarUrl: URL?, namespace: NameSpace?, repository: Repository?, group: Group?, fetchedAvatarData: Data?) {
        self.id = id
        self.name = name
        self.path = path
        self.webURL = webURL
        self.avatarUrl = avatarUrl
        self.namespace = namespace
        self.repository = repository
        self.group = group
        self.fetchedAvatarData = fetchedAvatarData
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: TargetProject.CodingKeys.self)
        
        self.id = try container.decode(String.self, forKey: .id)
        self.name = try container.decodeIfPresent(String.self, forKey: .name)
        self.path = try container.decodeIfPresent(String.self, forKey: .path)
        self.webURL = try container.decodeURLWithEncodingIfPresent(forKey: .webURL)
        self.avatarUrl = try? container.decodeURLWithEncodingIfPresent(forKey: .avatarUrl)
        self.namespace = try container.decodeIfPresent(NameSpace.self, forKey: .namespace)
        self.repository = try container.decodeIfPresent(Repository.self, forKey: .repository)
        self.group = try container.decodeIfPresent(Group.self, forKey: .group)
        self.fetchedAvatarData = try container.decodeIfPresent(Data.self, forKey: .fetchedAvatarData)
    }
}

// MARK: - NameSpace
public struct NameSpace: Codable, Defaults.Serializable, Equatable, Hashable, Identifiable {
    public let id: String
    public let fullPath: String
    public let fullName: String

    enum CodingKeys: String, CodingKey {
        case id, fullPath, fullName
    }
}

// MARK: - Repository
public struct Repository: Codable, Defaults.Serializable, Equatable, Hashable {
    /// Main Branch
    public let rootRef: String?

    enum CodingKeys: String, CodingKey {
        case rootRef = "rootRef"
    }
}

// MARK: - Group
public struct Group: Codable, Defaults.Serializable, Equatable, Hashable {
    public let id, name, fullName, fullPath: String?
    public let webURL: URL?

    enum CodingKeys: String, CodingKey {
        case id, name, fullName, fullPath
        case webURL = "webUrl"
    }

    public init(id: String?, name: String?, fullName: String?, fullPath: String?, webURL: URL?) {
        self.id = id
        self.name = name
        self.fullName = fullName
        self.fullPath = fullPath
        self.webURL = webURL
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.id = try container.decodeIfPresent(String.self, forKey: .id)
        self.name = try container.decodeIfPresent(String.self, forKey: .name)
        self.fullName = try container.decodeIfPresent(String.self, forKey: .fullName)
        self.fullPath = try container.decodeIfPresent(String.self, forKey: .fullPath)
        // Should re-encode any non-escaped utf8 strings
        self.webURL = try? container.decodeURLWithEncodingIfPresent(forKey: .webURL)
    }
}

// MARK: - PipelineStatus
public enum PipelineStatus: String, Codable, Defaults.Serializable, Equatable {
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
public enum MergeStatus: String, Codable, Defaults.Serializable, Equatable {
    case cannotBeMerged = "CANNOT_BE_MERGED"
    case cannotBeMergedRecheck = "CANNOT_BE_MERGED_RECHECK"
    case canBeMerged = "CAN_BE_MERGED"
    case checking = "CHECKING"
    case unchecked = "UNCHECKED"
}

// MARK: - MergeRequestState
public enum MergeRequestState: String, Codable, Defaults.Serializable, Equatable {
    case merged = "merged"
    case opened = "opened"
    case closed = "closed"
    case locked = "locked"
    case all = "all"
}

// MARK: - MergeRequestEventType
public enum MergeRequestEventType: String, Codable, Defaults.Serializable, Equatable {
    /// Pipeline run on the changes from the source branch combined with the target branch.
    case mergedResult = "MERGED_RESULT"
    /// Pipeline run on the changes in the merge request source branch.
    case detached = "DETACHED"
    /// Pipeline ran as part of a merge train.
    case mergeTrain = "MERGE_TRAIN"
}

public enum StageStatusType: String, Codable, Defaults.Serializable, Equatable {
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

// MARK: - ProjectImageResponse
public struct ProjectImageResponse: Codable, Defaults.Serializable, Equatable, Hashable {
    let fileName, filePath: String?
    let size: Int?
    let encoding, contentSha256, ref, blobID: String?
    let commitID, lastCommitID: String?
    let executeFilemode: Bool?
    let content: String?

    enum CodingKeys: String, CodingKey {
        case fileName = "file_name"
        case filePath = "file_path"
        case size, encoding
        case contentSha256 = "content_sha256"
        case ref = "ref"
        case blobID = "blob_id"
        case commitID = "commit_id"
        case lastCommitID = "last_commit_id"
        case executeFilemode = "execute_filemode"
        case content = "content"
    }
}
