//
//  NetworkManager.swift
//  GitLab
//
//  Created by Stef Kors on 13/09/2021.
//

import Foundation
import Get
import SwiftUI
import Defaults
#if canImport(AppKit)
import AppKit
#else
import UIKit
#endif

public enum AppIcons: String, Defaults.Serializable, CaseIterable {
    case ReleaseIcon
    case DevIcon
}

enum RequestError: Error {
    case sessionError(error: Error)
}

public class NetworkManager: ObservableObject {
    // Subview States: Use with @EnvironmentObject
    public var noticeState = NoticeState()
    public var launchpadState: LaunchpadController
    
    // Stored App State:
    @AppStorage("apiToken") static var storedToken: String = ""
    @AppStorage("baseURL") var baseURL: String = "https://gitlab.com"

    var apiToken: String {
        return Self.storedToken.trimmingCharacters(in: .whitespacesAndNewlines)
    }
    
    @Default(.authoredMergeRequests) public var authoredMergeRequests
    @Default(.reviewRequestedMergeRequests) public var reviewRequestedMergeRequests
    @Default(.targetProjectsDict) public var targetProjectsDict
    
    // Not Persisted AppState
    @Published public var lastUpdate: Date?
    @Published public var tokenExpired: Bool = false
    
    public init(launchState: LaunchpadController = .init()) {
        self.launchpadState = launchState
#if canImport(AppKit)
        NSApplication.shared.dockTile.showsApplicationBadge = false
#endif
    }
    
    /// https://gitlab.com/-/graphql-explorer
    public static func getQuery(_ type: QueryType) -> String {
        "query { currentUser { name \(type.rawValue)(state: opened) { edges { node { state id title draft webUrl reference targetProject { id name path webUrl avatarUrl repository { rootRef } group { id name fullName fullPath webUrl } } approvedBy { edges { node { id name username avatarUrl } } } mergeStatusEnum approved approvalsLeft userDiscussionsCount userNotesCount headPipeline { id active status mergeRequestEventType stages { edges { node { id status name jobs { edges { node { id active name status detailedStatus { id detailsPath } } } } } } } } } } } } }"
    }
    
    public var client: APIClient {
        APIClient(baseURL: URL(string: "\(baseURL)/api"))
    }
    public var branchPushReq: Request<PushEvents> {
        Request.init(path: "/v4/events", query: [
            ("after", "2022-06-25"),
            ("scope", "read_user"),
            ("action", "pushed"),
            ("private_token", apiToken)
        ])
    }
    
    public var authoredMergeRequestsReq: Request<GitLabQuery> {
        Request.init(path: "/graphql", method: .post, query: [
            ("query", Self.getQuery(.authoredMergeRequests)),
            ("private_token", apiToken)
        ])
    }
    
    public var reviewRequestedMergeRequestsReq: Request<GitLabQuery> {
        Request.init(path: "/graphql", method: .post, query: [
            ("query", Self.getQuery(.reviewRequestedMergeRequests)),
            ("private_token", apiToken)
        ])
    }
    
    // uses custom delegate to handle correctly encoding url path
    public var launchPadClient: APIClient {
        APIClient(configuration: APIClient.Configuration(
            baseURL: URL(string: baseURL),
            delegate: LaunchPadClientDelegate()
        ))
    }
    
    public func fetch() async {
        /// Parallel?
        await fetchLatestBranchPush()
        await fetchAuthoredMergeRequests()
        await fetchReviewRequestedMergeRequests()
    }
    
    func validateToken() async -> AccessToken? {
        let accessTokenReq: Request<AccessToken> = Request.init(path: "/v4/personal_access_tokens/self", query: [
            ("private_token", apiToken)
        ])
        
        let response: AccessToken? = try? await client.send(accessTokenReq).value
        
        return response
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

public enum QueryType: String, CaseIterable, Identifiable {
    case authoredMergeRequests
    case reviewRequestedMergeRequests
    public var id: Self { self }
}
