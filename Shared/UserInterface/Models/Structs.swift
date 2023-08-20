// This file was generated from JSON Schema using quicktype, do not modify it directly.
// To parse the JSON, add this file to your project and do:
//

import Foundation

// MARK: - GitLabQuery
struct GitLabQuery: Codable, Equatable {
    let data: DataClass?
}

extension GitLabQuery {
    var authoredMergeRequests: [MergeRequest] {
        return self.data?.currentUser?.authoredMergeRequests?.edges?.compactMap({ edge in
            return MergeRequest(edge.node)
        }) ?? self.data?.user?.authoredMergeRequests?.edges?.compactMap({ edge in
            return MergeRequest(edge.node)
        }) ?? []
    }

    var reviewRequestedMergeRequests: [MergeRequest] {
        return self.data?.currentUser?.reviewRequestedMergeRequests?.edges?.compactMap({ edge in
            return MergeRequest(edge.node)
        }) ?? self.data?.user?.reviewRequestedMergeRequests?.edges?.compactMap({ edge in
            return MergeRequest(edge.node)
        }) ?? []
    }
}

// MARK: - DataClass
struct DataClass: Codable, Equatable {
    let currentUser: CurrentUser?
    let user: CurrentUser?
}

// MARK: - CurrentUser
struct CurrentUser: Codable, Equatable {
    let name: String?
    let authoredMergeRequests: AuthoredMergeRequests?
    let reviewRequestedMergeRequests: ReviewRequestedMergeRequests?
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

struct Author: Codable, Equatable {
    let id, name, username: String?
    let avatarUrl: URL?

    enum CodingKeys: String, CodingKey {
        case id, name, username
        case avatarUrl = "avatarUrl"
    }

    init(id: String?, name: String?, username: String?, avatarUrl: URL?) {
        self.id = id
        self.name = name
        self.username = username
        self.avatarUrl = avatarUrl
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: Author.CodingKeys.self)
        self.id = try container.decode(String.self, forKey: .id)
        self.name = try container.decodeIfPresent(String.self, forKey: .name)
        self.username = try container.decodeIfPresent(String.self, forKey: .username)
        // Should re-encode any non-escaped utf8 strings
        self.avatarUrl = try? container.decodeURLWithEncodingIfPresent(forKey: .avatarUrl)
    }
}

/// (same as Author above ^ but with int for id
struct EventAuthor: Codable, Equatable {
    let id: Int?
    let name, username: String?
    let avatarUrl: URL?

    enum CodingKeys: String, CodingKey {
        case id, name, username
        case avatarUrl = "avatarUrl"
    }

    init(id: Int?, name: String?, username: String?, avatarUrl: URL?) {
        self.id = id
        self.name = name
        self.username = username
        self.avatarUrl = avatarUrl
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: EventAuthor.CodingKeys.self)
        self.id = try container.decodeIfPresent(Int.self, forKey: .id)
        self.name = try container.decodeIfPresent(String.self, forKey: .name)
        self.username = try container.decodeIfPresent(String.self, forKey: .username)
        // Should re-encode any non-escaped utf8 strings
        self.avatarUrl = try? container.decodeURLWithEncodingIfPresent(forKey: .avatarUrl)
    }
}

// MARK: - ApprovedMergeRequestsEdge
struct ApprovedMergeRequestsEdge: Codable, Equatable {
    let node: Author?
}

// MARK: - ApprovedMergeRequests
struct ApprovedMergeRequests: Codable, Equatable {
    let edges: [ApprovedMergeRequestsEdge]?
}

// MARK: - AuthoredMergeRequestsEdge
struct AuthoredMergeRequestsEdge: Codable, Equatable {
    let node: MergeRequestCodable?
}

// MARK: - AuthoredMergeRequests
struct AuthoredMergeRequests: Codable, Equatable {
    let edges: [AuthoredMergeRequestsEdge]?
}

// MARK: - ReviewRequestedMergeRequests
struct ReviewRequestedMergeRequests: Codable, Equatable {
    let edges: [ReviewRequestedMergeRequestsEdge]?
}

// MARK: - ReviewRequestedMergeRequestsEdge
struct ReviewRequestedMergeRequestsEdge: Codable, Equatable {
    let node: MergeRequestCodable?
}

// MARK: - JobsEdge
struct JobsEdge: Codable, Equatable {
    let node: HeadPipeline?
}


