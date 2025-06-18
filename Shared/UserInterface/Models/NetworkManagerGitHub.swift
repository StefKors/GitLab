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

    /// Private method to build the GraphQL query for authored pull requests
    /// - Parameters:
    ///   - type: QueryType
    /// - Returns: GraphQL query with PR information
    fileprivate static func buildAuthoredQuery(type: QueryType) -> String {
        let query = "{ viewer { pullRequests(last: 100, states: OPEN) { nodes { id title url state isDraft url createdAt updatedAt headRefName baseRefName reviewDecision labels(first: 100) { nodes { id name color isDefault } } isInMergeQueue locked mergeStateStatus number permalink totalCommentsCount repository { name id isLocked isArchived url owner { login id avatarUrl } homepageUrl } state reviewDecision reviews(first: 100) { nodes { id state author { avatarUrl login } } } statusCheckRollup { state contexts(last: 100) { nodes { ... on CheckRun { id name status conclusion detailsUrl title url checkSuite { workflowRun { workflow { id name } } } } } } } } } } }"

        return "{\n\t\"query\": \"\(query)\",\n\t\"variables\": {}\n}"
    }

    /// Private method to build the GraphQL query for review requested pull requests using search
    /// - Parameters:
    ///   - type: QueryType
    /// - Returns: GraphQL query with PR information
    fileprivate static func buildReviewRequestedQuery(type: QueryType) -> String {
        let query = "{ search(query: \"is:pr is:open review-requested:@me\", type: ISSUE, first: 100) { issueCount edges { node { ... on PullRequest { id title url state isDraft createdAt updatedAt headRefName baseRefName reviewDecision labels(first: 100) { nodes { id name color isDefault } } isInMergeQueue locked mergeStateStatus number permalink totalCommentsCount repository { name id isLocked isArchived url owner { login id avatarUrl } homepageUrl } reviews(first: 100) { nodes { id state author { avatarUrl login } } } statusCheckRollup { state contexts(last: 100) { nodes { ... on CheckRun { id name status conclusion detailsUrl title url checkSuite { workflowRun { workflow { id name } } } } } } } } } } } }"

        return "{\n\t\"query\": \"\(query)\",\n\t\"variables\": {}\n}"
    }

    func authoredMergeRequestsReq(with account: Account) -> Request<GitHub.Query> {
        Request.init(
            path: "/graphql",
            method: .post,
            body: Self.buildAuthoredQuery(type: .authoredMergeRequests),
            headers: ["Authorization": "token \(account.token)"]
        )
    }

    func reviewRequestedMergeRequestsReq(with account: Account) -> Request<GitHub.SearchQuery> {
        Request.init(
            path: "/graphql",
            method: .post,
            body: Self.buildReviewRequestedQuery(type: .reviewRequestedMergeRequests),
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

    func fetchReviewRequestedPullRequests(with account: Account) async throws -> [GitHub.PullRequestsNode]? {
        let client = APIClient(baseURL: URL(string: account.instance))
        print("doing request to \(account.instance) with token: \(account.token)")
        let response: GitHub.SearchQuery = try await client.send(reviewRequestedMergeRequestsReq(with: account)).value
        let result = response.reviewRequestedMergeRequests
        print("recieved \(result.count) review requested pull requests")
        return result
    }

}
