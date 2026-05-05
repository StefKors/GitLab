//
//  NetworkManagerGitHub.swift
//  GitLab
//
//  Created by Stef Kors on 30/10/2024.
//

import Foundation
import Get

enum GitHubNetworkError: LocalizedError {
    case invalidInstance(String)
    case unsupportedURLScheme(String)

    var errorDescription: String? {
        switch self {
        case .invalidInstance(let value):
            return "Invalid GitHub instance URL: \(value)"
        case .unsupportedURLScheme(let value):
            return "Unsupported URL scheme for instance: \(value)"
        }
    }
}

class NetworkManagerGitHub {
    static let shared = NetworkManagerGitHub()

    private let defaultGitHubAPIBaseURL = "https://api.github.com"
    var clients: [String: APIClient] = [
        "https://api.github.com": APIClient(baseURL: URL(string: "https://api.github.com")!)
    ]

    func getClient(instance: String) throws -> APIClient {
        let normalizedInstance = try normalizedAPIBaseURL(from: instance)

        if let client = clients[normalizedInstance] {
            return client
        } else {
            let client = APIClient(baseURL: URL(string: normalizedInstance)!)
            clients[normalizedInstance] = client
            return client
        }
    }

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
//        let query = "{ viewer { pullRequests(last: 100, states: OPEN) { nodes { id title url state isDraft url createdAt updatedAt headRefName baseRefName reviewDecision labels(first: 100) { nodes { id name color isDefault } } isInMergeQueue locked mergeStateStatus number permalink totalCommentsCount repository { name id isLocked isArchived url owner { login id avatarUrl } homepageUrl } state reviewDecision reviews(first: 100) { nodes { id state author { avatarUrl login } } } statusCheckRollup { state contexts(last: 100) { nodes { ... on CheckRun { id name status conclusion detailsUrl title url checkSuite { workflowRun { workflow { id name } } } } } } } } } } }"
//
//        return "{\n\t\"query\": \"\(query)\",\n\t\"variables\": {}\n}"
        return "{\n\t\"query\": \"query{viewer{pullRequests(last:100,states:OPEN){nodes{id title url state isDraft url createdAt updatedAt headRefName baseRefName reviewDecision labels(first:100){nodes{id name color isDefault}}isInMergeQueue locked mergeStateStatus number permalink totalCommentsCount repository{name id isLocked isArchived url owner{login id avatarUrl}homepageUrl}state reviewDecision reviews(first:100){nodes{id state author{avatarUrl login}}}statusCheckRollup{state contexts(last:100){nodes{... on CheckRun{id name status conclusion detailsUrl title url checkSuite{workflowRun{workflow{id name}}}}}}}}}}}\",\n\t\"variables\": {}\n}"
    }

    //    func getQuery() {
    //
    //    }



    private func graphqlHeaders(token: String) -> [String: String] {
        [
            "Authorization": "bearer \(token)",
            "Content-Type": "application/json; charset=utf-8"
        ]
    }

    func authoredMergeRequestsReq(with account: Account) -> Request<GitHub.Query> {
        Request.init(
            path: "/graphql",
            method: .post,
            body: """
            { "query": "query{viewer{pullRequests(last:100,states:OPEN){nodes{id title url state isDraft url createdAt updatedAt headRefName baseRefName reviewDecision labels(first:100){nodes{id name color isDefault}}isInMergeQueue locked mergeStateStatus number permalink totalCommentsCount repository{name id isLocked isArchived url owner{login id avatarUrl}homepageUrl}state reviewDecision reviews(first:100){nodes{id state author{avatarUrl login}}}statusCheckRollup{state contexts(last:100){nodes{... on CheckRun{id name status conclusion detailsUrl title url checkSuite{workflowRun{workflow{id name}}}}}}}}}}}", "variables": {}}
""".trimmingCharacters(in: .whitespacesAndNewlines),
            headers: graphqlHeaders(token: account.token)
        )
    }

    func reviewRequestedPullRequestsReq(with account: Account) -> Request<GitHub.SearchQuery> {
        Request.init(
            path: "/graphql",
            method: .post,
            body: """
            { "query": "query{search(query:\\"is:pr is:open review-requested:@me\\",type:ISSUE,first:100){nodes{... on PullRequest{id title url state isDraft createdAt updatedAt headRefName baseRefName reviewDecision labels(first:100){nodes{id name color isDefault}}isInMergeQueue locked mergeStateStatus number permalink totalCommentsCount repository{name id isLocked isArchived url owner{login id avatarUrl}homepageUrl}reviews(first:100){nodes{id state author{avatarUrl login}}}statusCheckRollup{state contexts(last:100){nodes{... on CheckRun{id name status conclusion detailsUrl title url checkSuite{workflowRun{workflow{id name}}}}}}}}}}}", "variables": {}}
""".trimmingCharacters(in: .whitespacesAndNewlines),
            headers: graphqlHeaders(token: account.token)
        )
    }

    // https://docs.github.com/en/graphql/overview/explorer
    // https://api.github.com/graphql
    func fetchAuthoredPullRequests(with account: Account) async throws -> [GitHub.PullRequestsNode]? {
        let client = try getClient(instance: account.instance)
        let response = try await client.send(authoredMergeRequestsReq(with: account))
        return response.value.authoredPullRequests
    }

    func fetchReviewRequestedPullRequests(with account: Account) async throws -> [GitHub.PullRequestsNode]? {
        let client = try getClient(instance: account.instance)
        let response = try await client.send(reviewRequestedPullRequestsReq(with: account))
        return response.value.reviewRequestedPullRequests
    }

    func fetchAuthoredPullRequests(with account: Account) async throws -> [UniversalMergeRequest]? {
        return try await fetchAuthoredPullRequests(with: account)?.map { request in
            return UniversalMergeRequest(
                request: request,
                account: account,
                provider: .GitHub,
                type: .authoredMergeRequests
            )
        }
    }

    func fetchReviewRequestedPullRequests(with account: Account) async throws -> [UniversalMergeRequest]? {
        return try await fetchReviewRequestedPullRequests(with: account)?.map { request in
            return UniversalMergeRequest(
                request: request,
                account: account,
                provider: .GitHub,
                type: .reviewRequestedMergeRequests
            )
        }
    }

    private func normalizedAPIBaseURL(from instance: String) throws -> String {
        guard var components = URLComponents(string: instance) else {
            throw GitHubNetworkError.invalidInstance(instance)
        }

        if components.scheme == nil {
            components.scheme = "https"
        }

        guard let scheme = components.scheme, scheme == "https" || scheme == "http" else {
            throw GitHubNetworkError.unsupportedURLScheme(instance)
        }

        guard let host = components.host, !host.isEmpty else {
            throw GitHubNetworkError.invalidInstance(instance)
        }

        let isGitHubDotCom = host.caseInsensitiveCompare("github.com") == .orderedSame
        let isGitHubAPI = host.caseInsensitiveCompare("api.github.com") == .orderedSame

        if isGitHubDotCom || isGitHubAPI {
            return defaultGitHubAPIBaseURL
        }

        components.path = "/api/v3"
        components.query = nil
        components.fragment = nil

        guard let normalizedURL = components.url else {
            throw GitHubNetworkError.invalidInstance(instance)
        }

        return normalizedURL.absoluteString.trimmingCharacters(in: CharacterSet(charactersIn: "/"))
    }
}
