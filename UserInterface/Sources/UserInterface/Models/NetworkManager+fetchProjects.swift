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
    public func fetchProjects(ids: [Int]) async {
        do {
            let projectIds: String = ids.reduce("") { partialResult, id in
                let arrString = partialResult + ", \"gid://gitlab/Project/\(id)\""
                return arrString
            }

            let projectQuery = "{ projects(ids: [\(projectIds)]) { edges { node { id name path webUrl group { id name fullName     fullPath webUrl } } } } }"
            let client = APIClient(baseURL: URL(string: "https://gitlab.com/api"))
            let req = Request<TargetProjectsQuery>.post("/graphql", query: [
                ("query", projectQuery),
                ("private_token", self.apiToken)
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
            let isGitLabReachable = reachable(host: "gitlab.com")
            if isGitLabReachable == false {
                let informationNotice = NoticeMessage(
                    label: "Unable to reach gitlab.com",
                    type: .network
                )
                noticeState.addNotice(notice: informationNotice)
                return
            }

            print("\(Date.now) Fetch fetchProjects failed with unexpected error: \(error).")
        }
    }

    public func updateDict(_ targetProject: TargetProject) {
        self.targetProjectsDict[targetProject.id] = targetProject
    }
}
