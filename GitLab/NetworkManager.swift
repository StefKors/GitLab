//
//  NetworkManager.swift
//  GitLab
//
//  Created by Stef Kors on 13/09/2021.
//

import Foundation
import Combine
import Get
import SwiftUI

enum RequestError: Error {
    case sessionError(error: Error)
}

class NetworkManager: ObservableObject {
    @Published var isUpdatingMRs: Bool = false

    @AppStorage("username") var apiToken: String = "glpat-vQVd9zZynapzXDZ6aDKc"

    @Published var queryResponse: GitLabQuery?

    @Published var mergeRequests: [MergeRequest] = []


    let client = APIClient(baseURL: URL(string: "https://gitlab.com/api"))
    let graphqlQuery = "query { currentUser { name authoredMergeRequests(state: opened) { edges { node { state id title draft webUrl approvedBy { edges { node { id name username } } } approved approvalsLeft headPipeline { id active status stages { edges { node { id status name jobs { edges { node { id active name status } } } } } } } } } } } }"
    func getMRs() async {

        let req = Request<GitLabQuery>.post("/graphql", query: [
            ("query", graphqlQuery),
            ("private_token", apiToken)
        ])

        guard let response: GitLabQuery = try? await client.send(req).value else {
            return
        }

        await MainActor.run {
            mergeRequests = response.data?.currentUser?.authoredMergeRequests?.edges?.compactMap({ edge in
                return edge.node
            }) ?? []

            queryResponse = response
        }
    }

}
