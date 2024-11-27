//
//  Account.swift
//  GitLab
//
//  Created by Stef Kors on 26/07/2023.
//

import SwiftUI
import SharingGRDB

extension EnvironmentValues {
    @Entry var account: Account? = nil
}

enum GitProvider: String, Codable, CaseIterable, Hashable {
    case GitLab = "GitLab"
    case GitHub = "GitHub"
}

@Table
struct Account: FetchableRecord, Identifiable, Equatable, Codable, MutablePersistableRecord {
    

    /// AutoIncrementedPrimaryKey
    var id: Int64?
    var token: String
    var instance: String
    @Column(as: JSONRepresentation<GitProvider>.self)
    var provider: GitProvider
    @Column(as: Date.ISO8601Representation.self)
    var createdAt: Date = Date.now
//    var requests: [UniversalMergeRequest] = []

//    /// The association from an account to its requests
//    static let requests = hasMany(UniversalMergeRequest.self)
//    /// The request for the requests of an account
//    var requests: QueryInterfaceRequest<UniversalMergeRequest> {
//        request(for: Account.requests)
//    }

    mutating func didInsert(_ inserted: InsertionSuccess) {
        id = inserted.rowID
    }
}

extension Account {
    static let preview = Account(token: "sdflkjdsfkljdsflkj", instance: "https://gitlab.com", provider: .GitLab)
    static let previewGitHub = Account(token: "sdflkjdsfkljdsflkj", instance: "https://github.com", provider: .GitHub)
}
