//
//  CIJobsView.swift
//  
//
//  Created by Stef Kors on 28/06/2022.
//

import SwiftUI

struct CIJobsView: View {
    // TODO: account / instance from env
    let stage: FluffyNode
    var instance: String

    init(stage: FluffyNode, instance: String? = nil) {
        self.stage = stage
        self.instance = instance ?? "https://www.gitlab.com"
    }

    @State var presentPopover: Bool = false
    @State var tapState: Bool = false

    private var hasFailedChildJob: Bool {
        stage.jobs?.edges?.contains(where: { $0.node?.status == .failed }) ?? false
    }

    private var status: PipelineStatus? {
        if let stageStatus = stage.status?.toPipelineStatus() {
            if stageStatus == .success, hasFailedChildJob {
                return .warning
            }
        }

        return stage.status?.toPipelineStatus()
    }

    var body: some View {
        HStack {
            CIStatusView(status: status)
                .contentShape(Rectangle())
                .onTapGesture {
                    tapState.toggle()
                    presentPopover.toggle()
                }
                .popover(isPresented: $presentPopover, content: {
                    if let jobs = stage.jobs?.edges?.map({ $0.node }) {
                        VStack(alignment: .leading, spacing: 4) {
                            Text(stage.name?.capitalized ?? "")
                                .fontWeight(.bold)
                                .padding(.bottom, 4)
                            ForEach(jobs.indices, id: \.self) { index in
                                if let job = jobs[index] {
                                    HStack {
                                        if let path = job.detailedStatus?.detailsPath,
                                           let destination = URL(string: instance + path) {
                                            Link(destination: destination, label: {
                                                CIStatusView(status: job.status)
                                                Text(job.name ?? "")
                                            })
                                        }
                                    }
                                }
                            }
                        }.padding()
                    }
                })
        }
    }
}
