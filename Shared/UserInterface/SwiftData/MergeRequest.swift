//
//  MergeRequest.swift
//  GitLab
//
//  Created by Stef Kors on 10/08/2023.
//

import SwiftUI
import SwiftData

extension String {
    func deletingPrefix(_ prefix: String) -> String {
        guard self.hasPrefix(prefix) else { return self }
        return String(self.dropFirst(prefix.count))
    }
}

// MARK: - MergeRequest
@Model class MergeRequest {
    @Attribute(.unique) var id: String
    var mergerequestID: String?
    var title: String?
    var state: MergeRequestState?
    var draft: Bool?
    var webUrl: URL?
    var mergeStatusEnum: MergeStatus?
    var approvedBy: ApprovedMergeRequests?
    var userDiscussionsCount: Int?
    var userNotesCount: Int?
    // TODO: Fix otherwise crash
    var headPipeline: HeadPipeline?
    var reference: String?
    var targetProject: TargetProject?
    var type: QueryType?

//    @Relationship(inverse: \Account.mergeRequests)
    var account: Account?

    init(
        id: String? = nil,
        mergerequestID: String? = nil,
        title: String? = nil,
        state: MergeRequestState? = nil,
        draft: Bool? = nil,
        webUrl: URL? = nil,
        mergeStatusEnum: MergeStatus? = nil,
        approvedBy: ApprovedMergeRequests? = nil,
        userDiscussionsCount: Int? = nil,
        userNotesCount: Int? = nil,
        headPipeline: HeadPipeline? = nil,
        reference: String? = nil,
        targetProject: TargetProject? = nil,
        type: QueryType? = nil,
        account: Account? = nil
    ) {
        self.mergerequestID = mergerequestID
        self.id = id?.deletingPrefix("gid://").replacingOccurrences(of: "/", with: "-") ?? UUID().uuidString
        self.title = title
        self.state = state
        self.draft = draft
        self.webUrl = webUrl
        self.mergeStatusEnum = mergeStatusEnum
        self.approvedBy = approvedBy
        self.userDiscussionsCount = userDiscussionsCount
        self.userNotesCount = userNotesCount
        self.headPipeline = headPipeline
        self.reference = reference
        self.targetProject = targetProject
        self.type = type
        self.account = account
    }

    convenience init?(_ codablevariant: MergeRequestCodable?) {
        guard let codablevariant else { return nil }
        self.init(
            id: codablevariant.id,
            mergerequestID: codablevariant.id,
            title: codablevariant.title,
            state: codablevariant.state,
            draft: codablevariant.draft,
            webUrl: codablevariant.webUrl,
            mergeStatusEnum: codablevariant.mergeStatusEnum,
            approvedBy: codablevariant.approvedBy,
            userDiscussionsCount: codablevariant.userDiscussionsCount,
            userNotesCount: codablevariant.userNotesCount,
            headPipeline: codablevariant.headPipeline,
            reference: codablevariant.reference,
            targetProject: codablevariant.targetProject,
            type: codablevariant.type
        )
    }
}

extension MergeRequest {
    static let preview = MergeRequest(
        id: "gid://gitlab/MergeRequest/2676",
        mergerequestID: "gid://gitlab/MergeRequest/2676",
        title: "Resolve \"Sidebar Cleanup\"",
        state: .opened,
        draft: false,
        webUrl: URL(string: "https://gitlab.com/proj"),
        mergeStatusEnum: .canBeMerged,
        approvedBy: nil,
        userDiscussionsCount: 12,
        userNotesCount: 12,
        headPipeline: nil,
        reference: "2676",
        targetProject: .preview,
        type: .authoredMergeRequests,
        account: nil
    )

    static let preview2 = MergeRequest(
        id: "gid://gitlab/MergeRequest/512",
        mergerequestID: "gid://gitlab/MergeRequest/512",
        title: "Fix: Account settings redesign list performance",
        state: .opened,
        draft: true,
        webUrl: URL(string: "https://gitlab.com/proj"),
        mergeStatusEnum: .checking,
        approvedBy: nil,
        userDiscussionsCount: nil,
        userNotesCount: nil,
        headPipeline: nil,
        reference: "512",
        targetProject: .preview,
        type: .authoredMergeRequests,
        account: nil
    )
}

extension MergeRequest: CustomDebugStringConvertible {
    var debugDescription: String {
        return "MergeRequest(mergerequestID: \(mergerequestID ?? "nil"), title: \(title ?? "nil"))"
    }
}

class MergeRequestCodable: Codable, Equatable, Identifiable {
    // TODO: improve
    static func == (lhs: MergeRequestCodable, rhs: MergeRequestCodable) -> Bool {
        lhs.id == rhs.id
    }

    var id: String?
    var title: String?
    var state: MergeRequestState?
    var draft: Bool?
    var webUrl: URL?
    var mergeStatusEnum: MergeStatus?
    var approvedBy: ApprovedMergeRequests?
    var userDiscussionsCount: Int?
    var userNotesCount: Int?
    var headPipeline: HeadPipeline?
    var reference: String?
    var targetProject: TargetProject?

    var type: QueryType?

    enum CodingKeys: String, CodingKey {
        case type
        case state, uuid, id, title, draft
        case webUrl = "webUrl"
        case reference, targetProject, approvedBy, mergeStatusEnum, userDiscussionsCount, userNotesCount, headPipeline
    }

