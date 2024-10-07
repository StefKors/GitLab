//
//  CIJobsView.swift
//  
//
//  Created by Stef Kors on 28/06/2022.
//

import SwiftUI

public struct CIJobsView: View {
    var stage: FluffyNode
    @State var presentPopover: Bool = false
    @State var isHovering: Bool = false
    @State var tapState: Bool = false

    @EnvironmentObject  var model: NetworkManager

    public init(stage: FluffyNode) {
        self.stage = stage
    }

    public var body: some View {
        HStack {
            Button(action: {
                tapState.toggle()
                presentPopover.toggle()
            }, label: {
                CIStatusView(status: stage.status?.toPipelineStatus())
            })
            .buttonStyle(.borderless)
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
                                       let destination = URL(string: model.$baseURL.wrappedValue + path) {
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