// MARK: - Jobs
struct Jobs: Codable, Equatable {
    let edges: [JobsEdge]?
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
struct FluffyNode: Codable, Equatable {
    let id: String?
    let status: StageStatusType?
    let name: String?
    let jobs: Jobs?
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
struct StagesEdge: Codable, Equatable {
    let node: FluffyNode?
}

// MARK: - Stages
struct Stages: Codable, Equatable {
    let edges: [StagesEdge]?
}

extension Stages {
    static let previewParent = Stages(edges: [StagesEdge(node: .previewTest)])
    static let previewChild = Stages(edges: [StagesEdge(node: .previewNoChildren)])
}

// MARK: - HeadPipeline
struct HeadPipeline: Codable, Equatable {
    let id: String?
    let active: Bool?
    let status: PipelineStatus?
    let stages: Stages?
    let name: String?
    let detailedStatus: DetailedStatus?
    let mergeRequestEventType: MergeRequestEventType?
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
struct DetailedStatus: Codable, Equatable {
    let id: String?
    let detailsPath: String?
}

extension DetailedStatus {
    static let preview = DetailedStatus(id: "id-id-id", detailsPath: "/details?...")
}

// MARK: - TargetProject
struct TargetProject: Codable, Equatable, Hashable, Identifiable {
    let id: String
    let name, path: String?
    let webURL: URL?
    let avatarUrl: URL?
    let namespace: NameSpace?
    let repository: Repository?
    let group: Group?
    let fetchedAvatarData: Data?

    enum CodingKeys: String, CodingKey {
        case id, name, path
        case webURL = "webUrl"
        case avatarUrl = "avatarUrl"
        case namespace
        case repository
        case group
        case fetchedAvatarData
    }

    init(id: String, name: String?, path: String?, webURL: URL?, avatarUrl: URL?, namespace: NameSpace?, repository: Repository?, group: Group?, fetchedAvatarData: Data?) {
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

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: TargetProject.CodingKeys.self)

        self.id = try container.decode(String.self, forKey: .id)
        self.name = try container.decodeIfPresent(String.self, forKey: .name)
        self.path = try container.decodeIfPresent(String.self, forKey: .path)
        self.webURL = try? container.decodeURLWithEncodingIfPresent(forKey: .webURL)
        self.avatarUrl = try? container.decodeURLWithEncodingIfPresent(forKey: .avatarUrl)
        self.namespace = try container.decodeIfPresent(NameSpace.self, forKey: .namespace)
        self.repository = try container.decodeIfPresent(Repository.self, forKey: .repository)
        self.group = try container.decodeIfPresent(Group.self, forKey: .group)
        self.fetchedAvatarData = try container.decodeIfPresent(Data.self, forKey: .fetchedAvatarData)
    }
}

// MARK: - NameSpace
struct NameSpace: Codable, Equatable, Hashable, Identifiable {
    let id: String
    let fullPath: String
    let fullName: String

    enum CodingKeys: String, CodingKey {
        case id, fullPath, fullName
    }
}

// MARK: - Repository
struct Repository: Codable, Equatable, Hashable {
    /// Main Branch
    let rootRef: String?

    enum CodingKeys: String, CodingKey {
        case rootRef = "rootRef"
    }
}

// MARK: - Group
struct Group: Codable, Equatable, Hashable {
    let id, name, fullName, fullPath: String?
    let webURL: URL?

    enum CodingKeys: String, CodingKey {
        case id, name, fullName, fullPath
        case webURL = "webUrl"
    }

    init(id: String?, name: String?, fullName: String?, fullPath: String?, webURL: URL?) {
        self.id = id
        self.name = name
        self.fullName = fullName
        self.fullPath = fullPath
        self.webURL = webURL
    }

    init(from decoder: Decoder) throws {
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
enum PipelineStatus: String, Codable, Equatable {
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
enum MergeStatus: String, Codable, Equatable {
    case cannotBeMerged = "CANNOT_BE_MERGED"
    case cannotBeMergedRecheck = "CANNOT_BE_MERGED_RECHECK"
    case canBeMerged = "CAN_BE_MERGED"
    case checking = "CHECKING"
    case unchecked = "UNCHECKED"
}

// MARK: - MergeRequestState
enum MergeRequestState: String, Codable, Equatable {
    case merged = "merged"
    case opened = "opened"
    case closed = "closed"
    case locked = "locked"
    case all = "all"
}

// MARK: - MergeRequestEventType
enum MergeRequestEventType: String, Codable, Equatable {
    /// Pipeline run on the changes from the source branch combined with the target branch.
    case mergedResult = "MERGED_RESULT"
    /// Pipeline run on the changes in the merge request source branch.
    case detached = "DETACHED"
    /// Pipeline ran as part of a merge train.
    case mergeTrain = "MERGE_TRAIN"
}

enum StageStatusType: String, Codable, Equatable {
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

    func toPipelineStatus() -> PipelineStatus? {
        PipelineStatus(rawValue: self.rawValue.uppercased())
    }
}

// MARK: - ProjectImageResponse
struct ProjectImageResponse: Codable, Equatable, Hashable {
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
