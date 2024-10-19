//
//  QueryType.swift
//  GitLab
//
//  Created by Stef Kors on 17/10/2024.
//

import Foundation

enum QueryType: String, Codable, CaseIterable, Identifiable {
    case authoredMergeRequests
    case reviewRequestedMergeRequests

    /// Only use for viewToggle
    case networkDebug
    var id: Self { self }
}
