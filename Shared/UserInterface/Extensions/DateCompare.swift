//
//  DateCompare.swift
//  GitLab
//
//  Created by Stef Kors on 28/10/2024.
//


import Foundation

extension Date {
    func isWithinLastHours(_ number: Int) -> Bool {
        let calendar = Calendar.current
        let now = Date()
        let sevenDaysAgo = calendar.date(byAdding: .hour, value: -number, to: now)
        return self >= (sevenDaysAgo ?? now)
    }
}
