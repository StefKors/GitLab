//
//  GitHubCIJobsView.swift
//
//
//  Created by Stef Kors on 28/06/2022.
//

import SwiftUI

// We reorder the data model to group Contexts (aka jobs) by workflow (aka pipeline)

struct GitHubCIJobsView: View {
    var workflow: GitHub.Workflow
    // TODO: account / instance from env
    var stages: [GitHub.ContextsNode]
    var instance: String?
//
//    init(stages: [GitHub.ContextsNode], instance: String? = nil) {
//        self.stages = stages
//        self.instance = instance ?? "https://api.github.com"
//    }

    @State var presentPopover: Bool = false
    @State var tapState: Bool = false

    private var hasFailedChildJob: Bool {
        stages.contains(where: { step in
            step.conclusion == .failure
        })
    }

    private var status: PipelineStatus? {
        let hasAnyInProgress = stages.contains { stage in
            stage.status == .inProgress
        }

        if hasAnyInProgress {
            return .running
        }

        let hasAnyFailed = stages.contains { stage in
            stage.conclusion == .failure
        }

        if hasAnyFailed {
            return .failed
        }

        let hasAnyCancelled = stages.contains { stage in
            stage.conclusion == .cancelled
        }

        if hasAnyCancelled {
            return .canceled
        }

        let hasAllSucceeded = stages.allSatisfy { stage in
            stage.conclusion == .success
        }

        if hasAllSucceeded {
            return .success
        }

        // Not sure if this is correct...
        return .warning
    }

    var body: some View {
        HStack {
            CIStatusView(status: status)
                .contentShape(Rectangle())
                .onTapGesture {
                    if !stages.isEmpty {
                        tapState.toggle()
                        presentPopover.toggle()
                    }
                }
                .popover(isPresented: $presentPopover, content: {
                    VStack(alignment: .leading, spacing: 4) {
                        Text(workflow.name?.capitalized ?? "")
                            .fontWeight(.bold)
                            .padding(.bottom, 4)
                        ForEach(stages, id: \.id) { stage in
                            if let path = stage.detailsURL,
                               let destination = URL(string: path) {
                                HStack {
                                    Link(destination: destination, label: {
                                        CIStatusView(status: PipelineStatus.from(stage.status))
                                        Text(stage.name ?? "")
                                    })
                                }
                            }
                        }
                    }.padding()
                })
        }
    }
}
