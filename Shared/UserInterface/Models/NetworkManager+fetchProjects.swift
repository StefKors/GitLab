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
     func fetchProjects(ids: [Int]) async {
        do {
            let projectIds: String = ids.map { id in
                return "\"gid://gitlab/Project/\(id)\""
            }.joined(separator: ", ")

            let projectQuery = "{ projects(ids: [\(projectIds)]) { edges { node { id name path webUrl avatarUrl repository { rootRef } namespace { id fullPath fullName } group { id name fullName     fullPath webUrl } } } } }"

            let req: Request<TargetProjectsQuery> = Request.init(path: "/graphql", query: [
                ("query", projectQuery),
                ("private_token", apiToken)
            ])

            let fullProject: TargetProjectsQuery = try await client.send(req).value

            if let edges = fullProject.data?.projects?.edges {
                for edge in edges {
                    if let targetProject = edge.node {
                        updateDict(targetProject)
                    }
                }
            }
        } catch APIError.unacceptableStatusCode(let statusCode) {
            // Handle Bad GitLab Reponse
            let warningNotice = NoticeMessage(
                label: "[Branch Push] Recieved \(statusCode) from API, data might be out of date",
                statusCode: statusCode,
                type: .warning
            )
            noticeState.addNotice(notice: warningNotice)
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

            print("\(Date.now) Fetch fetchProjects failed with unexpected error: \(error).")
        }
    }

     func updateDict(_ targetProject: TargetProject) {
        self.addLaunchpadProject(targetProject)
        // self.targetProjectsDict[targetProject.id] = targetProject
    }
}
