//
//  CIJobsNotificationView.swift
//  
//
//  Created by Stef Kors on 29/06/2022.
//

import SwiftUI

public struct CIJobsNotificationView: View {
    public var stages: [FluffyNode?]

    public init (stages: [FluffyNode?]?) {
        self.stages = stages ?? []
    }

    public var body: some View {
        HStack(alignment: .top, spacing: 0) {
            ForEach(stages.indices, id: \.self) { index in
                if let stage = stages[index],
                   let jobs = stage.jobs?.edges?.map({ $0.node }) {
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
            }
        }

    }
}
