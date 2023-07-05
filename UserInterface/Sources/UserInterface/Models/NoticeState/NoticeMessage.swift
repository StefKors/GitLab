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
