//
//  Account.swift
//  GitLab
//
//  Created by Stef Kors on 26/07/2023.
//

import SwiftUI
import SwiftData

enum GitProvider: String, Codable, CaseIterable {
    case GitLab
    case GitHub
}

@Model final class Account {
    @Attribute(.unique) var id: String
    var token: String
    var instance: String
    var provider: GitProvider

//    @Relationship(deleteRule: .cascade, inverse: \MergeRequest.account)
    @Relationship(inverse: \MergeRequest.account)
    var mergeRequests: [MergeRequest] = []

    init(token: String, instance: String, provider: GitProvider = .GitLab) {
        self.id = UUID().uuidString
        self.token = token
        self.instance = instance
        self.provider = provider
    }
}

extension Account {
    static let preview = Account(token: "sdflkjdsfkljdsflkj", instance: "https://gitlab.com", provider: .GitLab)
    static let previewGitHub = Account(token: "sdflkjdsfkljdsflkj", instance: "https://github.com", provider: .GitHub)
}
