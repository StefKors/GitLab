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

#Preview {
    Grid(alignment: .leading, horizontalSpacing: 12, verticalSpacing: 12) {
        CIJobsPreviewRow(label: "All jobs pass", stage: .previewSuccess)

        CIJobsPreviewRow(label: "First job running, others pending", stage: .previewFirstJobRunning)

        CIJobsPreviewRow(label: "UI & unit tests running", stage: .previewTestsRunning)

        CIJobsPreviewRow(label: "Some jobs failed", stage: .previewSomeJobsFailed)

        CIJobsPreviewRow(label: "Warning (stage passed, child failed)", stage: .previewWarning)

        CIJobsPreviewRow(label: "Manual (can be triggered)", stage: .previewManual)
    }
    .scenePadding()
    .scenePadding()
}

private struct CIJobsPreviewRow: View {
    let label: String
    let stage: GitLab.FluffyNode

    private var jobs: [GitLab.HeadPipeline] {
        stage.jobs?.edges?.compactMap({ $0.node }) ?? []
    }

    var body: some View {
        GridRow {
            Text(label)
                .foregroundStyle(.secondary)
                .gridColumnAlignment(.trailing)

            GitLabCIJobsView(stage: stage)

            HStack(spacing: 4) {
                ForEach(jobs.indices, id: \.self) { index in
                    CIStatusView(status: jobs[index].status)
                }
            }
        }
    }
}