    init(
        type: QueryType?,
        id: String,
        title: String?,
        state: MergeRequestState?,
        draft: Bool?,
        webUrl: URL?,
        mergeStatusEnum: MergeStatus?,
        approvedBy: ApprovedMergeRequests?,
        userDiscussionsCount: Int?,
        userNotesCount: Int?,
        headPipeline: HeadPipeline?,
        reference: String?,
        targetProject: TargetProject?
    ) {
        self.id = id
        self.title = title
        self.state = state
        self.draft = draft
        self.webUrl = webUrl
        self.mergeStatusEnum = mergeStatusEnum
        self.approvedBy = approvedBy
        self.userDiscussionsCount = userDiscussionsCount
        self.userNotesCount = userNotesCount
        self.headPipeline = headPipeline
        self.reference = reference
        self.targetProject = targetProject
        self.type = type ?? nil
    }

    required init(from decoder: Decoder) throws {
        let container: KeyedDecodingContainer<MergeRequestCodable.CodingKeys> = try decoder.container(keyedBy: MergeRequestCodable.CodingKeys.self)

        self.type = try container.decodeIfPresent(QueryType.self, forKey: MergeRequestCodable.CodingKeys.type)
        self.state = try container.decodeIfPresent(MergeRequestState.self, forKey: MergeRequestCodable.CodingKeys.state)

        self.id = try container.decodeIfPresent(String.self, forKey: MergeRequestCodable.CodingKeys.id) ?? UUID().uuidString
        self.title = try container.decodeIfPresent(String.self, forKey: MergeRequestCodable.CodingKeys.title)
        self.draft = try container.decodeIfPresent(Bool.self, forKey: MergeRequestCodable.CodingKeys.draft)
        self.webUrl = try container.decodeIfPresent(URL.self, forKey: MergeRequestCodable.CodingKeys.webUrl)
        self.reference = try container.decodeIfPresent(String.self, forKey: MergeRequestCodable.CodingKeys.reference)
        self.targetProject = try container.decodeIfPresent(TargetProject.self, forKey: MergeRequestCodable.CodingKeys.targetProject)
        self.approvedBy = try container.decodeIfPresent(ApprovedMergeRequests.self, forKey: MergeRequestCodable.CodingKeys.approvedBy)
        self.mergeStatusEnum = try container.decodeIfPresent(MergeStatus.self, forKey: MergeRequestCodable.CodingKeys.mergeStatusEnum)
        self.userDiscussionsCount = try container.decodeIfPresent(Int.self, forKey: MergeRequestCodable.CodingKeys.userDiscussionsCount)
        self.userNotesCount = try container.decodeIfPresent(Int.self, forKey: MergeRequestCodable.CodingKeys.userNotesCount)
        self.headPipeline = try container.decodeIfPresent(HeadPipeline.self, forKey: MergeRequestCodable.CodingKeys.headPipeline)
    }

    func encode(to encoder: Encoder) throws {
        var container: KeyedEncodingContainer<MergeRequestCodable.CodingKeys> = encoder.container(keyedBy: MergeRequestCodable.CodingKeys.self)

        try container.encodeIfPresent(self.type, forKey: MergeRequestCodable.CodingKeys.type)
        try container.encodeIfPresent(self.state, forKey: MergeRequestCodable.CodingKeys.state)
        try container.encode(self.id, forKey: MergeRequestCodable.CodingKeys.id)
        try container.encodeIfPresent(self.title, forKey: MergeRequestCodable.CodingKeys.title)
        try container.encodeIfPresent(self.draft, forKey: MergeRequestCodable.CodingKeys.draft)
        try container.encodeIfPresent(self.webUrl, forKey: MergeRequestCodable.CodingKeys.webUrl)
        try container.encodeIfPresent(self.reference, forKey: MergeRequestCodable.CodingKeys.reference)
        try container.encodeIfPresent(self.targetProject, forKey: MergeRequestCodable.CodingKeys.targetProject)
        try container.encodeIfPresent(self.approvedBy, forKey: MergeRequestCodable.CodingKeys.approvedBy)
        try container.encodeIfPresent(self.mergeStatusEnum, forKey: MergeRequestCodable.CodingKeys.mergeStatusEnum)
        try container.encodeIfPresent(self.userDiscussionsCount, forKey: MergeRequestCodable.CodingKeys.userDiscussionsCount)
        try container.encodeIfPresent(self.userNotesCount, forKey: MergeRequestCodable.CodingKeys.userNotesCount)
        try container.encodeIfPresent(self.headPipeline, forKey: MergeRequestCodable.CodingKeys.headPipeline)
    }
}

// extension BidirectionalCollection where Element == MergeRequest {
//     /// Goes through all merge requests and returns the approvedBy authors
//     /// - Returns: in the format of `["!4": [Author]]`
//     var approvedByDict: [String: [Author]] {
//         var beforeDict: [String: [Author]] = [:]
//         self.forEach({ mr in
//             guard let id = mr.reference else { return }
//             let approved = mr.approvedBy?.edges?.compactMap({ $0.node })
//             beforeDict[id] = approved
//         })
//         return beforeDict
//     }
// }
