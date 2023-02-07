//
//  NoticeMessage.swift
//  
//
//  Created by Stef Kors on 25/07/2022.
//

import Foundation
import Defaults
import SwiftUI

public struct NoticeMessage: Codable, Defaults.Serializable, Equatable, Hashable  {
    public var id: UUID = UUID()
    public var label: String
    public var statusCode: Int?
    public var webLink: URL?
    public var dismissed: Bool = false
    public var type: NoticeType
    public var createdAt: Date = .now

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
