//
//  MergeStatusView.swift
//
//
//  Created by Stef Kors on 24/06/2022.
//

import SwiftUI
import Foundation

struct MergeStatusView: View {
    var MR: MergeRequest
    
    private var isOnMergeTrain: Bool {
        MR.headPipeline?.mergeRequestEventType == .mergeTrain
    }
    
    private var approvers: [Author]? {
        MR.approvedBy?.edges?.compactMap({ $0.node })
    }
    
    @Environment(\.isInWidget) private var isInWidget
    
    var body: some View {
        if isOnMergeTrain {
            MergeTrainIcon()
        } else if let approvers = approvers, !approvers.isEmpty {
            ApprovedReviewIcon(approvedBy: approvers, account: MR.account)
        } else if !isInWidget, let title = MR.title, !(title.containsIgnoringCase("draft") || title.containsIgnoringCase("wip")) {
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
