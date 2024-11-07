//
//  NetworkEvent.swift
//  GitLab
//
//  Created by Stef Kors on 17/10/2024.
//

import Foundation
import SwiftData
import Get

@Model
class NetworkEvent: Identifiable, Equatable {
    static func == (lhs: NetworkEvent, rhs: NetworkEvent) -> Bool {
        lhs.identifier == rhs.identifier &&
        lhs.info == rhs.info &&
        lhs.status == rhs.status &&
        lhs.response == rhs.response
    }

    var info: NetworkInfo
    var status: Int?
    var response: String?
    var timestamp: Date = Date.now
    var identifier: UUID = UUID()
    var id: String {
        "\(identifier)-\(status?.description ?? "nil")-\(timestamp)"
    }

    init(info: NetworkInfo, status: Int? = nil, response: String? = nil) {
        self.info = info
        self.status = status
        self.response = response
    }
}


@Model class NetworkInfo {
    var label: String
    var account: Account

    private var storedMethod: String
    var method: HTTPMethod {
        HTTPMethod(rawValue: storedMethod)
    }

    var timestamp: Date = Date.now
    var id: UUID = UUID()

    init(label: String, account: Account, method: HTTPMethod) {
        self.label = label
        self.account = account
        self.storedMethod = method.rawValue
    }
}

