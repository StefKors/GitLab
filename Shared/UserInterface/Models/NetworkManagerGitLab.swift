//
//  NetworkManagerGitLab.swift
//  GitLab
//
//  Created by Stef Kors on 13/09/2021.
//

import Foundation
import Get
import OSLog
import SwiftUI
#if canImport(AppKit)
import AppKit
#else
import UIKit
#endif

enum GitLabNetworkError: LocalizedError {
  case invalidInstance(String)
  case unsupportedURLScheme(String)

  var errorDescription: String? {
    switch self {
    case .invalidInstance(let value):
      return "Invalid GitLab instance URL: \(value)"
    case .unsupportedURLScheme(let value):
      return "Unsupported URL scheme for instance: \(value)"
    }
  }
}

class NetworkManagerGitLab {
  static let shared = NetworkManagerGitLab()

  private let logger = Logger(subsystem: "com.stefkors.gitlab", category: "NetworkManagerGitLab")

  var clients: [String: APIClient] = [
    "https://gitlab.com/api": APIClient(baseURL: URL(string: "https://gitlab.com/api")!)
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

  var launchpadClients: [String: APIClient] = [:]

  func getLaunchpadClient(instance: String) throws -> APIClient {
    let normalizedInstance = try normalizedInstanceURL(from: instance)

    if let client = launchpadClients[normalizedInstance] {
      return client
    } else {
      let client = APIClient(configuration: APIClient.Configuration(
        baseURL: URL(string: normalizedInstance)!,
        delegate: LaunchPadClientDelegate()
      ))

      launchpadClients[normalizedInstance] = client
      return client
    }
  }

  /// https://gitlab.com/-/graphql-explorer
  /// Return query for a the "currentUser"
  /// - Parameter type: QueryType
  /// - Returns: GraphQL query with MR information
  static func getQuery(_ type: QueryType) -> String {
    Self.buildQuery(target: "currentUser", type: type)
  }

  /// Private method to build the GraphQL query based on the user information. Prefer getQuery methods instead
  /// - Parameters:
  ///   - target: target string to fetch results for. Either string should be either `"currentUser"` or `"user(username: \"\(username)\""`
  ///   - type: QueryType
  /// - Returns: GraphQL query with MR information
  fileprivate static func buildQuery(target: String, type: QueryType) -> String {
      "{\n    \"query\": \"{\(target){name \(type.rawValue)(state:opened){edges{node{state id title draft webUrl reference createdAt updatedAt sourceBranch targetBranch labels{edges{node{id description color textColor title}}}targetProject{id name path webUrl avatarUrl namespace{id fullName fullPath}repository{rootRef}group{id name fullName fullPath webUrl}}approvedBy{edges{node{id name username avatarUrl}}}mergeStatusEnum userDiscussionsCount userNotesCount headPipeline{id active status mergeRequestEventType stages{edges{node{id status name jobs{edges{node{id active name status detailedStatus{id detailsPath text label group tooltip icon}}}}}}}}}}}}}\",\n    \"variables\": {}\n}"
  }

  func authoredMergeRequestsReq(with account: Account) -> Request<GitLab.GitLabQuery> {
      Request.init(
        path: "/graphql",
        method: .post,
        query: [("private_token", account.token)],
        body: Self.getQuery(.authoredMergeRequests),
        headers: [
            "Content-Type": "application/json; charset=utf-8"
        ]
      )
  }

  func reviewRequestedMergeRequestsReq(with account: Account) -> Request<GitLab.GitLabQuery> {
    Request.init(path: "/graphql", method: .post, query: [
      ("query", Self.getQuery(.reviewRequestedMergeRequests)),
      ("private_token", account.token)
    ])
  }

  func validateToken(instance: String, token: String) async -> AccessToken? {
    let accessTokenReq: Request<AccessToken> = Request.init(path: "/v4/personal_access_tokens/self", query: [
      ("private_token", token)
    ])

    do {
      let baseURL = try normalizedAPIBaseURL(from: instance)
      let response: AccessToken? = try await APIClient(baseURL: URL(string: baseURL)).send(accessTokenReq).value

      return response
    } catch {
      print(error.localizedDescription)
      return nil
    }
  }

  private func normalizedInstanceURL(from instance: String) throws -> String {
    guard var components = URLComponents(string: instance) else {
      throw GitLabNetworkError.invalidInstance(instance)
    }

    if components.scheme == nil {
      components.scheme = "https"
    }

    guard let scheme = components.scheme, scheme == "https" || scheme == "http" else {
      throw GitLabNetworkError.unsupportedURLScheme(instance)
    }

    guard components.host != nil else {
      throw GitLabNetworkError.invalidInstance(instance)
    }

    components.query = nil
    components.fragment = nil

    guard let url = components.url else {
      throw GitLabNetworkError.invalidInstance(instance)
    }

    return url.absoluteString.trimmingCharacters(in: CharacterSet(charactersIn: "/"))
  }

  private func normalizedAPIBaseURL(from instance: String) throws -> String {
    let base = try normalizedInstanceURL(from: instance)
    return "\(base)/api"
  }
}

extension NetworkManagerGitLab {
    func fetchAuthoredMergeRequests(with account: Account) async throws -> [GitLab.MergeRequest]? {
        let client = try getClient(instance: account.instance)
        let value: GitLab.GitLabQuery = try await client.send(authoredMergeRequestsReq(with: account)).value
        return value.authoredMergeRequests
    }
    
