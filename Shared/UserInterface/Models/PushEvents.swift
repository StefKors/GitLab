//
//  File.swift
//  
//
//  Created by Stef Kors on 26/07/2022.
//

import Foundation

// MARK: - PushEvent
typealias PushEvents = [PushEvent]

struct PushEvent: Codable, Equatable {
    let id, projectID: Int
    let actionName: ActionName?
    let targetID, targetIid, targetType: String?
    let authorID: Int?
    let targetTitle: String?
    let createdAt: String?
    let author: EventAuthor?
    let pushData: PushData?
    let authorUsername: String?
    var notice: NoticeMessage?
    
    enum CodingKeys: String, CodingKey {
        case id
        case projectID = "project_id"
        case actionName = "action_name"
        case targetID = "target_id"
        case targetIid = "target_iid"
        case targetType = "target_type"
        case authorID = "author_id"
        case targetTitle = "target_title"
        case createdAt = "created_at"
        case author
        case pushData = "push_data"
        case authorUsername = "author_username"
    }
}

enum ActionName: String, Codable {
    case deleted = "deleted"
    case pushedNew = "pushed new"
    case pushedTo = "pushed to"
}

// MARK: - PushData
struct PushData: Codable, Equatable {
    let commitCount: Int?
    let action: Action?
    let refType: RefType?
    let commitFrom, commitTo: String?
    let ref: String?
    let commitTitle: String?
    
    enum CodingKeys: String, CodingKey {
        case commitCount = "commit_count"
        case action
        case refType = "ref_type"
        case commitFrom = "commit_from"
        case commitTo = "commit_to"
        case ref
        case commitTitle = "commit_title"
    }
}

enum Action: String, Codable {
    case created = "created"
    case pushed = "pushed"
    case removed = "removed"
}

enum RefType: String, Codable {
    case branch = "branch"
}
