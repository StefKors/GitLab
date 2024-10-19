//
//  NetworkEvent.swift
//  GitLab
//
//  Created by Stef Kors on 17/10/2024.
//

import Foundation

class NetworkEvent: Identifiable, Equatable {
    static func == (lhs: NetworkEvent, rhs: NetworkEvent) -> Bool {
        lhs.identifier == rhs.identifier &&
        lhs.info == rhs.info &&
        lhs.status == rhs.status &&
        lhs.response == rhs.response
    }

    let info: NetworkInfo
    var status: Int?
    var response: String?
    let timestamp: Date = .now
    let identifier: UUID = UUID()
    var id: String {
        "\(identifier)-\(status?.description ?? "nil")-\(timestamp)"
    }

    init(info: NetworkInfo, status: Int? = nil, response: String? = nil) {
        self.info = info
        self.status = status
        self.response = response
    }
}
