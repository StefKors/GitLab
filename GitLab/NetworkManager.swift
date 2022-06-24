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

class NetworkManager: ObservableObject {
    @Published var isUpdatingMRs: Bool = false
    @Published var queryResponse: GitLabQuery?
    @Default(.apiToken) var apiToken
    @Default(.mergeRequests) var mergeRequests
    @Default(.lastUpdate) var lastUpdate

    let client = APIClient(baseURL: URL(string: "https://gitlab.com/api"))
    /// https://gitlab.com/-/graphql-explorer
    let graphqlQuery = """
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

    func getMRs() async {
        let req = Request<GitLabQuery>.post("/graphql", query: [
            ("query", graphqlQuery),
            ("private_token", apiToken)
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

                let approvers = mrs.first?.approvedBy?.edges?.compactMap { $0.node }
            // https://gitlab.com/uploads/-/system/user/avatar/8609834/avatar.png?width=40
                print(approvers)
            }
        } catch {
            print("\(Date.now) Fetch failed with unexpected error: \(error).")
        }
    }

}
