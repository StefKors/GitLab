//
//  MergeStatusView.swift
//
//
//  Created by Stef Kors on 24/06/2022.
//

import SwiftUI
import Foundation

struct MergeStatusView: View {
    var request: UniversalMergeRequest

    private var isOnMergeTrain: Bool {
        request.mergeRequest?.headPipeline?.mergeRequestEventType == .mergeTrain
    }

    private var approvers: [Approval]? {
        request.approvals
    }

    @Environment(\.isInWidget) private var isInWidget
    @EnvironmentObject private var settings: SettingsState

    var body: some View {
        if isOnMergeTrain {
            MergeTrainIcon()
        } else if let approvers = approvers, !approvers.isEmpty {
            ApprovedReviewIcon(approvedBy: approvers, account: request.account)
        } else if !isInWidget, !request.isDraft, settings.showShareButton {
            ShareMergeRequestIcon(request: request)
        } else {
            // NeedsReviewIcon()
        }
    }
}

extension String {
    func contains(_ find: String) -> Bool {
        return self.range(of: find) != nil
    }

    func containsIgnoringCase(_ find: String) -> Bool {
        return self.range(of: find, options: .caseInsensitive) != nil
    }
}
