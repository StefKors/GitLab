//
//  File.swift
//
//
//  Created by Stef Kors on 26/07/2022.
//

import Foundation
import Get
import SwiftUI

extension NetworkManager {
    func fetchReviewRequestedMergeRequests(with account: Account) async throws -> [MergeRequest]? {
        let client = APIClient(baseURL: URL(string: "\(account.instance)/api"))
        let response: GitLabQuery = try await client.send(reviewRequestedMergeRequestsReq(with: account)).value
        return response.reviewRequestedMergeRequests
    }
}
