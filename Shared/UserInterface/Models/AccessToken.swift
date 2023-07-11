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
