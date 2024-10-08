//
//  PipelineView.swift
//  
//
//  Created by Stef Kors on 24/06/2022.
//

import SwiftUI

 struct PipelineView: View {
     var stages: [FluffyNode?]
     var instance: String?

     var body: some View {
        HStack(alignment: .center, spacing: 0) {
            ForEach(stages.indices, id: \.self) { index in
                if let stage = stages[index] {
                    CIJobsView(stage: stage, instance: instance)
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
