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
    func fetchReviewRequestedMergeRequests() async -> [MergeRequest]? {
        do {
            print("fetch: start fetchReviewRequestedMergeRequests")
            let response: GitLabQuery = try await client.send(reviewRequestedMergeRequestsReq).value
            return response.reviewRequestedMergeRequests.map { mr in
                mr.type = .reviewRequestedMergeRequests
                return mr
            }

            // await MainActor.run {
            //     // MARK: - Update published values
            //     if beforeMergeRequests.isEmpty || (beforeMergeRequests != response.reviewRequestedMergeRequests) {
            //         // queryResponse = response
            //         reviewRequestedMergeRequests = response.reviewRequestedMergeRequests
            //         lastUpdate = .now
            //         print("fetch: updated data fetchReviewRequestedMergeRequests")
            //         noticeState.clearNetworkNotices()
            //     }
            // }
        } catch APIError.unacceptableStatusCode(let statusCode) {
            // Handle Bad GitLab Reponse
            let warningNotice = NoticeMessage(
                label: "Recieved \(statusCode) from API, data might be out of date",
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
            }

            print("\(Date.now) Fetch fetchReviewRequestedMergeRequests failed with unexpected error: \(error).")
        }
        return nil
    }
}
