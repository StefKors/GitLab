//
//  CIJobsView.swift
//
//
//  Created by Stef Kors on 28/06/2022.
//

import SwiftUI

public struct CIJobsView: View {
    var stage: FluffyNode
    @State var presentPopover: Bool = false

    @EnvironmentObject var model: NetworkManager

    public init(stage: FluffyNode) {
        self.stage = stage
    }

    public var hasFailedChildJob: Bool {
        stage.jobs?.edges?.contains(where: { $0.node?.status == .failed }) ?? false
    }

    public var status: PipelineStatus? {
        if let stageStatus = stage.status?.toPipelineStatus() {
            if stageStatus == .success, hasFailedChildJob {
                return .warning
            }
        }

        return stage.status?.toPipelineStatus()
    }

    public var body: some View {
        HStack {
            CIStatusView(status: status)
                .contentShape(Rectangle())
                .onTapGesture {
                    print(stage, hasFailedChildJob)
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
                                           let destination = URL(string: model.$baseURL.wrappedValue + path) {
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
