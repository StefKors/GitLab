//
//  AccessToken.swift
//  GitLab
//
//  Created by Stef Kors on 11/07/2023.
//

import Foundation
import Defaults

// MARK: - AccessToken
struct AccessToken: Codable, Defaults.Serializable, Equatable, Hashable {
    let id: Int?
    let name: String?
    let revoked: Bool?
    let createdAt: String?
    let scopes: [String]?
    let userID: Int?
    let lastUsedAt: String?
    let active: Bool?
    let expiresAt: String?

    enum CodingKeys: String, CodingKey {
        case id, name, revoked
        case createdAt = "created_at"
        case scopes
        case userID = "user_id"
        case lastUsedAt = "last_used_at"
        case active
        case expiresAt = "expires_at"
    }
}

extension AccessToken {
    static let preview = AccessToken(
        id: 123123,
        name: "gitlab_token",
        revoked: false,
        createdAt: "2023-07-06T11:21:49.117Z",
        scopes: ["read_api"],
        userID: 234234,
        lastUsedAt: "2023-07-11T07:39:06.346Z",
        active: true,
        expiresAt: "2024-07-05"
    )
}
