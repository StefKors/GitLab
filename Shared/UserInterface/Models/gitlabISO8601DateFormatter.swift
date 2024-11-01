//
//  File.swift
//  
//
//  Created by Stef Kors on 27/07/2022.
//

import Foundation

extension Date {

    static func fromGitLabISOString(_ string: String?) -> Date? {
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
        guard let string, let date = isoFormatter.date(from: string) else {
            return nil
        }
        return date
    }

}
