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

public enum AppIcons: String, DefaultsSerializable, CaseIterable {
    case ReleaseIcon
    case DevIcon
}

enum RequestError: Error {
    case sessionError(error: Error)
}

public class NetworkManager: ObservableObject {
    // Subview States: Use with @EnvironmentObject
    public var noticeState = NoticeState()
    public var launchpadState = LaunchpadState()

    // Stored App State:
    @Default(.apiToken) public static var apiToken
    @Default(.showDockIcon) public var showDockIcon {
        didSet {
            setDockIconPolicy()
        }
    }
    @Default(.selectedIcon) public var selectedIcon
    @Default(.showAppWindow) public var showAppWindow
    @Default(.authoredMergeRequests) public var authoredMergeRequests
    @Default(.reviewRequestedMergeRequests) public var reviewRequestedMergeRequests
    @Default(.targetProjectsDict) public var targetProjectsDict

    // Not Persisted AppState
    @Published public var lastUpdate: Date?
    @Published public var tokenExpired: Bool = false

    public init() {
        self.setDockIconPolicy()
    }

    /// https://gitlab.com/-/graphql-explorer
    public static func getQuery(_ type: QueryType) -> String {
        "query { currentUser { name \(type.rawValue)(state: opened) { edges { node { state id title draft webUrl reference targetProject { id name path webUrl avatarUrl group { id name fullName fullPath webUrl } } approvedBy { edges { node { id name username avatarUrl } } } mergeStatusEnum approved approvalsLeft userDiscussionsCount userNotesCount headPipeline { id active status mergeRequestEventType stages { edges { node { id status name jobs { edges { node { id active name status detailedStatus { id detailsPath } } } } } } } } } } } } }"
    }

    public let client = APIClient(baseURL: URL(string: "https://gitlab.com/api"))
    public let branchPushReq: Request<PushEvents> = Request.init(path: "/v4/events", query: [
        ("after", "2022-06-25"),
        ("scope", "read_user"),
        ("action", "pushed"),
        ("private_token", apiToken)
    ])

    public let authoredMergeRequestsReq: Request<GitLabQuery> = Request.init(path: "/graphql", method: .post, query: [
        ("query", getQuery(.authoredMergeRequests)),
        ("private_token", apiToken)
    ])

    public let reviewRequestedMergeRequestsReq: Request<GitLabQuery> = Request.init(path: "/graphql", method: .post, query: [
        ("query", getQuery(.reviewRequestedMergeRequests)),
        ("private_token", apiToken)
    ])

    // uses custom delegate to handle correctly encoding url path
    public let launchPadClient = APIClient(configuration: APIClient.Configuration(
        baseURL: URL(string: "https://gitlab.com"),
        delegate: LaunchPadClientDelegate()
    ))

    public func fetch() async {
        /// Parallel?
        await fetchLatestBranchPush()
        await fetchAuthoredMergeRequests()
        await fetchReviewRequestedMergeRequests()
    }

    public func setDockIconPolicy() {
        // if showDockIcon {
        //     // The application is an ordinary app that appears in the Dock and may
        //     // have a user interface.
        //     NSApp.setActivationPolicy(.regular)
        // } else {
        //     // The application does not appear in the Dock and does not have a menu
        //     // bar, but it may be activated programmatically or by clicking on one
        //     // of its windows.
        //     NSApp.setActivationPolicy(.accessory)
        // }
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
