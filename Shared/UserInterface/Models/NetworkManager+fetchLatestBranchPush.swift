//
//  File.swift
//
//
//  Created by Stef Kors on 29/07/2022.
//

import Foundation
import Get
import SwiftUI

extension NetworkManager {
    func fetchLatestBranchPush(with account: Account, repos: [LaunchpadRepo]) async throws -> NoticeMessage? {
        let req: Request<PushEvents> = Request.init(path: "/v4/events", query: [
            ("after", getYesterdayDate()),
            ("scope", "read_user"),
            ("action", "pushed"),
            ("private_token", account.token)
        ])

        let client = APIClient(baseURL: URL(string: "\(account.instance)/api"))

        let response: PushEvents = try await client.send(req).value

        let pushedBranch = response.first(where: { event in
            event.actionName == .pushedNew
        })

        if let notice = eventToNotice(event: pushedBranch, repos: repos) {
            return notice
        }

        return nil
    }
}

extension NetworkManager {
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

    fileprivate func eventToNotice(event: PushEvent?, repos: [LaunchpadRepo]) -> NoticeMessage? {
        guard let event,
              let project = repos.first(where: { $0.id == "gid://gitlab/Project/\(event.projectID)" }),
              let branchRef = event.pushData?.ref,
              let branchURL = URL(string: "\(project.url.absoluteString)/-/tree/\(branchRef)"),
              let createdAt = event.createdAt,
              let date = GitLabISO8601DateFormatter.date(from: createdAt) else {
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
