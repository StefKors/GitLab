//
//  NoticeMessage.swift
//  
//
//  Created by Stef Kors on 25/07/2022.
//

import Foundation
import Defaults
import SwiftUI

public struct NoticeMessage: Codable, Defaults.Serializable, Equatable, Hashable, Identifiable  {
    public var id: UUID
    public var label: String
    public var statusCode: Int?
    public var webLink: URL?
    public var dismissed: Bool
    public var type: NoticeType
    public var createdAt: Date

    public init(
        id: UUID = UUID(),
        label: String,
        statusCode: Int? = nil,
        webLink: URL? = nil,
        dismissed: Bool = false,
        type: NoticeType,
        createdAt: Date = .now
    ) {
        self.id = id
        self.label = label
        self.statusCode = statusCode
        self.webLink = webLink
        self.dismissed = dismissed
        self.type = type
        self.createdAt = createdAt
    }

    public var color: Color {
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

    public mutating func dismiss() {
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
