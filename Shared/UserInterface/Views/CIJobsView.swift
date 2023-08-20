//
//  CIJobsView.swift
//  
//
//  Created by Stef Kors on 28/06/2022.
//

import SwiftUI

struct CIJobsView: View {
    // TODO: account / instance from env
    let instance: String = "https://www.gitlab.com"
    let stage: FluffyNode
    @State var presentPopover: Bool = false
    @State var isHovering: Bool = false
    @State var tapState: Bool = false
    
    var body: some View {
        HStack {
            CIStatusView(status: stage.status?.toPipelineStatus())
                .onTapGesture {
                    tapState.toggle()
                    presentPopover.toggle()
                }
                .popover(isPresented: $presentPopover, content: {
                    if let jobs = stage.jobs?.edges?.map({ $0.node }) {
                        VStack(alignment: .leading, spacing: 4) {
                            Text(stage.name?.capitalized ?? "")
                                .fontWeight(.bold)
                                .padding(.bottom, 4)
                            ForEach(jobs.indices, id: \.self) { index in
                                if let job = jobs[index] {
                                    HStack {
                                        if let path = job.detailedStatus?.detailsPath,
                                           let destination = URL(string: instance + path) {
                                            Link(destination: destination, label: {
                                                CIStatusView(status: job.status)
                                                Text(job.name ?? "")
                                            })
                                        }
                                    }
                                }
                            }
                        }.padding()
                    }
                })
        }
        .animation(.spring(response: 0.35, dampingFraction: 1, blendDuration: 0), value: isHovering)
        // .onHover { hovering in
        //     isHovering = hovering
        // }
    }
}
