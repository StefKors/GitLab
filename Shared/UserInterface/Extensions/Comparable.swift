//
//  Comparable.swift
//  GitLab
//
//  Created by Stef Kors on 13/11/2024.
//

import Foundation


extension Comparable {
    func clamped(to limits: ClosedRange<Self>) -> Self {
        return min(max(self, limits.lowerBound), limits.upperBound)
    }
}
