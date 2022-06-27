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
                    MergeStatusView(MR: MR).id(MR.id)
                    CIStatusView(status: MR.headPipeline?.status)
                }
            }
        }
    }
    
    var iOSUI: some View {
        HStack {
            VStack(alignment: .leading) {
                MergeStatusView(MR: MR).id(MR.id)
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
    
    var body: some View {
#if os(macOS)
        macOSUI
#else
        iOSUI
#endif
    }
}
