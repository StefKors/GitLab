//
//  PipelineView.swift
//
//
//  Created by Stef Kors on 24/06/2022.
//

import SwiftUI

private struct Values {
    var spacing = Angle.zero
    var offset: CGFloat = 1.0
}

struct PipelineView: View {
    var pipeline: GitLab.HeadPipeline
    var instance: String?

    private var stages: [GitLab.FluffyNode] {
        pipeline.stages?.edges?.map({ $0.node }).compactMap({ $0 }) ?? []
    }

    private var allSucceeded: Bool {
        pipeline.status == .success && !isHovering
    }

    private var spacing: CGFloat {
        allSucceeded ? -14 : 0
    }

    @Environment(\.isHoveringRow) private var isHoveringRow

    private var isHovering: Bool {
        stages.count > 1 && isHoveringRow
    }

    var body: some View {
        if !Array(stages.enumerated()).isEmpty {
            HStack(alignment: .center, spacing: spacing) {

                ForEach(Array(stages.enumerated()), id: \.element, content: { index, stage in
                    HStack(spacing: 0) {
                        GitLabCIJobsView(stage: stage, instance: instance)
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
        }
    }
}

#Preview {
    VStack(alignment: .trailing) {
        PipelineView(pipeline: .previewTestFailed, instance: nil)
            .scenePadding()
            .modifier(IsHoveringRowPreviewEnv())

        PipelineView(pipeline: .previewMultiple, instance: nil)
            .scenePadding()
            .modifier(IsHoveringRowPreviewEnv())

        PipelineView(pipeline: .previewMultipleSuccess, instance: nil)
            .scenePadding()
            .modifier(IsHoveringRowPreviewEnv())

        PipelineView(pipeline: .previewMultipleSuccessMergeTrain, instance: nil)
            .scenePadding()
            .modifier(IsHoveringRowPreviewEnv())
    }
    .scenePadding()
    .scenePadding()
    .scenePadding()
}

fileprivate struct IsHoveringRowPreviewEnv: ViewModifier {
    @State private var isHoveringRow: Bool = false

    func body(content: Content) -> some View {
        content
            .environment(\.isHoveringRow, isHoveringRow)
            .onHover { state in
                withAnimation(.snappy(duration: 0.18)) {
                    isHoveringRow = state
                }
            }
    }
}
