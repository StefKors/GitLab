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

extension Defaults.Keys {
    static let apiToken = Key<String>("apiToken", default: "")
    static let authoredMergeRequests = Key<[MergeRequest]>("authoredMergeRequests", default: [])
    static let reviewRequestedMergeRequests = Key<[MergeRequest]>("reviewRequestedMergeRequests", default: [])
}

enum RequestError: Error {
    case sessionError(error: Error)
}

public class NetworkManager: ObservableObject {
    @Published public var isUpdatingMRs: Bool = false
    @Default(.apiToken) public var apiToken
    @Default(.authoredMergeRequests) public var authoredMergeRequests
    @Default(.reviewRequestedMergeRequests) public var reviewRequestedMergeRequests
    @Published public var lastUpdate: Date?

    public init() {}

    /// https://gitlab.com/-/graphql-explorer
    fileprivate func getQuery(_ type: QueryType) -> String {
        "query { currentUser { name \(type.rawValue)(state: opened) { edges { node { state id title draft webUrl reference targetProject { id name path webUrl group { id name fullName fullPath webUrl } } approvedBy { edges { node { id name username avatarUrl } } } mergeStatusEnum approved approvalsLeft userDiscussionsCount headPipeline { id active status mergeRequestEventType stages { edges { node { id status name jobs { edges { node { id active name status } } } } } } } } } } } }"
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
                           let headPipeline = eventMR.headPipeline,
                           let jsonData = try? JSONEncoder().encode(headPipeline) {

                            let userInfo = [
                                "MR_URL" : url.absoluteString,
                                "PIPELINE_STATUS": jsonData
                            ] as [String : Any]
                            NotificationManager.shared.sendNotification(
                                title: "\(reference) is approved",
                                subtitle: "by \(approvers.formatted())",
                                userInfo: userInfo
                            )

                        }

                        // MARK: - Notification Revoked MRs
                        let revokers = diff.removals.removedElements.compactMap({ $0.name })
                        if !revokers.isEmpty,
                           let eventMR = newMergeRequests.first(where: { $0.reference == reference }),
                           let url = eventMR.webURL,
                           let headPipeline = eventMR.headPipeline,
                           let jsonData = try? JSONEncoder().encode(headPipeline) {

                            let userInfo = [
                                "MR_URL" : url.absoluteString,
                                "PIPELINE_STATUS": jsonData
                            ] as [String : Any]
                            NotificationManager.shared.sendNotification(
                                title: "\(reference) approval was revoked",
                                subtitle: "by \(revokers.formatted())",
                                userInfo: userInfo
                            )

                        }
                    }
                }


                // MARK: - Update published values
                // queryResponse = response
                authoredMergeRequests = newMergeRequests
                lastUpdate = .now
                print("fetch: updated data fetchAuthoredMergeRequests")
            }
        } catch {
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
                // MARK: - Update published values
                if beforeMergeRequests.isEmpty || (beforeMergeRequests != response.reviewRequestedMergeRequests) {
                    // queryResponse = response
                reviewRequestedMergeRequests = response.reviewRequestedMergeRequests
                    lastUpdate = .now
                print("fetch: updated data fetchreviewRequestedMergeRequests")
                }
            }
        } catch {
            print("\(Date.now) Fetch fetchreviewRequestedMergeRequests failed with unexpected error: \(error).")
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

