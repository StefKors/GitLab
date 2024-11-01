//
//  NetworkManagerGitHub.swift
//  GitLab
//
//  Created by Stef Kors on 30/10/2024.
//

import Foundation
import Get

class NetworkManagerGitHub {
    static let shared = NetworkManagerGitHub()
//
//    func authoredMergeRequestsReq(with account: Account) -> Request<GitLabQuery> {
//
//    }

    /// Private method to build the GraphQL query based on the user information. Prefer getQuery methods instead
    /// - Parameters:
    ///   - target: target string to fetch results for. Either string should be either `"currentUser"` or `"user(username: \"\(username)\""`
    ///   - type: QueryType
    /// - Returns: GraphQL query with MR information
    fileprivate static func buildQuery(type: QueryType) -> String {
//        let state = "OPEN"
        let query = "{ viewer { pullRequests(last: 100, states: OPEN) { nodes { id title url state isDraft url createdAt updatedAt baseRefName reviewDecision labels(first: 100) { nodes { id name color isDefault } } isInMergeQueue locked mergeStateStatus number permalink repository { name id isLocked isArchived url owner { login } } state reviewDecision reviews(first: 100) { nodes { id state author { avatarUrl login } } } comments(first: 100) { nodes { id author { login } bodyText } } reactions(first: 100) { nodes { id user { avatarUrl name login } } } commits(last: 1) { nodes { commit { statusCheckRollup { state contexts(last: 100) { nodes { ... on StatusContext { id context description state targetUrl } ... on CheckRun { id name status conclusion detailsUrl steps(last: 30) { nodes { externalId name number secondsToCompletion status conclusion } } } } } } } } } } } } }"

        return "{\n\t\"query\": \"\(query)\",\n\t\"variables\": {}\n}"
    }

//    func getQuery() {
//
//    }

    func authoredMergeRequestsReq(with account: Account) -> Request<GitHub.Query> {
        Request.init(
            path: "/graphql",
            method: .post,
            body: Self.buildQuery(type: .authoredMergeRequests),
            headers: ["Authorization": "token \(account.token)"]
        )
    }

    // https://docs.github.com/en/graphql/overview/explorer
    // https://api.github.com/graphql
    func fetchAuthoredPullRequests(with account: Account) async throws -> [GitHub.PullRequestsNode]? {
        let client = APIClient(baseURL: URL(string: account.instance))
        print("doing request to \(account.instance) with token: \(account.token)")
        let response: GitHub.Query = try await client.send(authoredMergeRequestsReq(with: account)).value
        let result = response.authoredMergeRequests
        print("recieved \(result.count) pull requests")
        return result
    }

}
