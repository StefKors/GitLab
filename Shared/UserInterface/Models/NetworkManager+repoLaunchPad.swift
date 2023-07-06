//
//  File.swift
//
//
//  Created by Stef Kors on 19/09/2022.
//

import Foundation
import Get

extension NetworkManager {

    public func addLaunchpadProject(_ project: TargetProject) {
        // guard project.avatarUrl != nil, let url = project.webURL else {
        guard let url = project.webURL else {
            return
        }

        Task(priority: .background) { [weak self] in
            let repo = LaunchpadRepo(
                id: project.id,
                name: project.name ?? "",
                image:  await self?.getProjectImage(project),
                group: project.group?.fullName ?? project.namespace?.fullName ?? "", 
                url: url,
                hasUpdatedSinceLaunch: true
            )

            await self?.launchpadState.addRepo(repo: repo)
        }
    }


    fileprivate func getProjectImage(_ project: TargetProject) async -> Data? {
        let id = project.id.components(separatedBy: "/").last ?? ""
        let branch = project.repository?.rootRef ?? "main"

        // TODO: try using the file API to search and find the project image file
        // https://gitlab.com/api/v4/projects/35262023/repository/files/logo%2Epng

        let url = URL(string: "/api/v4/projects/\(id)/repository/files/logo%2Epng")!
        print("fetch: update project image \(project.name ?? "")")
        let req: Request<ProjectImageResponse> = Request.init(
            url: url,
            method: .get,
            query: [("ref", branch)],
            headers: [
                "Private-Token": Self.apiToken
            ]
        )

        do {
            let response: ProjectImageResponse? = try await launchPadClient.send(req).value
            if let content = response?.content {
                return Data(base64Encoded: content)
            }
        } catch {
            print("========== failed to get ProjectImageResponse for: \(String(describing: project.name)) \(id) \(branch)")
            print(error.localizedDescription)
            print("==========")
        }

        return nil
    }
}

final class LaunchPadClientDelegate: APIClientDelegate {
    func client<T>(_ client: APIClient, makeURLForRequest request: Request<T>) throws -> URL? {
        guard let base = client.configuration.baseURL?.absoluteString,
              let path = request.url,
              let query = request.query?.first,
              let branch = query.1 else {
            return nil
        }
        let ref = query.0
        let url = URL(string: "\(base)\(path)?\(ref)=\(branch)")
        return url
    }
}
