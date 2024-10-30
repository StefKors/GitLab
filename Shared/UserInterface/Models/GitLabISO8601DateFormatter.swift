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
