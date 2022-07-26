//
//  NetworkManager.swift
//  GitLab
//
//  Created by Stef Kors on 13/09/2021.
//

import Foundation
import Combine
import Get
import SwiftUI
import Defaults

public enum AppIcons: String, DefaultsSerializable, CaseIterable {
    case ReleaseIcon
    case DevIcon
}

extension Defaults.Keys {
    static let apiToken = Key<String>("apiToken", default: "")
    static let showDockIcon = Key<Bool>("showDockIcon", default: false)
    static let selectedIcon = Key<AppIcons>("selectedIcon", default: .DevIcon)
    static let showAppWindow = Key<Bool>("showAppWindow", default: false)
    static let authoredMergeRequests = Key<[MergeRequest]>("authoredMergeRequests", default: [])
    static let reviewRequestedMergeRequests = Key<[MergeRequest]>("reviewRequestedMergeRequests", default: [])
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
    @Published public var lastUpdate: Date?
    @Published public var tokenExpired: Bool = false

    public init() {
        self.setDockIconPolicy()
    }

    /// https://gitlab.com/-/graphql-explorer
    fileprivate func getQuery(_ type: QueryType) -> String {
        "query { currentUser { name \(type.rawValue)(state: opened) { edges { node { state id title draft webUrl reference targetProject { id name path webUrl group { id name fullName fullPath webUrl } } approvedBy { edges { node { id name username avatarUrl } } } mergeStatusEnum approved approvalsLeft userDiscussionsCount userNotesCount headPipeline { id active status mergeRequestEventType stages { edges { node { id status name jobs { edges { node { id active name status detailedStatus { id detailsPath } } } } } } } } } } } } }"
    }

    public func fetch() async {
        /// Parallel?
        await fetchAuthoredMergeRequests()
        await fetchReviewRequestedMergeRequests()
    }

    private func fetchAuthoredMergeRequests() async {
        do {
            print("fetch: start fetchAuthoredMergeRequests")
            let beforeApprovedByDict = authoredMergeRequests.approvedByDict
            let client = APIClient(baseURL: URL(string: "https://gitlab.com/api"))
            let req = Request<GitLabQuery>.post("/graphql", query: [
                ("query", getQuery(.authoredMergeRequests)),
                ("private_token", apiToken)
            ])
            let response: GitLabQuery = try await client.send(req).value

            await MainActor.run {
                if response.data?.currentUser == nil {
                    tokenExpired = true
                } else {
                    tokenExpired = false
                }
                // MARK: - Handle Notifications
                let newMergeRequests = response.authoredMergeRequests
                let newApproveByDict = newMergeRequests.approvedByDict

                if beforeApprovedByDict != newApproveByDict {
                    for (reference, newAuthors) in newApproveByDict {
                        let beforeAuthors = (beforeApprovedByDict[reference] ?? [])

                        let diff = newAuthors.difference(from: beforeAuthors)
                        // MARK: - Notification Approved MRs
                        let approvers = diff.insertions.insertedElements.compactMap({ $0.name })
                        if !approvers.isEmpty,
                           let eventMR = newMergeRequests.first(where: { $0.reference == reference }),
                           let url = eventMR.webURL,
                           let title = eventMR.title,
                           let headPipeline = eventMR.headPipeline,
                           let jsonData = try? JSONEncoder().encode(headPipeline) {

                            let userInfo = [
                                "MR_URL" : url.absoluteString,
                                "PIPELINE_STATUS": jsonData
                            ] as [String : Any]
                            NotificationManager.shared.sendNotification(
                                title: title,
                                subtitle: "\(reference) is approved by \(approvers.formatted())",
                                userInfo: userInfo
                            )

                        }

                        // MARK: - Notification Revoked MRs
                        let revokers = diff.removals.removedElements.compactMap({ $0.name })
                        if !revokers.isEmpty,
                           let eventMR = newMergeRequests.first(where: { $0.reference == reference }),
                           let url = eventMR.webURL,
                           let title = eventMR.title,
                           let headPipeline = eventMR.headPipeline,
                           let jsonData = try? JSONEncoder().encode(headPipeline) {

                            let userInfo = [
                                "MR_URL" : url.absoluteString,
                                "PIPELINE_STATUS": jsonData
                            ] as [String : Any]
                            NotificationManager.shared.sendNotification(
                                title: title,
                                subtitle: "\(reference) approval revoked by \(revokers.formatted())",
                                userInfo: userInfo
                            )

                        }
                    }
                }

                // MARK: - Update published values
                // queryResponse = response
                print("fetch: updated data fetchAuthoredMergeRequests")
                authoredMergeRequests = newMergeRequests
                lastUpdate = .now
                noticeState.clearNetworkNotices()
            }
        } catch APIError.unacceptableStatusCode(let statusCode) {
            // Handle Bad GitLab Reponse
            let warningNotice = NoticeMessage(
                label: "Recieved \(statusCode) from API, data might be out of date",
                statusCode: statusCode,
                type: .warning
            )
            noticeState.addNotice(notice: warningNotice)
        } catch {
            // Handle Offline Notice
            let isGitLabReachable = reachable(host: "gitlab.com")
            if isGitLabReachable == false {
                let informationNotice = NoticeMessage(
                    label: "Unable to reach gitlab.com",
                    type: .network
                )
                noticeState.addNotice(notice: informationNotice)
            }

            print("\(Date.now) Fetch fetchAuthoredMergeRequests failed with unexpected error: \(error).")
        }
    }

    private func fetchReviewRequestedMergeRequests() async {
        do {
            print("fetch: start fetchnreviewRequestedMergeRequests")
            let beforeMergeRequests = reviewRequestedMergeRequests
            let client = APIClient(baseURL: URL(string: "https://gitlab.com/api"))
            let req = Request<GitLabQuery>.post("/graphql", query: [
                ("query", getQuery(.reviewRequestedMergeRequests)),
                ("private_token", apiToken)
            ])
            let response: GitLabQuery = try await client.send(req).value
            await MainActor.run {
                if response.data?.currentUser == nil {
                    tokenExpired = true
                } else {
                    tokenExpired = false
                }
                // MARK: - Update published values
                if beforeMergeRequests.isEmpty || (beforeMergeRequests != response.reviewRequestedMergeRequests) {
                    // queryResponse = response
                reviewRequestedMergeRequests = response.reviewRequestedMergeRequests
                    lastUpdate = .now
                print("fetch: updated data fetchreviewRequestedMergeRequests")
                }
            }
        } catch {
            // ▿ APIError
            // - unacceptableStatusCode : 502
            print("\(Date.now) Fetch fetchreviewRequestedMergeRequests failed with unexpected error: \(error).")
        }
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

extension BidirectionalCollection where Element == CollectionDifference<Author>.Change {
    /// Return all elements of changed type `.insert`
    var insertedElements: [Author] {
        return self.compactMap({ insertion -> Author? in
            guard case let .insert(offset: _, element: element, associatedWith: _) = insertion else {
                return nil
            }
            return element
        })
    }

    /// Return all elements of changed type `.remove`
    var removedElements: [Author] {
        return self.compactMap({ insertion -> Author? in
            guard case let .remove(offset: _, element: element, associatedWith: _) = insertion else {
                return nil
            }
            return element
        })
    }
}

