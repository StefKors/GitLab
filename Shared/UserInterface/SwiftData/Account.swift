//
//  Account.swift
//  GitLab
//
//  Created by Stef Kors on 26/07/2023.
//

import SwiftUI
import SwiftData

@Model final class Account {
    var token: String
    var instance: String

    init(token: String, instance: String) {
        self.token = token
        self.instance = instance
    }
}

extension Account {
    static let preview = Account(token: "sdflkjdsfkljdsflkj", instance: "https://gitlab.com")
}
