//
//  ActionsView.swift
//  GitLab
//
//  Created by Stef Kors on 01/11/2024.
//

import OrderedCollections
import SwiftUI

struct ActionsView: View {
    let status: GitHub.StatusCheckRollup
    var instance: String?

    private var allStages: [GitHub.ContextsNode] {
        status.contexts?.nodes?.compactMap({ $0 }) ?? []
    }

    private var allSucceeded: Bool {
        status.state == .success && !isHovering
    }

    private var spacing: CGFloat {
        allSucceeded ? -14 : 0
    }

    @State private var isHovering: Bool = false

    private var groupedByWorkflow: OrderedDictionary<GitHub.Workflow, [GitHub.ContextsNode]> {
        var dict: OrderedDictionary<GitHub.Workflow, [GitHub.ContextsNode]> = [:]

        for stage in allStages {
            if let workflow = stage.checkSuite?.workflowRun?.workflow {
                dict[workflow, default: []].append(stage)
            }
        }

        return dict
    }

    var body: some View {
        if !Array(groupedByWorkflow.keys.enumerated()).isEmpty {
            HStack(alignment: .center, spacing: spacing) {
                
                ForEach(Array(groupedByWorkflow.keys.enumerated()), id: \.element) { index, workflow in
                    let stages = groupedByWorkflow[workflow] ?? []
                    HStack(spacing: 0) {
                        GitHubCIJobsView(workflow: workflow, stages: stages, instance: instance)
                            .id(workflow.id)
                        // Create a staggered effect by masking children to appear correctly
                            .mask {
                                Circle()
                                    .subtracting(
                                        Circle()
                                            .offset(x: index != 0 && allSucceeded ? -4 : -26)
                                    )
                            }
                            .zIndex(2)
                        
                        let isLast = index == Array(groupedByWorkflow.keys.enumerated()).count - 1
                        if !isLast {
                            Rectangle()
                                .fill(.quaternary)
                                .frame(width: allSucceeded ? 0 : 6, height: 2, alignment: .center)
                                .opacity(allSucceeded ? 0 : 1)
                                .animation(.snappy.delay(isHovering ? 0.05 : 0), value: isHovering)
                                .zIndex(1)
                        }
                        
                    }
                    .zIndex(Double(stages.count - index))
                }
            }
            .onHover { state in
                withAnimation(.easeInOut) {
                    if Array(groupedByWorkflow.keys).count > 1 {
                        isHovering = state
                    }
                }
            }
        }
    }
}

#Preview {
    VStack(alignment: .leading) {
        // Single
        // Double
        ActionsView(status: .preview, instance: nil)

    }.scenePadding()
}
