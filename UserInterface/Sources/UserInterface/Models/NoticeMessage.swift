//
//  NoticeMessage.swift
//  
//
//  Created by Stef Kors on 25/07/2022.
//

import Foundation
import Defaults

public enum NoticeType: String, DefaultsSerializable, CaseIterable, Codable {
    case information
    case warning
    case error
    case network
}

public struct NoticeMessage: Codable, DefaultsSerializable, Equatable, Hashable  {
    public var id: UUID = UUID()
    public var label: String
    public var statusCode: Int?
    public var dismissed: Bool = false
    public var type: NoticeType
    public var createdAt: Date = .now
}

let warningNotice = NoticeMessage(
    label: "Recieved 502 from API, data might be out of date",
    statusCode: 502,
    type: .warning
)

public class NoticeState: ObservableObject {
    @Published public var notices: [NoticeMessage] = []

    func addNotice(notice: NoticeMessage) {
        // If the new notice is basically the same as the last notice, Don't add new notice
        if let lastNotice = notices.last,
           lastNotice.type == notice.type,
           lastNotice.statusCode == notice.statusCode,
           lastNotice.label == notice.label,
           lastNotice.dismissed == false {
            print("not adding notice")
            return
        }

        notices.append(notice)
    }

    func removeNotice(id: UUID) {
        guard let indexToRemove = notices.lastIndex(where: { $0.id == id }) else { return }
        notices.remove(at: indexToRemove)
    }

    func clearNetworkNotices() {
        print("clear all? \(notices)")

        notices.removeAll(where: { $0.type == .network })
        print("clear all? after \(notices)")
    }
}