    func fetchAuthoredMergeRequests(with account: Account) async throws -> [UniversalMergeRequest]? {
        return try await fetchAuthoredMergeRequests(with: account)?.map { request in
            return UniversalMergeRequest(
                request: request,
                account: account,
                provider: .GitLab,
                type: .authoredMergeRequests
            )
        }
    }
    
    
}

extension NetworkManagerGitLab {
  func fetchReviewRequestedMergeRequests(with account: Account) async throws -> [GitLab.MergeRequest]? {
    let client = try getClient(instance: account.instance)
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

    let client = try getClient(instance: account.instance)

    let response: GitLab.PushEvents = try await client.send(req).value

    let actionCounts = Dictionary(grouping: response, by: { $0.actionName?.rawValue ?? "unknown" })
      .mapValues(\.count)
    logger.debug("Fetch Branch Push: decoded \(response.count) events, actions: \(actionCounts)")

    guard let pushedBranch = response.first(where: { event in
      event.actionName == .pushedNew
    }) else {
      logger.debug("Fetch Branch Push: no 'pushed new' event found, returning nil")
      return nil
    }

    return eventToNotice(event: pushedBranch, repos: repos)
  }
}

extension NetworkManagerGitLab {
  fileprivate func getYesterdayDate() -> String {
    let dateFormatter = DateFormatter()
    dateFormatter.dateFormat = "yyyy-MM-dd"
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
    guard let event else {
      logger.debug("Fetch Branch Push: event is nil, no notice created")
      return nil
    }
    guard let project = repos.first(where: { $0.id == "gid://gitlab/Project/\(event.projectID)" }) else {
      logger.debug("Fetch Branch Push: project \(event.projectID) not found in \(repos.count) launchpad repos, no notice created")
      return nil
    }
    guard let branchRef = event.pushData?.ref else {
      logger.debug("Fetch Branch Push: event \(event.id) has no push_data.ref, no notice created")
      return nil
    }
    guard let branchURL = URL(string: "\(project.url.absoluteString)/-/tree/\(branchRef)") else {
      logger.debug("Fetch Branch Push: could not build branch URL for ref '\(branchRef)', no notice created")
      return nil
    }
    guard let createdAt = event.createdAt,
          // Possible use Date.from(createdAt) or GitLabISO8601DateFormatter?
          let date = Date.from(createdAt) else {
      logger.warning("Fetch Branch Push: could not parse created_at '\(event.createdAt ?? "nil")' for event \(event.id), no notice created")
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

    let client = try getClient(instance: account.instance)

    let fullProject: GitLab.TargetProjectsQuery = try await client.send(req).value

    return fullProject.data?.projects?.edges?.compactMap({ edge in
      return edge.node
    })
  }
}
