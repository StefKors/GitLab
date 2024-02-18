//
//  Array+Difference.swift
//  GitLab
//
//  Created by Stef Kors on 15/02/2024.
//

import Foundation

/// https://www.hackingwithswift.com/example-code/language/how-to-find-the-difference-between-two-arrays
extension Array where Element: Hashable {
    func difference(from other: [Element]) -> [Element] {
        let thisSet = Set(self)
        let otherSet = Set(other)
        return Array(thisSet.symmetricDifference(otherSet))
    }
}
