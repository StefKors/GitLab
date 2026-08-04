//
//  Account.swift
//  GitLab
//
//  Created by Stef Kors on 26/07/2023.
//

import Foundation
import GRDB
import SQLiteData

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
    @Column(as: GitProvider.JSONRepresentation.self)
    var provider: GitProvider
    var createdAt: Date = Date.now

    mutating func didInsert(_ inserted: InsertionSuccess) {
        id = inserted.rowID
    }
}

extension Account {
    static let preview = Account(token: "sdflkjdsfkljdsflkj", instance: "https://gitlab.com", provider: .GitLab)
    static let previewGitHub = Account(token: "sdflkjdsfkljdsflkj", instance: "https://github.com", provider: .GitHub)
}
