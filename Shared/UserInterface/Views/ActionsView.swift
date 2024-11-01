//
//  ActionsView.swift
//  GitLab
//
//  Created by Stef Kors on 01/11/2024.
//

import SwiftUI

struct ActionsView: View {
    let status: GitHub.StatusCheckRollup
    var instance: String?

    private var stages: [GitHub.ContextsNode] {
        status.contexts?.nodes?.compactMap({ $0 }) ?? []
    }

    private var allSucceeded: Bool {
        status.state == .success && !isHovering
    }

    private var spacing: CGFloat {
        allSucceeded ? -14 : 0
    }

    @State private var isHovering: Bool = false

    var body: some View {
        HStack(alignment: .center, spacing: spacing) {

            ForEach(Array(stages.enumerated()), id: \.element, content: { index, stage in
                HStack(spacing: 0) {
                    CIPendingIcon()
//                    CIJobsView(stage: stage, instance: instance)
                        .id(stage.id)
                    // Create a staggered effect by masking children to appear correctly
                        .mask {
                            Circle()
                                .subtracting(
                                    Circle()
                                        .offset(x: index != 0 && allSucceeded ? -4 : -26)
                                )
                        }
                        .zIndex(2)

                    let isLast = index == stages.count - 1
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
            })
        }
        .onHover { state in
            withAnimation(.easeInOut) {
                isHovering = state
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
