//
//  NoticeMessage.swift
//  
//
//  Created by Stef Kors on 25/07/2022.
//

import Foundation
import SwiftUI

struct NoticeMessage: Codable, Equatable, Hashable, Identifiable {
    var id: UUID
    var label: String
    var statusCode: Int?
    var webLink: URL?
    var dismissed: Bool
    var type: NoticeType
    var branchRef: String?
    var createdAt: Date

    init(
        id: UUID = UUID(),
        label: String,
        statusCode: Int? = nil,
        webLink: URL? = nil,
        dismissed: Bool = false,
        type: NoticeType,
        branchRef: String? = nil,
        createdAt: Date = .now
    ) {
        self.id = id
        self.label = label
        self.statusCode = statusCode
        self.webLink = webLink
        self.dismissed = dismissed
        self.type = type
        self.branchRef = branchRef
        self.createdAt = createdAt
    }

    var color: Color {
        switch self.type {
        case .branch:
            return .green
        case .warning:
            return .yellow
        case .error:
            return .red
        default:
            return .blue
        }
    }

    mutating func dismiss() {
        dismissed = true
    }
}

extension NoticeMessage {
    static let previewInformationNotice = NoticeMessage(
        label: "Recieved 502 from API, data might be out of date",
        statusCode: nil,
        type: .information
    )
    static let previewWarningNotice = NoticeMessage(
        label: "Recieved 502 from API, data might be out of date",
        statusCode: 502,
        type: .warning
    )
    static let previewErrorNotice = NoticeMessage(
        label: "Recieved 502 from API, data might be",
        statusCode: 404,
        type: .error
    )
    static let previewBranchPushNotice = NoticeMessage(
        label: "You pushed to [GL-405/stef/create-release](http://www.example.com) at [StefKors/GitLab](http://www.example.com)",
        webLink: URL(string: "http://www.example.com"),
        type: .branch,
        createdAt: Date(timeIntervalSinceReferenceDate: Date.timeIntervalSinceReferenceDate - 1000)
    )
}
