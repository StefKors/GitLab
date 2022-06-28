//
//  PipelineView.swift
//  
//
//  Created by Stef Kors on 24/06/2022.
//

import SwiftUI

public struct PipelineView: View {
    public var stages: [FluffyNode?]

    public init (stages: [FluffyNode?]) {
        self.stages = stages
    }

    public var body: some View {
        HStack(alignment: .center, spacing: 0) {
            ForEach(stages.indices, id: \.self) { index in
                if let stage = stages[index] {
                    CIJobsView(stage: stage)
                    let isLast = index == stages.count - 1
                    if !isLast {
                        Rectangle()
                            .fill(.quaternary)
                            .frame(width: 6, height: 2, alignment: .center)
                    }
                }
            }
        }
    }
}
