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
    static let lastUpdate = Key<Date?>("lastUpdate", default: nil)
    static let mergeRequests = Key<[MergeRequest]>("mergeRequests", default: [])
    static let queryResponse = Key<GitLabQuery?>("gitlabQuery", default: nil)
}

enum RequestError: Error {
    case sessionError(error: Error)
}

public class NetworkManager: ObservableObject {
    @Published public var isUpdatingMRs: Bool = false
    @Default(.queryResponse) public var queryResponse: GitLabQuery?
    @Default(.apiToken) public var apiToken
    @Default(.mergeRequests) public var mergeRequests
    @Default(.lastUpdate) public var lastUpdate

    public init() {}

    public let client = APIClient(baseURL: URL(string: "https://gitlab.com/api"))

    var req: Request<GitLabQuery> {
        Request<GitLabQuery>.post("/graphql", query: [
            ("query", graphqlQuery),
            ("private_token", apiToken)
        ])}

    /// https://gitlab.com/-/graphql-explorer
    public let graphqlQuery = """
query {
  currentUser {
    name
    authoredMergeRequests(state: opened) {
      edges {
        node {
          state
          id
          title
          draft
          webUrl
          reference
          targetProject {
            id
            name
            path
            webUrl
            group {
              id
              name
              fullName
              fullPath
              webUrl
            }
          }
          approvedBy {
            edges {
              node {
                id
                name
                username
                avatarUrl
              }
            }
          }
          mergeStatusEnum
          approved
          approvalsLeft
          userDiscussionsCount
          headPipeline {
            id
            active
            status
            mergeRequestEventType
            stages {
              edges {
                node {
                  id
                  status
                  name
                  jobs {
                    edges {
                      node {
                        id
                        active
                        name
                        status
                      }
                    }
                  }
                }
              }
            }
          }
        }
      }
    }
  }
}
"""

    public func getMRs() async {
        do {
            let beforeApprovedByDict = mergeRequests.approvedByDict
            let response: GitLabQuery = try await client.send(req).value

            await MainActor.run {
                guard let previousResponse = queryResponse,
                      previousResponse != response else {
                    // didn't recieve any new data. returning early
                    return
                }

                // MARK: - Handle Notifications
                let newMergeRequests = response.mergeRequests
                let newApproveByDict = newMergeRequests.approvedByDict

                if beforeApprovedByDict != newApproveByDict {
                    for (reference, newAuthors) in newApproveByDict {
                        let beforeAuthors = (beforeApprovedByDict[reference] ?? [])

                        let diff = newAuthors.difference(from: beforeAuthors)
                        // MARK: - Notification Approved MRs
                        let approvers = diff.insertions.insertedElements.compactMap({ $0.name })
                        if !approvers.isEmpty {
                            NotificationManager.shared.sendNotification(
                                title: "Merge request \(reference) was approved",
                                subtitle: "by \(approvers.formatted())",
                                mrURL: newMergeRequests.first(where: { $0.reference == reference })?.webURL
                            )
                        }

                        // MARK: - Notification Revoked MRs
                        let revokers = diff.removals.removedElements.compactMap({ $0.name })
                        if !revokers.isEmpty {
                            NotificationManager.shared.sendNotification(
                                title: "Merge request \(reference) approval was revoked",
                                subtitle: "by \(revokers.formatted())",
                                mrURL: newMergeRequests.first(where: { $0.reference == reference })?.webURL
                            )
                        }
                    }
                }


                // MARK: - Update published values
                queryResponse = response
                mergeRequests = newMergeRequests
                lastUpdate = .now
            }
        } catch {
            print("\(Date.now) Fetch failed with unexpected error: \(error).")
        }
    }

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

