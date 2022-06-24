//
//  MergeRequestRowView.swift
//  
//
//  Created by Stef Kors on 24/06/2022.
//

import SwiftUI

struct MergeRequestRowView: View {
    var MR: MergeRequest
    var body: some View {
        VStack {
            // MARK: - Top Part
            HStack {
                VStack(alignment: .leading, spacing: 5) {
                    TitleWebLink(linkText: MR.title ?? "untitled", destination: MR.webURL)

                    WebLink(
                        linkText: "\(MR.targetProject?.path ?? "")\("/")\(MR.targetProject?.group?.fullPath ?? "")\(MR.reference ?? "")",
                        destination: MR.targetProject?.webURL
                    )
                }

                Spacer()
                VStack(alignment:.trailing) {
                    HStack {

                        if let count = MR.userDiscussionsCount, count > 1 {
                            DiscussionCountIcon(count: count)
                            Divider()
                                .padding(2)
                        }

                        let isApproved = MR.approved ?? false
                        let isOnMergeTrain = MR.headPipeline?.mergeRequestEventType == .mergeTrain
                        if isOnMergeTrain {
                            MergeTrainIcon()
                        } else if isApproved {
                            if let approvers = MR.approvedBy?.edges?.compactMap { $0.node } {
                                ApprovedReviewIcon(approvedBy: approvers)
                            }
                        } else {
                            // NeedsReviewIcon()
                        }

                        if let CIStatus = MR.headPipeline?.status {
                            switch CIStatus {
                            case .created:
                                CIProgressIcon()
                            case .manual:
                                CIManualIcon()
                            case .running:
                                CIProgressIcon()
                            case .success:
                                CISuccessIcon()
                            case .failed:
                                CIFailedIcon()
                            case .canceled:
                                CICanceledIcon()
                            case .skipped:
                                CISkippedIcon()
                            case .waitingForResource:
                                CIWaitingForResourceIcon()
                            case .preparing:
                                CIPreparingIcon()
                            case .pending:
                                CIPendingIcon()
                            case .scheduled:
                                CIScheduledIcon()
                            }
                        }
                    }
                }
            }
        }
    }
}
