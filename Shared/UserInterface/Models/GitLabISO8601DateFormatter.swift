//
//  File.swift
//  
//
//  Created by Stef Kors on 27/07/2022.
//

import Foundation

var GitLabISO8601DateFormatter: ISO8601DateFormatter {
    let isoFormatter = ISO8601DateFormatter()
    isoFormatter.formatOptions = [
        .withFullDate,
        .withTime,
        .withDashSeparatorInDate,
        .withColonSeparatorInTime,
        .withColonSeparatorInTimeZone,
        .withFractionalSeconds,
        .withTimeZone
    ]
    return isoFormatter
}

extension Date {
    static func fromGitLabISOString(_ string: String?) -> Date? {
        guard let string, let date = GitLabISO8601DateFormatter.date(from: string) else {
            return nil
        }
        return date
    }
}
