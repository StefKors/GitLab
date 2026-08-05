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
    var isHoveringRow: Bool = false

    private var stages: [GitLab.FluffyNode] {
        pipeline.stages?.edges?.map({ $0.node }).compactMap({ $0 }) ?? []
    }

    private var allSucceeded: Bool {
        pipeline.status == .success && !isHovering
    }

    private var spacing: CGFloat {
        allSucceeded ? -14 : 0
    }

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
    Grid(alignment: .leading, horizontalSpacing: 0, verticalSpacing: 0) {
        PipelinePreviewRow(label: "Single stage, no jobs", pipeline: .preview)

        PipelinePreviewRow(label: "Test stage failed", pipeline: .previewTestFailed)

        PipelinePreviewRow(label: "Mixed stages", pipeline: .previewMultiple)

        PipelinePreviewRow(label: "Mixed stages (hovering)", pipeline: .previewMultiple, isHoveringRow: true)

        PipelinePreviewRow(label: "All succeeded (collapsed)", pipeline: .previewMultipleSuccess)

        PipelinePreviewRow(label: "All succeeded (hovering)", pipeline: .previewMultipleSuccess, isHoveringRow: true)

        PipelinePreviewRow(label: "Merge train (hovering)", pipeline: .previewMultipleSuccessMergeTrain, isHoveringRow: true)

        PipelinePreviewRow(label: "Running towards manual deploy", pipeline: .previewRunningToManual, isHoveringRow: true)

        PipelinePreviewRow(label: "Failed tests & warning", pipeline: .previewFailedWithWarning, isHoveringRow: true)
    }
    .scenePadding()
    .scenePadding()
}

private struct PipelinePreviewRow: View {
    let label: String
    let pipeline: GitLab.HeadPipeline
    var isHoveringRow: Bool = false

    @State private var isHovering: Bool = false

    var body: some View {
        GridRow {
            Text(label)
                .foregroundStyle(.secondary)
                .gridColumnAlignment(.trailing)

            PipelineView(pipeline: pipeline, instance: nil, isHoveringRow: isHoveringRow || isHovering)
        }
        .padding(6)
        .contentShape(Rectangle())
        .onHover { state in
            withAnimation(.snappy(duration: 0.18)) {
                isHovering = state
            }
        }
    }
}

