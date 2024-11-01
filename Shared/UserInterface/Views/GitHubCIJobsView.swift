//
//  GitHubCIJobsView.swift
//
//
//  Created by Stef Kors on 28/06/2022.
//

import SwiftUI

struct GitHubCIJobsView: View {
    // TODO: account / instance from env
    let stage: GitHub.ContextsNode
    var instance: String

    init(stage: GitHub.ContextsNode, instance: String? = nil) {
        self.stage = stage
        self.instance = instance ?? "https://api.github.com"
    }

    @State var presentPopover: Bool = false
    @State var tapState: Bool = false

    private var hasFailedChildJob: Bool {
        stage.steps?.nodes?.contains(where: { step in
            step.conclusion == .failure
        }) ?? false
    }

    private var status: PipelineStatus? {
        let stageStatus = PipelineStatus.from(stage.status)
        if stageStatus == .success, hasFailedChildJob {
            return .warning
        }

        return stageStatus
    }

    private var steps: [GitHub.StepsNode] {
        stage.steps?.nodes?.compactMap({ $0 }) ?? []
    }

    var body: some View {
        HStack {
            CIStatusView(status: status)
                .contentShape(Rectangle())
                .onTapGesture {
                    if !steps.isEmpty {
                        tapState.toggle()
                        presentPopover.toggle()
                    }
                }
                .popover(isPresented: $presentPopover, content: {
                    VStack(alignment: .leading, spacing: 4) {
                        Text(stage.name?.capitalized ?? "")
                            .fontWeight(.bold)
                            .padding(.bottom, 4)
                        ForEach(steps, id: \.externalID) { step in
                            if let path = stage.detailsURL,
                               let destination = URL(string: path) {
                                HStack {
                                    Link(destination: destination, label: {
                                        CIStatusView(status: PipelineStatus.from(step.status))
                                        Text(step.name ?? "")
                                    })
                                }
                            }
                        }
                    }.padding()
                })
        }
    }
}
