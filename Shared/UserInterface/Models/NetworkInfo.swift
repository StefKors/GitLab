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
}
