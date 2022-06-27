//
//  MergeStatusView.swift
//  
//
//  Created by Stef Kors on 24/06/2022.
//

import SwiftUI

struct MergeStatusView: View {
    var MR: MergeRequest

    var isApproved: Bool {
        MR.approved ?? false
    }

    var isOnMergeTrain: Bool {
        MR.headPipeline?.mergeRequestEventType == .mergeTrain
    }

    var approvers: [Author]? {
        MR.approvedBy?.edges?.compactMap({ $0.node })
    }

    var body: some View {
        HStack {
            if isOnMergeTrain {
                MergeTrainIcon()
            } else if isApproved, let approvers = approvers, !approvers.isEmpty {
                ApprovedReviewIcon(approvedBy: approvers)
            } else {
                NeedsReviewIcon()
            }
        }
    }
}
