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
}

enum RequestError: Error {
    case sessionError(error: Error)
}

public class NetworkManager: ObservableObject {
    @Published public var isUpdatingMRs: Bool = false
    @Published public var queryResponse: GitLabQuery?
    @Default(.apiToken) public var apiToken
    @Default(.mergeRequests) public var mergeRequests
    @Default(.lastUpdate) public var lastUpdate

    public init() {}

    public let client = APIClient(baseURL: URL(string: "https://gitlab.com/api"))
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
        let req = Request<GitLabQuery>.post("/graphql", query: [
            ("query", graphqlQuery),
            ("private_token", "glpat-vQVd9zZynapzXDZ6aDKc")
        ])

        do {
            let response: GitLabQuery = try await client.send(req).value
            await MainActor.run {
                let mrs = response.data?.currentUser?.authoredMergeRequests?.edges?.compactMap({ edge in
                    return edge.node
                }) ?? []

                mergeRequests = mrs
                queryResponse = response
                lastUpdate = .now
                print("mergeRequests \(mergeRequests)")
            }
        } catch {
            print("\(Date.now) Fetch failed with unexpected error: \(error).")
        }
    }

}
