//
//  PipelineView.swift
//
//
//  Created by Stef Kors on 24/06/2022.
//

import SwiftUI

struct PipelineView: View {
    var pipeline: HeadPipeline
    var instance: String?
    
    private var stages: [FluffyNode] {
        pipeline.stages?.edges?.map({ $0.node }).compactMap({ $0 }) ?? []
    }
    
    private var allSucceeded: Bool {
        pipeline.status == .success && !isHovering
    }
    
    private var spacing: CGFloat {
        allSucceeded ? -14 : 0
    }
    
    @State private var isHovering: Bool = false
    
    var body: some View {
        HStack(alignment: .center, spacing: spacing) {
            
            ForEach(Array(stages.enumerated()), id: \.element, content: { index, stage in
                HStack(spacing: 0) {
                    CIJobsView(stage: stage, instance: instance)
                        .id(stage.id)
                    // Create a staggered effect by masking children to appear correctly
                        .mask {
                            Circle()
                                .subtracting(
                                    Circle()
                                        .offset(x: index != 0 && allSucceeded ? -4 : -26)
                                )
                        }
                    
                    let isLast = index == stages.count - 1
                    if !isLast {
                        Rectangle()
                            .fill(.quaternary)
                            .frame(width: allSucceeded ? 0 : 6, height: 2, alignment: .center)
                    }
                    
                }
                .zIndex(Double(stages.count - index))
            })
        }
        .onHover { state in
            withAnimation {
                isHovering = state
            }
        }
    }
}


#Preview {
    VStack(alignment: .trailing) {
        PipelineView(pipeline: .previewTestFailed, instance: nil)
            .scenePadding()
        PipelineView(pipeline: .previewMultiple, instance: nil)
            .scenePadding()
        PipelineView(pipeline: .previewMultipleSuccess, instance: nil)
            .scenePadding()
        PipelineView(pipeline: .previewMultipleSuccessMergeTrain, instance: nil)
            .scenePadding()
    }.scenePadding()
}
