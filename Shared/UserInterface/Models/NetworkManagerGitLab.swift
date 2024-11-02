//
//  NetworkManagerGitLab.swift
//  GitLab
//
//  Created by Stef Kors on 13/09/2021.
//

import Foundation
import Get
import SwiftUI
#if canImport(AppKit)
import AppKit
#else
import UIKit
#endif

class NetworkManagerGitLab {
    static let shared = NetworkManagerGitLab()

    /// https://gitlab.com/-/graphql-explorer
    /// Return query for a the "currentUser"
    /// - Parameter type: QueryType
    /// - Returns: GraphQL query with MR information
    static func getQuery(_ type: QueryType) -> String {
        Self.buildQuery(target: "currentUser", type: type)
    }

    /// Return query for a specific user name
    /// - Parameters:
    ///   - username: Username to fetch results for
    ///   - type: QueryType
    /// - Returns: GraphQL query with MR information
    static func getQuery(username: String, type: QueryType) -> String {
        let user = "user(username: \"\(username)\""
        return Self.buildQuery(target: user, type: type)
    }

    /// Private method to build the GraphQL query based on the user information. Prefer getQuery methods instead
    /// - Parameters:
    ///   - target: target string to fetch results for. Either string should be either `"currentUser"` or `"user(username: \"\(username)\""`
    ///   - type: QueryType
    /// - Returns: GraphQL query with MR information
    fileprivate static func buildQuery(target: String, type: QueryType) -> String {
        "query { \(target) { name \(type.rawValue)(state: opened) { edges { node { state id title draft webUrl reference createdAt updatedAt sourceBranch targetBranch labels { edges { node { id description color textColor title } } } targetProject { id name path webUrl avatarUrl namespace { id fullName fullPath } repository { rootRef } group { id name fullName fullPath webUrl } } approvedBy { edges { node { id name username avatarUrl } } } mergeStatusEnum userDiscussionsCount userNotesCount headPipeline { id active status mergeRequestEventType stages { edges { node { id status name jobs { edges { node { id active name status detailedStatus { id detailsPath text label group tooltip icon } } } } } } } } } } } } }"
    }

    func branchPushReq(with account: Account) -> Request<GitLab.PushEvents> {
        Request.init(path: "/v4/events", query: [
            ("after", "2022-06-25"),
            ("scope", "read_user"),
            ("action", "pushed"),
            ("private_token", account.token)
        ])
    }

    func authoredMergeRequestsReq(with account: Account) -> Request<GitLab.GitLabQuery> {
        Request.init(path: "/graphql", method: .post, query: [
            ("query", Self.getQuery(.authoredMergeRequests)),
            ("private_token", account.token)
        ])
    }

    func reviewRequestedMergeRequestsReq(with account: Account) -> Request<GitLab.GitLabQuery> {
        Request.init(path: "/graphql", method: .post, query: [
            ("query", Self.getQuery(.reviewRequestedMergeRequests)),
            ("private_token", account.token)
        ])
    }

    func fetch(with account: Account) async throws {
        // Parallel?
        // await fetchLatestBranchPush()
        // try await fetchAuthoredMergeRequests(with: account)
        // try await fetchReviewRequestedMergeRequests(with: account)
    }

    func validateToken(instance: String, token: String) async -> AccessToken? {
        let accessTokenReq: Request<AccessToken> = Request.init(path: "/v4/personal_access_tokens/self", query: [
            ("private_token", token)
        ])

        do {
            let response: AccessToken? = try await APIClient(baseURL: URL(string: "\(instance)/api")).send(accessTokenReq).value

            return response
        } catch {
            print(error.localizedDescription)
            return nil
        }
    }
}

extension NetworkManagerGitLab {
    func fetchAuthoredMergeRequests(with account: Account) async throws -> [GitLab.MergeRequest]? {
        let client = APIClient(baseURL: URL(string: "\(account.instance)/api"))
        let response: GitLab.GitLabQuery = try await client.send(authoredMergeRequestsReq(with: account)).value
        return response.authoredMergeRequests
    }
}

