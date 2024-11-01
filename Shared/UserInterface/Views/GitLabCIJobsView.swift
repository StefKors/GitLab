//
//  CIJobsView.swift
//
//
//  Created by Stef Kors on 28/06/2022.
//

import SwiftUI

struct GitLabCIJobsView: View {
    // TODO: account / instance from env
    let stage: GitLab.FluffyNode
    var instance: String

    init(stage: GitLab.FluffyNode, instance: String? = nil) {
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

    private var jobs: [GitLab.HeadPipeline] {
        stage.jobs?.edges?.map({ $0.node }).compactMap({ $0 }) ?? []
    }

    var body: some View {
        HStack {
            CIStatusView(status: status)
                .contentShape(Rectangle())
                .onTapGesture {
                    if !jobs.isEmpty {
                        tapState.toggle()
                        presentPopover.toggle()
                    }
                }
                .popover(isPresented: $presentPopover, content: {
                    VStack(alignment: .leading, spacing: 4) {
                        Text(stage.name?.capitalized ?? "")
                            .fontWeight(.bold)
                            .padding(.bottom, 4)
                        ForEach(jobs, id: \.id) { job in
                            if let path = job.detailedStatus?.detailsPath,
                               let destination = URL(string: instance + path) {
                                HStack {
                                    Link(destination: destination, label: {
                                        CIStatusView(status: job.status)
                                        Text(job.name ?? "")
                                    })
                                }
                            }
                        }
                    }.padding()
                })
        }
    }
}
