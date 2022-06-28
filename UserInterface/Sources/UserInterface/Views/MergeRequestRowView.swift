//
//  MergeRequestRowView.swift
//  
//
//  Created by Stef Kors on 24/06/2022.
//

import SwiftUI

struct CIJobsView: View {
    var stage: FluffyNode
    @State var isHovering: Bool = false

    var body: some View {
        HStack {
            CIStatusView(status: stage.status?.toPipelineStatus())
                .popover(isPresented: $isHovering, content: {
                    if let jobs = stage.jobs?.edges?.map({ $0.node }) {
                        VStack(alignment: .leading, spacing: 4) {
                            Text(stage.name?.capitalized ?? "")
                                .fontWeight(.bold)
                                .padding(.bottom, 4)
                            ForEach(jobs.indices, id: \.self) { index in
                                if let job = jobs[index] {
                                    HStack {
                                        CIStatusView(status: job.status)
                                        Text(job.name ?? "")
                                    }
                                }
                            }
                        }.padding()
                    }
                })
        }
        .animation(.spring(response: 0.35, dampingFraction: 1, blendDuration: 0), value: isHovering)
        .onHover { hovering in
            isHovering = hovering
        }
    }
}

struct PipelineView: View {
    var stages: [FluffyNode?]

    var body: some View {
        HStack(alignment: .center, spacing: 0) {
            ForEach(stages.indices, id: \.self) { index in
                if let stage = stages[index] {
                    CIJobsView(stage: stage)
                    let isLast = index == stages.count - 1
                    if !isLast {
                        Rectangle()
                            .fill(.quaternary)
                            .frame(width: 6, height: 2, alignment: .center)
                    }
                }
            }
        }
    }
}

struct MergeRequestRowView: View {
    var MR: MergeRequest
    var macOSUI: some View {
        HStack(alignment: .center) {
            MergeRequestLabelView(MR: MR)
            Spacer()
            PipelineView(stages: MR.headPipeline?.stages?.edges?.map({ $0.node }) ?? [])
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