extension NetworkManagerGitLab {
    func fetchReviewRequestedMergeRequests(with account: Account) async throws -> [GitLab.MergeRequest]? {
        let client = APIClient(baseURL: URL(string: "\(account.instance)/api"))
        let response: GitLab.GitLabQuery = try await client.send(reviewRequestedMergeRequestsReq(with: account)).value
        return response.reviewRequestedMergeRequests
    }
}

extension NetworkManagerGitLab {
    func fetchLatestBranchPush(with account: Account, repos: [LaunchpadRepo]) async throws -> NoticeMessage? {
        let req: Request<GitLab.PushEvents> = Request.init(path: "/v4/events", query: [
            ("after", getYesterdayDate()),
            ("scope", "read_user"),
            ("action", "pushed"),
            ("private_token", account.token)
        ])

        let client = APIClient(baseURL: URL(string: "\(account.instance)/api"))

        let response: GitLab.PushEvents = try await client.send(req).value

        let pushedBranch = response.first(where: { event in
            event.actionName == .pushedNew
        })

        if let notice = eventToNotice(event: pushedBranch, repos: repos) {
            return notice
        }

        return nil
    }
}

extension NetworkManagerGitLab {
    fileprivate func getYesterdayDate() -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "YYYY-MM-dd"
        // yesterday
        let date = Calendar.current.date(byAdding: .day, value: -1, to: Date()) ?? Date()
        return dateFormatter.string(from: date)
    }

    fileprivate func makeMRUrl(url: URL?, branchRef: String) -> URL? {
        guard let url = url else {
            return nil
        }
        let fullURLPath = url.absoluteString + "/-/merge_requests/new?merge_request[source_branch]=" + branchRef
        return URL(string: fullURLPath)
    }

    fileprivate func eventToNotice(event: GitLab.PushEvent?, repos: [LaunchpadRepo]) -> NoticeMessage? {
        guard let event,
              let project = repos.first(where: { $0.id == "gid://gitlab/Project/\(event.projectID)" }),
              let branchRef = event.pushData?.ref,
              let branchURL = URL(string: "\(project.url.absoluteString)/-/tree/\(branchRef)"),
              let createdAt = event.createdAt,
              // Possible use Date.from(createdAt) or GitLabISO8601DateFormatter?
              let date = Date.from(createdAt) else {
            return nil
        }
        return NoticeMessage(
            label: "You pushed to [\(branchRef)](\(branchURL)) at [\(project.group)/\(project.name)](\(project.url))",
            webLink: makeMRUrl(url: project.url, branchRef: branchRef),
            type: .branch,
            branchRef: branchRef,
            createdAt: date
        )
    }
}

extension NetworkManagerGitLab {
    func fetchProjects(with account: Account, ids: [Int]) async throws -> [GitLab.TargetProject]? {
        let projectIds: String = ids.map { id in
            return "\"gid://gitlab/Project/\(id)\""
        }.joined(separator: ", ")

        let projectQuery = "{ projects(ids: [\(projectIds)]) { edges { node { id name path webUrl avatarUrl repository { rootRef } namespace { id fullPath fullName } group { id name fullName     fullPath webUrl } } } } }"

        let req: Request<GitLab.TargetProjectsQuery> = Request.init(path: "/graphql", query: [
            ("query", projectQuery),
            ("private_token", account.token)
        ])

        let client = APIClient(baseURL: URL(string: "\(account.instance)/api"))

        let fullProject: GitLab.TargetProjectsQuery = try await client.send(req).value

        return fullProject.data?.projects?.edges?.compactMap({ edge in
            return edge.node
        })

//        guard let projects else { return nil }
//
//        var launchpadRepos: [LaunchpadRepo] = []
//        for project in projects {
//            if let result = await addLaunchpadProject(with: account, project) {
//                launchpadRepos.append(result)
//            }
//        }
//
//        return launchpadRepos
    }
}
