//
//  Date.swift
//  GitLab
//
//  Created by Stef Kors on 31/10/2024.
//

import SwiftUI

extension Date {
    /// from a date string like "2023-07-03T11:47:21Z" to a date object
    static func from(_ string: String?) -> Date? {
        guard let string else { return nil }
        let fixedFormatter = DateFormatter()
//        fixedFormatter.locale = Locale(identifier: "en_US_POSIX")
        fixedFormatter.timeZone = TimeZone(secondsFromGMT: 0)
        fixedFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZ"
        return fixedFormatter.date(from: string)
    }
}
