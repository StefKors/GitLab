//
//  NetworkInfo.swift
//  GitLab
//
//  Created by Stef Kors on 17/10/2024.
//

import Foundation
import Get

struct NetworkInfo: Identifiable, Equatable {
    let label: String
    let account: Account
    let method: HTTPMethod
    let timestamp: Date = .now
    let id: UUID = UUID()

    static let preview = NetworkInfo(
        label: "Fetch Authored Merge Requests",
        account: .preview,
        method: .get
    )
    static let previewGitLab = NetworkInfo(label: "Fetch Review Requested Merge Requests", account: .preview, method: .get)
    static let previewGitHub = NetworkInfo(
        label: "Fetch Authored Pull Requests",
        account: .previewGitHub,
        method: .get
    )
    static let previewGitHub2 = NetworkInfo(
        label: "Submit Authored Pull Requests",
        account: .previewGitHub,
        method: .post
    )
}
