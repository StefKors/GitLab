//
//  MergeStatusView.swift
//  
//
//  Created by Stef Kors on 24/06/2022.
//

import SwiftUI

struct MergeStatusView: View {
    var MR: MergeRequest
    var body: some View {
        let isApproved = MR.approved ?? false
        let isOnMergeTrain = MR.headPipeline?.mergeRequestEventType == .mergeTrain
        if isOnMergeTrain {
            MergeTrainIcon()
        } else if isApproved {
            if let approvers = MR.approvedBy?.edges?.compactMap({ $0.node }) {
                ApprovedReviewIcon(approvedBy: approvers)
            }
        } else {
            // NeedsReviewIcon()
        }
    }
}
