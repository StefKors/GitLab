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

    // Stored App State:
    @Default(.apiToken) public var apiToken
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
    public func getQuery(_ type: QueryType) -> String {
        "query { currentUser { name \(type.rawValue)(state: opened) { edges { node { state id title draft webUrl reference targetProject { id name path webUrl group { id name fullName fullPath webUrl } } approvedBy { edges { node { id name username avatarUrl } } } mergeStatusEnum approved approvalsLeft userDiscussionsCount userNotesCount headPipeline { id active status mergeRequestEventType stages { edges { node { id status name jobs { edges { node { id active name status detailedStatus { id detailsPath } } } } } } } } } } } } }"
    }

    public func fetch() async {
        /// Parallel?
        await fetchLatestBranchPush()
        await fetchAuthoredMergeRequests()
        await fetchReviewRequestedMergeRequests()
    }

    public func setDockIconPolicy() {
        if showDockIcon {
            // The application is an ordinary app that appears in the Dock and may
            // have a user interface.
            NSApp.setActivationPolicy(.regular)
        } else {
            // The application does not appear in the Dock and does not have a menu
            // bar, but it may be activated programmatically or by clicking on one
            // of its windows.
            NSApp.setActivationPolicy(.accessory)
        }
    }
}

public enum QueryType: String, CaseIterable, Identifiable {
    case authoredMergeRequests
    case reviewRequestedMergeRequests
    public var id: Self { self }
}
