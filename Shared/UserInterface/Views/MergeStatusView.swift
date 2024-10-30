//
//  MergeStatusView.swift
//
//
//  Created by Stef Kors on 24/06/2022.
//

import SwiftUI
import Foundation

struct MergeStatusView: View {
    var MR: UniversalMergeRequest

    private var isOnMergeTrain: Bool {
        MR.mergeRequest?.headPipeline?.mergeRequestEventType == .mergeTrain
    }
    
    private var approvers: [Approval]? {
        MR.approvals
    }
    
    @Environment(\.isInWidget) private var isInWidget
    
    var body: some View {
        if isOnMergeTrain {
            MergeTrainIcon()
        } else if let approvers = approvers, !approvers.isEmpty {
            ApprovedReviewIcon(approvedBy: approvers, account: MR.account)
        } else if !isInWidget, !MR.isDraft {
            ShareMergeRequestIcon(MR: MR)
        } else {
            // NeedsReviewIcon()
        }
    }
}


extension String {
    func contains(_ find: String) -> Bool{
        return self.range(of: find) != nil
    }
    
    func containsIgnoringCase(_ find: String) -> Bool{
        return self.range(of: find, options: .caseInsensitive) != nil
    }
}
