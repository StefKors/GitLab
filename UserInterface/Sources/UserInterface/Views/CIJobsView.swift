//
//  CIJobsView.swift
//  
//
//  Created by Stef Kors on 28/06/2022.
//

import SwiftUI

public struct CIJobsView: View {
    var stage: FluffyNode
    @State var isHovering: Bool = false

    public init(stage: FluffyNode) {
        self.stage = stage
    }

    public var body: some View {
        HStack {
            CIStatusView(status: stage.status?.toPipelineStatus())
                .popover(isPresented: $isHovering, content: {
                    if let jobs = stage.jobs?.edges?.map({ $0.node }) {
                        VStack(alignment: .leading, spacing: 4) {
                            Text(stage.name?.capitalized ?? "")
                                .fontWeight(.bold)
                                .padding(.bottom, 4)
                            ForEach(jobs.indices, id: \.self) { index in
                                if let job = jobs[index] {
                                    HStack {
                                        CIStatusView(status: job.status)
                                        Text(job.name ?? "")
                                    }
                                }
                            }
                        }.padding()
                    }
                })
        }
        .animation(.spring(response: 0.35, dampingFraction: 1, blendDuration: 0), value: isHovering)
        .onHover { hovering in
            isHovering = hovering
        }
    }
}
