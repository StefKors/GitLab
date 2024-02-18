//
//  NetworkManager+fetchAuthoredMergeRequests.swift
//  
//
//  Created by Stef Kors on 26/07/2022.
//

import Foundation
import Get
import SwiftUI

extension NetworkManager {
    func fetchAuthoredMergeRequests(with account: Account) async throws -> [MergeRequest]? {
        // do {
            print("fetch: start fetchAuthoredMergeRequests")
            let client = APIClient(baseURL: URL(string: "\(account.instance)/api"))
            // let beforeApprovedByDict = authoredMergeRequests.approvedByDict
            let response: GitLabQuery = try await client.send(authoredMergeRequestsReq(with: account)).value

            return response.authoredMergeRequests

            // await MainActor.run {
                // // MARK: - Handle Notifications
                // let newMergeRequests = response.authoredMergeRequests
                // let newApproveByDict = newMergeRequests.approvedByDict
                // 
                // if beforeApprovedByDict != newApproveByDict {
                //     for (reference, newAuthors) in newApproveByDict {
                //         let beforeAuthors = (beforeApprovedByDict[reference] ?? [])
                // 
                //         let diff = newAuthors.difference(from: beforeAuthors)
                //         // MARK: - Notification Approved MRs
                //         let approvers = diff.insertions.insertedElements.compactMap({ $0.name })
                //         if !approvers.isEmpty,
                //            let eventMR = newMergeRequests.first(where: { $0.reference == reference }),
                //            let url = eventMR.webURL,
                //            let title = eventMR.title,
                //            let headPipeline = eventMR.headPipeline,
                //            let jsonData = try? JSONEncoder().encode(headPipeline) {
                // 
                //             let userInfo = [
                //                 "OPEN_URL" : url.absoluteString,
                //                 "PIPELINE_STATUS": jsonData
                //             ] as [String : Any]
//                             NotificationManager.shared.sendNotification(
//                                 title: title,
//                                 subtitle: "\(reference) is approved by \(approvers.formatted())",
//                                 userInfo: userInfo
//                             )
                // 
                //         }
                // 
                //         // MARK: - Notification Revoked MRs
                //         let revokers = diff.removals.removedElements.compactMap({ $0.name })
                //         if !revokers.isEmpty,
                //            let eventMR = newMergeRequests.first(where: { $0.reference == reference }),
                //            let url = eventMR.webURL,
                //            let title = eventMR.title,
                //            let headPipeline = eventMR.headPipeline,
                //            let jsonData = try? JSONEncoder().encode(headPipeline) {
                // 
                //             let userInfo = [
                //                 "OPEN_URL" : url.absoluteString,
                //                 "PIPELINE_STATUS": jsonData
                //             ] as [String : Any]
                //             NotificationManager.shared.sendNotification(
                //                 title: title,
                //                 subtitle: "\(reference) approval revoked by \(revokers.formatted())",
                //                 userInfo: userInfo
                //             )
                // 
                //         }
                //     }
                // }
                // 
                // // MARK: - Update published values
                // // queryResponse = response
                // print("fetch: updated data fetchAuthoredMergeRequests")
                // authoredMergeRequests = newMergeRequests
                // lastUpdate = .now
                // noticeState.clearNetworkNotices()
                // 
                // for mr in response.authoredMergeRequests {
                //     if let project = mr.targetProject {
                //         addLaunchpadProject(project)
                //     }
                // }
            // }
        // } catch APIError.unacceptableStatusCode(let statusCode) {
        //     // Handle Bad GitLab Reponse
        //     let warningNotice = NoticeMessage(
        //         label: "Recieved \(statusCode) from API, data might be out of date",
        //         statusCode: statusCode,
        //         type: .warning
        //     )
        //     noticeState.addNotice(notice: warningNotice)
        // } catch {
        //     // Handle Offline Notice
        //     let isGitLabReachable = reachable(host: self.$baseURL.wrappedValue)
        //     if isGitLabReachable == false {
        //         let informationNotice = NoticeMessage(
        //             label: "Unable to reach \(self.$baseURL.wrappedValue)",
        //             type: .network
        //         )
        //         noticeState.addNotice(notice: informationNotice)
        //     }
        // 
        //     print("\(Date.now) Fetch fetchAuthoredMergeRequests failed with unexpected error: \(error).")
        // }
        // 
        //  return nil
    }
}
