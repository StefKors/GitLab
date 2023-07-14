//
//  File.swift
//  
//
//  Created by Stef Kors on 29/07/2022.
//

import Foundation
import Defaults

public class NoticeState: ObservableObject {
    @Published public var notices: [NoticeMessage] = [] {
        didSet {
            // limit notice list
            if notices.count > 10 {
                notices.removeFirst(1)
            }
        }
    }

    func addNotice(notice: NoticeMessage) {
        // If the new notice is basically the same as the last notice, Don't add new notice
        for existingNotice in notices {
            if existingNotice.type == notice.type,
               existingNotice.statusCode == notice.statusCode,
               existingNotice.label == notice.label {

                // skip adding duplicate notice even if branch notice is dismissed
                if notice.type == .branch {
                    return
                }

                if existingNotice.dismissed == false {
                    print("skipping adding duplicate notice")
                    return
                }
            }
        }

        notices.append(notice)
    }

    func dismissNotice(id: UUID) {
        let index = notices.lastIndex(where: { notice in
            notice.id == id
        })

        if let index = index {
            notices[index].dismiss()
        }
    }

    func clearNetworkNotices() {
        for (index, notice) in notices.enumerated() {
            if notice.type == .network {
                notices[index].dismiss()
            }
        }
    }

    func clearAllNotices() {
        for (index, notice) in notices.enumerated() {
            notices[index].dismiss()
        }
    }
}
