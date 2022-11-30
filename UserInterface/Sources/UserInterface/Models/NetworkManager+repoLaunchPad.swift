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
        let containsLaunchpad = launchpadState.contributedRepos.contains(where: { $0.id == project.id })
        let shouldFetch = containsLaunchpad == false
        guard project.avatarUrl != nil, shouldFetch, let url = project.webURL else {
            return
        }

        Task(priority: .background) { [weak self] in
            let repo = LaunchpadRepo(
                id: project.id,
                name: project.name ?? "",
                image: await getProjectImage(project),
                url: url
            )
            self?.launchpadState.add(repo)
        }
    }


    fileprivate func getProjectImage(_ project: TargetProject) async -> Data? {
        let id = project.id.components(separatedBy: "/").last ?? ""

        // TODO: try using the file API to search and find the project image file
    // https://gitlab.com/api/v4/projects/35262023/repository/files/logo%2Epng
        let url = URL(string: "/api/v4/projects/\(id)/repository/files/logo%2Epng")!

        let req: Request<ProjectImageResponse> = Request.init(
            url: url,
            method: .get,
            query: [("ref", "main")],
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
            print("========== failed to get ProjectImageResponse")
            print(error)
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
