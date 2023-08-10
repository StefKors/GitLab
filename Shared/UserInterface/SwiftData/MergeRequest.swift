//
//  MergeRequest.swift
//  GitLab
//
//  Created by Stef Kors on 10/08/2023.
//

import SwiftUI
import SwiftData

// MARK: - MergeRequest
@Model final class MergeRequest: Codable, Equatable {
    // this ID is failing with SwiftData
    @Attribute(.unique) var id: String
    var title: String?
    var state: MergeRequestState?
    var draft: Bool?
    var webURL: URL?
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
        case state, id, title, draft
        case webURL = "webUrl"
        case reference, targetProject, approvedBy, mergeStatusEnum, userDiscussionsCount, userNotesCount, headPipeline
    }

    init(
        type: QueryType?,
        id: String,
        title: String?,
        state: MergeRequestState?,
        draft: Bool?,
        webURL: URL?,
        mergeStatusEnum: MergeStatus?,
        approvedBy: ApprovedMergeRequests?,
        userDiscussionsCount: Int?,
        userNotesCount: Int?,
        headPipeline: HeadPipeline?,
        reference: String?,
        targetProject: TargetProject?
    ) {
        self.id = id ?? UUID().uuidString
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
        self.type = type ?? nil
    }

    init(from decoder: Decoder) throws {
        let container: KeyedDecodingContainer<MergeRequest.CodingKeys> = try decoder.container(keyedBy: MergeRequest.CodingKeys.self)

        self.type = try container.decodeIfPresent(QueryType.self, forKey: MergeRequest.CodingKeys.type)
        self.state = try container.decodeIfPresent(MergeRequestState.self, forKey: MergeRequest.CodingKeys.state)
        self.id = try container.decodeIfPresent(String.self, forKey: MergeRequest.CodingKeys.id) ?? UUID().uuidString
        self.title = try container.decodeIfPresent(String.self, forKey: MergeRequest.CodingKeys.title)
        self.draft = try container.decodeIfPresent(Bool.self, forKey: MergeRequest.CodingKeys.draft)
        self.webURL = nil //try container.decodeURLWithEncodingIfPresent(forKey: MergeRequest.CodingKeys.webURL)
        self.reference = try container.decodeIfPresent(String.self, forKey: MergeRequest.CodingKeys.reference)
        self.targetProject = nil //try container.decodeIfPresent(TargetProject.self, forKey: MergeRequest.CodingKeys.targetProject)
        self.approvedBy = try container.decodeIfPresent(ApprovedMergeRequests.self, forKey: MergeRequest.CodingKeys.approvedBy)
        self.mergeStatusEnum = try container.decodeIfPresent(MergeStatus.self, forKey: MergeRequest.CodingKeys.mergeStatusEnum)
        self.userDiscussionsCount = try container.decodeIfPresent(Int.self, forKey: MergeRequest.CodingKeys.userDiscussionsCount)
        self.userNotesCount = try container.decodeIfPresent(Int.self, forKey: MergeRequest.CodingKeys.userNotesCount)
        self.headPipeline = try container.decodeIfPresent(HeadPipeline.self, forKey: MergeRequest.CodingKeys.headPipeline)
    }

    func encode(to encoder: Encoder) throws {
        var container: KeyedEncodingContainer<MergeRequest.CodingKeys> = encoder.container(keyedBy: MergeRequest.CodingKeys.self)

        try container.encodeIfPresent(self.type, forKey: MergeRequest.CodingKeys.type)
        try container.encodeIfPresent(self.state, forKey: MergeRequest.CodingKeys.state)
        try container.encode(self.id, forKey: MergeRequest.CodingKeys.id)
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
