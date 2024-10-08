//
//  CIStatusView.swift
//  
//
//  Created by Stef Kors on 24/06/2022.
//

import SwiftUI

public struct CIStatusView: View {
    public var status: PipelineStatus?

    public init(status: PipelineStatus?) {
        self.status = status
    }

    public var body: some View {
        if let CIStatus = status {
            switch CIStatus {
            case .created:
                CICreatedIcon()
            case .manual:
                CIManualIcon()
            case .running:
                CIProgressIcon()
            case .success:
                CISuccessIcon()
            case .failed:
                CIFailedIcon()
            case .warning:
                CIWarningIcon()
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

struct CIStatusView_Previews: PreviewProvider {
    static var previews: some View {
        VStack {
            HStack {
                CIStatusView(status: .created)
                CIStatusView(status: .manual)
                CIStatusView(status: .running)
                CIStatusView(status: .success)
                CIStatusView(status: .failed)
                CIStatusView(status: .warning)
            }
            HStack {
                CIStatusView(status: .canceled)
                CIStatusView(status: .skipped)
                CIStatusView(status: .waitingForResource)
                CIStatusView(status: .preparing)
                CIStatusView(status: .pending)
                CIStatusView(status: .scheduled)
            }
        }
    }
}
