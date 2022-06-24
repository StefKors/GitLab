//
//  MergeRequestRowView.swift
//  
//
//  Created by Stef Kors on 24/06/2022.
//

import SwiftUI

struct MergeRequestRowView: View {
    var MR: MergeRequest

    var macOSUI: some View {
        VStack {
            // MARK: - Top Part
            HStack {
                MergeRequestLabelView(MR: MR)
                Spacer()
                VStack(alignment:.trailing) {
                    HStack {

                        if let count = MR.userDiscussionsCount, count > 1 {
                            DiscussionCountIcon(count: count)
                            Divider()
                                .padding(2)
                        }
                        MergeStatusView(MR: MR)
                        CIStatusView(status: MR.headPipeline?.status)
                    }
                }
            }
        }
    }

    var iOSUI: some View {
        VStack {
            // MARK: - Top Part
            HStack {
                VStack(alignment: .leading) {
                    MergeStatusView(MR: MR)
                    MergeRequestLabelView(MR: MR)
                }
                Spacer()
                VStack(alignment:.trailing) {
                    HStack {
                        if let count = MR.userDiscussionsCount, count > 1 {
                            DiscussionCountIcon(count: count)
                        }
                        CIStatusView(status: MR.headPipeline?.status)
                    }
                }
            }
        }
    }

    var body: some View {
#if os(macOS)
        macOSUI
#else
        iOSUI
#endif
    }
}
