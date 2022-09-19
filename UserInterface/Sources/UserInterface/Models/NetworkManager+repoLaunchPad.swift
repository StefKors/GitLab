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
        let shouldFetch = containsLaunchpad == false || containsLaunchpad == true && launchpadState.updatedAtLaunch
        guard project.avatarUrl != nil, shouldFetch else {
            return
        }

        Task(priority: .background) {
            let repo = LaunchpadRepo(
                id: project.id,
                name: project.name ?? "",
                image: await getProjectImage(project)
            )
            launchpadState.add(repo)
        }
    }


    fileprivate func getProjectImage(_ project: TargetProject) async -> Data? {
        let id = project.id.components(separatedBy: "/").last ?? ""

        // TODO: try using the file API to search and find the project image file
        let url = URL(string: "/api/v4/projects/\(id)/repository/files/logo%2Epng")!

        // uses custom delegate to handle correctly encoding url path
        print(url)
        let client = APIClient(configuration: APIClient.Configuration(
            baseURL: URL(string: "https://gitlab.com"),
            delegate: ClientDelegate())
        )

        let req: Request<ProjectImageResponse> = Request.init(
            url: url,
            method: .get,
            query: [("ref", "main")],
            headers: [
                "Private-Token": apiToken
            ]
        )

        let response: ProjectImageResponse? = try? await client.send(req).value
        if let content = response?.content {
            return Data(base64Encoded: content)
        }

        return nil
    }
}

fileprivate final class ClientDelegate: APIClientDelegate {
    func client<T>(_ client: APIClient, makeURLForRequest request: Request<T>) throws -> URL? {
        return request.url
    }
}
