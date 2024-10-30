//
//  NetworkManagerGitHub.swift
//  GitLab
//
//  Created by Stef Kors on 30/10/2024.
//

import OctoKit
import Foundation

class NetworkManagerGitHub {
    static let shared = NetworkManagerGitHub()
//
//    func authoredMergeRequestsReq(with account: Account) -> Request<GitLabQuery> {
//
//    }



    func fetchAuthoredMergeRequests(with account: Account) async throws -> [MergeRequest]? {
        let config = TokenConfiguration(account.token)
        
//        let client = APIClient(baseURL: URL(string: "\(account.instance)/api"))
//        let response: GitLabQuery = try await client.send(authoredMergeRequestsReq(with: account)).value
//        return response.authoredMergeRequests
    }

}
