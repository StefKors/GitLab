//
//  File.swift
//  
//
//  Created by Stef Kors on 29/07/2022.
//

import Foundation
import Get
import SwiftUI
import Defaults

extension NetworkManager {
    public func fetchLatestBranchPush() async {

        do {
            let response: PushEvents = try await client.send(branchPushReq).value

            let pushedBranch = response.first(where: { event in
                event.actionName == .pushedNew
            })

            print(pushedBranch.debugDescription)

            // Check cached projects otherwise fetch project from API
            if let projectID = pushedBranch?.projectID {
                let hasCachedproject = targetProjectsDict["gid://gitlab/Project/\(projectID)"]

                if hasCachedproject.isNil {
                    // fetching because dict is empty
                    print("fetching because dict is empty")
                    await fetchProjects(ids: [projectID])
                }
            }

            let event = response.first(where: { event in
                guard let createdAt = event.createdAt,
                      let date = GitLabISO8601DateFormatter.date(from: createdAt) else { return false }
                let pastHour: Double = 60 * 60 * 1 // 60 min
                return event.actionName == .pushedNew && abs(date.timeIntervalSinceNow) < pastHour
            })

            if let event = event,
               let project = targetProjectsDict["gid://gitlab/Project/\(event.projectID)"],
               let projectName = project.name,
               let branchRef = event.pushData?.ref,
               let projectURL = project.webURL, let branchURL = URL(string: "\(projectURL.absoluteString)/-/tree/\(branchRef)"),
               let createdAt = event.createdAt,
               let date = GitLabISO8601DateFormatter.date(from: createdAt) {
                let groupName = project.group?.fullName ?? project.namespace?.fullName ?? ""
                print("creating notice")
                let notice = NoticeMessage(
                    label: "You pushed to [\(branchRef)](\(branchURL)) at [\(groupName)/\(projectName)](\(projectURL))",
                    webLink: makeMRUrl(url: project.webURL, branchRef: branchRef),
                    type: .branch,
                    createdAt: date
                )

                noticeState.addNotice(notice: notice)
            }

        } catch APIError.unacceptableStatusCode(let statusCode) {
            // Handle Bad GitLab Reponse
            // let warningNotice = NoticeMessage(
            //     label: "[Branch Push] Recieved \(statusCode) from API, data might be out of date",
            //     statusCode: statusCode,
            //     type: .warning
            // )
            // noticeState.addNotice(notice: warningNotice)
        } catch {
            // Handle Offline Notice
            let isGitLabReachable = reachable(host: self.$baseURL.wrappedValue)
            if isGitLabReachable == false {
                let informationNotice = NoticeMessage(
                    label: "Unable to reach \(self.$baseURL.wrappedValue)",
                    type: .network
                )
                noticeState.addNotice(notice: informationNotice)
                return
            }

            print("\(Date.now) Fetch fetchLatestBranchPush failed with unexpected error: \(error).")
        }
    }
}

extension NetworkManager {
    fileprivate func makeMRUrl(url: URL?, branchRef: String) -> URL? {
        guard let url = url else {
            return nil
        }
        let fullURLPath = url.absoluteString + "/-/merge_requests/new?merge_request[source_branch]=" + branchRef
        return URL(string: fullURLPath)
    }
}
