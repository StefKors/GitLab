//
//  NetworkManager.swift
//  GitLab
//
//  Created by Stef Kors on 13/09/2021.
//

import Foundation
import Get
import SwiftUI
#if canImport(AppKit)
import AppKit
#else
import UIKit
#endif

enum AppIcons: String, CaseIterable {
    case ReleaseIcon
    case DevIcon
}

enum RequestError: Error {
    case sessionError(error: Error)
}

class NetworkManager {
    static let shared = NetworkManager()
    
    /// https://gitlab.com/-/graphql-explorer
    /// Return query for a the "currentUser"
    /// - Parameter type: QueryType
    /// - Returns: GraphQL query with MR information
    static func getQuery(_ type: QueryType) -> String {
        Self.buildQuery(target: "currentUser", type: type)
    }
    
    /// Return query for a specific user name
    /// - Parameters:
    ///   - username: Username to fetch results for
    ///   - type: QueryType
    /// - Returns: GraphQL query with MR information
    static func getQuery(username: String, type: QueryType) -> String {
        let user = "user(username: \"\(username)\""
        return Self.buildQuery(target: user, type: type)
    }
    
    /// Private method to build the GraphQL query based on the user information. Prefer getQuery methods instead
    /// - Parameters:
    ///   - target: target string to fetch results for. Either string should be either `"currentUser"` or `"user(username: \"\(username)\""`
    ///   - type: QueryType
    /// - Returns: GraphQL query with MR information
    fileprivate static func buildQuery(target: String, type: QueryType) -> String {
        "query { \(target) { name \(type.rawValue)(state: opened) { edges { node { state id title draft webUrl reference targetProject { id name path webUrl avatarUrl namespace { id fullName fullPath } repository { rootRef } group { id name fullName fullPath webUrl } } approvedBy { edges { node { id name username avatarUrl } } } mergeStatusEnum userDiscussionsCount userNotesCount headPipeline { id active status mergeRequestEventType stages { edges { node { id status name jobs { edges { node { id active name status detailedStatus { id detailsPath text label group tooltip icon } } } } } } } } } } } } }"
    }

    func branchPushReq(with account: Account) -> Request<PushEvents> {
        Request.init(path: "/v4/events", query: [
            ("after", "2022-06-25"),
            ("scope", "read_user"),
            ("action", "pushed"),
            ("private_token", account.token)
        ])
    }
    
    func authoredMergeRequestsReq(with account: Account) -> Request<GitLabQuery> {
        Request.init(path: "/graphql", method: .post, query: [
            ("query", Self.getQuery(.authoredMergeRequests)),
            ("private_token", account.token)
        ])
    }

    func reviewRequestedMergeRequestsReq(with account: Account) -> Request<GitLabQuery> {
        Request.init(path: "/graphql", method: .post, query: [
            ("query", Self.getQuery(.reviewRequestedMergeRequests)),
            ("private_token", account.token)
        ])
    }
    
    func fetch(with account: Account) async throws {
        /// Parallel?
        // await fetchLatestBranchPush()
        // try await fetchAuthoredMergeRequests(with: account)
        // try await fetchReviewRequestedMergeRequests(with: account)
    }
    
    func validateToken(instance: String, token: String) async -> AccessToken? {
        let accessTokenReq: Request<AccessToken> = Request.init(path: "/v4/personal_access_tokens/self", query: [
            ("private_token", token)
        ])
        
        do {
            let response: AccessToken? = try await APIClient(baseURL: URL(string: "\(instance)/api")).send(accessTokenReq).value
            
            return response
        } catch {
            print(error.localizedDescription)
            return nil
        }
        
    }
}

extension Date {
    static var oneHourAgo: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "YYYY-MM-DD"
        let date = Calendar.current.date(byAdding: .hour, value: -1, to: .now)!
        return formatter.string(from: date)
    }
}

enum QueryType: String, Codable, CaseIterable, Identifiable {
    case authoredMergeRequests
    case reviewRequestedMergeRequests
    var id: Self { self }
}
